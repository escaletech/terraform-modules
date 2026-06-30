locals {
  provided_port_mappings = var.port_mappings != null ? var.port_mappings : []

  base_port_mappings = (
    length(local.provided_port_mappings) > 0 ?
    local.provided_port_mappings :
    [
      {
        container_port = 2022
        host_port      = 2022
        protocol       = "tcp"
        name           = "${var.family}-2022-tcp"
      },
      {
        container_port = 8080
        host_port      = 8080
        protocol       = "tcp"
        app_protocol   = "http"
        name           = "${var.family}-8080-tcp"
      }
    ]
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

  volume_name = coalesce(var.volume_name, "sftpgo-efs-volume")
}

module "efs" {
  source = "github.com/escaletech/terraform-modules/modules/efs"

  service_name                = var.family
  vpc_id                      = var.vpc_id
  subnet_ids                  = var.subnet_ids
  ecs_task_security_group_ids = [var.ecs_task_sg_id]
  tags                        = var.tags

  performance_mode       = "generalPurpose"
  throughput_mode        = "bursting"
  transition_to_ia       = "AFTER_30_DAYS"
  access_point_root_path = var.access_point_root_path
  uid                    = var.efs_uid
  gid                    = var.efs_gid
  root_permissions       = "0755"
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

  depends_on = [
    module.efs
  ]

  volume {
    name = local.volume_name

    efs_volume_configuration {
      file_system_id     = module.efs.file_system_id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = module.efs.access_point_id
        iam             = "ENABLED"
      }
    }
  }

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

        mountPoints = [
          {
            sourceVolume  = local.volume_name
            containerPath = var.efs_mount_path
            readOnly      = false
          }
        ]
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
