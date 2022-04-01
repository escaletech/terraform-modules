resource "aws_s3_bucket" "internal-logs" {
  bucket = "${var.domain}-logs"
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
    key = "error.html"
  }
}

resource "aws_s3_bucket_logging" "internal" {
  bucket = aws_s3_bucket.internal.id

  target_bucket = aws_s3_bucket.internal-logs.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_policy" "internal" {
  bucket = aws_s3_bucket.internal.id
  policy = data.aws_iam_policy_document.internal.json
}

data "aws_iam_policy_document" "internal" {
  policy_id = "${title(var.app_name)}InternalTestPolicy"
  statement {
    sid    = "PublicReadVpce"
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.internal.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.internal.id]
    }
  }

  statement {
    sid    = "DenyPublicReadNonVpce"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.internal.arn}/*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.internal.id]
    }
  }
}
