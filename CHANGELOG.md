# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
