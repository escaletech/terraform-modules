resource "aws_security_group" "sns_sg" {
  vpc_id      = data.aws_vpc.vpc.id
  name        = join("-", [var.tags.Name, "sg"])
  description = "security group that allows ingress and  egress traffic"

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_vpc_endpoint" "sns" {
  vpc_id             = data.aws_vpc.vpc.id
  service_name       = join(".", ["com.amazonaws", data.aws_region.current.name, "sns"])
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.sns_sg.id]
  subnet_ids         = values(var.subnets)

  private_dns_enabled = false

  tags = var.tags
}
