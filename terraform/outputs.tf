output "bucket_name" {
  value       = aws_s3_bucket.backup.bucket
  description = "Backup bucket name"
}

output "bucket_arn" {
  value       = aws_s3_bucket.backup.arn
  description = "Backup bucket ARN"
}

output "restorer_user" {
  value       = aws_iam_user.restorer.name
  description = "IAM username for restore operations"
}

# Secrets Manager disabled to save $0.40/month
# Use manual credential retrieval via Terraform state instead
# output "writer_secret_name" {
#   value       = aws_secretsmanager_secret.writer.name
#   description = "Secrets Manager secret name for immich-writer credentials"
# }

# output "writer_secret_arn" {
#   value       = aws_secretsmanager_secret.writer.arn
#   description = "Secrets Manager secret ARN for immich-writer credentials"
# }

output "terraform_state_bucket" {
  value       = aws_s3_bucket.terraform_state.id
  description = "S3 bucket for Terraform state"
}

output "terraform_state_lock_table" {
  value       = aws_dynamodb_table.terraform_state_lock.id
  description = "DynamoDB table for Terraform state locking"
}
