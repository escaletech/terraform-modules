##### SECRET MANAGER #####

resource "aws_secretsmanager_secret" "secret_opensource" {
  name = "${var.client_name}-saas/env/${var.environment}"
}

resource "aws_secretsmanager_secret_version" "secret_opensource" {
  secret_id     = aws_secretsmanager_secret.secret_opensource.id
  secret_string = var.initial_secret_value
}

##### SECURITY GROUP #####

resource "aws_security_group" "opensource" {
  name        = "${var.client_name}-saas"
  description = "SG used by the platform Opensource ${var.environment} - ${var.client_name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ports_ingress_allowed
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.ipv4_cidr_blocks
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