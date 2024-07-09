resource "aws_api_gateway_domain_name" "custom_domain" {
  certificate_arn = local.certificate_arn
  domain_name     = local.domain
}

resource "aws_api_gateway_rest_api" "gateway_api" {
  name                         = local.name
  disable_execute_api_endpoint = true
  api_key_source               = var.api_key_source
}

data aws_iam_policy_document "policy" {

  dynamic "statement" {
    for_each = var.routes_private
    content {
      effect = "Deny"
      principals {
        type        = "AWS"
        identifiers = ["*"]
      }
      actions = ["execute-api:Invoke"]
      resources = [
        "${aws_api_gateway_rest_api.gateway_api.execution_arn}/*/${statement.value}/*"
      ]
    }
  }

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["execute-api:Invoke"]

    resources = [
      aws_api_gateway_rest_api.gateway_api.execution_arn
    ]
  }

}

resource "aws_api_gateway_rest_api_policy" "policy_invoke" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id

  policy = aws_iam_policy_document.policy.json
}

resource "aws_route53_record" "domain" {
  name    = local.domain
  type    = "A"
  zone_id = data.aws_route53_zone.zone.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.custom_domain.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain.cloudfront_zone_id
  }

  depends_on = [
    aws_api_gateway_domain_name.custom_domain
  ]
}