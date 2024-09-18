resource "aws_launch_configuration" "ecs_instance" {
  name          = "${var.cluster_name}-launch-configuration"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = var.instance_type
  key_name      = var.key_name

  lifecycle {
    create_before_destroy = true
  }

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.ecs-cluster-ec2.name} >> /etc/ecs/ecs.config
              EOF

  security_groups = var.security_groups

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 50
    delete_on_termination = true
  }
}

data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_autoscaling_group" "ecs_cluster" {
  name                 = var.cluster_name
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = var.subnet_ids
  launch_configuration = aws_launch_configuration.ecs_instance.id

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

  tags = var.tags
}

resource "aws_ecs_capacity_provider" "ecs_cluster" {
  name = var.cluster_name
  
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_cluster.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status = "ENABLED"
      target_capacity = 3
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