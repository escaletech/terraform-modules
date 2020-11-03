// Configure Route53 record to deliver distribution
resource "aws_route53_record" "main" {
  zone_id         = data.aws_route53_zone.zone.zone_id
  name            = var.host
  type            = "A"
  allow_overwrite = true

  alias {
    name    = aws_cloudfront_distribution.main.domain_name
    zone_id = aws_cloudfront_distribution.main.hosted_zone_id

    evaluate_target_health = false
  }
}
