# Off‑Site Backups to AWS S3 + Glacier

Terraform-managed AWS infrastructure for backing up data to S3 with
Glacier/Deep Archive lifecycle policies.

This manages the historical Immich and Obsidian backup buckets.

Active database archives remain in their upload storage class. CNPG owns their
retention. S3 does not expire current or noncurrent objects in the application
backup prefixes. Media and historical Obsidian archive transitions remain in
place. Already archived objects still require a Glacier restore before reading;
this change does not retrieve or delete them. Keeping old versions can increase
storage cost. Review that cost before a separate, deliberate archive retirement.

To change lifecycle rules, make a saved Terraform plan with the normal environment
from `scripts/env.sh`. Keep the plan private because it contains state values.
Review `terraform show` and push the branch before applying. Then use the Soyspray
Ansible environment to apply only that reviewed plan:

```sh
ansible-playbook runbooks/apply-lifecycle.yml \
  -e lifecycle_plan=/private/lifecycle.tfplan \
  -e lifecycle_plan_sha256=<sha256-of-reviewed-plan> --check
# Repeat without --check to apply.
```

If a full plan contains unrelated changes, leave them for their own review. For
this isolated lifecycle repair, select only
`-target=aws_s3_bucket_lifecycle_configuration.backup` and
`-target=aws_s3_bucket_lifecycle_configuration.obsidian_backup` when saving the
plan. Read a full plan afterward and record any unrelated drift.

The operation accepts only in-place lifecycle updates to the two existing backup
buckets. Terraform retains its state lock. Verify the live rules and a no-change
plan afterward. Do not roll back by restoring automatic expiry or database
archive transitions; keep backup-tool retention in control.

## Quick Start

```bash
cp .env.example .env
make apply
```

For detailed setup instructions, see **[runbooks/quick-start.md](runbooks/quick-start.md)**.

## Documentation

- **[Quick Start Guide](runbooks/quick-start.md)** - Complete setup workflow
- **[Database Restore](runbooks/restore-db.md)** - Restore database from backup
- **[Media Restore](runbooks/restore-media.md)** - Restore media files from backup

## What This Provides

- S3 bucket with automated lifecycle policies for cost-effective archival
- IAM users with minimal required permissions (writer and restorer)
- Terraform state management with S3 backend
- Versioning and encryption enabled by default
