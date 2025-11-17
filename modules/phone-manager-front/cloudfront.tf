data "aws_cloudfront_cache_policy" "main" {
  name = var.cache_policy_name
}

resource "aws_cloudfront_origin_access_control" "main" {
  count = var.origin_access_control ? 1 : 0

  name                              = var.domain
  description                       = "Access control for ${var.domain} S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main" {
  depends_on = [
    aws_s3_bucket.internal,
    aws_cloudfront_origin_access_control.main
  ]
  enabled         = true
  is_ipv6_enabled = true
  # Avoid appending index.html when the bucket only issues redirects
  default_root_object = var.s3_redirect_enabled ? null : "index.html"
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
    domain_name              = var.origin_access_control ? aws_s3_bucket.internal.bucket_regional_domain_name : aws_s3_bucket_website_configuration.internal.website_endpoint
    origin_id                = var.domain
    origin_access_control_id = var.origin_access_control ? aws_cloudfront_origin_access_control.main[0].id : null

    dynamic "custom_origin_config" {
      for_each = var.origin_access_control ? [] : [1]
      content {
        http_port              = 80
        https_port             = 443
        origin_ssl_protocols   = ["TLSv1.2"]
        origin_protocol_policy = "http-only"
      }
    }

    dynamic "s3_origin_config" {
      for_each = var.origin_access_control ? [1] : []
      content {
        origin_access_identity = ""
      }
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.domain
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = data.aws_cloudfront_cache_policy.main.id
  }

  dynamic "custom_error_response" {
    # When using OAC with the REST endpoint, S3 returns AccessDenied for SPA routes;
    # serve index.html instead so client-side routing continues to work.
    for_each = var.s3_redirect_enabled ? [] : [403, 404]
    content {
      error_code            = custom_error_response.value
      response_code         = 200
      response_page_path    = "/index.html"
      error_caching_min_ttl = 0
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.certificate.arn
    ssl_support_method  = "sni-only"
  }
}
