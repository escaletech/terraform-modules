resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role-${var.family}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_ecsTaskExecutionRole" {
  name       = "attach-ecsTaskExecutionRole"
  roles      = [aws_iam_role.ecs_task_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy_attachment" "attach_ecrReadOnly" {
  name       = "attach-AmazonElasticContainerRegistryPublicReadOnly"
  roles      = [aws_iam_role.ecs_task_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicReadOnly"
}


resource "aws_iam_policy_attachment" "attach_SecretsManagerReadWrite" {
  name       = "SecretsManagerReadWrite"
  roles      = [aws_iam_role.ecs_task_role.name]
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_policy_attachment" "attach_ecs_task_cloudwatch_logs_policy" {
  name       = "ecs_task_cloudwatch_logs_policy"
  roles      = [aws_iam_role.ecs_task_role.name]
  policy_arn = data.aws_iam_policy.ecs_task_cloudwatch_logs_policy.arn
}
