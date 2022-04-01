resource "aws_s3_bucket" "internal-logs" {
  bucket = "${var.domain}-logs"
  acl    = "log-delivery-write"
  tags   = var.tags
}

resource "aws_s3_bucket_acl" "internal-logs" {
  bucket = aws_s3_bucket.internal-logs.bucket
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket" "internal" {
  bucket = var.domain
  tags   = var.tags
}

resource "aws_s3_bucket_acl" "internal" {
  bucket = aws_s3_bucket.internal.bucket
  acl    = "private"
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
  bucket        = aws_s3_bucket.internal.bucket
  target_bucket = aws_s3_bucket.internal-logs.id
}

resource "aws_s3_bucket_policy" "internal" {
  bucket = aws_s3_bucket.internal.bucket
  policy = data.aws_iam_policy_document.internal
}

data "aws_iam_policy_document" "internal" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    sid       = "PublicReadVpce"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_website.arn}/*"]
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
    resources = ["${aws_s3_bucket.static_website.arn}/*"]
    effect    = "Deny"

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.internal.id]
    }
  }
}
