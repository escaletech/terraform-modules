data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc]
  }
}

data "aws_subnet" "subnet-private-ids" {
  for_each = toset(var.subnet)

  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:Name"
    values = [each.value]
  }
}

data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "certificate-opensearch" {
  domain = "*.${var.domain_name}"
}

data "aws_route53_zone" "zone" {
  name         = "${var.domain_name}"
  private_zone = true
}

data "aws_kms_key" "opensearch" {
  key_id = "alias/aws/es"
}
