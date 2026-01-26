data "aws_api_gateway_resource" "paths_cors" {
  for_each = var.create_cors_options ? toset(var.cors_paths) : toset([])

  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  path        = each.value
}

resource "aws_api_gateway_method" "cors" {
  for_each = var.create_cors_options ? { for path, res in data.aws_api_gateway_resource.paths_cors : path => res } : {}

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
