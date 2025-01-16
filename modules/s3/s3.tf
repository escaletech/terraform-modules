resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_policy" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.bucket
  policy = data.aws_iam_policy_document.s3_secure_policy.json
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  count = var.website_static ? 1 : 0

  bucket = aws_s3_bucket.s3_bucket.bucket

  dynamic "redirect_all_requests_to" {
    for_each = var.redirect ? [1] : []

    content {
      host_name = var.website_hostname
      protocol  = var.website_protocol
    }
  }

  dynamic "index_document" {
    for_each = var.index_document ? [1] : []

    content {
      suffix = var.website_index_document
    }
  }

  dynamic "error_document" {
    for_each = var.error_document ? [1] : []

    content {
      key = var.website_error_document
    }
  }


}

resource "aws_s3_bucket_acl" "static_website" {
  count = var.website_static_acl ? 1 : 0

  bucket = aws_s3_bucket.s3_bucket.bucket
  acl    = var.website_acl

  access_control_policy {
    grant {
      grantee {
        display_name = var.grantee_display_name
        id           = var.grantee_id
        type         = var.grantee_type
      }
      permission = var.grant_permission
    }
    owner {
      display_name = var.grantee_display_name
      id           = var.grantee_id
    }
  }
}