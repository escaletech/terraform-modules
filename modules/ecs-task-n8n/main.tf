# =============================================
# Locals para port mappings (seu código original mantido)
# =============================================
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

# =============================================
# Módulo EFS separado (um EFS por chamada do ecs-task)
# =============================================
module "efs" {
  source = "github.com/escaletech/terraform-modules/modules/efs"
  
  service_name                  = var.family
  vpc_id                        = var.vpc_id
  subnet_ids                    = var.subnet_ids
  ecs_task_security_group_ids   = [var.ecs_task_sg_id]  # ou aws_security_group.seu_sg.id
  tags                          = var.tags

  # Opcionais (pode remover se usar defaults)
  performance_mode              = "generalPurpose"
  throughput_mode               = "bursting"
  transition_to_ia              = "AFTER_30_DAYS"
  efs_mount_path                = "/home/node"
  uid                           = 1000
  gid                           = 1000
  root_permissions              = "0755"
}

# =============================================
# Task Definition com EFS integrado + depends_on
# =============================================
resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  skip_destroy             = true

  # Dependência explícita: task só é criada após EFS + mount targets + access point
  depends_on = [
    module.efs
  ]

  # Volume EFS (monta o filesystem inteiro via Access Point)
  volume {
    name = "n8n-efs-volume"

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

        # Mount point do EFS (substitui o /home/node local pelo EFS)
        mountPoints = [
          {
            sourceVolume  = "n8n-efs-volume"
            containerPath = "/home/node"
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