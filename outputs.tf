# Google Workload Identity Federation outputs
output "workload_identity_pool_name" {
  description = "The name of the Workload Identity Pool."
  value       = google_iam_workload_identity_pool.this.name
}

output "workload_identity_pool_provider" {
  description = "The full resource name of the Workload Identity Provider."
  value       = google_iam_workload_identity_pool_provider.this.workload_identity_pool_provider_id
}
output "service_account_email" {
  description = "The email of the Service Account used."
  value       = local.sa_email
}

output "principal_set" {
  description = "The principal sets string used for IAM bindings."
  value       = local.principal_sets
}

# GitLab variables outputs
output "gitlab_variables" {
  description = "The GitLab variables created by this module."
  value = merge(
    {
      (var.gitlab_gcp_wif_project_id_variable_name)            = var.gcp_project_id
      (var.gitlab_gcp_wif_pool_variable_name)                  = google_iam_workload_identity_pool.this.name
      (var.gitlab_gcp_wif_provider_variable_name)              = google_iam_workload_identity_pool_provider.this.name
      (var.gitlab_gcp_wif_service_account_email_variable_name) = local.sa_email
    },
    length(var.gitlab_variables_additional) > 0 ? {
      for key, val in var.gitlab_variables_additional :
      key => val.value
    } : {}
  )
}

# Secret manager outputs

output "secret_names" {
  description = "Map of original secret names to their formatted names"
  value       = local.formatted_secret_names
}

output "secret_project_id" {
  description = "The GCP project ID where secrets are stored."
  value       = local.secret_gcp_project_id
}

output "secret_created" {
  description = "The names and IDs of the secrets created by this module."
  value = {
    for k, v in google_secret_manager_secret.secrets : k => {
      name = v.name
      id   = v.id
    }
  }
}

output "secret_ids" {
  description = "Map of original secret names to their Secret Manager secret IDs"
  value = {
    for name, formatted_name in local.formatted_secret_names :
    name => google_secret_manager_secret.secrets[name].id
  }
}

output "secret_versions" {
  description = "Map of original secret names to their latest Secret Manager version names"
  value = {
    for name, formatted_name in local.formatted_secret_names :
    name => google_secret_manager_secret.secrets[name].secret_id
  }
}
