locals {
  resource_name_suffix = "${var.name}-${random_id.suffix.hex}"
  resource_name_pool_suffix = (
    var.use_legacy_pool_provider_id_format
    ? local.resource_name_suffix
    : "${random_id.suffix.hex}-${var.name}"
  )

  project_resource_suffix              = "project"
  group_resource_suffix                = "group"
  custom_id_group_valid_attribute_name = "custom_is_group_valid"

  has_group_filters   = length(var.gitlab_group_ids) > 0 || length(var.gitlab_group_static_full_paths) > 0
  has_user_filters    = length(var.gitlab_user_logins) > 0 || length(var.gitlab_user_ids) > 0
  has_projects_filter = length(var.gitlab_project_ids) > 0
  has_any_source      = local.has_group_filters || local.has_projects_filter
  user_filter_is_or   = lower(var.gitlab_user_filter_logic) == "or"

  # Union of numeric user IDs: those resolved from logins and those supplied directly.
  resolved_gitlab_user_ids = distinct(concat(
    [for login in distinct(var.gitlab_user_logins) : tostring(data.gitlab_user.this[login].id)],
    [for id in var.gitlab_user_ids : tostring(id)],
  ))

  projects_attribute_condition = "(${join(" || ", [for id in var.gitlab_project_ids : "attribute.project_id==\"${id}\""])})"
  groups_attribute_condition   = "(attribute.${local.custom_id_group_valid_attribute_name}==\"1\")"
  users_attribute_condition    = "(${join(" || ", [for id in local.resolved_gitlab_user_ids : "attribute.user_id==\"${id}\""])})"

  # Source condition: projects OR groups. Defines WHERE pipelines can come from.
  source_attribute_condition = join(" || ", compact([
    local.has_projects_filter ? local.projects_attribute_condition : "",
    local.has_group_filters ? local.groups_attribute_condition : "",
  ]))

  # Base attribute_condition (source/user filters), before any ref gate.
  # - No user filter: just the source condition.
  # - User filter + no source: just the user condition (only users allowed).
  # - User filter + source + logic=and: source AND user (restrict who from those sources).
  # - User filter + source + logic=or:  source OR  user (trusted-user bypass).
  base_attribute_condition = local.has_user_filters ? (
    local.has_any_source ? (
      local.user_filter_is_or
      ? "(${local.source_attribute_condition}) || ${local.users_attribute_condition}"
      : "(${local.source_attribute_condition}) && ${local.users_attribute_condition}"
    ) : local.users_attribute_condition
  ) : local.source_attribute_condition

  # Optional ref gate: restrict WHICH pipeline ref (and ref type) may authenticate,
  # AND'd onto the base condition so it binds federation to the intended execution
  # context regardless of who/where the token comes from. attribute.ref and
  # attribute.ref_type are mapped from assertion.ref / assertion.ref_type.
  has_ref_filters          = length(var.gitlab_refs) > 0
  refs_attribute_condition = "(${join(" || ", [for ref in var.gitlab_refs : "attribute.ref==\"${ref}\""])})"
  ref_attribute_terms = compact([
    local.has_ref_filters ? local.refs_attribute_condition : "",
    var.gitlab_ref_type != null ? "attribute.ref_type==\"${var.gitlab_ref_type}\"" : "",
  ])
  ref_attribute_condition = join(" && ", local.ref_attribute_terms)

  # Final attribute_condition: base AND the ref gate when a ref filter is set. With
  # no base (instance-wide), the ref gate stands alone.
  attribute_condition = (
    length(local.ref_attribute_terms) > 0
    ? (local.base_attribute_condition != "" ? "(${local.base_attribute_condition}) && ${local.ref_attribute_condition}" : local.ref_attribute_condition)
    : local.base_attribute_condition
  )

  final_gitlab_group_full_paths = concat(
    [for item in data.gitlab_group.this : item.full_path],
    var.gitlab_group_static_full_paths
  )

  # Normalize: strip trailing slash if present, so we can build consistent CEL conditions.
  normalized_gitlab_group_full_paths = [
    for path in local.final_gitlab_group_full_paths :
    trimsuffix(path, "/")
  ]

  # Each group needs: exact match (direct projects) OR startsWith with trailing slash (subgroups).
  gitlab_group_cel_conditions = [
    for path in local.normalized_gitlab_group_full_paths :
    "(assertion.namespace_path.startsWith(\"${path}/\") || assertion.namespace_path == \"${path}\")"
  ]

  principal_subjects = merge(
    local.has_projects_filter ? { for id in var.gitlab_project_ids : "${local.project_resource_suffix}-${id}" => "attribute.project_id/${id}" } : {},
    length(local.final_gitlab_group_full_paths) > 0 ? { (local.group_resource_suffix) = "attribute.${local.custom_id_group_valid_attribute_name}/1" } : {},
    # Per-user principalSets are always emitted when a user filter is set, so the
    # IAM binding member string self-documents the user gate (in `and` mode it
    # complements the source principalSets; in `or` mode it stands alone).
    local.has_user_filters ? { for id in local.resolved_gitlab_user_ids : "user-${id}" => "attribute.user_id/${id}" } : {},
  )
  principals = merge(
    # Build the principalSet for each project, group, and user.
    {
      for key, subject in local.principal_subjects : key => "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.this.name}/${subject}"
    },
    # If no specific projects, groups, static paths, or users are defined, allow the entire GitLab instance.
    !local.has_any_source && !local.has_user_filters ? {
      "instance-wide" = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.this.name}/*"
    } : {},
  )

  # Ensure the account_id is always 28 characters or less
  sa_name_prefix    = "gwif-sa-"
  sa_name_max_len   = 28 - length(local.sa_name_prefix)
  sa_name_truncated = substr(local.resource_name_suffix, 0, local.sa_name_max_len)
  account_id        = "${local.sa_name_prefix}${local.sa_name_truncated}"

  # Service account mode selection
  sa_use_existing = var.gcp_existing_service_account_account_id != null
  sa_use_explicit = var.gcp_service_account_account_id != null && var.gcp_service_account_project_id != null

  # Unified SA identity — resolves to the correct value in all 3 modes
  sa_account_id = (
    local.sa_use_existing ? var.gcp_existing_service_account_account_id :
    local.sa_use_explicit ? var.gcp_service_account_account_id :
    local.account_id
  )
  sa_project_id = (
    local.sa_use_explicit ? var.gcp_service_account_project_id :
    var.gcp_project_id
  )

  # Manage conditionally creation of the service account
  sa_must_be_created = !local.sa_use_existing
  sa_name            = local.sa_must_be_created ? resource.google_service_account.this[0].name : data.google_service_account.this[0].name
  sa_email           = local.sa_must_be_created ? resource.google_service_account.this[0].email : data.google_service_account.this[0].email
  sa_member          = local.sa_must_be_created ? resource.google_service_account.this[0].member : data.google_service_account.this[0].member

  # Ensure the display_name is always 32 characters or less
  pool_display_name_suffix    = " Pool"
  pool_display_name_max_len   = 32 - length(local.pool_display_name_suffix)
  pool_display_name_truncated = substr(var.name, 0, local.pool_display_name_max_len)
  pool_display_name           = "${local.pool_display_name_truncated}${local.pool_display_name_suffix}"

  # Ensure the provider display_name is always 32 characters or less
  provider_display_name_suffix    = " Provider"
  provider_display_name_max_len   = 32 - length(local.provider_display_name_suffix)
  provider_display_name_truncated = substr(var.name, 0, local.provider_display_name_max_len)
  provider_display_name           = "${local.provider_display_name_truncated}${local.provider_display_name_suffix}"

  # Create a prefix for secrets and ensure the final name is valid and under 255 characters
  secret_prefix          = "${var.name}-"
  max_secret_name_length = 255 - length(local.secret_prefix)

  # Clean and format each secret name
  formatted_secret_names = {
    for name in var.secret_names :
    name => substr("${local.secret_prefix}${lower(replace(replace(name, "_", "-"), "/[^a-z0-9-]/", ""))}", 0, local.max_secret_name_length)
  }

  secret_gcp_project_id = var.secret_gcp_project_id != null ? var.secret_gcp_project_id : var.gcp_project_id

  gitlab_group_variables_enabled   = var.gitlab_gcp_wif_variables_enabled && length(var.gitlab_group_ids) > 0
  gitlab_project_variables_enabled = var.gitlab_gcp_wif_variables_enabled && length(var.gitlab_project_ids) > 0

  gitlab_variables_description = replace(var.gitlab_variables_description, "{{MANAGER_NAME}}", var.gitlab_variables_description_manager_name)

  gitlab_variables_additional_group = flatten([
    for gitlab_resource_id in var.gitlab_group_ids : [
      for key, value in var.gitlab_variables_additional : [
        merge(
          value,
          {
            gitlab_resource_type = local.group_resource_suffix,
            gitlab_resource_id   = gitlab_resource_id,
            key                  = key,
            description          = replace(value.description, "{{MANAGER_NAME}}", var.gitlab_variables_description_manager_name)
          }
        )
      ]
  ]])

  gitlab_variables_additional_project = flatten([
    for gitlab_resource_id in var.gitlab_project_ids : [
      for key, value in var.gitlab_variables_additional : [
        merge(
          value,
          {
            gitlab_resource_type = local.project_resource_suffix,
            gitlab_resource_id   = gitlab_resource_id,
            key                  = key,
            description          = replace(value.description, "{{MANAGER_NAME}}", var.gitlab_variables_description_manager_name)
          }
        )
      ]
  ]])

  gitlab_variables_additional_final = {
    for item in concat(local.gitlab_variables_additional_group, local.gitlab_variables_additional_project) :
    "${item.key}--${item.gitlab_resource_type}--${item.gitlab_resource_id}" => item
  }
}
