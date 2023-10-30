data "aws_region" "current" {}

data "aws_iam_policy" "ecs_task_cloudwatch_logs_policy" {
  name = "ecs_task_cloudwatch_logs_policy"
}
