resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = data.aws_iam_role.ecs_task_role.arn
  task_role_arn            = data.aws_iam_role.ecs_task_role.arn
  skip_destroy             = true

  container_definitions = jsonencode([
    {
      name      = var.family
      image     = var.image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          name          = "${var.container_port}-${var.family}-${var.protocol}"
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = var.protocol
        }
      ],
      logConfiguration : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group"         = var.family
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "task"
          "awslogs-create-group"  = "true"
        }
      },
      environment = var.environment-variables
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
