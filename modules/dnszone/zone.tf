resource "aws_route53_zone" "dev" {
  name = var.dnszone
  tags = var.tags

  dynamic "vpc" {
    for_each = var.private && length(var.vpc_associations) > 0 ? [var.vpc_associations[0]] : []
    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = vpc.value.vpc_region
    }
  }
}

resource "aws_route53_zone_association" "private_vpcs" {
  for_each = var.private && length(var.vpc_associations) > 1 ? {
    for idx, assoc in var.vpc_associations : idx => assoc if idx > 0
  } : {}

  zone_id    = aws_route53_zone.dev.zone_id
  vpc_id     = each.value.vpc_id
  vpc_region = each.value.vpc_region
}
