## ADDED Requirements

### Requirement: Module gates the attribute condition on GitLab pipeline refs

The module SHALL accept an optional `gitlab_refs` list of GitLab ref names (branches
or tags). When non-empty, the WIF provider attribute condition SHALL include a term
matching `attribute.ref` against those refs (OR'd across the list), AND'd onto the
rest of the condition, so a federated token is accepted only when the pipeline ran on
one of the listed refs in addition to any user, project, or group filter. When
`gitlab_refs` is empty, the attribute condition SHALL be unchanged.

#### Scenario: ref gate AND'd onto a user condition

- **WHEN** `gitlab_user_logins` (or `gitlab_user_ids`) is set and `gitlab_refs = ["claude-agent"]`
- **THEN** the attribute condition requires both the user term and `attribute.ref=="claude-agent"`, so the user authenticates only from the `claude-agent` ref

#### Scenario: multiple refs are OR'd within the ref term

- **WHEN** `gitlab_refs = ["main", "release"]`
- **THEN** the condition accepts a pipeline on `main` or on `release`, AND'd onto the rest of the condition

#### Scenario: empty refs leaves the condition unchanged

- **WHEN** `gitlab_refs = []` and `gitlab_ref_type = null`
- **THEN** the attribute condition is identical to the module's behavior without ref gating

### Requirement: Module optionally gates on the GitLab ref type

The module SHALL accept an optional `gitlab_ref_type` of `branch` or `tag`. When set,
the attribute condition SHALL include an `attribute.ref_type` term for that type,
AND'd onto the condition (alongside the `gitlab_refs` term when also set). When
`gitlab_ref_type` is `null`, no ref-type term SHALL be added. Setting
`gitlab_ref_type` without `gitlab_refs` SHALL gate by type alone.

#### Scenario: branch-only gate

- **WHEN** `gitlab_ref_type = "branch"`
- **THEN** the attribute condition requires `attribute.ref_type=="branch"`, so tag pipelines do not federate

#### Scenario: refs and ref type combine

- **WHEN** `gitlab_refs = ["claude-agent"]` and `gitlab_ref_type = "branch"`
- **THEN** the condition requires `attribute.ref=="claude-agent"` AND `attribute.ref_type=="branch"`
