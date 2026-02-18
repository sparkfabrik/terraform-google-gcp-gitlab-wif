locals {
  resource_name_suffix = "${var.name}-${random_id.suffix.hex}"

  project_resource_suffix              = "project"
  group_resource_suffix                = "group"
  custom_id_group_valid_attribute_name = "custom_is_group_valid"

  projects_attribute_condition = "(${join(" || ", [for id in var.gitlab_project_ids : "attribute.project_id==\"${id}\""])})"
  groups_attribute_condition   = "(attribute.${local.custom_id_group_valid_attribute_name}==\"1\")"
  attribute_condition = join(" || ", concat(
    length(var.gitlab_project_ids) > 0 ? [local.projects_attribute_condition] : [],
    length(var.gitlab_group_ids) > 0 ? [local.groups_attribute_condition] : []
  ))

  principal_subjects = merge(
    length(var.gitlab_project_ids) > 0 ? { for id in var.gitlab_project_ids : "${local.project_resource_suffix}-${id}" => "attribute.project_id/${id}" } : {},
    length(var.gitlab_group_ids) > 0 ? { (local.group_resource_suffix) = "attribute.${local.custom_id_group_valid_attribute_name}/1" } : {},
  )
  principals = merge(
    # Build the principalSet for each project and group.
    {
      for key, subject in local.principal_subjects : key => "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.this.name}/${subject}"
    },
    # If no specific projects or groups are defined, allow the entire GitLab instance.
    length(var.gitlab_group_ids) == 0 && length(var.gitlab_project_ids) == 0 ? {
      "instance-wide" = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.this.name}/*"
    } : {},
  )

  # Ensure the account_id is always 28 characters or less
  sa_name_prefix    = "gwif-sa-"
  sa_name_max_len   = 28 - length(local.sa_name_prefix)
  sa_name_truncated = substr(local.resource_name_suffix, 0, local.sa_name_max_len)
  account_id        = "${local.sa_name_prefix}${local.sa_name_truncated}"

  # Manage conditionally creation of the service account
  sa_must_be_created = var.gcp_existing_service_account_account_id == null
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
