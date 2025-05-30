# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2025-05-30

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-gitlab-wif/compare/0.4.0...0.5.0)

### :warning: Breaking change

The variables `gitlab_group_id` and `gitlab_project_id` have been renamed to `gitlab_group_ids` and `gitlab_project_ids` and the type has been changed from `string` to `list(string)`. This allows for multiple group and project IDs to be specified.

You can update your configuration simply by changing the variable names and wrapping the existing values in a list, like this:

**From:**

```hcl
module "example" {
  source  = "github.com/sparkfabrik/terraform-google-gcp-gitlab-wif?ref=main"
  version = ">= 0.1.0"

  name              = "My Workload Identity Federation"
  gcp_project_id    = "awesome-gcp-project"
  gitlab_project_id = 42
}
```

**To:**

```hcl
module "example" {
  source  = "github.com/sparkfabrik/terraform-google-gcp-gitlab-wif?ref=main"
  version = ">= 0.1.0"

  name               = "My Workload Identity Federation"
  gcp_project_id     = "awesome-gcp-project"
  gitlab_project_ids = [42]
}
```

### Added

- You can add GitLab groups and projects together with the same module, allowing for more flexibility in managing multiple GitLab groups and projects usint the same OIDC provider configuration.

### Changed

- Change the variables `gitlab_group_id` and `gitlab_project_id` to `gitlab_group_ids` and `gitlab_project_ids`, allowing for multiple group and project IDs to be specified.

## [0.4.0] - 2025-05-29

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-gitlab-wif/compare/0.3.1...0.4.0)

### :warning: Breaking change

The default attribute mapping for `google.subject` has changed, see below. Consider updating your configuration accordingly.

### Added

- Add `gcp_workload_identity_pool_provider_attribute_mapping` to allow customization of the attribute mapping for the GCP Workload Identity Pool Provider.

### Changed

- Change the default attribute mapping for the GCP Workload Identity Pool Provider from `google.subject = assertion.sub` to `google.subject = assertion.user_email+"::"+assertion.project_id+"::"+assertion.job_id`. This prevents issues with very long branch names (`assertion.sub` contains the branch name, see [here](https://docs.gitlab.com/ci/secrets/id_token_authentication/#token-payload) for more details) and could be useful for Audit Logs and other purposes.

## [0.3.1] - 2025-05-29

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-gitlab-wif/compare/0.3.0...0.3.1)

### Changed

- Change `google_service_account_iam_binding` to `google_service_account_iam_member` for the role `roles/iam.workloadIdentityUser` to the desired service account to avoid issues with multiple bindings for the same role (e.g., when using the Workload Identity Federation for GKE clusters).

## [0.3.0] - 2025-05-29

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-gitlab-wif/compare/0.2.0...0.3.0)

### Added

- Add `gitlab_variables_additional` variable to allow users to add additional custom GitLab variables in project or group where the module is used.

## [0.2.0] - 2025-05-28

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-gitlab-wif/compare/0.1.0...0.2.0)

### Added

- Add `gitlab_variables_description` variable to provide a description for GitLab variables.
- Add `gitlab_variables_description_manager_name` variable to customize the manager name in GitLab variable descriptions (`gitlab_variables_description`).

## [0.1.0] - 2025-05-28

- First release.
