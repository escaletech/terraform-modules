resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  block_public_acls = true
  block_public_policy = false
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.bucket
  policy = data.aws_iam_policy_document.s3_secure_policy.json
}

resource "aws_iam_policy_attachment" "secure_policy_attachment" {
  name       = "${var.bucket_name}-policy-attachment"
  policy_arn = aws_iam_policy.s3_secure_policy.arn
  users      = []
  roles      = []
}