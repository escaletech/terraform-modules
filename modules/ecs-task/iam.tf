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

resource "aws_iam_role_policy" "ecs_task_kms_policy" {
  count = var.sqs_queue_arn != null ? 1 : 0

  name = "ecs-task-policy-sqs-kms-${var.family}"
  role = aws_iam_role.ecs_task_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSQSAccessToQueue"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ]
        Resource = var.sqs_queue_arn
      },
      {
        Sid    = "AllowKMSForQueue"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        # Se informou a fila mas não informou a chave, usa "*" para KMS 
        # ou você pode passar o ARN da chave KMS se houver uma.
        Resource = var.kms_key_arn != null ? var.kms_key_arn : "*"
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
  policy_arn = data.aws_iam_policy.ecs_task_cloudwatch_logs_policy.arn
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_role_policy_attachment" "attach_additional_policy" {
  for_each = toset(var.arn_attach_additional_policy)

  policy_arn = each.value
  role       = aws_iam_role.ecs_task_role.name
}
