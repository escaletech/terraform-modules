output "website_endpoint" {
  value = aws_s3_bucket.s3_bucket.website_endpoint
}

output "bucket_id" {
  value = aws_s3_bucket.s3_bucket.id
}