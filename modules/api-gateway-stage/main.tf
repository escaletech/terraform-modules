resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = data.aws_api_gateway_rest_api.gateway_api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = data.aws_api_gateway_rest_api.gateway_api.id
  stage_name    = local.name
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  api_id      = data.aws_api_gateway_rest_api.gateway_api.id
  domain_name = local.domain
  stage_name  = aws_api_gateway_stage.stage.stage_name
}