module "s3-static" {
  source = "../phone-manager-front"

  app_name             = var.app_name
  domain               = var.domain_front
  dns_zone_name        = var.dns_zone_name
  vpc_name             = var.vpc_name
  subnets              = var.subnets
  tags                 = var.tags
  sg-name              = var.sg-name
  aws_lb_listener_arn  = var.aws_lb_listener_arn
  aws_lb_rule_priority = var.aws_lb_rule_priority
  aws_lb_zone_id       = var.aws_lb_zone_id
  aws_lb_dns           = var.aws_lb_dns
}
