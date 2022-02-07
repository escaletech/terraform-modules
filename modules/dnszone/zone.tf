resource "aws_route53_zone" "dev" {
  name = var.dnszone
  tags = var.tags
}