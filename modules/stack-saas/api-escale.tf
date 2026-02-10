
resource "aws_api_gateway_resource" "api_evolution" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = data.aws_api_gateway_rest_api.api-escale.id
  parent_id   = data.aws_api_gateway_rest_api.api-escale.root_resource_id
  path_part   = var.client_name
}

resource "aws_api_gateway_resource" "api_evolution_whatsapp" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = data.aws_api_gateway_rest_api.api-escale.id
  parent_id   = aws_api_gateway_resource.api_evolution[0].id
  path_part   = "whatsapp"

  depends_on = [aws_api_gateway_resource.api_evolution]
}

resource "aws_api_gateway_resource" "api_evolution_meta" {
  count       = var.enable_api_gateway ? 1 : 0
  rest_api_id = data.aws_api_gateway_rest_api.api-escale.id
  parent_id   = aws_api_gateway_resource.api_evolution_whatsapp[0].id
  path_part   = "meta"

  depends_on = [aws_api_gateway_resource.api_evolution_whatsapp]
}

resource "aws_api_gateway_method" "api_evolution_meta_any" {
  count         = var.enable_api_gateway ? 1 : 0
  rest_api_id   = data.aws_api_gateway_rest_api.api-escale.id
  resource_id   = aws_api_gateway_resource.api_evolution_meta[0].id
  http_method   = "ANY"
  authorization = "NONE"

  depends_on = [aws_api_gateway_resource.api_evolution_meta]
}

resource "aws_api_gateway_integration" "api_evolution_meta_any" {
  count                   = var.enable_api_gateway ? 1 : 0
  rest_api_id             = data.aws_api_gateway_rest_api.api-escale.id
  resource_id             = aws_api_gateway_resource.api_evolution_meta[0].id
  http_method             = aws_api_gateway_method.api_evolution_meta_any[0].http_method
  type                    = "HTTP_PROXY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = data.aws_api_gateway_vpc_link.vpc_link_ecs_apps.id
  uri                     = "https://${var.client_name}-evolution.saas.escale.ai/webhook/meta"

  depends_on = [aws_api_gateway_method.api_evolution_meta_any]

}

### Custom Domain ###

resource "aws_api_gateway_domain_name" "custom_domain_name" {
  count           = var.enable_api_gateway ? 1 : 0
  certificate_arn = data.aws_acm_certificate.xclapi.arn
  domain_name     = "${var.client_name}.saas.xclapi.in"
}

resource "aws_route53_record" "domain_name" {
  count   = var.enable_api_gateway ? 1 : 0
  name    = aws_api_gateway_domain_name.custom_domain_name[0].domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.xclapi.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.custom_domain_name[0].cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain_name[0].cloudfront_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "evolution" {
  count       = var.enable_api_gateway ? 1 : 0
  api_id      = data.aws_api_gateway_rest_api.api-escale.id
  stage_name  = "production"
  domain_name = aws_api_gateway_domain_name.custom_domain_name[0].domain_name

  depends_on = [aws_api_gateway_domain_name.custom_domain_name, aws_route53_record.domain_name]
}
