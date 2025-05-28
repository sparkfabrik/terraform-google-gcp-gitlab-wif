# Terraform Module Template

This project can be used as a template for the initial stub of a Terraform 
module. 

We suggest following Terraform best practices as described in https://www.terraform-best-practices.com/code-structure.

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
| <a name="input_gitlab_group_id"></a> [gitlab\_group\_id](#input\_gitlab\_group\_id) | The GitLab group ID to allow access from. Use this for group-level access. | `string` | `null` | no |
| <a name="input_gitlab_instance_url"></a> [gitlab\_instance\_url](#input\_gitlab\_instance\_url) | The URL of your GitLab instance. | `string` | `"https://gitlab.com"` | no |
| <a name="input_gitlab_project_id"></a> [gitlab\_project\_id](#input\_gitlab\_project\_id) | The GitLab project ID to allow access from. Use this for project-level access. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to use for all resources created by this module. | `string` | n/a | yes |
| <a name="input_secret_gcp_project_id"></a> [secret\_gcp\_project\_id](#input\_secret\_gcp\_project\_id) | The GCP project ID where secrets will be created. If not provided, defaults to `var.gcp_project_id`. | `string` | `null` | no |
| <a name="input_secret_names"></a> [secret\_names](#input\_secret\_names) | List of secret names to create and grant access to. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_example"></a> [example](#output\_example) | The name of the resource. |

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
