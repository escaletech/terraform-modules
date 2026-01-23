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

locals {
  cloudwatch_logs_policy_arn = (
    var.create_policy_cloudwatch ?
    aws_iam_policy.ecs_task_cloudwatch_logs_policy[0].arn :
    (
      length(data.aws_iam_policies.ecs_task_cloudwatch_logs_policy.arns) > 0 ?
      data.aws_iam_policies.ecs_task_cloudwatch_logs_policy.arns[0] :
      null
    )
  )
}

resource "aws_iam_policy" "ecs_task_cloudwatch_logs_policy" {
  count = var.create_policy_cloudwatch ? 1 : 0

  name = "ecs_task_cloudwatch_logs_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "logs:CreateLogGroup"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ecsTaskExecutionRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_role_policy_attachment" "attach_ecrReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicReadOnly"
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_role_policy_attachment" "attach_SecretsManagerReadWrite" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_role_policy_attachment" "attach_ecs_task_cloudwatch_logs_policy" {
  count = local.cloudwatch_logs_policy_arn != null ? 1 : 0

  policy_arn = local.cloudwatch_logs_policy_arn
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_role_policy_attachment" "attach_additional_policy" {
  for_each = toset(var.arn_attach_additional_policy)

  policy_arn = each.value
  role       = aws_iam_role.ecs_task_role.name
}
