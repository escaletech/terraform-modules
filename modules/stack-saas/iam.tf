resource "aws_iam_role" "ec2_role" {
  name = "${local.iam_prefix}_ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "${local.iam_prefix}_ec2_policy"
  description = "Policy to allow EC2 actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeTags"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "sqs:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "events:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "scheduler:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "appconfig:*",
        "Resource" : "*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "appconfigdata:*",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "pass_role_to_scheduler" {
  name        = "${local.iam_prefix}_PassRoleToEventBridgeScheduler"
  description = "Permite que o serviço EventBridge Scheduler assuma a role EventBridgeSchedulerRole"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/EventBridgeSchedulerRole"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "scheduler.amazonaws.com"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_role_policy_attachment" "pass_role_to_scheduler_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.pass_role_to_scheduler.arn
}

resource "aws_iam_role_policy_attachment" "s3_bucket_policy_attachment" {
  count      = var.create_s3 ? 1 : 0
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.policy-bucket-saas[0].arn
}

resource "aws_iam_instance_profile" "platform_conversational_iam_profile" {
  name = "${local.iam_prefix}_ec2_iam_profile"
  role = aws_iam_role.ec2_role.name
}
