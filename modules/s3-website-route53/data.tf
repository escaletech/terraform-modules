data "aws_vpc" "escale-staging" {
  filter {
    name   = "tag:Name"
    values = [var.vpc-name]
  }
}

data "aws_vpc_endpoint" "s3" {
  vpc_id = data.aws_vpc.escale-staging.id
  filter {
    name   = "tag:Name"
    values = [var.endpoint-name]
  }
}

data "aws_lb" "alb_staging" {
  name = "vpc-endpoint-websites-s3"
}

data "aws_route53_zone" "zone" {
  name         = var.domain-zone
  private_zone = true
}
