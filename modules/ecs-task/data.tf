data "aws_region" "current" {}

data "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role-${var.family}"
}
