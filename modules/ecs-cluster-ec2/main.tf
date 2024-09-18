# resource "aws_launch_configuration" "ecs_instance" {
#   name          = "${var.cluster_name}-launch-configuration"
#   image_id      = data.aws_ami.ecs_optimized.id
#   instance_type = var.instance_type
#   key_name      = var.key_name

#   lifecycle {
#     create_before_destroy = true
#   }

#   user_data = <<-EOF
#               #!/bin/bash
#               echo ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster-ec2.name} >> /etc/ecs/ecs.config
#               EOF

#   security_groups = var.security_groups

#   root_block_device {
#     volume_size = 50
#     delete_on_termination = true
#   }
# }

# data "aws_ami" "ecs_optimized" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
#   }
# }

data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs_ec2" {
  name_prefix            = "demo-ecs-ec2-"
  image_id               = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ecs_node_sg.id]

  iam_instance_profile { arn = aws_iam_instance_profile.ecs_node.arn }
  monitoring { enabled = true }

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config;
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
    id      = aws_launch_template.ecs_ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-instance"
    propagate_at_launch = true
  }
}

# resource "aws_autoscaling_policy" "scale_up" {
#   name                   = "${var.cluster_name}-scale-up"
#   scaling_adjustment     = 1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.ecs_cluster.name
# }

# resource "aws_autoscaling_policy" "scale_down" {
#   name                   = "${var.cluster_name}-scale-down"
#   scaling_adjustment     = -1
#   adjustment_type        = "ChangeInCapacity"
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.ecs_cluster.name
# }

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