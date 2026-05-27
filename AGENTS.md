# AGENTS.md

## Project Overview

Terraform module that configures Google Cloud Platform (GCP) Workload Identity Federation (WIF) for GitLab CI/CD pipelines. It creates a Workload Identity Pool, Provider, optional service account, and GitLab CI/CD variables for OIDC-based authentication.

**Tech stack:** Terraform (HCL), GCP (Workload Identity Federation), GitLab (OIDC, CI/CD variables). Check `versions.tf` for the current list of required providers and their version constraints.

## Setup

This is a Terraform module — it is not applied directly. It is consumed by other Terraform configurations via `module` blocks.

To work on the module locally:

```bash
terraform init        # Install providers
terraform validate    # Validate HCL syntax
make lint             # Run tflint via Docker
make generate-docs    # Lint + regenerate README.md (via terraform-docs)
```

## Key Conventions

- **Local development.** No Docker required for daily work. `terraform` CLI runs directly. Docker is used only for linting (`tflint`) and doc generation (`terraform-docs`) via `make` targets.
- **Makefile** is the task runner. Run `make` targets, not raw Docker commands.
- **README.md is auto-generated.** The section between `<!-- BEGIN_TF_DOCS -->` and `<!-- END_TF_DOCS -->` is produced by `make generate-docs`. Never edit anything inside that block by hand. Manual edits are allowed only outside the markers (e.g., the intro paragraphs). After any change to variables, outputs, resources, or providers, ALWAYS run `make generate-docs` to regenerate the block. After regeneration, the resulting markdown must be formatted. To change a description, fix the source (variable `description`, terraform-docs config, etc.) and regenerate, do not patch the generated table directly.
- **CHANGELOG.md must be updated on every change.** Add entries under the `## [Unreleased]` section. Only create a new versioned section (e.g., `## [x.y.z] - YYYY-MM-DD`) when the user explicitly asks to cut a release. Follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.
- **Markdown formatting.** After creating or editing any `.md` file, always run the formatter. Do not format markdown by hand.
- **Examples** live in `examples/`. `examples/test.tfvars` is used by tflint and tfsec for validation.
- **Renovate** manages dependency updates via `renovate.json` (extends SparkFabrik defaults).
- **Provider version bumps.** Renovate handles routine bumps. Before manually bumping a provider in `versions.tf`, check the Terraform Registry for the latest stable release and any breaking changes in the release notes. Always commit the regenerated `.terraform.lock.hcl` together with the manifest change.

## Code Style

- **Terraform:** tflint with rules defined in `.tflint.hcl`:
  - `terraform_naming_convention`: enforced (use `snake_case` for all identifiers)
  - `terraform_unused_declarations`: enforced
  - `terraform_typed_variables`: enforced
  - `terraform_standard_module_structure`: enforced (maintain `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`)
  - `terraform_comment_syntax`: enforced (use `#` not `//`)
  - `terraform_deprecated_index` and `terraform_deprecated_interpolation`: enforced
- Run `make lint` before committing.
- Run `terraform fmt -recursive` to format HCL files.

## Git Workflow

### Commits

Follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>(<scope>): <description>
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`, `perf`, `build`.
**Scope** is optional — use the affected component.

Keep the description lowercase, imperative, no period.

### Branching

- Branch naming: `feat/`, `fix/`, `chore/`, `test/`, `docs/` prefix + kebab-case description (e.g., `fix/cel-group-path-terminator`).
- **Never push directly to `main`.** Always create a feature branch and open a pull request.

### Rebasing

- Always rebase onto `main` before pushing. No merge commits.
- Use `--force-with-lease` (never `--force`) after rebasing.
- Rebase before the first push, before opening a PR, and whenever `main` advances.

## CI/CD

The project uses GitHub Actions (`.github/workflows/tflint.yml`):

- **Trigger:** push to `main` and pull request open/sync.
- **Job:** `tflint` — runs tflint on the module to validate HCL.

## OpenSpec Change Management

Spec artifacts live in `openspec/changes/<name>/`, archived in `openspec/changes/archive/YYYY-MM-DD-<name>/`. Capabilities (long-lived specs) live in `openspec/specs/`. Configuration: `openspec/config.yaml`.

### Git workflow for specs

OpenSpec is a local file workflow. We add these conventions:

1. **Always commit spec artifacts to git.** Never leave proposals, designs, specs, or tasks untracked. Commit them as soon as they are created or updated.
2. **Non-trivial changes: spec-first PR.** For changes that span multiple files, involve architectural decisions, or require infrastructure work:
   - Create a branch (e.g., `docs/<issue>-<name>-spec`).
   - Commit the proposal, design, specs, and tasks.
   - Open a PR for review ("is this the right plan?").
   - Merge the spec PR before starting implementation.
3. **Trivial changes: spec + implementation in one PR.** For small, well-scoped changes, spec and code can ship together.
4. **Archive on merge.** When the implementation is complete, move `openspec/changes/<name>/` to `openspec/changes/archive/YYYY-MM-DD-<name>/` as part of that PR or an immediate follow-up. Do not leave completed changes in the active directory.

## Command Safety

### Safe (run autonomously)

- `terraform validate`
- `terraform fmt -check -recursive`
- `make lint`
- `make generate-docs`
- `git status`, `git log`, `git diff`

### Dangerous (ask user first)

- `git push`
- Creating GitHub releases or tags

### Destructive (never run)

- `terraform apply` / `terraform destroy` — this module is consumed by other configurations. Never apply or destroy. If the user asks, tell them to run these commands themselves in their consuming configuration.
- `git push --force` — never force push under any circumstances. If the user asks, tell them to run the command themselves.
- `rm -rf .terraform/`

## Important Rules

- Never edit the auto-generated section of README.md by hand. Run `make generate-docs` after any change to variables, outputs, or resources.
- Always update `CHANGELOG.md` on every change, using the `[Unreleased]` section.
- Always format markdown files after editing them.
- Run `make lint` before committing.
- Follow conventional commits.
- Never push directly to `main`.
