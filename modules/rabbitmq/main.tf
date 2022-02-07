locals {
  engine                     = "RabbitMQ"
  engine_version             = "3.8.11"
  authentication_strategy    = "simple"
  auto_minor_version_upgrade = true
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

resource "aws_security_group" "rabbitmq-sg" {
  vpc_id      = data.aws_vpc.vpc.id
  name        = join("-", [var.tags.Name, "sg"])
  description = "security group that allows ingress and  egress traffic"

  ingress {
    from_port   = 5671
    to_port     = 5671
    protocol    = "tcp"
    description = ""
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    description = ""
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = ""
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 15672
    to_port     = 15672
    protocol    = "tcp"
    description = ""
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = ""
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_mq_broker" "main" {
  broker_name                = var.name
  engine_type                = local.engine
  engine_version             = local.engine_version
  host_instance_type         = var.instance_type
  security_groups            = [aws_security_group.rabbitmq-sg.id]
  subnet_ids                 = values(var.subnets)
  tags                       = var.tags
  authentication_strategy    = local.authentication_strategy
  auto_minor_version_upgrade = local.auto_minor_version_upgrade
  deployment_mode            = var.deployment_mode
  publicly_accessible        = var.publicly_accessible

  user {
    username = var.username
    password = var.password
  }

  logs {
    general = true
  }
}
