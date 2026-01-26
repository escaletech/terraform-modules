resource "aws_security_group" "nlb" {
  count       = local.create_nlb && var.nlb_create_security_group ? 1 : 0
  name        = "${var.name}-nlb"
  description = "Security group for NLB"
  vpc_id      = local.vpc_id

  dynamic "ingress" {
    for_each = var.nlb_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.nlb_ingress_cidr_blocks
    }
  }

  dynamic "ingress" {
    for_each = var.nlb_additional_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.nlb_egress_cidr_blocks
    ipv6_cidr_blocks = var.nlb_egress_ipv6_cidr_blocks
  }

  tags = merge(var.tags, { Name = "${var.name}-nlb" })
}

locals {
  nlb_security_group_ids = local.create_nlb && var.nlb_create_security_group ? [aws_security_group.nlb[0].id] : var.nlb_security_group_ids
}

resource "aws_lb" "nlb" {
  count                            = local.create_nlb ? 1 : 0
  name                             = var.name
  load_balancer_type               = "network"
  internal                         = var.nlb_internal
  subnets                          = var.nlb_subnet_ids
  security_groups                  = local.nlb_security_group_ids
  enable_deletion_protection       = var.enable_deletion_protection
  enable_cross_zone_load_balancing = var.nlb_enable_cross_zone_load_balancing

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_lb_listener" "nlb" {
  for_each          = local.create_nlb ? { for idx, listener in var.nlb_listeners : idx => listener } : {}
  load_balancer_arn = aws_lb.nlb[0].arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = coalesce(
      try(each.value.target_group_arn, null),
      try(aws_lb_target_group.nlb[each.value.target_group_name].arn, null)
    )
  }
}

resource "aws_lb_target_group" "nlb" {
  for_each = local.create_nlb ? { for tg in var.nlb_target_groups : tg.name => tg } : {}

  name        = each.value.name
  target_type = each.value.target_type
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = coalesce(each.value.vpc_id, local.vpc_id)

  dynamic "health_check" {
    for_each = each.value.health_check == null ? [] : [each.value.health_check]
    content {
      enabled             = try(health_check.value.enabled, null)
      interval            = try(health_check.value.interval, null)
      path                = try(health_check.value.path, null)
      port                = try(health_check.value.port, null)
      protocol            = try(health_check.value.protocol, null)
      timeout             = try(health_check.value.timeout, null)
      healthy_threshold   = try(health_check.value.healthy_threshold, null)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, null)
      matcher             = try(health_check.value.matcher, null)
    }
  }

  tags = merge(var.tags, each.value.tags, { Name = each.value.name })
}
