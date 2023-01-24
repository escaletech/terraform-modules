resource "aws_api_gateway_domain_name" "custom_domain" {
  certificate_arn = aws_acm_certificate.certificate.arn
  domain_name     = local.domain
}

resource "aws_api_gateway_rest_api" "gateway_api" {
  name                         = local.name
  disable_execute_api_endpoint = true
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
      "Resource": "${aws_api_gateway_rest_api.gateway_api.execution_arn}"
    }
  ]
}
EOF
}