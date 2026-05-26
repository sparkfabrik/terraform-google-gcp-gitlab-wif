resource "random_id" "suffix" {
  byte_length = 4
}

# Google resources for Workload Identity Federation
data "google_project" "project" {
  project_id = var.gcp_project_id
}

resource "google_iam_workload_identity_pool" "this" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = "pool-${substr(local.resource_name_pool_suffix, 0, 32 - length("pool-"))}"
  display_name              = local.pool_display_name
  description               = "Identity pool for ${var.name}"
}

resource "google_iam_workload_identity_pool_provider" "this" {
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.this.workload_identity_pool_id
  workload_identity_pool_provider_id = "provider-${substr(local.resource_name_pool_suffix, 0, 32 - length("provider-"))}"
  display_name                       = local.provider_display_name
  description                        = "OIDC identity pool provider for ${var.name}"
  attribute_condition                = local.attribute_condition
  attribute_mapping = merge(
    var.gcp_workload_identity_pool_provider_attribute_mapping,
    length(local.gitlab_group_cel_conditions) > 0 ? {
      "attribute.${local.custom_id_group_valid_attribute_name}" = "${
        join(" || ", local.gitlab_group_cel_conditions)
      } ? \"1\" : \"0\"",
    } : {}
  )

  oidc {
    issuer_uri        = var.gitlab_instance_url
    allowed_audiences = [var.gitlab_instance_url]
  }
}

resource "google_service_account" "this" {
  count = !local.sa_use_existing ? 1 : 0

  project      = local.sa_project_id
  account_id   = local.sa_account_id
  display_name = "Service Account for ${var.name}"

  lifecycle {
    precondition {
      condition     = (var.gcp_service_account_account_id == null) == (var.gcp_service_account_project_id == null)
      error_message = "gcp_service_account_account_id and gcp_service_account_project_id must be provided together."
    }
  }
}

data "google_service_account" "this" {
  count = local.sa_use_existing ? 1 : 0

  account_id = local.sa_account_id
  project    = local.sa_project_id

  lifecycle {
    precondition {
      condition     = var.gcp_service_account_account_id == null && var.gcp_service_account_project_id == null
      error_message = "gcp_existing_service_account_account_id cannot be used together with gcp_service_account_account_id or gcp_service_account_project_id. Use either the existing service account reuse path or the explicit creation path, not both."
    }
  }
}

resource "google_service_account_iam_member" "this" {
  for_each = local.principals

  service_account_id = local.sa_name
  role               = "roles/iam.workloadIdentityUser"
  member             = each.value
}
