resource "aws_sqs_queue" "sqs_queue" {
  name                      = "${var.name}-sqs-${var.environment}"
  delay_seconds             = var.delay_seconds
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_queue_dlq.arn
    maxReceiveCount     = 5
  })

  tags = var.tags
}

resource "aws_sqs_queue" "sqs_queue_dlq" {
  name = "${var.name}-dlq-${var.environment}"
  tags = var.tags
}
