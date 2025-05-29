# GitLab group and project variables for Workload Identity Federation
# Group variables if `var.gitlab_group_id` is provided
resource "gitlab_group_variable" "gcp_wif_project_id" {
  count = local.is_gitlab_group_level ? 1 : 0

  group       = var.gitlab_group_id
  key         = var.gitlab_gcp_wif_project_id_variable_name
  value       = data.google_project.project.number
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_group_variable" "gcp_wif_pool" {
  count = local.is_gitlab_group_level ? 1 : 0

  group       = var.gitlab_group_id
  key         = var.gitlab_gcp_wif_pool_variable_name
  value       = google_iam_workload_identity_pool.this.workload_identity_pool_id
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_group_variable" "gcp_wif_provider" {
  count = local.is_gitlab_group_level ? 1 : 0

  group       = var.gitlab_group_id
  key         = var.gitlab_gcp_wif_provider_variable_name
  value       = google_iam_workload_identity_pool_provider.this.workload_identity_pool_provider_id
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_group_variable" "gcp_wif_service_account_email" {
  count = local.is_gitlab_group_level ? 1 : 0

  group       = var.gitlab_group_id
  key         = var.gitlab_gcp_wif_service_account_email_variable_name
  value       = local.sa_email
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_group_variable" "gitlab_variables_additional" {
  for_each = local.is_gitlab_group_level ? local.gitlab_variables_additional_final : {}

  group       = var.gitlab_group_id
  key         = each.key
  value       = each.value.value
  description = each.value.description
  protected   = each.value.protected
  masked      = each.value.masked
}

# Project variables if `var.gitlab_project_id` is provided
resource "gitlab_project_variable" "gcp_wif_project_id" {
  count = local.is_gitlab_project_level ? 1 : 0

  project     = var.gitlab_project_id
  key         = var.gitlab_gcp_wif_project_id_variable_name
  value       = data.google_project.project.number
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_project_variable" "gcp_wif_pool" {
  count = local.is_gitlab_project_level ? 1 : 0

  project     = var.gitlab_project_id
  key         = var.gitlab_gcp_wif_pool_variable_name
  value       = google_iam_workload_identity_pool.this.workload_identity_pool_id
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_project_variable" "gcp_wif_provider" {
  count = local.is_gitlab_project_level ? 1 : 0

  project     = var.gitlab_project_id
  key         = var.gitlab_gcp_wif_provider_variable_name
  value       = google_iam_workload_identity_pool_provider.this.workload_identity_pool_provider_id
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_project_variable" "gcp_wif_service_account_email" {
  count = local.is_gitlab_project_level ? 1 : 0

  project     = var.gitlab_project_id
  key         = var.gitlab_gcp_wif_service_account_email_variable_name
  value       = local.sa_email
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_project_variable" "gitlab_variables_additional" {
  for_each = local.is_gitlab_project_level ? local.gitlab_variables_additional_final : {}

  project     = var.gitlab_project_id
  key         = each.key
  value       = each.value.value
  description = each.value.description
  protected   = each.value.protected
  masked      = each.value.masked
}
