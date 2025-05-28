# Terraform Google Cloud Platform Workload Identity Federation for GitLab

This Terraform module sets up Google Cloud Platform (GCP) Workload Identity Federation (WIF) resources in order to allow GitLab CI/CD pipelines to authenticate with GCP. It creates a Workload Identity Pool, a Workload Identity Provider, and optionally a service account, and creates GitLab variables to store the necessary information to be used in GitLab CI/CD pipelines to perform the authentication.

You can refer to the official [GitLab documentation](https://docs.gitlab.com/ci/cloud_services/google_cloud/) about configure OpenID Connect with GCP Workload Identity Federation.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_gitlab"></a> [gitlab](#provider\_gitlab) | >= 17 |
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.53 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.0 |

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
| <a name="input_gcp_existing_service_account_account_id"></a> [gcp\_existing\_service\_account\_account\_id](#input\_gcp\_existing\_service\_account\_account\_id) | The email of an existing service account to use for GitLab WIF. | `string` | `null` | no |
| <a name="input_gcp_existing_service_account_project_id"></a> [gcp\_existing\_service\_account\_project\_id](#input\_gcp\_existing\_service\_account\_project\_id) | The project ID of the existing service account to use for GitLab WIF. | `string` | `null` | no |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | The ID of the project in which to provision resources. | `string` | n/a | yes |
| <a name="input_gitlab_gcp_wif_pool_variable_name"></a> [gitlab\_gcp\_wif\_pool\_variable\_name](#input\_gitlab\_gcp\_wif\_pool\_variable\_name) | The name of the GitLab variable to store the GCP WIF pool name. | `string` | `"GCP_WIF_POOL"` | no |
| <a name="input_gitlab_gcp_wif_project_id_variable_name"></a> [gitlab\_gcp\_wif\_project\_id\_variable\_name](#input\_gitlab\_gcp\_wif\_project\_id\_variable\_name) | The name of the GitLab variable to store the GCP project ID for WIF. | `string` | `"GCP_WIF_PROJECT_ID"` | no |
| <a name="input_gitlab_gcp_wif_provider_variable_name"></a> [gitlab\_gcp\_wif\_provider\_variable\_name](#input\_gitlab\_gcp\_wif\_provider\_variable\_name) | The name of the GitLab variable to store the GCP WIF provider name. | `string` | `"GCP_WIF_PROVIDER"` | no |
| <a name="input_gitlab_gcp_wif_service_account_email_variable_name"></a> [gitlab\_gcp\_wif\_service\_account\_email\_variable\_name](#input\_gitlab\_gcp\_wif\_service\_account\_email\_variable\_name) | The name of the GitLab variable to store the GCP WIF service account email. | `string` | `"GCP_WIF_SERVICE_ACCOUNT_EMAIL"` | no |
| <a name="input_gitlab_group_id"></a> [gitlab\_group\_id](#input\_gitlab\_group\_id) | The GitLab group ID to allow access from. Use this for group-level access. | `number` | `0` | no |
| <a name="input_gitlab_instance_url"></a> [gitlab\_instance\_url](#input\_gitlab\_instance\_url) | The URL of your GitLab instance. | `string` | `"https://gitlab.com"` | no |
| <a name="input_gitlab_project_id"></a> [gitlab\_project\_id](#input\_gitlab\_project\_id) | The GitLab project ID to allow access from. Use this for project-level access. | `number` | `0` | no |
| <a name="input_gitlab_variables_description"></a> [gitlab\_variables\_description](#input\_gitlab\_variables\_description) | The description for the GitLab variables created by this module. You can use `{{MANAGER_NAME}}` to include the name of the 'manager' defined in `gitlab_variables_description_manager_name`. | `string` | `"Managed by {{MANAGER_NAME}}."` | no |
| <a name="input_gitlab_variables_description_manager_name"></a> [gitlab\_variables\_description\_manager\_name](#input\_gitlab\_variables\_description\_manager\_name) | The name of the manager to include in the GitLab variable description. | `string` | `"terraform-google-gcp-gitlab-wif module"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to use for all resources created by this module. | `string` | n/a | yes |
| <a name="input_secret_gcp_project_id"></a> [secret\_gcp\_project\_id](#input\_secret\_gcp\_project\_id) | The GCP project ID where secrets will be created. If not provided, defaults to `var.gcp_project_id`. | `string` | `null` | no |
| <a name="input_secret_names"></a> [secret\_names](#input\_secret\_names) | List of secret names to create and grant access to. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gitlab_variables"></a> [gitlab\_variables](#output\_gitlab\_variables) | The GitLab variables created by this module. |
| <a name="output_principal_set"></a> [principal\_set](#output\_principal\_set) | The principal set string used for IAM bindings. |
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
| [gitlab_project_variable.gcp_wif_pool](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.gcp_wif_project_id](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.gcp_wif_provider](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.gcp_wif_service_account_email](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [google_iam_workload_identity_pool.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_secret_manager_secret.secrets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.secrets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_service_account.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_service_account.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Modules

No modules.

<!-- END_TF_DOCS -->
