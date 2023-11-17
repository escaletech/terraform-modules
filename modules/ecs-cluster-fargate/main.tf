resource "aws_ecs_cluster" "ecs-cluster-fargate" {
  depends_on = [aws_service_discovery_http_namespace.default-ecs-cluster-fargate]
  name       = var.cluster_name

  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

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

resource "aws_service_discovery_http_namespace" "default-ecs-cluster-fargate" {
  name        = var.cluster_name
  description = "Default namespace"
}

#resource "aws_iam_role" "ecs_execution_role" {
#  name = "ecsTaskExecutionRole"
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [{
#      Action = "sts:AssumeRole",
#      Effect = "Allow",
#      Principal = {
#        Service = "ecs-tasks.amazonaws.com"
#      }
#    }]
#  })
#}

#resource "aws_iam_policy_attachment" "ecs_execution_policy_attachment" {
#  name       = "ecs-execution-policy-attachment"
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
#  roles      = data.aws_iam_role.ecstaskexecutinonrole.name
#}
