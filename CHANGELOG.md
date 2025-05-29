# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
