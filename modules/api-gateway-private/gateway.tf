resource "aws_api_gateway_domain_name" "custom_domain" {
  certificate_arn = local.certificate_arn
  domain_name     = local.domain
  endpoint_configuration {
    types = [var.type_endpoint]
  }
}

resource "aws_vpc_endpoint" "api_gateway_vpc_endpoint" {
  count               = var.create_vpc_endpoint ? 1 : 0
  vpc_id              = var.vpc_id
  service_name        = var.vpc_endpoint_service_name != null ? var.vpc_endpoint_service_name : "com.amazonaws.${data.aws_region.current.name}.execute-api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = var.vpc_endpoint_private_dns_enabled

  security_group_ids = var.vpc_endpoint_security_group_ids
  subnet_ids         = var.vpc_endpoint_subnet_ids
}

resource "aws_api_gateway_rest_api" "gateway_api" {
  name                         = local.name
  disable_execute_api_endpoint = false

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = local.vpc_endpoint_ids_effective
  }
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
    },
    {
        "Effect": "Deny",
        "Principal": "*",
        "Action": "execute-api:Invoke",
        "Resource": "${aws_api_gateway_rest_api.gateway_api.execution_arn}/*/*",
        "Condition" : {
            "ForAllValues:StringNotEquals": {
                "aws:SourceVpce": ${jsonencode(local.vpc_endpoint_ids_effective)}
            }
        }
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
    name                   = aws_api_gateway_domain_name.custom_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain.cloudfront_zone_id
  }

  depends_on = [
    aws_api_gateway_domain_name.custom_domain
  ]
}
