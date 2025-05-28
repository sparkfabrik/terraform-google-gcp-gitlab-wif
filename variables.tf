variable "name" {
  description = "The name to use for all resources created by this module."
  type        = string
}

# Google Cloud Platform (GCP) variables
variable "gcp_project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "gcp_existing_service_account_project_id" {
  description = "The project ID of the existing service account to use for GitLab WIF."
  type        = string
  default     = null
}

variable "gcp_existing_service_account_account_id" {
  description = "The email of an existing service account to use for GitLab WIF."
  type        = string
  default     = null
}

# GitLab variables
variable "gitlab_group_id" {
  description = "The GitLab group ID to allow access from. Use this for group-level access."
  type        = number
  default     = 0

  validation {
    condition     = var.gitlab_group_id >= 0
    error_message = "gitlab_group_id must be a valid GitLab group ID or 0 for non-set value (everything will be configured for project-level access)."
  }
}

variable "gitlab_project_id" {
  description = "The GitLab project ID to allow access from. Use this for project-level access."
  type        = number
  default     = 0

  validation {
    condition     = var.gitlab_project_id >= 0
    error_message = "gitlab_project_id must be a valid GitLab project ID or 0 for non-set value (everything will be configured for group-level access)."
  }
}

variable "gitlab_instance_url" {
  description = "The URL of your GitLab instance."
  type        = string
  default     = "https://gitlab.com"
}

variable "gitlab_gcp_wif_project_id_variable_name" {
  description = "The name of the GitLab variable to store the GCP project ID for WIF."
  type        = string
  default     = "GCP_WIF_PROJECT_ID"
}

variable "gitlab_gcp_wif_pool_variable_name" {
  description = "The name of the GitLab variable to store the GCP WIF pool name."
  type        = string
  default     = "GCP_WIF_POOL"
}

variable "gitlab_gcp_wif_provider_variable_name" {
  description = "The name of the GitLab variable to store the GCP WIF provider name."
  type        = string
  default     = "GCP_WIF_PROVIDER"
}
variable "gitlab_gcp_wif_service_account_email_variable_name" {
  description = "The name of the GitLab variable to store the GCP WIF service account email."
  type        = string
  default     = "GCP_WIF_SERVICE_ACCOUNT_EMAIL"
}

# Secret Manager variables
variable "secret_gcp_project_id" {
  description = "The GCP project ID where secrets will be created. If not provided, defaults to `var.gcp_project_id`."
  type        = string
  default     = null
}

variable "secret_names" {
  description = "List of secret names to create and grant access to."
  type        = list(string)
  default     = []
}
