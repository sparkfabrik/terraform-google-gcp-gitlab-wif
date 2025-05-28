locals {
  resource_name_suffix    = "${var.name}-${random_id.suffix.hex}"
  is_gitlab_group_level   = var.gitlab_group_id > 0
  is_gitlab_project_level = var.gitlab_project_id > 0
  attribute_condition     = local.is_gitlab_project_level ? "assertion.project_id==\"${var.gitlab_project_id}\"" : "assertion.namespace_id==\"${var.gitlab_group_id}\""
  principal_subject       = local.is_gitlab_project_level ? "attribute.project_id/${var.gitlab_project_id}" : "attribute.namespace_id/${var.gitlab_group_id}"
  principal_set           = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.this.name}/${local.principal_subject}"

  # Ensure the account_id is always 28 characters or less
  sa_name_prefix    = "gwif-sa-"
  sa_name_max_len   = 28 - length(local.sa_name_prefix)
  sa_name_truncated = substr(local.resource_name_suffix, 0, local.sa_name_max_len)
  account_id        = "${local.sa_name_prefix}${local.sa_name_truncated}"

  # Manage conditionally creation of the service account
  sa_must_be_created = var.gcp_existing_service_account_account_id == null && var.gcp_existing_service_account_project_id == null
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

  gitlab_variables_description = replace(var.gitlab_variables_description, "{{MANAGER_NAME}}", var.gitlab_variables_description_manager_name)
}
