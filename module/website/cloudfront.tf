locals {
  origin_id = "Custom-${var.origin_host}"
}

// Create CloudFront distribution
resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  aliases         = [var.host]
  tags            = var.tags
  is_ipv6_enabled = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
  }

  logging_config {
    bucket          = "escale-cloudfront-logs.s3.amazonaws.com"
    include_cookies = false
    prefix          = "cloudfront"
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 500
    response_code         = 0
  }

  origin {
    domain_name = var.origin_host
    origin_id   = local.origin_id

    custom_header {
      name  = "X-CloudFront-Forwarded-Proto"
      value = "https"
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_protocol_policy = "http-only"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.origin_id

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers      = [
        "Host",
        "Origin",
        "X-Request-Id",
        "X-Session-Id",
        "Authorization",
        "Access-Control-Request-Headers",
        "Access-Control-Request-Method"
      ]

      cookies {
        forward           = "whitelist"
        whitelisted_names = [
          "io.prismic.preview",
          "session",
          "session.sig"
        ]
      }
    }
  }
}
