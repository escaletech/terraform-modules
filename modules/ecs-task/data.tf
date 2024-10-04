data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy" "ecs_task_cloudwatch_logs_policy" {
  name = "ecs_task_cloudwatch_logs_policy"
}

data "aws_cloudwatch_log_group" "logs" {
  name = var.family
}