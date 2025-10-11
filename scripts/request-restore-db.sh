#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
LATEST_KEY=$(aws s3api list-objects-v2 \
  --bucket "${BUCKET_NAME}" \
  --prefix "${DB_PREFIX}" \
  --query 'reverse(sort_by(Contents,&LastModified))[0].Key' \
  --output text)
aws s3api restore-object \
  --bucket "${BUCKET_NAME}" \
  --key "${LATEST_KEY}" \
  --restore-request "{\"Days\":${GLACIER_RESTORE_DAYS},\"GlacierJobParameters\":{\"Tier\":\"${GLACIER_RESTORE_TIER}\"}}"
echo "${LATEST_KEY}"

