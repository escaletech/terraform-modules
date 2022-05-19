resource "aws_route53_zone" "private" {
  name = var.host

  dynamic "vpc" {
    for_each = toset(var.vpc_ids)
    content {
      vpc_id = vpc.value
    }
  }

  tags = var.tags
}

data "aws_lb" "private" {
  tags = var.lb_private_tag
}

resource "aws_route53_record" "private" {
  zone_id = aws_route53_zone.private.zone_id
  name    = var.host
  type    = "A"

  alias {
    name                   = data.aws_lb.private.dns_name
    zone_id                = data.aws_lb.private.zone_id
    evaluate_target_health = true
  }
}
