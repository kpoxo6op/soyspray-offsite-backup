# Quick start

## 1) Provision AWS
```bash
make apply
```

## 2) Migrate state to S3 backend
```bash
source scripts/env.sh
terraform -chdir=terraform init -migrate-state
# Answer "yes" when prompted
```

## 3) Fetch writer credentials

**Note**: Secrets Manager is disabled to save ~$0.40/month. Credentials are stored in Terraform state.

```bash
source scripts/env.sh

# Extract credentials from Terraform state
terraform -chdir=terraform state show aws_iam_access_key.writer | \
  awk '/^id =/ {print "AWS_ACCESS_KEY_ID=" $3} /^secret =/ {print "AWS_SECRET_ACCESS_KEY=" $3}' | \
  tr -d '"' > .writer-credentials.env

# Add region and bucket info
echo "AWS_REGION=${AWS_REGION}" >> .writer-credentials.env
echo "BUCKET_NAME=${BUCKET_NAME}" >> .writer-credentials.env
echo "DB_PREFIX=${DB_PREFIX}" >> .writer-credentials.env
echo "MEDIA_PREFIX=${MEDIA_PREFIX}" >> .writer-credentials.env

cat .writer-credentials.env
```

**Note**: `.writer-credentials.env` contains sensitive AWS credentials and is gitignored.
