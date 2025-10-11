# Restore Immich database (CNPG) from S3 + Glacier

## 0) Environment
```bash
source scripts/env.sh
kubectl -n "${DB_NAMESPACE}" get pods
```

## 1) Identify the latest backup key
```bash
LATEST_KEY=$(aws s3api list-objects-v2 \
  --bucket "${BUCKET_NAME}" \
  --prefix "${DB_PREFIX}" \
  --query 'reverse(sort_by(Contents,&LastModified))[0].Key' \
  --output text)
echo "${LATEST_KEY}"
```

## 2) Request Glacier restore if needed
```bash
aws s3api restore-object \
  --bucket "${BUCKET_NAME}" \
  --key "${LATEST_KEY}" \
  --restore-request "{\"Days\":${GLACIER_RESTORE_DAYS},\"GlacierJobParameters\":{\"Tier\":\"${GLACIER_RESTORE_TIER}\"}}"
```

## 3) Wait until rehydration completes
```bash
while true; do
  RESTORE=$(aws s3api head-object --bucket "${BUCKET_NAME}" --key "${LATEST_KEY}" --query 'Restore' --output text || true)
  [[ "${RESTORE}" == *'ongoing-request="false"'* ]] && break
  sleep 60
done
```

## 4) Stream restore into CNPG primary
```bash
PRIMARY_POD=$(kubectl -n "${DB_NAMESPACE}" get pods -l "cnpg.io/cluster=${DB_CLUSTER_NAME},role=primary" -o jsonpath='{.items[0].metadata.name}')
aws s3 cp "s3://${BUCKET_NAME}/${LATEST_KEY}" - | zstd -d | kubectl -n "${DB_NAMESPACE}" exec -i "${PRIMARY_POD}" -- psql -U "${DB_USER}" -d "${DB_NAME}"
```

## 5) Verify
```bash
kubectl -n "${DB_NAMESPACE}" exec -it "${PRIMARY_POD}" -- psql -U "${DB_USER}" -d "${DB_NAME}" -c 'SELECT NOW();'
```


