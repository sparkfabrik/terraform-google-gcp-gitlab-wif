# Fetch  GitLab groups path, if needed
data "gitlab_group" "this" {
  for_each = length(var.gitlab_group_ids) > 0 ? toset([for id in var.gitlab_group_ids : tostring(id)]) : []

  group_id = tonumber(each.value)
}

# GitLab group and project variables for Workload Identity Federation
# Group variables if `var.gitlab_group_id` is provided
resource "gitlab_group_variable" "gcp_wif_project_id" {
  for_each = length(var.gitlab_group_ids) > 0 ? toset([for id in var.gitlab_group_ids : tostring(id)]) : []

  group       = tonumber(each.value)
  key         = var.gitlab_gcp_wif_project_id_variable_name
  value       = data.google_project.project.number
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_group_variable" "gcp_wif_pool" {
  for_each = length(var.gitlab_group_ids) > 0 ? toset([for id in var.gitlab_group_ids : tostring(id)]) : []

  group       = tonumber(each.value)
  key         = var.gitlab_gcp_wif_pool_variable_name
  value       = google_iam_workload_identity_pool.this.workload_identity_pool_id
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_group_variable" "gcp_wif_provider" {
  for_each = length(var.gitlab_group_ids) > 0 ? toset([for id in var.gitlab_group_ids : tostring(id)]) : []

  group       = tonumber(each.value)
  key         = var.gitlab_gcp_wif_provider_variable_name
  value       = google_iam_workload_identity_pool_provider.this.workload_identity_pool_provider_id
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_group_variable" "gcp_wif_service_account_email" {
  for_each = length(var.gitlab_group_ids) > 0 ? toset([for id in var.gitlab_group_ids : tostring(id)]) : []

  group       = tonumber(each.value)
  key         = var.gitlab_gcp_wif_service_account_email_variable_name
  value       = local.sa_email
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_group_variable" "gitlab_variables_additional" {
  for_each = length(var.gitlab_group_ids) > 0 ? {
    for key, val in local.gitlab_variables_additional_final : key => val if val.gitlab_resource_type == local.group_resource_suffix
  } : {}

  group       = each.value.gitlab_resource_id
  key         = each.value.key
  value       = each.value.value
  description = each.value.description
  protected   = each.value.protected
  masked      = each.value.masked
}

# Project variables if `var.gitlab_project_id` is provided
resource "gitlab_project_variable" "gcp_wif_project_id" {
  for_each = length(var.gitlab_project_ids) > 0 ? toset([for id in var.gitlab_project_ids : tostring(id)]) : []

  project     = tonumber(each.value)
  key         = var.gitlab_gcp_wif_project_id_variable_name
  value       = data.google_project.project.number
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_project_variable" "gcp_wif_pool" {
  for_each = length(var.gitlab_project_ids) > 0 ? toset([for id in var.gitlab_project_ids : tostring(id)]) : []

  project     = tonumber(each.value)
  key         = var.gitlab_gcp_wif_pool_variable_name
  value       = google_iam_workload_identity_pool.this.workload_identity_pool_id
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_project_variable" "gcp_wif_provider" {
  for_each = length(var.gitlab_project_ids) > 0 ? toset([for id in var.gitlab_project_ids : tostring(id)]) : []

  project     = tonumber(each.value)
  key         = var.gitlab_gcp_wif_provider_variable_name
  value       = google_iam_workload_identity_pool_provider.this.workload_identity_pool_provider_id
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_project_variable" "gcp_wif_service_account_email" {
  for_each = length(var.gitlab_project_ids) > 0 ? toset([for id in var.gitlab_project_ids : tostring(id)]) : []

  project     = tonumber(each.value)
  key         = var.gitlab_gcp_wif_service_account_email_variable_name
  value       = local.sa_email
  description = local.gitlab_variables_description
  protected   = false
  masked      = false
}

resource "gitlab_project_variable" "gitlab_variables_additional" {
  for_each = length(var.gitlab_project_ids) > 0 ? {
    for key, val in local.gitlab_variables_additional_final : key => val if val.gitlab_resource_type == local.project_resource_suffix
  } : {}

  project     = each.value.gitlab_resource_id
  key         = each.value.key
  value       = each.value.value
  description = each.value.description
  protected   = each.value.protected
  masked      = each.value.masked
}
