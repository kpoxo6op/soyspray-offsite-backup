# Off‑Site Backups to AWS S3 + Glacier

Terraform-managed AWS infrastructure for backing up data to S3 with
Glacier/Deep Archive lifecycle policies.

Currently, this is configured for Immich.

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
