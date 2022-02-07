output "lambda_arn" {
  value = aws_lambda_function.edge_security_headers_lambda.qualified_arn
}
