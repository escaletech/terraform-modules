resource "aws_appautoscaling_target" "ecs-target" {
  count = var.auto_scaling ? 1 : 0

  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  count = var.auto_scaling ? 1 : 0

  name               = "${var.service_name}.as-policy-memory"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs-target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs-target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs-target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = var.memory_target
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  count = var.auto_scaling ? 1 : 0
  name = "${var.service_name}.as-policy-cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ecs-target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs-target.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs-target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = var.cpu_target
  }
}
