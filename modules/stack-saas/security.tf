##### SECURITY GROUP #####

resource "aws_security_group" "opensource" {
  name        = var.role_prefix
  description = "SG used by the platform Opensource - ${var.role_prefix}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [22, 443, 80, 2375]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.ipv4_cidr_blocks_allowed
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags

}