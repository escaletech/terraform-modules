resource "aws_lb_listener_rule" "listener" {
  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.platform-conversational[each.key].arn
  }

  dynamic "condition" {
    for_each = length(var.host_header) > 0 ? [1] : []
    content {
      host_header {
        values = var.host_header
      }
    }
  }

  dynamic "condition" {
    for_each = length(var.path_pattern) > 0 ? [1] : []
    content {
      path_pattern {
        values = var.path_pattern
      }
    }
  }

  dynamic "condition" {
    for_each = length(var.source_ip) > 0 ? [1] : []
    content {
      source_ip {
        values = var.source_ip
      }
    }
  }

  tags = {
    Name = each.key
  }
}
