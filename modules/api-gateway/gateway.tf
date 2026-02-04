resource "aws_api_gateway_domain_name" "custom_domain" {
  domain_name              = local.domain
  certificate_arn          = var.endpoint_type == "EDGE" ? local.certificate_arn : null
  regional_certificate_arn = var.endpoint_type == "REGIONAL" ? local.certificate_arn : null

  endpoint_configuration {
    types = [var.endpoint_type]
  }
}

resource "aws_api_gateway_rest_api" "gateway_api" {
  name                         = local.name
  disable_execute_api_endpoint = true
  api_key_source               = var.api_key_source
}

resource "aws_api_gateway_rest_api_policy" "policy_invoke" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "execute-api:Invoke",
      "Resource": "${aws_api_gateway_rest_api.gateway_api.execution_arn}/*/*"
    }
  ]
}
EOF
}

resource "aws_route53_record" "domain" {
  name    = local.domain
  type    = "A"
  zone_id = data.aws_route53_zone.zone.id

  alias {
    evaluate_target_health = true
    name                   = var.endpoint_type == "REGIONAL" ? aws_api_gateway_domain_name.custom_domain.regional_domain_name : aws_api_gateway_domain_name.custom_domain.cloudfront_domain_name
    zone_id                = var.endpoint_type == "REGIONAL" ? aws_api_gateway_domain_name.custom_domain.regional_zone_id : aws_api_gateway_domain_name.custom_domain.cloudfront_zone_id
  }

  depends_on = [
    aws_api_gateway_domain_name.custom_domain
  ]
}
