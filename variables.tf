variable "name" {
  description = "The name to use for all resources created by this module."
  type        = string
}

# Google Cloud Platform (GCP) variables
variable "gcp_project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "gcp_existing_service_account_account_id" {
  description = "The email of an existing service account to use for GitLab WIF."
  type        = string
  default     = null
}

variable "gcp_workload_identity_pool_provider_attribute_mapping" {
  description = "A map of attribute mappings for the GCP Workload Identity Federation provider. This allows you to customize how attributes are mapped from GitLab to GCP."
  type        = map(string)
  default = {
    "google.subject"                 = "assertion.user_email+\"::\"+assertion.project_id+\"::\"+assertion.job_id"
    "attribute.aud"                  = "assertion.aud"
    "attribute.project_id"           = "assertion.project_id"
    "attribute.namespace_id"         = "assertion.namespace_id"
    "attribute.user_email"           = "assertion.user_email"
    "attribute.ref"                  = "assertion.ref"
    "attribute.ref_type"             = "assertion.ref_type"
    "attribute.custom_assertion_sub" = "assertion.sub"
  }

  validation {
    condition     = length(var.gcp_workload_identity_pool_provider_attribute_mapping) > 0 && contains(keys(var.gcp_workload_identity_pool_provider_attribute_mapping), "google.subject") && length(var.gcp_workload_identity_pool_provider_attribute_mapping["google.subject"]) > 0
    error_message = "gcp_workload_identity_pool_provider_attribute_mapping must contain a non-empty 'google.subject' mapping."
  }
}

# GitLab variables
variable "gitlab_group_ids" {
  description = "The GitLab group IDs to allow access from. Use this for group-level access. If both gitlab_group_ids and gitlab_project_ids are not provided, the module will create a Workload Identity Pool that allows access from the entire GitLab instance."
  type        = list(number)
  default     = []

  validation {
    condition     = length(var.gitlab_group_ids) == 0 || alltrue([for id in var.gitlab_group_ids : id > 0])
    error_message = "gitlab_group_ids must be a valid list of GitLab group IDs or an empty list for non-set value."
  }
}

variable "gitlab_project_ids" {
  description = "The GitLab project IDs to allow access from. Use this for project-level access. If both gitlab_group_ids and gitlab_project_ids are not provided, the module will create a Workload Identity Pool that allows access from the entire GitLab instance."
  type        = list(number)
  default     = []

  validation {
    condition     = length(var.gitlab_project_ids) == 0 || alltrue([for id in var.gitlab_project_ids : id > 0])
    error_message = "gitlab_project_ids must be a valid list of GitLab project IDs or an empty list for non-set value."
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

variable "gitlab_variables_description" {
  description = "The description for the GitLab variables created by this module. You can use `{{MANAGER_NAME}}` to include the name of the 'manager' defined in `gitlab_variables_description_manager_name`."
  type        = string
  default     = "Managed by {{MANAGER_NAME}}."
}

variable "gitlab_variables_description_manager_name" {
  description = "The name of the manager to include in the GitLab variable description."
  type        = string
  default     = "terraform-google-gcp-gitlab-wif module"
}

variable "gitlab_variables_additional" {
  description = "Additional GitLab variables to create. This should be a map where the key is the variable name and the value is an object containing the variable properties. This allows you to define custom variables for project or group where the module is applied."
  type = map(object({
    value       = string
    protected   = optional(bool, false)
    masked      = optional(bool, false)
    description = optional(string, "Managed by {{MANAGER_NAME}}.")
  }))
  default = {}
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
