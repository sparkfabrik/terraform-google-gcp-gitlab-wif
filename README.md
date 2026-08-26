# Terraform Google Cloud Platform Workload Identity Federation for GitLab

This Terraform module sets up Google Cloud Platform (GCP) Workload Identity Federation (WIF) resources in order to allow GitLab CI/CD pipelines to authenticate with GCP. It creates a Workload Identity Pool, a Workload Identity Provider, and optionally a service account, and creates GitLab variables to store the necessary information to be used in GitLab CI/CD pipelines to perform the authentication.

You can refer to the official [GitLab documentation](https://docs.gitlab.com/ci/cloud_services/google_cloud/) about configure OpenID Connect with GCP Workload Identity Federation.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_gitlab"></a> [gitlab](#provider\_gitlab) | 19.0.0 |
| <a name="provider_google"></a> [google](#provider\_google) | 7.36.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | >= 17 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.53 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gcp_existing_service_account_account_id"></a> [gcp\_existing\_service\_account\_account\_id](#input\_gcp\_existing\_service\_account\_account\_id) | The account ID of an existing service account to reuse for GitLab WIF. This is the short identifier (e.g., `my-service-account`), not the full email address. The service account is looked up in the project specified by `gcp_project_id`. Mutually exclusive with `gcp_service_account_account_id` and `gcp_service_account_project_id`. | `string` | `null` | no |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | The ID of the project in which to provision resources. | `string` | n/a | yes |
| <a name="input_gcp_service_account_account_id"></a> [gcp\_service\_account\_account\_id](#input\_gcp\_service\_account\_account\_id) | The account ID of the service account to create for GitLab WIF. Must be provided together with `gcp_service_account_project_id`. Mutually exclusive with `gcp_existing_service_account_account_id`. | `string` | `null` | no |
| <a name="input_gcp_service_account_project_id"></a> [gcp\_service\_account\_project\_id](#input\_gcp\_service\_account\_project\_id) | The GCP project ID where the service account will be created. Must be provided together with `gcp_service_account_account_id`. If not set, the module creates the service account in `gcp_project_id` using a generated account ID. | `string` | `null` | no |
| <a name="input_gcp_workload_identity_pool_provider_attribute_mapping"></a> [gcp\_workload\_identity\_pool\_provider\_attribute\_mapping](#input\_gcp\_workload\_identity\_pool\_provider\_attribute\_mapping) | A map of attribute mappings for the GCP Workload Identity Federation provider. This allows you to customize how attributes are mapped from GitLab to GCP. | `map(string)` | <pre>{<br/>  "attribute.aud": "assertion.aud",<br/>  "attribute.custom_assertion_sub": "assertion.sub",<br/>  "attribute.namespace_id": "assertion.namespace_id",<br/>  "attribute.project_id": "assertion.project_id",<br/>  "attribute.ref": "assertion.ref",<br/>  "attribute.ref_type": "assertion.ref_type",<br/>  "attribute.user_email": "assertion.user_email",<br/>  "attribute.user_id": "assertion.user_id",<br/>  "attribute.user_login": "assertion.user_login",<br/>  "google.subject": "assertion.user_email+\"::\"+assertion.project_id+\"::\"+assertion.job_id"<br/>}</pre> | no |
| <a name="input_gitlab_gcp_wif_pool_variable_name"></a> [gitlab\_gcp\_wif\_pool\_variable\_name](#input\_gitlab\_gcp\_wif\_pool\_variable\_name) | The name of the GitLab variable to store the GCP WIF pool name. | `string` | `"GCP_WIF_POOL"` | no |
| <a name="input_gitlab_gcp_wif_project_id_variable_name"></a> [gitlab\_gcp\_wif\_project\_id\_variable\_name](#input\_gitlab\_gcp\_wif\_project\_id\_variable\_name) | The name of the GitLab variable to store the GCP project ID for WIF. | `string` | `"GCP_WIF_PROJECT_ID"` | no |
| <a name="input_gitlab_gcp_wif_provider_variable_name"></a> [gitlab\_gcp\_wif\_provider\_variable\_name](#input\_gitlab\_gcp\_wif\_provider\_variable\_name) | The name of the GitLab variable to store the GCP WIF provider name. | `string` | `"GCP_WIF_PROVIDER"` | no |
| <a name="input_gitlab_gcp_wif_service_account_email_variable_name"></a> [gitlab\_gcp\_wif\_service\_account\_email\_variable\_name](#input\_gitlab\_gcp\_wif\_service\_account\_email\_variable\_name) | The name of the GitLab variable to store the GCP WIF service account email. | `string` | `"GCP_WIF_SERVICE_ACCOUNT_EMAIL"` | no |
| <a name="input_gitlab_gcp_wif_variables_enabled"></a> [gitlab\_gcp\_wif\_variables\_enabled](#input\_gitlab\_gcp\_wif\_variables\_enabled) | Whether to create GitLab variables for the GCP WIF configuration. If true, the module will create variables for the GCP project ID, WIF pool name, provider name, and service account email. These variables can then be used in your GitLab CI/CD pipelines to authenticate with GCP using Workload Identity Federation. | `bool` | `true` | no |
| <a name="input_gitlab_group_ids"></a> [gitlab\_group\_ids](#input\_gitlab\_group\_ids) | The GitLab group IDs to allow access from. Use this for group-level access. If both gitlab\_group\_ids and gitlab\_project\_ids are not provided, the module will create a Workload Identity Pool that allows access from the entire GitLab instance. | `list(number)` | `[]` | no |
| <a name="input_gitlab_group_static_full_paths"></a> [gitlab\_group\_static\_full\_paths](#input\_gitlab\_group\_static\_full\_paths) | The GitLab group paths to allow access from. This is used in the attribute condition for group access statically instead of dynamically querying the GitLab API. It is useful when you don't have access to the GitLab instance. The paths should be in the format `root_namespace/subgroup1/subgroup2`. If both gitlab\_group\_ids and gitlab\_group\_static\_full\_paths are provided, the module will merge the conditions to allow access from both the specified group IDs and the static paths. | `list(string)` | `[]` | no |
| <a name="input_gitlab_instance_url"></a> [gitlab\_instance\_url](#input\_gitlab\_instance\_url) | The URL of your GitLab instance. | `string` | `"https://gitlab.com"` | no |
| <a name="input_gitlab_project_ids"></a> [gitlab\_project\_ids](#input\_gitlab\_project\_ids) | The GitLab project IDs to allow access from. Use this for project-level access. If both gitlab\_group\_ids and gitlab\_project\_ids are not provided, the module will create a Workload Identity Pool that allows access from the entire GitLab instance. | `list(number)` | `[]` | no |
| <a name="input_gitlab_ref_type"></a> [gitlab\_ref\_type](#input\_gitlab\_ref\_type) | Optionally restrict the attribute condition to a GitLab ref type, `branch` or `tag`. When set, an `attribute.ref_type=="<type>"` term is AND'd onto the condition (alongside gitlab\_refs when also set), so for example only branch pipelines federate. `null` (the default) adds no ref-type term. `attribute.ref_type` is mapped from `assertion.ref_type` by the default attribute mapping; if you override the mapping, keep it. Setting gitlab\_ref\_type without gitlab\_refs is allowed (gate by type only). | `string` | `null` | no |
| <a name="input_gitlab_refs"></a> [gitlab\_refs](#input\_gitlab\_refs) | The GitLab pipeline refs (branch or tag names) allowed to authenticate via WIF. When set, the attribute condition gains an `attribute.ref=="<ref>"` term (OR'd across the list) that is AND'd onto the rest of the condition, so a token is accepted only when the pipeline ran on one of these refs in addition to any user/project/group filter. This binds federation to the intended execution context (for example a dedicated automation trigger branch), so a principal that can otherwise authenticate cannot mint credentials from an arbitrary ref. Empty (the default) adds no ref term and leaves the condition unchanged. `attribute.ref` is mapped from `assertion.ref` by the default attribute mapping; if you override gcp\_workload\_identity\_pool\_provider\_attribute\_mapping, keep that mapping. | `list(string)` | `[]` | no |
| <a name="input_gitlab_user_filter_logic"></a> [gitlab\_user\_filter\_logic](#input\_gitlab\_user\_filter\_logic) | How the user filter combines with project/group filters in the WIF attribute condition. `and` (default): the user filter restricts who can authenticate via the project/group sources (a token must match a source filter AND a user). `or`: the user filter is an additional auth path (a token authenticates if it matches a source filter OR a user), useful for trusted-user bypass (e.g., admins who can authenticate from any project/group). Has no effect when no user filter is set, or when no project/group filter is set. | `string` | `"and"` | no |
| <a name="input_gitlab_user_ids"></a> [gitlab\_user\_ids](#input\_gitlab\_user\_ids) | The GitLab numeric user IDs allowed to trigger pipelines that authenticate via WIF. This is the static counterpart to gitlab\_user\_logins: it skips the GitLab API lookup and is useful when you don't have access to the GitLab instance or already know the IDs. IDs are immutable for the lifetime of a user, so this is the most stable way to identify users. When both gitlab\_user\_ids and gitlab\_user\_logins are set, the resulting ID set is the union of direct IDs and resolved logins. How the user filter combines with project/group filters is controlled by gitlab\_user\_filter\_logic. A per-user principalSet (`attribute.user_id/<id>`) is emitted for each matching user. | `list(number)` | `[]` | no |
| <a name="input_gitlab_user_logins"></a> [gitlab\_user\_logins](#input\_gitlab\_user\_logins) | The GitLab user logins (usernames) allowed to trigger pipelines that authenticate via WIF. Logins are resolved to immutable numeric user IDs at plan time via the GitLab API (data.gitlab\_user), and the WIF attribute condition matches on `attribute.user_id` (mapped from `assertion.user_id` by default). This prevents access from being silently transferred if a username is renamed or freed and reclaimed by another user. Use gitlab\_user\_ids instead (or in addition) if you don't have access to the GitLab API or already know the numeric IDs; when both variables are set, the resulting ID set is the union of resolved logins and direct IDs. How the user filter combines with project/group filters is controlled by gitlab\_user\_filter\_logic (`and` restricts source filters to these users, `or` lets these users authenticate in addition to the project/group filters). A per-user principalSet (`attribute.user_id/<id>`) is emitted for each matching user, so IAM bindings self-document the user gate. | `list(string)` | `[]` | no |
| <a name="input_gitlab_variables_additional"></a> [gitlab\_variables\_additional](#input\_gitlab\_variables\_additional) | Additional GitLab variables to create. This should be a map where the key is a stable label and the value is an object containing the variable properties. This allows you to define custom variables for project or group where the module is applied. The GitLab variable name defaults to the map key; set the optional `key` field to override it. This lets you declare the same variable name more than once at different `environment_scope` values (e.g. one entry per cluster environment) by giving each entry a distinct map key (used only as a stable label) and the same `key`. Each (name, environment\_scope) pair must be unique. | <pre>map(object({<br/>    key               = optional(string)<br/>    value             = string<br/>    protected         = optional(bool, false)<br/>    masked            = optional(bool, false)<br/>    description       = optional(string, "Managed by {{MANAGER_NAME}}.")<br/>    environment_scope = optional(string, "*")<br/>  }))</pre> | `{}` | no |
| <a name="input_gitlab_variables_description"></a> [gitlab\_variables\_description](#input\_gitlab\_variables\_description) | The description for the GitLab variables created by this module. You can use `{{MANAGER_NAME}}` to include the name of the 'manager' defined in `gitlab_variables_description_manager_name`. | `string` | `"Managed by {{MANAGER_NAME}}."` | no |
| <a name="input_gitlab_variables_description_manager_name"></a> [gitlab\_variables\_description\_manager\_name](#input\_gitlab\_variables\_description\_manager\_name) | The name of the manager to include in the GitLab variable description. | `string` | `"terraform-google-gcp-gitlab-wif module"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to use for all resources created by this module. | `string` | n/a | yes |
| <a name="input_secret_gcp_project_id"></a> [secret\_gcp\_project\_id](#input\_secret\_gcp\_project\_id) | The GCP project ID where secrets will be created. If not provided, defaults to `var.gcp_project_id`. | `string` | `null` | no |
| <a name="input_secret_names"></a> [secret\_names](#input\_secret\_names) | List of secret names to create and grant access to. | `list(string)` | `[]` | no |
| <a name="input_use_legacy_pool_provider_id_format"></a> [use\_legacy\_pool\_provider\_id\_format](#input\_use\_legacy\_pool\_provider\_id\_format) | If true, place the random hex suffix AFTER `var.name` in the workload identity pool and provider IDs (pre-1.0.0 layout: `pool-{name}-{hex}`, `provider-{name}-{hex}`). Default (false) uses the 1.0.0+ layout `pool-{hex}-{name}` / `provider-{hex}-{name}`, which avoids ID collisions when `var.name` is long enough to truncate the random part. Enable this ONLY to keep stability on existing deployments that were created before 1.0.0 and have not yet been migrated. Do not enable for new deployments. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gitlab_variables"></a> [gitlab\_variables](#output\_gitlab\_variables) | The GitLab variables created by this module. |
| <a name="output_principals"></a> [principals](#output\_principals) | The principals string used for IAM bindings. |
| <a name="output_secret_created"></a> [secret\_created](#output\_secret\_created) | The names and IDs of the secrets created by this module. |
| <a name="output_secret_ids"></a> [secret\_ids](#output\_secret\_ids) | Map of original secret names to their Secret Manager secret IDs |
| <a name="output_secret_names"></a> [secret\_names](#output\_secret\_names) | Map of original secret names to their formatted names |
| <a name="output_secret_project_id"></a> [secret\_project\_id](#output\_secret\_project\_id) | The GCP project ID where secrets are stored. |
| <a name="output_secret_versions"></a> [secret\_versions](#output\_secret\_versions) | Map of original secret names to their latest Secret Manager version names |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | The email of the Service Account used. |
| <a name="output_workload_identity_pool_name"></a> [workload\_identity\_pool\_name](#output\_workload\_identity\_pool\_name) | The name of the Workload Identity Pool. |
| <a name="output_workload_identity_pool_provider"></a> [workload\_identity\_pool\_provider](#output\_workload\_identity\_pool\_provider) | The full resource name of the Workload Identity Provider. |

## Resources

| Name | Type |
|------|------|
| [gitlab_group_variable.gcp_wif_pool](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/group_variable) | resource |
| [gitlab_group_variable.gcp_wif_project_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/group_variable) | resource |
| [gitlab_group_variable.gcp_wif_provider](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/group_variable) | resource |
| [gitlab_group_variable.gcp_wif_service_account_email](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/group_variable) | resource |
| [gitlab_group_variable.gitlab_variables_additional](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/group_variable) | resource |
| [gitlab_project_variable.gcp_wif_pool](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.gcp_wif_project_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.gcp_wif_provider](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.gcp_wif_service_account_email](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.gitlab_variables_additional](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [google_iam_workload_identity_pool.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_secret_manager_secret.secrets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.secrets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_service_account.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [gitlab_group.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/group) | data source |
| [gitlab_user.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/data-sources/user) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_service_account.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Modules

No modules.

<!-- END_TF_DOCS -->

## Recovering a deleted workload identity pool or provider

Google Cloud **soft-deletes** workload identity pools and providers. When the resources managed by this module are destroyed (for example, by `terraform destroy`, or by a `terraform apply` that replaces them), they are not removed immediately. Instead:

- Both pools and providers stay in a `DELETED` state for **up to 30 days**, after which the deletion becomes permanent ([source](https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers)).
- Deleting a pool also deletes all of its providers ("When you delete a workload identity pool, you also delete its workload identity pool providers." — [source](https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers)).
- While the resource is in the `DELETED` state, its ID **cannot be reused** to create a new pool or provider with the same name. From the docs: "Until a pool is permanently deleted, you cannot reuse its name when creating a new workload identity pool." The same restriction applies to providers.

This matters in two situations:

1. You destroyed the module by mistake and need to bring the same WIF back without changing GitLab CI/CD variables, IAM bindings on third-party resources, or the federation principal strings.
2. You ran `terraform apply` after upgrading to 1.0.0+ without setting `use_legacy_pool_provider_id_format = true`, the old pool/provider were soft-deleted, and you want to roll back to the pre-1.0.0 layout (set the flag) without waiting 30 days for the IDs to be released.

In both cases, the workflow is **undelete in Google Cloud, then import into Terraform state**. Do not let Terraform try to create a new resource with the same ID — it will fail until the soft-deleted one is purged.

### Step 1: Undelete in Google Cloud

Use `gcloud` (or the Cloud Console "Show deleted pools and providers" toggle described in the [official docs](https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers)).

Undelete the pool first ([gcloud reference](https://cloud.google.com/sdk/gcloud/reference/iam/workload-identity-pools/undelete)):

```bash
gcloud iam workload-identity-pools undelete POOL_ID \
  --location=global \
  --project=PROJECT_ID
```

Then undelete each provider ([gcloud reference](https://cloud.google.com/sdk/gcloud/reference/iam/workload-identity-pools/providers/undelete)):

```bash
gcloud iam workload-identity-pools providers undelete PROVIDER_ID \
  --workload-identity-pool=POOL_ID \
  --location=global \
  --project=PROJECT_ID
```

`POOL_ID` and `PROVIDER_ID` are the short IDs (for example `pool-a1b2c3d4-myname`), not the full resource path. `LOCATION` is always `global` for the pools and providers created by this module.

### Step 2: Import into Terraform state

Once the resources are back to `ACTIVE`, import them into the module state so Terraform stops planning to recreate them. The exact addresses depend on whether the module is rooted at the top level or under a parent module (prefix with `module.<name>.` accordingly).

Pool ([Terraform resource docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool#import)):

```bash
terraform import google_iam_workload_identity_pool.this \
  projects/PROJECT_ID/locations/global/workloadIdentityPools/POOL_ID
```

Provider ([Terraform resource docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider#import)):

```bash
terraform import google_iam_workload_identity_pool_provider.this \
  projects/PROJECT_ID/locations/global/workloadIdentityPools/POOL_ID/providers/PROVIDER_ID
```

After import, run `terraform plan` and verify that no replacement is queued. If Terraform still wants to replace the pool or provider, the `workload_identity_pool_id` / `workload_identity_pool_provider_id` computed by the module does not match the imported one; check `var.name`, the `random_id.suffix` value (`terraform state show random_id.suffix`), and `use_legacy_pool_provider_id_format`.
