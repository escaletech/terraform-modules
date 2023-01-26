data "aws_route53_zone" "zone" {
  name         = var.zone
  private_zone = var.private_zone
}
