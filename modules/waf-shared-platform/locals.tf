locals {
  name       = var.name
  log_group  = var.log_group_name
  aws_region = try(data.aws_region.current.region, data.aws_region.current.name)
  tags = merge(var.tags, {
    Name      = var.name
    Terraform = "true"
    Module    = "waf-shared-platform"
  })
}
