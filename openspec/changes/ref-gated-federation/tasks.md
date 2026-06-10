## 1. Inputs

- [x] 1.1 Add `gitlab_refs` (list(string), default `[]`) to `variables.tf`, with
  validation rejecting empty/whitespace entries.
- [x] 1.2 Add `gitlab_ref_type` (string, default `null`) to `variables.tf`, with
  validation restricting it to `branch`, `tag`, or `null`.

## 2. Attribute condition

- [x] 2.1 In `locals.tf`, rename the existing final condition to
  `base_attribute_condition`.
- [x] 2.2 Build `ref_attribute_terms` from `gitlab_refs` (an OR'd
  `attribute.ref==...` group) and `gitlab_ref_type` (an `attribute.ref_type==...`
  term), and join them with `&&`.
- [x] 2.3 Set the final `attribute_condition` to `(base) && <ref gate>` when a ref
  term exists, the ref gate alone when there is no base (instance-wide), and the
  base unchanged when no ref term is set.

## 3. Docs and examples

- [x] 3.1 Update `CHANGELOG.md` under `[Unreleased]`.
- [x] 3.2 Regenerate the `README.md` inputs table (terraform-docs).
- [x] 3.3 Add the new inputs to `examples/test.tfvars` so tflint/tfsec exercise them.

## 4. Validation

- [x] 4.1 `terraform fmt -recursive` and `terraform validate` pass.
- [ ] 4.2 `make lint` (tflint with `examples/test.tfvars`) passes.
