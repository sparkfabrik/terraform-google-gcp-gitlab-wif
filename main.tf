resource "random_id" "suffix" {
  byte_length = 4
}

# Google resources for Workload Identity Federation
data "google_project" "project" {
  project_id = var.gcp_project_id
}

resource "google_iam_workload_identity_pool" "this" {
  project                   = var.gcp_project_id
  workload_identity_pool_id = "pool-${substr(local.resource_name_suffix, 0, 32 - length("pool-"))}"
  display_name              = local.pool_display_name
  description               = "Identity pool for ${var.name}"

  lifecycle {
    # Prevent creation of resources if the module is not configured correctly
    precondition {
      condition     = var.gitlab_group_id > 0 || var.gitlab_project_id > 0
      error_message = "Either gitlab_group_id or gitlab_project_id must be provided."
    }

    precondition {
      condition     = (var.gitlab_group_id > 0) != (var.gitlab_project_id > 0)
      error_message = "Only one of gitlab_group_id or gitlab_project_id should be provided, not both."
    }
  }
}

resource "google_iam_workload_identity_pool_provider" "this" {
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.this.workload_identity_pool_id
  workload_identity_pool_provider_id = "provider-${substr(local.resource_name_suffix, 0, 32 - length("provider-"))}"
  display_name                       = local.provider_display_name
  description                        = "OIDC identity pool provider for ${var.name}"

  attribute_mapping = {
    "google.subject"         = "assertion.sub"
    "attribute.aud"          = "assertion.aud"
    "attribute.project_id"   = "assertion.project_id"
    "attribute.namespace_id" = "assertion.namespace_id"
    "attribute.user_email"   = "assertion.user_email"
    "attribute.ref"          = "assertion.ref"
    "attribute.ref_type"     = "assertion.ref_type"
  }

  attribute_condition = local.attribute_condition

  oidc {
    issuer_uri        = var.gitlab_instance_url
    allowed_audiences = [var.gitlab_instance_url]
  }
}

resource "google_service_account" "this" {
  count = var.gcp_existing_service_account_account_id == null ? 1 : 0

  project      = var.gcp_project_id
  account_id   = local.account_id
  display_name = "Service Account for ${var.name}"
}

data "google_service_account" "this" {
  count = var.gcp_existing_service_account_account_id != null ? 1 : 0

  project    = var.gcp_existing_service_account_project_id
  account_id = var.gcp_existing_service_account_account_id
}

resource "google_service_account_iam_member" "this" {
  service_account_id = local.sa_name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.principal_set
}
