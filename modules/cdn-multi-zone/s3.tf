resource "aws_s3_bucket" "cloudfront-logs" {
  bucket = var.bucket_logs_name != null ? var.bucket_logs_name : "${var.host}-cloudfront-logs"
  tags   = var.tags
}

resource "aws_s3_bucket_ownership_controls" "cloudfront-logs-ownership" {
  bucket = aws_s3_bucket.cloudfront-logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "cloudfront-logs" {
  depends_on = [aws_s3_bucket_ownership_controls.cloudfront-logs-ownership]

  bucket = aws_s3_bucket.cloudfront-logs.bucket
  acl    = "private"
}
