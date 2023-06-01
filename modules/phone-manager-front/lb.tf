resource "aws_lb_listener_rule" "index" {
  listener_arn = var.aws_lb_listener_arn
  priority     = var.aws_lb_rule_priority

  action {
    type = "redirect"
    redirect {
      path        = "/index.html"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["phonemanager.staging.escale.com.br"]
    }
  }
}

resource "aws_lb_target_group" "internal" {
  name_prefix          = "${substr(var.app_name, 0, 5)}-"
  port                 = 443
  protocol             = "HTTPS"
  vpc_id               = data.aws_vpc.vpc.id
  deregistration_delay = 60
  target_type          = "ip"

  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-499"
  }
}

resource "aws_lb_target_group_attachment" "internal" {
  count            = length(data.aws_network_interface.internal[*].private_ip)
  target_group_arn = aws_lb_target_group.internal.arn
  target_id        = data.aws_network_interface.internal[count.index].private_ip
}
