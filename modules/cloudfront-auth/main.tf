locals {
  source_zip = "${path.root}/${var.lambda_file}"
}

#
# S3
#
resource "aws_s3_bucket" "default" {
  bucket = var.bucket_name
  acl    = "private"
  tags   = var.tags

  dynamic "cors_rule" {
    for_each = var.cors_rule == null ? [] : [var.cors_rule]
    content {
      allowed_headers = var.cors_rule.allowed_headers
      allowed_methods = var.cors_rule.allowed_methods
      allowed_origins = var.cors_rule.allowed_origins
      expose_headers  = var.cors_rule.expose_headers
    }
  }

  dynamic "website" {
    for_each = var.website == null ? [] : [var.website]
    content {
      index_document = var.website.index_document
      error_document = var.website.error_document
    }
  }
}

# Block direct public access
resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.default.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.default.arn}/*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.default.iam_arn,
      ]
    }
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.default.arn,
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.default.iam_arn,
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.default.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

#
# Cloudfront
#
resource "aws_cloudfront_origin_access_identity" "default" {
  comment = var.bucket_name
}

resource "aws_cloudfront_distribution" "default" {
  origin {
    domain_name = var.website == null ? aws_s3_bucket.default.bucket_regional_domain_name : aws_s3_bucket.default.website_endpoint
    origin_id   = local.s3_origin_id

    dynamic "custom_origin_config" {
      for_each = var.website == null ? [] : ["enable_website"]
      content {
        http_port              = "80"
        https_port             = "443"
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }

    dynamic "s3_origin_config" {
      for_each = var.website == null ? ["disable_website"] : []
      content {
        origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
      }
    }
  }

  aliases = concat([var.cloudfront_distribution], [var.bucket_name], var.cloudfront_aliases)

  comment             = "Managed by Terraform"
  default_root_object = null
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = var.cloudfront_price_class
  tags                = var.tags

  default_cache_behavior {
    target_origin_id = local.s3_origin_id

    // Read only
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    forwarded_values {
      query_string = false
      headers = [
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method",
        "Origin"
      ]

      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = aws_lambda_function.default.qualified_arn
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  # Handle the case where no certificate ARN provided
  dynamic "viewer_certificate" {
    for_each = (var.cloudfront_acm_certificate_arn == null ? { use_acm = false } : {})

    content {
      ssl_support_method             = "sni-only"
      cloudfront_default_certificate = true
    }
  }

  # Handle the case where certificate ARN was provided
  dynamic "viewer_certificate" {
    for_each = (var.cloudfront_acm_certificate_arn != null ? { use_acm = true } : {}
    )
    content {
      ssl_support_method             = "sni-only"
      acm_certificate_arn            = var.cloudfront_acm_certificate_arn
      cloudfront_default_certificate = false
    }
  }
}

#
# Lambda
#
data "aws_iam_policy_document" "lambda_log_access" {
  // Allow lambda access to logging
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:*:*:*",
    ]

    effect = "Allow"
  }
}

# This function is created in us-east-1 as required by CloudFront.
resource "aws_lambda_function" "default" {
  provider = aws.us-east-1

  description      = "Managed by Terraform"
  runtime          = "nodejs12.x"
  role             = aws_iam_role.lambda_role.arn
  filename         = local.source_zip
  function_name    = "cloudfront_auth"
  handler          = "index.handler"
  publish          = true
  timeout          = 5
  source_code_hash = filebase64sha256(local.source_zip)
  tags             = var.tags
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Attach the logging access document to the above role.
resource "aws_iam_role_policy_attachment" "lambda_log_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_log_access.arn
}

# Create an IAM policy that will be attached to the role
resource "aws_iam_policy" "lambda_log_access" {
  name   = "cloudfront_auth_lambda_log_access"
  policy = data.aws_iam_policy_document.lambda_log_access.json
}
