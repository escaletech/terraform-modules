### Target Groups ###
resource "aws_lb_target_group" "platform-conversational" {
  for_each = toset(local.applications)

  name        = each.key
  target_type = "ip"
  port        = local.ingress[each.key].port
  protocol    = local.ingress[each.key].protocol
  vpc_id      = data.aws_vpc.escale-prod.id

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

  listener_arn = var.listerner_arn

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
      values = each.key == "${var.client_name}-chatwootMedia" ? ["0.0.0.0/0"] : (each.key == "${var.client_name}-evolutionWebhook" ? ["192.168.0.0/16"] : ["186.225.143.246/32", "3.225.122.61/32", "52.22.27.47/32", "54.166.93.109/32"])
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