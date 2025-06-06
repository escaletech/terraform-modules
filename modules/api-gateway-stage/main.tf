# resource "aws_api_gateway_deployment" "deployment" {
#   rest_api_id       = (var.gateway_api_id == null) ? data.aws_api_gateway_rest_api.gateway_api.id : var.gateway_api_id
#   description       = "Deployment"

#   dynamic "triggers" {
#     for_each = var.hash != null ? [1] : []
#     content {
#       redeployment = var.hash
#     }
#   }


#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_api_gateway_stage" "stage" {
  deployment_id = var.deployment_id
  rest_api_id   = (var.gateway_api_id == null) ? data.aws_api_gateway_rest_api.gateway_api.id : var.gateway_api_id
  stage_name    = local.name
  variables     = local.variables
  depends_on    = [aws_cloudwatch_log_group.log_api_gateway]
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log_api_gateway.arn
    format          = "[ip:$context.identity.sourceIp] [iss:$context.domainName] $context.httpMethod $context.resourcePath - $context.status duration: $context.responseLatency ms [trackingId: $context.requestId] [user: $context.authorizer.email]"
  }
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  count = var.private ? 0 : 1

  api_id      = (var.gateway_api_id == null) ? data.aws_api_gateway_rest_api.gateway_api.id : var.gateway_api_id
  domain_name = local.domain
  stage_name  = aws_api_gateway_stage.stage.stage_name
}

resource "aws_cloudwatch_log_group" "log_api_gateway" {
  name              = "API-Gateway-Execution-Logs_${data.aws_api_gateway_rest_api.gateway_api.name}/${local.name}"
  retention_in_days = 400
}
