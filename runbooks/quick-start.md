# Quick start

## 1) Provision AWS
```bash
make apply
```

## 2) Migrate state to S3 backend
```bash
AWS_REGION=ap-southeast-6 terraform -chdir=terraform init -migrate-state
# Answer "yes" when prompted
```

## 3) Fetch writer credentials
```bash
export WRITER_SECRET_NAME=$(AWS_REGION=ap-southeast-6 terraform -chdir=terraform output -raw writer_secret_name)
aws secretsmanager get-secret-value \
  --secret-id "$WRITER_SECRET_NAME" \
  --region ap-southeast-6 \
  --query 'SecretString' \
  --output text | jq -r 'to_entries|map("\(.key)=\(.value)")|.[]' > .writer-credentials.env
```

**Note**: `.writer-credentials.env` contains sensitive AWS credentials and is gitignored.
