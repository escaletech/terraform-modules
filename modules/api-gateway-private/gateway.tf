resource "aws_api_gateway_domain_name" "custom_domain" {
  certificate_arn          = var.type_endpoint == "EDGE" ? local.certificate_arn : null
  regional_certificate_arn = var.type_endpoint == "REGIONAL" ? local.certificate_arn : null
  domain_name              = local.domain
  endpoint_configuration {
    types = [var.type_endpoint]
  }
}

resource "aws_vpc_endpoint" "api_gateway_vpc_endpoint" {
  count               = var.create_vpc_endpoint ? 1 : 0
  vpc_id              = var.vpc_id
  service_name        = var.vpc_endpoint_service_name != null ? var.vpc_endpoint_service_name : "com.amazonaws.${data.aws_region.current.id}.execute-api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = var.vpc_endpoint_private_dns_enabled

  security_group_ids = local.vpc_endpoint_security_group_ids_effective
  subnet_ids         = var.vpc_endpoint_subnet_ids
}

resource "aws_security_group" "vpc_endpoint" {
  count = var.create_vpc_endpoint ? 1 : 0

  name        = "${var.name}-vpce"
  description = "Security group for API Gateway VPC endpoint"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "vpc_endpoint_ingress_https" {
  count = var.create_vpc_endpoint ? 1 : 0

  type              = "ingress"
  description       = "Allow HTTPS from VPC"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [local.vpc_cidr_block]
  security_group_id = aws_security_group.vpc_endpoint[0].id
}

resource "aws_security_group_rule" "vpc_endpoint_egress_all" {
  count = var.create_vpc_endpoint ? 1 : 0

  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpc_endpoint[0].id
}

resource "aws_api_gateway_rest_api" "gateway_api" {
  name                         = local.name
  disable_execute_api_endpoint = false

  endpoint_configuration {
    types            = ["PRIVATE"]
    vpc_endpoint_ids = local.vpc_endpoint_ids_effective
    ip_address_type  = "dualstack"
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
  count   = var.create_route53_record ? 1 : 0
  name    = local.domain
  type    = "A"
  zone_id = data.aws_route53_zone.zone[0].id

  alias {
    evaluate_target_health = true
    name                   = var.type_endpoint == "EDGE" ? aws_api_gateway_domain_name.custom_domain.cloudfront_domain_name : aws_api_gateway_domain_name.custom_domain.regional_domain_name
    zone_id                = var.type_endpoint == "EDGE" ? aws_api_gateway_domain_name.custom_domain.cloudfront_zone_id : aws_api_gateway_domain_name.custom_domain.regional_zone_id
  }

  depends_on = [
    aws_api_gateway_domain_name.custom_domain
  ]
}
