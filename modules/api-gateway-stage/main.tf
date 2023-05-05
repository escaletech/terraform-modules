resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id       = data.aws_api_gateway_rest_api.gateway_api.id
  description       = "Deployed at ${timestamp()}"
  stage_description = "Deployed at ${timestamp()}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = data.aws_api_gateway_rest_api.gateway_api.id
  stage_name    = local.name
  variables     = local.variables
  depends_on    = [aws_cloudwatch_log_group.log_api_gateway]
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.log_api_gateway.arn
    format          = "[ip:$context.identity.sourceIp] [iss:$context.domainName] $context.httpMethod $context.resourcePath - $context.status duration: $context.responseLatency ms [trackingId: $context.requestId]"
  }
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  api_id      = data.aws_api_gateway_rest_api.gateway_api.id
  domain_name = local.domain
  stage_name  = aws_api_gateway_stage.stage.stage_name
}

resource "aws_cloudwatch_log_group" "log_api_gateway" {
  name              = "API-Gateway-Execution-Logs_${data.aws_api_gateway_rest_api.gateway_api.name}/${local.name}"
  retention_in_days = 400
}
