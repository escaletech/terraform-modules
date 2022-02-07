resource "aws_route53_record" "internal" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.domain
  type    = "A"
  ttl     = 60

  records = [var.input_ip]
}
