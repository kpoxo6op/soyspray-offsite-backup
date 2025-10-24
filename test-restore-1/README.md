# Test Restore

Restore the latest DB and full media from S3 as an exercise.

## DB

Screenshoted the immich GUI dated 2025-10-24 around 16:00

Emptied immich namespace. Deleted immich and immich DB, deleted immich backup app too

Recreated the empty immich DB.

Verified .ENV matches the empty restored DB, verified connection to the empty restored DB.

```bash
source scripts/env.sh
kubectl -n "${DB_NAMESPACE}" exec "${DB_CLUSTER_NAME}-1" -- env PGPASSWORD=immich psql -h localhost -U "${DB_USER}" -d "${DB_NAME}" -c 'SELECT current_user, current_database(), NOW();'
```

Checked S3 bucket DB backup status: 433 STANDARD, 187 GLACIER (no DEEP_ARCHIVE found). Recent backups are in STANDARD storage, older ones transitioned to GLACIER as expected.

```bash
source scripts/env.sh
aws s3api list-objects-v2 --bucket "${BUCKET_NAME}" --prefix "${DB_PREFIX}" --query 'Contents[].StorageClass' --output text | tr '\t' '\n' | sort | uniq -c | sort -nr
```

Identified latest backup key

```bash
source scripts/env.sh
LATEST_KEY=$(aws s3api list-objects-v2 --bucket "${BUCKET_NAME}" --prefix "${DB_PREFIX}" --query 'reverse(sort_by(Contents,&LastModified))[0].Key' --output text)
echo "${LATEST_KEY}"
```
Result: `immich/db/immich-db/wals/0000000100000003/0000000100000003000000E3`

Checked storage class of latest backup

```bash
aws s3api head-object --bucket "${BUCKET_NAME}" --key "${LATEST_KEY}" --query 'StorageClass' --output text
```
Result: `None` (STANDARD storage - no Glacier restore needed)

Extracted restorer credentials

```bash
source scripts/env.sh
echo "OFFSITE_BACKUP_RESTORER_AWS_ACCESS_KEY_ID=$(terraform -chdir=terraform output -raw restorer_access_key_id)" > .restorer-credentials.env
echo "OFFSITE_BACKUP_RESTORER_AWS_SECRET_ACCESS_KEY=$(terraform -chdir=terraform output -raw restorer_secret_access_key)" >> .restorer-credentials.env
cat .restorer-credentials.env
```

Created a new cluster from backup using `recovery` bootstrap method in soyspray repo.

See details soyspray repo -> cnpg docs how to do this.

ABORTED - the DB restored incrorrect DB name, will start over.

Buckets were emptied as junk data, will start over.
