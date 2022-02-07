output "queue_arn" {
  value = aws_sqs_queue.sqs_queue.arn
}

output "queue_id" {
  value = aws_sqs_queue.sqs_queue.id
}
