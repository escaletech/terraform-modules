# locals {
#   log_group_exists = try(data.aws_cloudwatch_log_group.logs.name, null) != null ? true : false
# }
#
# resource "aws_cloudwatch_log_group" "logs" {
#   count = local.log_group_exists ? 0 : 1
#
#   name = var.family
#   retention_in_days = var.retention_in_days
# }

locals {
  provided_port_mappings = var.port_mappings != null ? var.port_mappings : []

  base_port_mappings = (
    length(local.provided_port_mappings) > 0 ?
    local.provided_port_mappings :
    (
      var.container_port != null ?
      [
        {
          container_port = var.container_port
          host_port      = var.container_port
          protocol       = var.protocol
          app_protocol   = var.app_protocol
          name           = "${var.family}-${var.container_port}-${var.protocol}"
        }
      ] :
      []
    )
  )

  normalized_port_mappings = [
    for mapping in local.base_port_mappings : {
      for key, value in {
        containerPort = mapping.container_port
        hostPort      = lookup(mapping, "host_port", mapping.container_port)
        protocol      = lookup(mapping, "protocol", "tcp")
        appProtocol   = lookup(mapping, "app_protocol", null)
        name          = lookup(mapping, "name", null)
      } : key => value if value != null
    }
  ]
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  skip_destroy             = true

  container_definitions = jsonencode([
    merge(
      {
        name      = var.family
        image     = var.image
        cpu       = var.cpu
        memory    = var.memory
        essential = true
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = var.family
            awslogs-region        = data.aws_region.current.name
            awslogs-stream-prefix = "task"
            awslogs-create-group  = "true"
          }
        }
        environment = var.environment-variables
        secrets     = length(var.secrets) > 0 ? var.secrets : []
      },
      length(local.normalized_port_mappings) > 0 ? {
        portMappings = local.normalized_port_mappings
      } : {}
    )
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.cpu_architecture
  }
}
