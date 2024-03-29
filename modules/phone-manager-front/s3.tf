resource "aws_s3_bucket" "internal-logs" {
  bucket = "${var.domain}-logs"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "public_access_internal_logs" {
  bucket = aws_s3_bucket.internal-logs.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "internal" {
  bucket = var.domain
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "public_access_internal" {
  bucket = aws_s3_bucket.internal.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "internal" {
  bucket = aws_s3_bucket.internal.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_logging" "internal" {
  bucket = aws_s3_bucket.internal.bucket

  target_bucket = aws_s3_bucket.internal-logs.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_policy" "internal" {
  bucket = aws_s3_bucket.internal.bucket
  policy = data.aws_iam_policy_document.internal.json
}

data "aws_iam_policy_document" "internal" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    sid       = "PublicRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.internal.arn}/*"]
    effect    = "Allow"
  }
}

resource "aws_s3_bucket_acl" "acl-internal-log" {
  bucket = aws_s3_bucket.internal-logs.bucket
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "owner-internal-log" {
  bucket = aws_s3_bucket.internal-logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
