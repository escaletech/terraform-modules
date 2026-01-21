data "aws_vpc" "selected" {
  count = var.vpc_id == null ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

locals {
  create_alb = var.lb_type == "alb"
  create_nlb = var.lb_type == "nlb"
  vpc_id     = var.vpc_id != null ? var.vpc_id : data.aws_vpc.selected[0].id
}
