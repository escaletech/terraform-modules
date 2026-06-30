output "task_definition_arn" {
  description = "ARN da definição de tarefa ECS criada."
  value       = aws_ecs_task_definition.task_definition.arn
}

output "task_role_arn" {
  description = "ARN da task role IAM."
  value       = aws_iam_role.ecs_task_role.arn
}
