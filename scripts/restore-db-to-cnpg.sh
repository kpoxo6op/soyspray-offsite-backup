#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
KEY="${1:-}"
if [[ -z "${KEY}" ]]; then
  KEY=$(aws s3api list-objects-v2 \
    --bucket "${BUCKET_NAME}" \
    --prefix "${DB_PREFIX}" \
    --query 'reverse(sort_by(Contents,&LastModified))[0].Key' \
    --output text)
fi
while true; do
  RESTORE=$(aws s3api head-object --bucket "${BUCKET_NAME}" --key "${KEY}" --query 'Restore' --output text || true)
  [[ "${RESTORE}" == *'ongoing-request="false"'* ]] && break
  sleep 60
done
PRIMARY_POD=$(kubectl -n "${DB_NAMESPACE}" get pods -l "cnpg.io/cluster=${DB_CLUSTER_NAME},role=primary" -o jsonpath='{.items[0].metadata.name}')
aws s3 cp "s3://${BUCKET_NAME}/${KEY}" - | zstd -d | kubectl -n "${DB_NAMESPACE}" exec -i "${PRIMARY_POD}" -- psql -U "${DB_USER}" -d "${DB_NAME}"

