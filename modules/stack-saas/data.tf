data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "escale-staging" {
  filter {
    name   = "tag:Name"
    values = ["escale-staging"]
  }
}

data "aws_subnets" "subnet_private_staging" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.escale-staging.id]
  }
  filter {
    name = "tag:Name"
    values = ["escale-staging-subnet-private-a",
    "escale-staging-subnet-private-b"]
  }
}

data "aws_route53_zone" "staging_private" {
  name         = "staging.escale.com.br"
  private_zone = true
}

data "aws_route53_zone" "staging_public" {
  name         = "staging.escale.com.br"
  private_zone = false
}


##ALB PUBLIC
data "aws_lb" "ecs_escale_staging" {
  name = "ecs-escale-staging"
}

data "aws_lb_listener" "listener_ecs_escale_staging" {
  load_balancer_arn = data.aws_lb.ecs_escale_staging.arn
  port              = 443
}

## ALB PRIVATE
data "aws_lb" "ecs_escale_apps" {
  name = "ecs-escale-apps"
}

data "aws_lb_listener" "listener_ecs_escale_apps" {
  load_balancer_arn = data.aws_lb.ecs_escale_apps.arn
  port              = 443
}

# data "aws_iam_policy_document" "policy_bucket_saas" {
#   statement {
#     sid    = "Stmt${var.client_name}Saas"
#     effect = "Allow"

#     principals {
#       type        = "AWS"
#       identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/access_s3"]
#     }

#     actions = [
#       "s3:DeleteObject",
#       "s3:GetObject",
#       "s3:ListBucket",
#       "s3:PutObject"
#     ]

#     resources = [
#       "arn:aws:s3:::${local.s3_name}",
#       "arn:aws:s3:::${local.s3_name}/*"
#     ]
#   }
# }
