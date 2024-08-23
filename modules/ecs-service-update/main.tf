resource "aws_ecs_service" "ecs_service_update" {
  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = var.task_definition_arn
  desired_count   = var.desire_count

  capacity_provider_strategy {
    weight = var.spot ? 1 : 2
    capacity_provider = "FARGATE"
  }

  capacity_provider_strategy {
    weight = var.spot ? 2 : 0
    capacity_provider = "FARGATE_SPOT"
  }

  network_configuration {
    assign_public_ip = var.assign_public_ip
    subnets          = var.subnets
    security_groups  = var.security_groups
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [1] : []

    content {
      container_name   = var.service_name
      container_port   = var.container_port
      target_group_arn = var.target_group_arn
    }
  }

  enable_ecs_managed_tags = true

  tags = var.tags
}