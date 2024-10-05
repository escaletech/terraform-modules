output "task_definition_arn" {
  description = "ARN da definição de tarefa ECS criada."
  value       = aws_ecs_task_definition.task_definition.arn
}

output "log_group_exists" {
  value = local.log_group_exists
}