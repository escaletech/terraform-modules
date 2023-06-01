resource "aws_security_group" "internal-sg" {
  vpc_id      = data.aws_vpc.vpc.id
  name        = join("-", [var.sg-name, "sg"])
  description = "security group that allows ingress and  egress traffic"
  ingress {
    from_port   = 80
    to_port     = 80
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = ""
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_vpc_endpoint" "internal" {
  vpc_id             = data.aws_vpc.vpc.id
  service_name       = join(".", ["com.amazonaws", data.aws_region.current.name, "s3"])
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.internal-sg.id]
  subnet_ids         = var.subnets

  private_dns_enabled = false

  tags = var.tags
}

data "aws_network_interface" "internal" {
  count = length(var.subnets)
  id    = flatten(aws_vpc_endpoint.internal.network_interface_ids)[count.index]
}
