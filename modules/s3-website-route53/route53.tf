resource "aws_route53_record" "internal" {
  zone_id = data.aws_route53_zone.zone.id
  name    = var.domain
  type    = "A"

  alias {
    name                   = data.aws_lb.alb_staging.dns_name
    zone_id                = data.aws_lb.alb_staging.zone_id
    evaluate_target_health = false
  }
}

