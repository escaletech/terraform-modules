resource "aws_s3_bucket" "internal-logs" {
  bucket = "${var.domain}-logs"
  tags   = var.tags
}

resource "aws_s3_bucket_ownership_controls" "internal_logs" {
  bucket = aws_s3_bucket.internal_logs.id
  rule { object_ownership = "ObjectWriter" }
}

resource "aws_s3_bucket_acl" "internal-logs" {
  bucket = aws_s3_bucket.internal-logs.bucket
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "internal" {
  bucket = var.domain
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "internal" {
  bucket                  = aws_s3_bucket.internal.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
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

    sid       = "PublicReadVpce"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.internal.arn}/*"]
    effect    = "Allow"

    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.internal.id]
    }
  }

  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    sid       = "DenyPublicReadNonVpce"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.internal.arn}/*"]
    effect    = "Deny"

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.internal.id]
    }
  }
}
