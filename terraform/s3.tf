resource "aws_s3_bucket" "backup" {
  bucket        = var.bucket_name
  force_destroy = var.bucket_force_destroy
  tags          = local.tags
}

resource "aws_s3_bucket_ownership_controls" "backup" {
  bucket = aws_s3_bucket.backup.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket                  = aws_s3_bucket.backup.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "backup" {
  bucket = aws_s3_bucket.backup.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

data "aws_iam_policy_document" "tls_only" {
  statement {
    sid     = "HttpsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.backup.arn,
      "${aws_s3_bucket.backup.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "backup" {
  bucket = aws_s3_bucket.backup.id
  policy = data.aws_iam_policy_document.tls_only.json
}

resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id     = "db-tiering"
    status = "Enabled"

    filter {
      prefix = var.db_prefix
    }

    transition {
      days          = var.db_to_glacier_days
      storage_class = "GLACIER"
    }

    transition {
      days          = var.db_to_deep_archive_days
      storage_class = "DEEP_ARCHIVE"
    }

    noncurrent_version_transition {
      noncurrent_days = var.noncurrent_to_deep_archive_days
      storage_class   = "DEEP_ARCHIVE"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_expire_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "media-deep-archive-immediate"
    status = "Enabled"

    filter {
      prefix = var.media_prefix
    }

    transition {
      days          = var.media_to_deep_archive_days
      storage_class = "DEEP_ARCHIVE"
    }

    noncurrent_version_transition {
      noncurrent_days = var.noncurrent_to_deep_archive_days
      storage_class   = "DEEP_ARCHIVE"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_expire_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Obsidian LiveSync Backup Bucket
resource "aws_s3_bucket" "obsidian_backup" {
  bucket        = var.obsidian_bucket_name
  force_destroy = var.bucket_force_destroy
  tags          = local.tags
}

resource "aws_s3_bucket_ownership_controls" "obsidian_backup" {
  bucket = aws_s3_bucket.obsidian_backup.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "obsidian_backup" {
  bucket                  = aws_s3_bucket.obsidian_backup.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "obsidian_backup" {
  bucket = aws_s3_bucket.obsidian_backup.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "obsidian_backup" {
  bucket = aws_s3_bucket.obsidian_backup.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

data "aws_iam_policy_document" "obsidian_tls_only" {
  statement {
    sid     = "HttpsOnly"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.obsidian_backup.arn,
      "${aws_s3_bucket.obsidian_backup.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "obsidian_backup" {
  bucket = aws_s3_bucket.obsidian_backup.id
  policy = data.aws_iam_policy_document.obsidian_tls_only.json
}

resource "aws_s3_bucket_lifecycle_configuration" "obsidian_backup" {
  bucket = aws_s3_bucket.obsidian_backup.id

  rule {
    id     = "obsidian-deep-archive"
    status = "Enabled"

    filter {
      prefix = var.obsidian_prefix
    }

    transition {
      days          = var.obsidian_to_deep_archive_days
      storage_class = "DEEP_ARCHIVE"
    }

    noncurrent_version_transition {
      noncurrent_days = var.noncurrent_to_deep_archive_days
      storage_class   = "DEEP_ARCHIVE"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_expire_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

