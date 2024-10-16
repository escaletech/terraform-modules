resource "aws_ecs_service" "ecs_service_update" {
  name            = var.service_name
  cluster         = var.cluster_name
  task_definition = var.task_definition_arn
  desired_count   = var.desire_count
  launch_type     = var.spot || var.ec2 ? null : "FARGATE"

  dynamic "network_configuration" {
    for_each = var.ec2 ? [] : [1]

    content {
      assign_public_ip = var.assign_public_ip
      subnets          = var.subnets
      security_groups  = var.security_groups
    }
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

  dynamic "capacity_provider_strategy" {
    for_each = var.ec2 ? [1] : []

    content {
      capacity_provider = var.cluster_name
      weight            = 1
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
    for_each = var.target_group_arn != null ? [1] : []

    content {
      container_name   = var.service_name
      container_port   = var.container_port
      target_group_arn = var.target_group_arn
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.ec2 ? [1] : []

    content {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    }
  }

 force_new_deployment = var.ec2 ? true : null
 
 dynamic "placement_constraints" {
  for_each = var.ec2 ? [1] : []

  content {
    type = "distinctInstance"
  }
 }

  enable_ecs_managed_tags = true

  tags = var.tags
}
