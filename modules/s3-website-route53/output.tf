output "s3-internal" {
  description = "Bucket name"
  value       = aws_s3_bucket.internal.bucket
}
