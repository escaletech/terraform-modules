resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = var.api_gateway_id
  resource_id   = var.resource_id
  http_method   = var.method
  authorization = var.authorization != "NONE" ? "CUSTOM" : "NONE"
  authorizer_id = var.authorization != "NONE" ? var.authorizer_id : null

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = var.api_gateway_id
  resource_id             = var.resource_id
  http_method             = var.method
  integration_http_method = var.method
  type                    = "HTTP_PROXY"
  uri                     = var.uri_origin

  cache_key_parameters = [
    "method.request.path.proxy"
  ]

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }

  connection_type = "VPC_LINK"
  connection_id   = var.vpc_link_id
}