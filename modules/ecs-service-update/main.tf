resource "aws_ecs_service" "ecs_service_update" {
  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = var.task_definition_arn
  launch_type     = "FARGATE"
  desired_count   = var.desire_count
  #iam_role       = var.iam_role

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      weight            = capacity_provider_strategy.value.weight
      capacity_provider = capacity_provider_strategy.value.capacity_provider
    }
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
