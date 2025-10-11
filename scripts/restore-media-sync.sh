#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
SUB="${1:-}"
SCOPE_PREFIX="${MEDIA_PREFIX}${SUB}"
pending=1
while [[ $pending -eq 1 ]]; do
  pending=0
  for KEY in $(aws s3api list-objects-v2 --bucket "${BUCKET_NAME}" --prefix "${SCOPE_PREFIX}" --query 'Contents[].Key' --output text); do
    RESTORE=$(aws s3api head-object --bucket "${BUCKET_NAME}" --key "${KEY}" --query 'Restore' --output text || true)
    if [[ "${RESTORE}" != *'ongoing-request="false"'* ]]; then pending=1; fi
  done
  [[ $pending -eq 1 ]] && sleep 120
done
aws s3 sync "s3://${BUCKET_NAME}/${SCOPE_PREFIX}" "${RESTORE_MEDIA_TARGET_DIR}"

