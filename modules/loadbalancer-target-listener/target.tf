resource "aws_lb_target_group" "target" {
  name        = var.target_name
  target_type = var.target_type
  port        = var.target_port
  protocol    = var.target_protocol
  vpc_id      = data.aws_vpc.escale-prod.id

  health_check {
    interval            = 30
    path                = var.health_path
    protocol            = var.target_protocol
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = var.health_statuscode
  }
}

resource "aws_lb_target_group_attachment" "internal" {
  target_group_arn = aws_lb_target_group.target.arn
  target_id        = (var.target_type == "ip") ? var.ip : null
  port             = var.target_port
}