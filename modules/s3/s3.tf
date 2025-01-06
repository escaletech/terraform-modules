resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  block_public_acls = var.block_public_acls
  block_public_policy = var.block_public_policy
  ignore_public_acls = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_policy" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.bucket
  policy = data.aws_iam_policy_document.s3_secure_policy.json
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  count = var.website_static ? 1 : 0

  bucket = aws_s3_bucket.s3_bucket.bucket

  redirect_all_requests_to {
    host_name = var.website_hostname
    protocol  = var.website_protocol
  }
}

resource "aws_s3_bucket_acl" "static_website" {
  count  = var.website_static ? 1 : 0

  bucket = aws_s3_bucket.s3_bucket.bucket
  acl    = var.website_acl
}