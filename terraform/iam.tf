# terraform/iam.tf
resource "aws_iam_user" "writer" {
  name          = var.writer_username
  force_destroy = true
  tags          = local.tags
}

resource "aws_iam_user" "restorer" {
  name          = var.restorer_username
  force_destroy = true
  tags          = local.tags
}

data "aws_iam_policy_document" "writer" {
  statement {
    sid     = "ListBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.backup.arn
    ]
  }
  statement {
    sid    = "WriteObjects"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload",
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.backup.arn}/*"
    ]
  }
  statement {
    sid    = "DenyDeletes"
    effect = "Deny"
    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
    resources = [
      "${aws_s3_bucket.backup.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "writer" {
  name        = "${var.writer_username}-s3-write"
  description = "Put-only access to backup bucket prefixes"
  policy      = data.aws_iam_policy_document.writer.json
  tags        = local.tags
}

resource "aws_iam_user_policy_attachment" "writer" {
  user       = aws_iam_user.writer.name
  policy_arn = aws_iam_policy.writer.arn
}

data "aws_iam_policy_document" "restorer" {
  statement {
    sid     = "ListBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.backup.arn
    ]
  }
  statement {
    sid    = "ReadAndRestore"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:RestoreObject"
    ]
    resources = [
      "${aws_s3_bucket.backup.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "restorer" {
  name        = "${var.restorer_username}-s3-read"
  description = "Read and restore access to backup bucket prefixes"
  policy      = data.aws_iam_policy_document.restorer.json
  tags        = local.tags
}

resource "aws_iam_user_policy_attachment" "restorer" {
  user       = aws_iam_user.restorer.name
  policy_arn = aws_iam_policy.restorer.arn
}

resource "aws_iam_access_key" "writer" {
  user = aws_iam_user.writer.name
}

