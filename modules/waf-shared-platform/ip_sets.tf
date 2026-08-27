resource "aws_wafv2_ip_set" "allow" {
  name               = "${local.name}-allow"
  description        = "Allow IP set for ${local.name}. Empty is a no-op. Do not treat as a global public allowlist."
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.allow_ipv4_cidrs
  tags               = local.tags
}

resource "aws_wafv2_ip_set" "deny" {
  name               = "${local.name}-deny"
  description        = "Deny IP set for ${local.name}. Empty is a no-op."
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.deny_ipv4_cidrs
  tags               = local.tags
}
