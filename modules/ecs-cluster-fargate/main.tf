resource "aws_ecs_cluster" "ecs-cluster-fargate" {
  depends_on = [aws_service_discovery_http_namespace.default-ecs-cluster-fargate]
  name       = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights
  }

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
  service_connect_defaults {
    namespace = aws_service_discovery_http_namespace.default-ecs-cluster-fargate.arn
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "ecs-cluster-fargate" {
  cluster_name = aws_ecs_cluster.ecs-cluster-fargate.name

  default_capacity_provider_strategy {
    weight            = 1
    capacity_provider = var.capacity_provider
  }
}

resource "aws_service_discovery_http_namespace" "default-ecs-cluster-fargate" {
  name        = var.cluster_name
  description = "Default namespace"
}
