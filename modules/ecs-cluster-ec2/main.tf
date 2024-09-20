data "aws_ssm_parameter" "ecs-node-ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs-cluster" {
  name_prefix            = "${var.cluster_name}-launch-template"
  image_id               = data.aws_ssm_parameter.ecs-node-ami.value
  instance_type          = var.instance_type
  vpc_security_group_ids = var.security_groups
  key_name               = var.key_name

  iam_instance_profile { arn = aws_iam_instance_profile.ecs_node.arn }
  monitoring { enabled = true }

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster-ec2.name} >> /etc/ecs/ecs.config;
    EOF
  )
}

resource "aws_autoscaling_group" "ecs_cluster" {
  name                      = var.cluster_name
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  vpc_zone_identifier       = var.subnet_ids
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.ecs-cluster.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.cluster_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ecs_cluster.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.cluster_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ecs_cluster.name
}

resource "aws_ecs_cluster" "ecs-cluster-ec2" {
  name = var.cluster_name

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
    namespace = aws_service_discovery_http_namespace.ecs-cluster-ec2.arn
  }

  tags = var.tags

  depends_on = [aws_service_discovery_http_namespace.ecs-cluster-ec2]
}

resource "aws_service_discovery_http_namespace" "ecs-cluster-ec2" {
  name        = var.cluster_name
  description = "Default namespace"
}

resource "aws_ecs_capacity_provider" "ecs_cluster" {
  name = var.cluster_name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_cluster.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster" {
  cluster_name = aws_ecs_cluster.ecs-cluster-ec2.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_cluster.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_cluster.name
  }
}