locals {
  queue_base_name = join("-", [var.name, "sqs", var.environment])
  queue_name      = var.fifo_queue == true ? "${local.queue_base_name}.fifo" : local.queue_base_name
}

resource "aws_sqs_queue" "sqs_queue" {
  name                        = local.queue_name
  delay_seconds               = var.delay_seconds
  max_message_size            = var.max_message_size
  message_retention_seconds   = var.message_retention_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  tags                        = var.tags
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication
  redrive_policy              = var.redrive_policy
}

resource "aws_sqs_queue_policy" "sqs_queue" {
  count = var.vpc_endpoint_name != null ? 1 : 0

  queue_url = aws_sqs_queue.sqs_queue.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = join("-", [aws_sqs_queue.sqs_queue.name, "sqs-policy"])
    Statement = [
      {
        Sid       = "SendReceiveVpce"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "sqs:GetQueueUrl",
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = aws_sqs_queue.sqs_queue.arn
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = data.aws_vpc_endpoint.sqs[0].id
          }
        }
      },
      {
        Sid       = "DenyPublicReadNonVpce"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = aws_sqs_queue.sqs_queue.arn
        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = data.aws_vpc_endpoint.sqs[0].id
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  count = var.vpc_endpoint_name == null && var.topic_arn != null ? 1 : 0

  queue_url = aws_sqs_queue.sqs_queue.id
  policy = jsonencode({
    Version = "2008-10-17",
    Id      = join("-", [aws_sqs_queue.sqs_queue.name, "sqs-policy"]),
    Statement = [
      {
        Sid      = "SendMessageSQS",
        Effect   = "Allow",
        Action   = "SQS:*",
        Resource = aws_sqs_queue.sqs_queue.arn
      },
      {
        Sid       = join(":", ["topic-subscription-arn", var.topic_arn])
        Effect    = "Allow",
        Principal = "*",
        Action    = "SQS:SendMessage",
        Resource  = aws_sqs_queue.sqs_queue.arn,
        Condition = {
          ArnLike = {
            "aws:SourceArn" = var.topic_arn
          }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "sqs_queue" {
  count = var.role_name != null ? 1 : 0

  statement {
    actions = [
      "sqs:GetQueueUrl",
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]

    resources = [
      aws_sqs_queue.sqs_queue.arn
    ]
  }

  dynamic "statement" {
    for_each = var.topic_arn != null ? [1] : []
    content {
      effect = "Allow"

      actions = [
        "sqs:SendMessage"
      ]

      resources = [
        aws_sqs_queue.sqs_queue.arn
      ]

      condition {
        test     = "ArnEquals"
        variable = "aws:SourceArn"

        values = [
          var.topic_arn
        ]
      }
    }
  }
}

resource "aws_iam_policy" "sqs_queue" {
  count = var.role_name != null ? 1 : 0
  name  = aws_sqs_queue.sqs_queue.name

  policy = data.aws_iam_policy_document.sqs_queue[0].json
}

resource "aws_iam_role_policy_attachment" "sqs_queue" {
  count = var.role_name != null ? 1 : 0

  role       = var.role_name
  policy_arn = aws_iam_policy.sqs_queue[0].arn
}
