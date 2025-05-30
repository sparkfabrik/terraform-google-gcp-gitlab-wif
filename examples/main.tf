/*
   # A simple example on how to use this module
 */
module "example" {
  source  = "github.com/sparkfabrik/terraform-google-gcp-gitlab-wif?ref=main"
  version = ">= 0.1.0"

  name                  = var.name
  gcp_project_id        = var.gcp_project_id
  gitlab_project_ids    = var.gitlab_project_ids
  gitlab_instance_url   = var.gitlab_instance_url
  secret_gcp_project_id = var.secret_gcp_project_id
  secret_names          = var.secret_names
}
