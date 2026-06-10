## Why

The WIF attribute condition gates federation on the GitLab user, project, and group
only. With a user filter set (the autonomous-agent use case), the condition is
`attribute.user_id == "<id>"`: the listed user authenticates from anywhere, on any
pipeline ref. When that identity is meant to run only on a dedicated trigger branch,
nothing binds federation to that ref. A pipeline running as the same user on a
different ref (for example a branch carrying an attacker-influenced `.gitlab-ci.yml`)
federates just as well and reads the same secrets. The user gate alone does not bind
federation to the intended execution context.

The default attribute mapping already exposes `attribute.ref` and
`attribute.ref_type` (mapped from `assertion.ref` / `assertion.ref_type`), but no
input lets a caller add a ref term to the condition, and the condition is not
overridable.

## What Changes

- Add an optional `gitlab_refs` input (list of branch or tag names). When set, an
  `attribute.ref=="<ref>"` term (OR'd across the list) is AND'd onto the rest of the
  attribute condition, so a token is accepted only when the pipeline ran on one of
  those refs in addition to any user/project/group filter.
- Add an optional `gitlab_ref_type` input (`branch` or `tag`, default `null`). When
  set, an `attribute.ref_type=="<type>"` term is AND'd onto the condition (alongside
  `gitlab_refs` when also set), so a caller can require, for example, branch
  pipelines only.
- Leave the condition unchanged when neither is set (empty list / null), so existing
  consumers are unaffected.
- Update documentation, the changelog, and the example tfvars.

## Capabilities

### New Capabilities

- `wif-ref-gating`: Define how the module optionally restricts the WIF attribute
  condition to specific GitLab pipeline refs and ref types, AND'd onto the existing
  user/project/group condition.

### Modified Capabilities

None.

## Impact

- Affected Terraform files: `variables.tf`, `locals.tf`, `README.md`,
  `examples/test.tfvars`, and `CHANGELOG.md`.
- No new providers or external dependencies. `attribute.ref` / `attribute.ref_type`
  are already in the default attribute mapping.
- Existing consumers remain compatible: with `gitlab_refs` empty and
  `gitlab_ref_type` null, the attribute condition is byte-for-byte unchanged.
