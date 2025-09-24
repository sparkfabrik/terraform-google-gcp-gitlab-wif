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
      condition     = length(var.gitlab_group_ids) > 0 || length(var.gitlab_project_ids) > 0
      error_message = "Either gitlab_group_ids or gitlab_project_ids must be provided."
    }
  }
}

resource "google_iam_workload_identity_pool_provider" "this" {
  project                            = var.gcp_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.this.workload_identity_pool_id
  workload_identity_pool_provider_id = "provider-${substr(local.resource_name_suffix, 0, 32 - length("provider-"))}"
  display_name                       = local.provider_display_name
  description                        = "OIDC identity pool provider for ${var.name}"
  attribute_condition                = local.attribute_condition
  attribute_mapping = merge(
    var.gcp_workload_identity_pool_provider_attribute_mapping,
    length(var.gitlab_group_ids) > 0 ? {
      "attribute.${local.custom_id_group_valid_attribute_name}" = "${
        join(" || ", formatlist("assertion.namespace_path.startsWith(\"%s\")", [for item in data.gitlab_group.this : item.full_path]))
      } ? \"1\" : \"0\"",
    } : {}
  )

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

  account_id = var.gcp_existing_service_account_account_id
}

resource "google_service_account_iam_member" "this" {
  for_each = local.principal_sets

  service_account_id = local.sa_name
  role               = "roles/iam.workloadIdentityUser"
  member             = each.value
}
