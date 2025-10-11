#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
aws s3api list-objects-v2 \
  --bucket "${BUCKET_NAME}" \
  --prefix "${DB_PREFIX}" \
  --query 'reverse(sort_by(Contents,&LastModified))[:10].[LastModified,Key]' \
  --output table

