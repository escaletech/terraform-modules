resource "aws_customer_gateway" "fortigate" {
  bgp_asn    = 65000
  ip_address = var.fortigate_public_ip
  type       = "ipsec.1"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cgw"
  })
}

resource "aws_vpn_gateway" "vgw" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vgw"
  })
}

resource "aws_vpn_connection" "vpn" {
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  customer_gateway_id = aws_customer_gateway.fortigate.id
  type                = "ipsec.1"

  static_routes_only = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-connection"
  })

  lifecycle {
    ignore_changes = [
      tunnel1_ike_versions,
      tunnel1_phase1_dh_group_numbers,
      tunnel1_phase1_encryption_algorithms,
      tunnel1_phase1_integrity_algorithms,
      tunnel1_phase2_dh_group_numbers,
      tunnel1_phase2_encryption_algorithms,
      tunnel1_phase2_integrity_algorithms,
      tunnel2_ike_versions,
      tunnel2_phase1_dh_group_numbers,
      tunnel2_phase1_encryption_algorithms,
      tunnel2_phase1_integrity_algorithms,
      tunnel2_phase2_dh_group_numbers,
      tunnel2_phase2_encryption_algorithms,
      tunnel2_phase2_integrity_algorithms,
    ]
  }
}

resource "aws_vpn_connection_route" "fortigate" {
  for_each = toset(var.fortigate_cidrs)

  vpn_connection_id      = aws_vpn_connection.vpn.id
  destination_cidr_block = each.value
}

resource "aws_route" "to_fortigate" {
  for_each = toset(var.fortigate_cidrs)

  route_table_id         = var.route_table_id
  destination_cidr_block = each.value
  gateway_id             = aws_vpn_gateway.vgw.id
}
