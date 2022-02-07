resource "aws_s3_bucket" "cloudfront-logs" {
  bucket = var.bucket_logs_name != null ? var.bucket_logs_name : "${var.host}-cloudfront-logs"
  acl    = "private"
  tags   = var.tags
}
