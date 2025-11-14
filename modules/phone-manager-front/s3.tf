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

  block_public_acls       = var.origin_access_control ? true : true
  block_public_policy     = var.origin_access_control ? true : false
  ignore_public_acls      = var.origin_access_control ? true : false
  restrict_public_buckets = var.origin_access_control ? true : false
}

resource "aws_s3_bucket_website_configuration" "internal" {
  bucket = aws_s3_bucket.internal.bucket

  dynamic "index_document" {
    for_each = var.s3_redirect_enabled ? [] : [1]
    content {
      suffix = "index.html"
    }
  }

  dynamic "error_document" {
    for_each = var.s3_redirect_enabled ? [] : [1]
    content {
      key = "index.html"
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.s3_redirect_enabled && var.s3_redirect_path == null ? [1] : []
    content {
      host_name = var.s3_redirect_host_name
      protocol  = var.s3_redirect_protocol
    }
  }

  dynamic "routing_rule" {
    for_each = var.s3_redirect_enabled && var.s3_redirect_path != null ? [1] : []
    content {
      redirect {
        host_name          = var.s3_redirect_host_name
        protocol           = var.s3_redirect_protocol
        replace_key_with   = var.s3_redirect_path
        http_redirect_code = var.s3_redirect_http_code
      }
    }
  }

  lifecycle {
    precondition {
      condition     = !var.s3_redirect_enabled || var.s3_redirect_host_name != null
      error_message = "s3_redirect_host_name must be provided when s3_redirect_enabled is true."
    }
  }
}

resource "aws_s3_bucket_logging" "internal" {
  bucket = aws_s3_bucket.internal.bucket

  target_bucket = aws_s3_bucket.internal-logs.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_policy" "internal" {
  bucket = aws_s3_bucket.internal.bucket
  policy = var.origin_access_control ? data.aws_iam_policy_document.access_origin_control[0].json : data.aws_iam_policy_document.internal.json
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
