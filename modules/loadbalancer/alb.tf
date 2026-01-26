resource "aws_security_group" "alb" {
  count       = local.create_alb && var.alb_create_security_group ? 1 : 0
  name        = "${var.name}-alb"
  description = "Security group for ALB"
  vpc_id      = local.vpc_id

  dynamic "ingress" {
    for_each = var.alb_ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.alb_ingress_cidr_blocks
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.alb_egress_cidr_blocks
    ipv6_cidr_blocks = var.alb_egress_ipv6_cidr_blocks
  }

  tags = merge(var.tags, { Name = "${var.name}-alb" })
}

locals {
  alb_security_group_ids = local.create_alb && var.alb_create_security_group ? [aws_security_group.alb[0].id] : var.alb_security_group_ids
}

resource "aws_lb" "alb" {
  count                      = local.create_alb ? 1 : 0
  name                       = var.name
  internal                   = var.alb_internal
  load_balancer_type         = "application"
  subnets                    = var.alb_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  security_groups            = local.alb_security_group_ids

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_lb_listener" "alb_http" {
  count             = local.create_alb && var.alb_enable_default_listeners ? 1 : 0
  load_balancer_arn = aws_lb.alb[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb_https" {
  count             = local.create_alb && var.alb_enable_default_listeners ? 1 : 0
  load_balancer_arn = aws_lb.alb[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = var.alb_https_fixed_response.status_code
      message_body = var.alb_https_fixed_response.message_body
      content_type = var.alb_https_fixed_response.content_type
    }
  }
}
