module "s3-static" {
  source = "../s3-website-vpc"

  app_name      = var.app_name
  domain        = var.domain_front
  dns_zone_name = var.dns_zone_name
  vpc_name      = var.vpc_name
  subnets       = var.subnets
  tags          = var.tags
}
