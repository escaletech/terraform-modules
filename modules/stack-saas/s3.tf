resource "aws_s3_bucket" "bucket-saas" {
  count  = var.create_s3 ? 1 : 0
  bucket = local.s3_name
  tags   = merge(var.tags, { Name = local.s3_name })
}

resource "aws_s3_bucket_public_access_block" "bucket-saas" {
  count                   = var.create_s3 ? 1 : 0
  bucket                  = aws_s3_bucket.bucket-saas[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "policy-bucket-saas" {
  count = var.create_s3 ? 1 : 0
  name  = "${local.s3_name}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${local.s3_name}/*",
          "arn:aws:s3:::${local.s3_name}"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "bucket-saas-policy" {
  count  = var.create_s3 ? 1 : 0
  bucket = aws_s3_bucket.bucket-saas[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_role.arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${local.s3_name}",
          "arn:aws:s3:::${local.s3_name}/*"
        ]
      }
    ]
  })
}
