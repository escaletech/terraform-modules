data "aws_cloudfront_cache_policy" "main" {
  name = var.cache_policy_name
}

resource "aws_cloudfront_distribution" "main" {
  depends_on = [
    aws_s3_bucket.internal
  ]
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["${var.domain}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    include_cookies = true
    bucket          = aws_s3_bucket.internal-logs.bucket_domain_name
  }

  origin {
    domain_name = aws_s3_bucket.internal.website_endpoint
    origin_id   = var.domain

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
      origin_protocol_policy = "http-only"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.domain
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.main.id
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.certificate.arn
    ssl_support_method  = "sni-only"
  }
}
