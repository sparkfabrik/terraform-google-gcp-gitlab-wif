## 1. Service Account Inputs

- [x] 1.1 Add `gcp_service_account_account_id` and `gcp_service_account_project_id` to `variables.tf`, including validation for mutual exclusivity and complete explicit-creation input.
- [x] 1.2 Clarify the reuse-path documentation for `gcp_existing_service_account_account_id` so it matches the module behavior.

## 2. Service Account Resolution

- [x] 2.1 Update `locals.tf` to centralize service account mode selection for existing-service-account reuse, explicit module-managed creation, and the legacy generated fallback.
- [x] 2.2 Update `main.tf` so `google_service_account.this` uses the caller-provided account ID and project when the new explicit-creation inputs are set and preserves the generated fallback otherwise.

## 3. Documentation And Verification

- [x] 3.1 Update `README.md`, examples, and `CHANGELOG.md` to document the new explicit-creation path as the preferred way to manage a deterministic service account from this module.
- [x] 3.2 Run `terraform fmt -recursive`, `terraform validate`, `make lint`, and `make generate-docs`, and fix any issues that surface.
