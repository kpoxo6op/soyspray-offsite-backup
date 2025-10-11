variable "aws_region" {
  type        = string
  description = "AWS region for all resources"
}

variable "bucket_name" {
  type        = string
  description = "Globally-unique S3 bucket name for Immich backups"
}

variable "bucket_force_destroy" {
  type        = bool
  default     = false
  description = "Allow terraform destroy to remove bucket with objects"
}

variable "enable_versioning" {
  type        = bool
  default     = true
  description = "Enable S3 versioning for safety"
}

variable "db_prefix" {
  type        = string
  default     = "immich/db/"
  description = "Prefix for DB backups"
}

variable "media_prefix" {
  type        = string
  default     = "immich/media/"
  description = "Prefix for media backups"
}

variable "db_to_glacier_days" {
  type        = number
  default     = 7
  description = "Days before DB transitions to Glacier (Flexible Retrieval)"
}

variable "db_to_deep_archive_days" {
  type        = number
  default     = 97
  description = "Days before DB transitions from Glacier to Deep Archive"
}

variable "media_to_deep_archive_days" {
  type        = number
  default     = 0
  description = "Days before media transitions to Deep Archive"
}

variable "noncurrent_to_deep_archive_days" {
  type        = number
  default     = 1
  description = "Days before noncurrent versions transition to Deep Archive (minimum 1)"
}

variable "noncurrent_expire_days" {
  type        = number
  default     = 90
  description = "Days before noncurrent versions expire"
}

variable "writer_username" {
  type        = string
  default     = "immich-writer"
  description = "IAM user for cluster backup jobs"
}

variable "restorer_username" {
  type        = string
  default     = "immich-restorer"
  description = "IAM user for restore operations"
}

variable "writer_secret_name" {
  type        = string
  default     = "soyspray/offsite/immich-writer"
  description = "AWS Secrets Manager secret name for immich-writer credentials"
}
