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
  description = "The account ID of an existing service account to reuse for GitLab WIF. This is the short identifier (e.g., `my-service-account`), not the full email address. The service account is looked up in the project specified by `gcp_project_id`. Mutually exclusive with `gcp_service_account_account_id` and `gcp_service_account_project_id`."
  type        = string
  default     = null
}

variable "gcp_service_account_account_id" {
  description = "The account ID of the service account to create for GitLab WIF. Must be provided together with `gcp_service_account_project_id`. Mutually exclusive with `gcp_existing_service_account_account_id`."
  type        = string
  default     = null

  validation {
    condition     = var.gcp_service_account_account_id == null || can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.gcp_service_account_account_id))
    error_message = "gcp_service_account_account_id must be 6-30 characters, start with a lowercase letter, end with a lowercase letter or digit, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "gcp_service_account_project_id" {
  description = "The GCP project ID where the service account will be created. Must be provided together with `gcp_service_account_account_id`. If not set, the module creates the service account in `gcp_project_id` using a generated account ID."
  type        = string
  default     = null
}

variable "use_legacy_pool_provider_id_format" {
  description = "If true, place the random hex suffix AFTER `var.name` in the workload identity pool and provider IDs (pre-1.0.0 layout: `pool-{name}-{hex}`, `provider-{name}-{hex}`). Default (false) uses the 1.0.0+ layout `pool-{hex}-{name}` / `provider-{hex}-{name}`, which avoids ID collisions when `var.name` is long enough to truncate the random part. Enable this ONLY to keep stability on existing deployments that were created before 1.0.0 and have not yet been migrated. Do not enable for new deployments."
  type        = bool
  default     = false
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
    "attribute.user_id"              = "assertion.user_id"
    "attribute.user_login"           = "assertion.user_login"
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

variable "gitlab_group_static_full_paths" {
  description = "The GitLab group paths to allow access from. This is used in the attribute condition for group access statically instead of dynamically querying the GitLab API. It is useful when you don't have access to the GitLab instance. The paths should be in the format `root_namespace/subgroup1/subgroup2`. If both gitlab_group_ids and gitlab_group_static_full_paths are provided, the module will merge the conditions to allow access from both the specified group IDs and the static paths."
  type        = list(string)
  default     = []
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

variable "gitlab_user_logins" {
  description = "The GitLab user logins (usernames) allowed to trigger pipelines that authenticate via WIF. Logins are resolved to immutable numeric user IDs at plan time via the GitLab API (data.gitlab_user), and the WIF attribute condition matches on `attribute.user_id` (mapped from `assertion.user_id` by default). This prevents access from being silently transferred if a username is renamed or freed and reclaimed by another user. Use gitlab_user_ids instead (or in addition) if you don't have access to the GitLab API or already know the numeric IDs; when both variables are set, the resulting ID set is the union of resolved logins and direct IDs. How the user filter combines with project/group filters is controlled by gitlab_user_filter_logic (`and` restricts source filters to these users, `or` lets these users authenticate in addition to the project/group filters). A per-user principalSet (`attribute.user_id/<id>`) is emitted for each matching user, so IAM bindings self-document the user gate."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.gitlab_user_logins) == 0 || alltrue([for login in var.gitlab_user_logins : length(login) > 0 && login == trimspace(login)])
    error_message = "gitlab_user_logins must be a list of GitLab usernames with no leading or trailing whitespace, or an empty list."
  }
}

variable "gitlab_user_ids" {
  description = "The GitLab numeric user IDs allowed to trigger pipelines that authenticate via WIF. This is the static counterpart to gitlab_user_logins: it skips the GitLab API lookup and is useful when you don't have access to the GitLab instance or already know the IDs. IDs are immutable for the lifetime of a user, so this is the most stable way to identify users. When both gitlab_user_ids and gitlab_user_logins are set, the resulting ID set is the union of direct IDs and resolved logins. How the user filter combines with project/group filters is controlled by gitlab_user_filter_logic. A per-user principalSet (`attribute.user_id/<id>`) is emitted for each matching user."
  type        = list(number)
  default     = []

  validation {
    condition     = length(var.gitlab_user_ids) == 0 || alltrue([for id in var.gitlab_user_ids : id > 0 && floor(id) == id])
    error_message = "gitlab_user_ids must be a list of positive integer GitLab user IDs or an empty list."
  }
}

variable "gitlab_user_filter_logic" {
  description = "How the user filter combines with project/group filters in the WIF attribute condition. `and` (default): the user filter restricts who can authenticate via the project/group sources (a token must match a source filter AND a user). `or`: the user filter is an additional auth path (a token authenticates if it matches a source filter OR a user), useful for trusted-user bypass (e.g., admins who can authenticate from any project/group). Has no effect when no user filter is set, or when no project/group filter is set."
  type        = string
  default     = "and"

  validation {
    condition     = contains(["and", "or"], lower(var.gitlab_user_filter_logic))
    error_message = "gitlab_user_filter_logic must be either \"and\" or \"or\" (case-insensitive)."
  }
}

variable "gitlab_refs" {
  description = "The GitLab pipeline refs (branch or tag names) allowed to authenticate via WIF. When set, the attribute condition gains an `attribute.ref==\"<ref>\"` term (OR'd across the list) that is AND'd onto the rest of the condition, so a token is accepted only when the pipeline ran on one of these refs in addition to any user/project/group filter. This binds federation to the intended execution context (for example a dedicated automation trigger branch), so a principal that can otherwise authenticate cannot mint credentials from an arbitrary ref. Empty (the default) adds no ref term and leaves the condition unchanged. `attribute.ref` is mapped from `assertion.ref` by the default attribute mapping; if you override gcp_workload_identity_pool_provider_attribute_mapping, keep that mapping."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.gitlab_refs) == 0 || alltrue([for r in var.gitlab_refs : length(r) > 0 && r == trimspace(r)])
    error_message = "gitlab_refs must be a list of non-empty ref names with no leading or trailing whitespace, or an empty list."
  }
}

variable "gitlab_ref_type" {
  description = "Optionally restrict the attribute condition to a GitLab ref type, `branch` or `tag`. When set, an `attribute.ref_type==\"<type>\"` term is AND'd onto the condition (alongside gitlab_refs when also set), so for example only branch pipelines federate. `null` (the default) adds no ref-type term. `attribute.ref_type` is mapped from `assertion.ref_type` by the default attribute mapping; if you override the mapping, keep it. Setting gitlab_ref_type without gitlab_refs is allowed (gate by type only)."
  type        = string
  default     = null

  validation {
    condition     = var.gitlab_ref_type == null || contains(["branch", "tag"], var.gitlab_ref_type)
    error_message = "gitlab_ref_type must be either \"branch\" or \"tag\", or null to add no ref-type term."
  }
}

variable "gitlab_instance_url" {
  description = "The URL of your GitLab instance."
  type        = string
  default     = "https://gitlab.com"
}

variable "gitlab_gcp_wif_variables_enabled" {
  description = "Whether to create GitLab variables for the GCP WIF configuration. If true, the module will create variables for the GCP project ID, WIF pool name, provider name, and service account email. These variables can then be used in your GitLab CI/CD pipelines to authenticate with GCP using Workload Identity Federation."
  type        = bool
  default     = true
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
