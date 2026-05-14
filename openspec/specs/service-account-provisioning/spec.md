### Requirement: Module supports explicit service account creation

The module SHALL allow callers to request module-managed service account creation by setting both `gcp_service_account_account_id` and `gcp_service_account_project_id`. When this mode is selected, the module SHALL create the service account in the requested project using the provided `account_id` and SHALL use that service account for workload identity bindings, outputs, GitLab variables, and secret IAM grants.

#### Scenario: Explicit module-managed service account creation

- **WHEN** `gcp_existing_service_account_account_id` is unset and both `gcp_service_account_account_id` and `gcp_service_account_project_id` are set
- **THEN** the module creates the service account in `gcp_service_account_project_id` with account ID `gcp_service_account_account_id`
- **AND** the created service account is used by the module's IAM bindings, outputs, GitLab variables, and secret IAM grants

### Requirement: Module preserves existing service account reuse

The module SHALL continue to support reusing an existing service account when `gcp_existing_service_account_account_id` is provided, and it SHALL NOT create a new service account in that mode.

#### Scenario: Reuse existing service account

- **WHEN** `gcp_existing_service_account_account_id` is set
- **THEN** the module resolves and uses the existing service account
- **AND** the module does not create a new service account resource

### Requirement: Module validates service account input combinations

The module SHALL reject incomplete or conflicting service account configuration so callers can distinguish between explicit module-managed creation, existing-service-account reuse, and the legacy fallback behavior.

#### Scenario: Conflicting service account modes

- **WHEN** `gcp_existing_service_account_account_id` is set together with `gcp_service_account_account_id` or `gcp_service_account_project_id`
- **THEN** `terraform plan` fails with a validation error explaining that existing-service-account reuse and explicit module-managed creation are mutually exclusive

#### Scenario: Incomplete explicit creation configuration

- **WHEN** only one of `gcp_service_account_account_id` or `gcp_service_account_project_id` is set
- **THEN** `terraform plan` fails with a validation error explaining that both inputs are required for explicit module-managed creation

### Requirement: Module preserves legacy automatic service account creation

The module SHALL preserve the current automatic service account creation behavior when `gcp_existing_service_account_account_id`, `gcp_service_account_account_id`, and `gcp_service_account_project_id` are all unset.

#### Scenario: Legacy fallback service account creation

- **WHEN** all service-account selection inputs are unset
- **THEN** the module creates a service account in `gcp_project_id` using the current generated account ID logic
- **AND** the generated service account continues to be used by downstream IAM bindings, outputs, GitLab variables, and secret IAM grants
