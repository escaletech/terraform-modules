data "aws_acm_certificate" "escale-staging" {
  domain      = "*.staging.escale.com.br"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
