output "tunnel1_address" {
  value = aws_vpn_connection.vpn.tunnel1_address
}

output "tunnel1_preshared_key" {
  value     = aws_vpn_connection.vpn.tunnel1_preshared_key
  sensitive = true
}

output "tunnel2_address" {
  value = aws_vpn_connection.vpn.tunnel2_address
}

output "tunnel2_preshared_key" {
  value     = aws_vpn_connection.vpn.tunnel2_preshared_key
  sensitive = true
}
