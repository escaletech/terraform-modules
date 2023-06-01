resource "aws_route53_record" "internal" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = var.aws_lb_dns
    zone_id                = var.aws_lb_zone_id
    evaluate_target_health = false
  }
}
