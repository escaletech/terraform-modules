data "aws_route53_zone" "zone" {
  name         = var.dns_zone_name
  private_zone = true
}

resource "aws_route53_record" "record" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.domain_backend
  type    = "A"

  alias {
    name                   = var.aws_lb_dns
    zone_id                = var.aws_lb_zone_id
    evaluate_target_health = true
  }
}
