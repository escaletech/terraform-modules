resource "aws_s3_bucket" "bucket-saas" {
  bucket = var.s3_name
  tags = {
    Name = var.s3_name
  }
}

resource "aws_s3_bucket_public_access_block" "bucket-saas" {
  bucket                  = aws_s3_bucket.bucket-saas.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "role-bucket-saas" {
  name = "${var.s3_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "policy-bucket-saas" {
  name = "${var.s3_name}-policy"

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
          "arn:aws:s3:::${var.s3_name}/*",
          "arn:aws:s3:::${var.s3_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment-bucket-saas" {
  role       = aws_iam_role.role-bucket-saas.name
  policy_arn = aws_iam_policy.policy-bucket-saas.arn
}