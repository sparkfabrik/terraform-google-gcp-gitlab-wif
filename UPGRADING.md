# Upgrading

## 0.9.x to 1.0.0

### What changes

The workload identity pool and provider IDs now place the random hex **before** `var.name` instead of after it. This fixes potential ID collisions when `var.name` is long enough to cause the random suffix to be truncated.

| Resource | Old ID format           | New ID format           |
| -------- | ----------------------- | ----------------------- |
| Pool     | `pool-{name}-{hex}`     | `pool-{hex}-{name}`     |
| Provider | `provider-{name}-{hex}` | `provider-{hex}-{name}` |

### What happens on `terraform apply`

Terraform will **destroy and recreate** the following resources per module instance:

- `google_iam_workload_identity_pool` (new pool ID)
- `google_iam_workload_identity_pool_provider` (new provider ID)
- `google_service_account_iam_member` (references the pool name in its `member` attribute)
- `gitlab_project_variable` / `gitlab_group_variable` for pool and provider (updated values)

All of these are configuration-only resources (no data is stored in them).

**Not affected:** service account, its email address, and any IAM roles granted to the service account on other GCP resources.

### Steps

1. Run `terraform plan` and verify that only the resources listed above are being replaced. The service account itself must **not** appear in the plan.
2. Schedule a short maintenance window. GitLab CI/CD pipelines using WIF authentication will fail between the destroy and recreate (typically seconds).
3. Run `terraform apply`.

### Escape hatch: skipping the 1.0.0 rename

Starting from 1.2.0, you can opt back into the pre-1.0.0 ID layout (`pool-{name}-{hex}`, `provider-{name}-{hex}`) by setting:

```hcl
use_legacy_pool_provider_id_format = true
```

With this flag set, upgrading from 0.9.x through 1.0.0+ does not replace the pool, provider, IAM binding, or related GitLab variables. Use this only when you need to defer the migration on existing deployments; new deployments should leave the flag at its default (`false`) to avoid the truncation/collision risk that motivated the 1.0.0 change.

> **Strongly recommended:** treat this flag as a temporary bridge, not a permanent setting. Plan and schedule a migration to the new layout (`use_legacy_pool_provider_id_format = false`) as soon as a maintenance window allows. Keeping the legacy layout long-term leaves the deployment exposed to the ID truncation and collision risk that the 1.0.0 change was designed to eliminate. Once migrated, remove the flag from the module call so the default applies.

### Recovering after an accidental upgrade

If you already ran `terraform apply` against the 1.0.0+ layout and need to roll back to the legacy IDs (or simply restore a destroyed deployment), keep in mind that Google Cloud **soft-deletes** workload identity pools and providers for **up to 30 days** ([reference](https://cloud.google.com/iam/docs/manage-workload-identity-pools-providers)). During that window the deleted ID cannot be reused, so a plain `terraform apply` will fail.

The recovery path is:

1. `gcloud iam workload-identity-pools undelete POOL_ID --location=global --project=PROJECT_ID`
2. `gcloud iam workload-identity-pools providers undelete PROVIDER_ID --workload-identity-pool=POOL_ID --location=global --project=PROJECT_ID`
3. `terraform import` the pool and provider into the module state, then re-run `terraform plan` to confirm no replacement is queued.

Full commands, address formats, and troubleshooting are in the ["Recovering a deleted workload identity pool or provider"](README.md#recovering-a-deleted-workload-identity-pool-or-provider) section of the README.
