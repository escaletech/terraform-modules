resource "aws_s3_bucket" "internal-logs" {
  bucket = "${var.domain}-logs"
  acl    = "log-delivery-write"
  tags   = var.tags
}

resource "aws_s3_bucket" "internal" {
  bucket = var.domain
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  logging {
    target_bucket = aws_s3_bucket.internal-logs.id
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${title(var.app_name)}InternalTestPolicy"
    Statement = [
      {
        Sid       = "PublicReadVpce"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource = [
          "arn:aws:s3:::${var.domain}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = aws_vpc_endpoint.internal.id
          }
        }
      },
      {
        Sid       = "DenyPublicReadNonVpce"
        Effect    = "Deny"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource = [
          "arn:aws:s3:::${var.domain}/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = aws_vpc_endpoint.internal.id
          }
        }
      }
    ]
  })

  tags = var.tags
}
