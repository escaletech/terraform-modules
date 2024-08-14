data "aws_api_gateway_rest_api" "gateway_api" {
  name = var.api_gateway
}

data "aws_lambda_function" "lambda" {
  function_name = var.function_name
}