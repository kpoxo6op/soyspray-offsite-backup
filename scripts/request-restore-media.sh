#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
SUB="${1:-}"
SCOPE_PREFIX="${MEDIA_PREFIX}${SUB}"
aws s3api list-objects-v2 --bucket "${BUCKET_NAME}" --prefix "${SCOPE_PREFIX}" --query 'Contents[].Key' --output text | tr '\t' '\n' | while read -r KEY; do
  aws s3api restore-object \
    --bucket "${BUCKET_NAME}" \
    --key "${KEY}" \
    --restore-request "{\"Days\":${GLACIER_RESTORE_DAYS},\"GlacierJobParameters\":{\"Tier\":\"${GLACIER_RESTORE_TIER}\"}}" || true
done
echo "${SCOPE_PREFIX}"

