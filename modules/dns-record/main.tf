locals {
  use_alias  = var.alias_name != null && var.alias_zone_id != null
  record_ttl = coalesce(var.ttl, var.default_ttl)
}

resource "aws_route53_record" "dns" {
  zone_id         = var.zone_id
  name            = var.record_name
  type            = var.record_type
  allow_overwrite = var.allow_overwrite

  ttl     = local.use_alias ? null : local.record_ttl
  records = local.use_alias ? null : var.records

  dynamic "alias" {
    for_each = local.use_alias ? [1] : []
    content {
      name                   = var.alias_name
      zone_id                = var.alias_zone_id
      evaluate_target_health = true
    }
  }
}
