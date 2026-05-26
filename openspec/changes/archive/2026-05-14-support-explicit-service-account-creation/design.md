## Context

Today the module resolves a service account in one of two ways. When `gcp_existing_service_account_account_id` is unset, it creates a service account in `gcp_project_id` with a generated `account_id`. When `gcp_existing_service_account_account_id` is set, it reads an existing service account through `data.google_service_account.this` and uses that account throughout the module.

That design is sufficient when callers accept the generated service account name or when the reused service account already exists before the module is planned. It breaks down when callers want a deterministic service account name but still want the module to manage creation in the same Terraform action. In that case, the caller often creates the service account elsewhere and passes it to this module, but the data lookup can fail during `terraform plan` because the service account is not yet present.

This change must remain non-breaking. Existing consumers who reuse a service account must keep working, and existing consumers who pass nothing must keep receiving the generated fallback behavior.

## Goals / Non-Goals

**Goals:**

- Allow callers to request module-managed service account creation with an explicit `account_id`.
- Allow callers to choose the project where the module creates that service account.
- Preserve the existing-service-account reuse path.
- Preserve the current generated fallback behavior for backward compatibility.
- Keep downstream resources and outputs working through the existing `local.sa_name`, `local.sa_email`, and `local.sa_member` interface.

**Non-Goals:**

- Remove the legacy generated service account fallback in this change.
- Rename or remove `gcp_existing_service_account_account_id`.
- Redesign secret access, GitLab variable creation, or workload identity IAM behavior.
- Expand the existing-service-account lookup contract beyond the current behavior unless required for the explicit creation path.

## Decisions

### 1. Add explicit service account creation inputs

The module will add two optional variables:

- `gcp_service_account_account_id`
- `gcp_service_account_project_id`

These inputs provide a deterministic creation path for callers who want the module to own the service account lifecycle.

Alternative considered: repurpose `gcp_existing_service_account_account_id` so the module would attempt reuse first and create on failure. This was rejected because it would overload one variable with two incompatible behaviors and would still rely on plan-time data source behavior.

### 2. Keep a three-branch service account selection flow

The module will resolve the service account in this order:

1. Reuse an existing service account when `gcp_existing_service_account_account_id` is set.
2. Create a service account with the caller-provided `account_id` and project when both new variables are set.
3. Create a service account with the current generated `account_id` in `gcp_project_id` when none of the service-account selection inputs are set.

This preserves current behavior for existing consumers while making the explicit creation path available for new use cases.

Alternative considered: require the new variables for any module-managed creation. This was rejected because it would break current users who rely on the generated fallback.

### 3. Scope the new project input to module-managed creation

`gcp_service_account_project_id` will control the project used when the module creates the service account. The existing-service-account lookup path will keep its current behavior unless follow-up work explicitly broadens that contract.

This keeps the change minimal and matches the primary user need: letting callers define where the module creates the service account.

Alternative considered: use `gcp_service_account_project_id` for both creation and data lookup. This would be useful for some reuse scenarios, but it introduces additional behavior changes that are not required to solve the current problem.

### 4. Centralize service account mode selection in locals

The module will continue to expose a single selected service account through:

- `local.sa_name`
- `local.sa_email`
- `local.sa_member`

Creation and reuse logic will stay behind locals so IAM bindings, outputs, secret access grants, and GitLab variables do not need separate branching logic.

Alternative considered: branch each downstream resource individually. This was rejected because it increases complexity and makes the change harder to review and maintain.

### 5. Add validation and documentation clarifications

The module will validate that:

- `gcp_service_account_account_id` and `gcp_service_account_project_id` are provided together.
- `gcp_existing_service_account_account_id` cannot be combined with the new explicit-creation inputs.

Documentation will also clarify that the existing-service-account input is an `account_id`-based reuse path and that the new explicit-creation path is the preferred way to get a deterministic service account name managed by this module.

## Risks / Trade-offs

- Legacy fallback remains part of the module surface area -> Keep it documented as a compatibility path and prefer the new explicit-creation flow in examples.
- Callers may assume the new project input also affects existing-service-account lookup -> Document the scope clearly and leave broader lookup configuration for follow-up work.
- Additional branching can make the service account logic harder to follow -> Keep the branching centralized in locals and avoid changing downstream consumers.

## Migration Plan

No migration is required for current users.

Callers who currently create the service account outside the module can migrate by:

1. Removing the external service account resource from their composition when appropriate.
2. Setting `gcp_service_account_account_id` and `gcp_service_account_project_id` on this module.
3. Applying the change so the module creates and uses the service account directly.

Rollback is straightforward: unset the new inputs and return to the previous external or legacy configuration.

## Open Questions

- None for the initial scope. If users need explicit project scoping for existing-service-account lookup, that can be proposed as a follow-up change.
