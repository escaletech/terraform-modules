resource "aws_s3_bucket" "cloudfront-logs" {
  bucket = var.bucket_logs_name != null ? var.bucket_logs_name : "${var.host}-cloudfront-logs"
  tags   = var.tags
}

resource "aws_s3_bucket_acl" "cloudfront-logs" {
  bucket = aws_s3_bucket.cloudfront-logs.bucket
  acl    = "private"
}
