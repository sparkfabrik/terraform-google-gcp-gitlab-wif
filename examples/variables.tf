variable "name" {
  description = "The name to use for all resources created by this module."
  type        = string
}

# Google Cloud Platform (GCP) variables
variable "gcp_project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

# GitLab variables
variable "gitlab_project_id" {
  description = "The GitLab project ID to allow access from. Use this for project-level access."
  type        = string
}

variable "gitlab_instance_url" {
  description = "The URL of your GitLab instance."
  type        = string
}

# Secret Manager variables
variable "secret_gcp_project_id" {
  description = "The GCP project ID where secrets will be created. If not provided, defaults to `var.gcp_project_id`."
  type        = string
}

variable "secret_names" {
  description = "List of secret names to create and grant access to."
  type        = list(string)
  default     = []
}
