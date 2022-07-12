resource "aws_lb" "internal" {
  name               = var.tags.Name
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal-sg.id]
  subnets            = var.subnets
  internal           = true
  tags               = var.tags
}

resource "aws_lb_listener" "internal_http_to_https" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "internal_https" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-2019-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal.arn
  }
}

resource "aws_lb_listener_certificate" "internal" {
  for_each        = data.aws_acm_certificate.domains
  listener_arn    = aws_lb_listener.internal_https.arn
  certificate_arn = each.value.arn
}

resource "aws_lb_listener_rule" "index" {
  listener_arn = aws_lb_listener.internal_https.arn
  priority     = 100

  action {
    type = "redirect"
    redirect {
      path        = "/index.html"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_lb_target_group" "internal" {
  name                 = var.tags.Name
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
  count            = length(data.aws_network_interface.internal.*.private_ip)
  target_group_arn = aws_lb_target_group.internal.arn
  target_id        = data.aws_network_interface.internal[count.index].private_ip
}
