locals {
  origin_id        = "Custom-${var.origin_host}"
  certificate_arn  = var.create_certificate ? aws_acm_certificate_validation.cert[0].certificate_arn : var.certificate_arn
}

data "aws_cloudfront_cache_policy" "main" {
  name = var.cache_policy_name
}

data "aws_cloudfront_response_headers_policy" "x_frame_options" {
  name = "x_frame_options"
}



resource "aws_cloudfront_distribution" "main" {
  enabled         = true
  aliases         = length(var.custom_cname) > 0 ? var.custom_cname : [var.host]
  tags            = var.tags
  is_ipv6_enabled = true
  web_acl_id      = var.web_acl_id

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    ssl_support_method       = "sni-only"
    acm_certificate_arn      = local.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
  }

  logging_config {
    bucket          = aws_s3_bucket.cloudfront-logs.bucket_domain_name
    include_cookies = true
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 500
    response_code         = 0
  }

  dynamic "custom_error_response" {
    for_each = var.additional_error_responses
    iterator = er
    content {
      error_caching_min_ttl = er.value.error_caching_min_ttl
      error_code            = er.value.error_code
      response_code         = er.value.response_code
      response_page_path    = er.value.response_page_path
    }
  }

  origin {
    domain_name = var.origin_host
    origin_id   = (var.origin_id != null) ? var.origin_id : local.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = var.origin_ssl_protocols
      origin_protocol_policy = var.origin_protocol_policy
    }
  }

  dynamic "origin" {
    for_each = var.dynamic_origins
    iterator = or
    content {
      domain_name = or.value["host"]
      origin_id   = "Custom-${or.value["host"]}"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_ssl_protocols   = ["TLSv1.2"]
        origin_protocol_policy = or.value["origin_protocol_policy"]
      }
    }
  }

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT", "DELETE"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    target_origin_id           = (var.origin_id != null) ? var.origin_id : local.origin_id
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id            = data.aws_cloudfront_cache_policy.main.id
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.x_frame_options.id


    dynamic "function_association" {
      for_each = var.functions
      content {
        event_type   = function_association.value["event_type"]
        function_arn = function_association.value["arn"]
      }
    }
    dynamic "lambda_function_association" {
      for_each = var.lambda_functions
      content {
        event_type   = lambda_function_association.value["event_type"]
        lambda_arn   = lambda_function_association.value["lambda_arn"]
        include_body = lambda_function_association.value["include_body"]
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.dynamic_behavior
    iterator = db
    content {
      path_pattern           = db.value.path_pattern
      allowed_methods        = db.value.allowed_methods
      cached_methods         = db.value.cached_methods
      target_origin_id       = "Custom-${db.value.target_origin_id}"
      compress               = lookup(db.value, "compress", null)
      viewer_protocol_policy = db.value.viewer_protocol_policy

      cache_policy_id          = lookup(db.value, "cache_policy_id", null)
      origin_request_policy_id = lookup(db.value, "origin_request_policy_id", null)
      dynamic "lambda_function_association" {
        iterator = lambda
        for_each = lookup(db.value, "lambda_function_association", [])
        content {
          event_type   = lambda.value.event_type
          lambda_arn   = lambda.value.lambda_arn
          include_body = lookup(lambda.value, "include_body", null)
        }
      }

      dynamic "function_association" {
        iterator = cffunction
        for_each = lookup(db.value, "function_association", [])
        content {
          event_type   = cffunction.value.event_type
          function_arn = cffunction.value.function_arn
        }
      }

    }
  }

  lifecycle {
    ignore_changes = [
      viewer_certificate[0].acm_certificate_arn
    ]
  }
}
