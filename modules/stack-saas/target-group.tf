### Target Groups ###
resource "aws_lb_target_group" "platform-conversational" {
  for_each = toset(local.applications)

  name        = "${substr(replace(each.key, "_", "-"), 0, 24)}-${substr(md5(each.key), 0, 7)}"
  target_type = "ip"
  port        = local.ingress[each.key].port
  protocol    = local.ingress[each.key].protocol
  vpc_id      = var.vpc_id

  health_check {
    interval            = 30
    path                = local.ingress[each.key].health_check
    protocol            = local.ingress[each.key].protocol
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-499"
  }
}

resource "aws_lb_listener_rule" "listener" {
  for_each = toset(local.applications)

  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.platform-conversational[each.key].arn
  }

  condition {
    host_header {
      values = [local.ingress[each.key].host]
    }
  }

  dynamic "condition" {
    for_each = each.key == "${var.client_name}-chatwootMedia" ? [1] : []
    content {
      path_pattern {
        values = ["/rails/active_storage/*"]
      }
    }
  }

  condition {
    source_ip {
      values = lookup(var.listener_source_ips, each.key, local.default_listener_source_ips[each.key])
    }
  }

  dynamic "condition" {
    for_each = each.key == "${var.client_name}-evolutionWebhook" ? [1] : []
    content {
      path_pattern {
        values = ["/webhook/*"]
      }
    }
  }

  tags = {
    Name = each.key
  }
}

resource "aws_lb_target_group_attachment" "internal" {
  for_each = toset(local.applications)

  target_group_arn = aws_lb_target_group.platform-conversational[each.key].arn
  target_id        = aws_instance.platform_conversational.private_ip
  port             = local.ingress[each.key].port
}

resource "aws_route53_record" "platform-conversational" {
  for_each = local.dns

  zone_id = var.route53_id
  name    = each.value.host
  type    = "A"

  alias {
    name                   = var.lb_name
    zone_id                = var.lb_id
    evaluate_target_health = true
  }
}
