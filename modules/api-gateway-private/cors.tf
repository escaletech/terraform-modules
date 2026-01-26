data "aws_api_gateway_resource" "paths_cors" {
  for_each = var.create_cors_options ? toset([
    for path in var.cors_paths : path
    if !(local.create_proxy_resource_effective && path == local.cors_proxy_path)
  ]) : toset([])

  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  path        = each.value
}

resource "aws_api_gateway_resource" "cors_proxy" {
  count = local.create_proxy_resource_effective ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  parent_id   = aws_api_gateway_rest_api.gateway_api.root_resource_id
  path_part   = "{proxy+}"
}

locals {
  cors_resource_map = var.create_cors_options ? merge(
    { for path, res in data.aws_api_gateway_resource.paths_cors : path => res },
    local.create_proxy_resource_effective ? { (local.cors_proxy_path) = aws_api_gateway_resource.cors_proxy[0] } : {}
  ) : {}
}

resource "aws_api_gateway_method" "cors" {
  for_each = local.cors_resource_map

  rest_api_id   = aws_api_gateway_rest_api.gateway_api.id
  resource_id   = each.value.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors" {
  for_each = aws_api_gateway_method.cors

  rest_api_id = each.value.rest_api_id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "cors" {
  for_each = aws_api_gateway_method.cors

  rest_api_id = each.value.rest_api_id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "cors" {
  for_each = aws_api_gateway_method.cors

  rest_api_id = each.value.rest_api_id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'"
  }

  response_templates = {
    "application/json" = <<EOF
#set($domainsList = ${jsonencode(var.cors_allowed_origins)})
#set($origin = $input.params("origin"))
#if($domainsList.contains($origin))
#set($context.responseOverride.header.Access-Control-Allow-Origin = $origin)
#end
EOF
  }

  depends_on = [aws_api_gateway_method_response.cors]
}
