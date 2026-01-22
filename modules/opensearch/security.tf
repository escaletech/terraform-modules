resource "aws_security_group" "opensearch" {
  name        = "sg_${var.name}"
  description = "Security group for OpenSearch domain"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = [443, 9200]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.ingress_cidrs
    }
  }

  tags = var.tags
}