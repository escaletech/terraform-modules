resource "aws_cloudwatch_log_group" "logs" {
  depends_on = [ aws_ecs_task_definition.task_definition ]
  name = data.aws_cloudwatch_log_group.logs.name
  retention_in_days = var.retention_in_days
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
    {
      name      = var.family
      image     = var.image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          name          = "${var.family}-${var.container_port}-${var.protocol}"
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = var.protocol
          appProtocol   = var.app_protocol
        }
      ],
      logConfiguration : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group"         = aws_cloudwatch_log_group.logs.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "task"
          "awslogs-create-group"  = "true"
        }
      },
      environment = var.environment-variables
      secrets     = length(var.secrets) > 0 ? var.secrets : [],
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}
