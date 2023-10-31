resource "aws_ecs_service" "ecs_service_update" {
  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = var.task_definition_arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets = var.subnets
    security_groups = var.security_groups
  }

  deployment_controller {
    type = "ECS"
  }

  enable_ecs_managed_tags = true

  tags = var.tags
}
