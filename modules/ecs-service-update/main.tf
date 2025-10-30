resource "aws_ecs_service" "ecs_service_update" {
  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = var.task_definition_arn
  desired_count   = var.desire_count
  launch_type     = var.spot ? null : "FARGATE"

  network_configuration {
    assign_public_ip = var.assign_public_ip
    subnets          = var.subnets
    security_groups  = var.security_groups
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.spot ? [1] : []

    content {
      capacity_provider = "FARGATE"
      weight            = var.spot_staging ? 1 : var.weight_fargate
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.spot ? [1] : []

    content {
      capacity_provider = "FARGATE_SPOT"
      weight            = var.spot_staging ? 2 : var.weight_fargate_spot
    }
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  dynamic "load_balancer" {
    for_each = try(length(var.load_balancers), 0) > 0 ? var.load_balancers : (
      var.target_group_arn != null ? [
        {
          container_name   = var.service_name
          container_port   = var.container_port
          target_group_arn = var.target_group_arn
        }
      ] : []
    )

    content {
      container_name   = try(load_balancer.value.container_name, var.service_name)
      container_port   = load_balancer.value.container_port
      target_group_arn = load_balancer.value.target_group_arn
    }
  }

  enable_ecs_managed_tags = true

  tags = var.tags
}
