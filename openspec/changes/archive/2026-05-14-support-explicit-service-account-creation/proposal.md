## Why

The module currently supports either reusing an existing service account or creating one with a generated name. Teams that need a deterministic service account name and create all infrastructure in a single Terraform action often create the service account outside the module, which can fail at plan time because the module resolves reused service accounts through a data source before that account exists.

The module needs an explicit in-module service account creation path so callers can choose the service account name and creation project without breaking existing consumers.

## What Changes

- Add two optional inputs, `gcp_service_account_account_id` and `gcp_service_account_project_id`, to support module-managed service account creation with an explicit name and project.
- Update service account selection logic to prefer existing-service-account reuse when `gcp_existing_service_account_account_id` is set, otherwise create a caller-defined service account when the new inputs are provided, and otherwise keep the current generated service account behavior for compatibility.
- Validate service account inputs so the explicit creation path is complete and mutually exclusive with existing-service-account reuse.
- Update documentation, examples, and changelog to describe the new preferred explicit-creation flow and clarify existing service account input semantics.

## Capabilities

### New Capabilities

- `service-account-provisioning`: Define how the module selects, creates, and reuses the service account used by workload identity federation resources.

### Modified Capabilities

None.

## Impact

- Affected Terraform files: `variables.tf`, `locals.tf`, `main.tf`, `README.md`, `examples/main.tf`, `examples/variables.tf`, and `CHANGELOG.md`.
- No new providers or external dependencies are required.
- Existing consumers remain compatible because the current generated-service-account path is preserved as a fallback.
