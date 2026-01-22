locals {
  effective_vpc_associations = length(var.vpc_associations) > 0 ? var.vpc_associations : (
    var.vpc_id != null ? [{
      vpc_id     = var.vpc_id
      vpc_region = null
    }] : []
  )
}

resource "aws_route53_zone" "dev" {
  name = var.dnszone
  tags = var.tags

  dynamic "vpc" {
    for_each = var.private && length(local.effective_vpc_associations) > 0 ? [local.effective_vpc_associations[0]] : []
    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = vpc.value.vpc_region
    }
  }

  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_zone_association" "private_vpcs" {
  for_each = var.private && length(local.effective_vpc_associations) > 1 ? {
    for idx, assoc in local.effective_vpc_associations : idx => assoc if idx > 0
  } : {}

  zone_id    = aws_route53_zone.dev.zone_id
  vpc_id     = each.value.vpc_id
  vpc_region = each.value.vpc_region
}
