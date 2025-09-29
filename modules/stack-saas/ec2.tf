resource "aws_instance" "platform_conversational" {

  depends_on = [aws_security_group.opensource]

  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.subnet_private_staging.ids[1]
  vpc_security_group_ids = [aws_security_group.opensource.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.platform_conversational_iam_profile.name
  root_block_device {
    volume_size = 50
  }

  user_data = <<-EOT
    #!/bin/bash
    # Atualizar e instalar pacotes necessários
    sudo yum update -y
    sudo yum install -y nfs-utils docker amazon-cloudwatch-agent htop

    # Iniciar e habilitar o Docker
    sudo systemctl start docker
    sudo systemctl enable docker

    # Configurar o daemon.json para o Docker
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<EOF
    {
      "hosts": ["tcp://0.0.0.0:2375", "unix:///var/run/docker.sock"],
      "log-driver": "json-file",
      "log-opts": {
        "max-size": "50m",
        "max-file": "5"
      }
    }
    EOF

    # Configurar o override.conf para o Docker
    sudo mkdir -p /etc/systemd/system/docker.service.d
    sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF
    [Service]
    ExecStart=
    ExecStart=/usr/bin/dockerd
    EOF

    # Aplicar permissões e reiniciar o Docker
    sudo chmod 644 /etc/docker/daemon.json
    sudo systemctl daemon-reload
    sudo systemctl restart docker

    # Configurar o CloudWatch Agent
    sudo mkdir -p /usr/share/collectd
    sudo touch /usr/share/collectd/types.db
    sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json <<EOF
    {
      "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "root"
      },
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/docker.log",
                "log_group_name": "docker-logs",
                "log_stream_name": "{instance_id}",
                "retention_in_days": 30
              }
            ]
          }
        }
      },
      "metrics": {
        "aggregation_dimensions": [
          ["InstanceId"]
        ],
        "append_dimensions": {
          "AutoScalingGroupName": "\$${aws:AutoScalingGroupName}",
          "ImageId": "\$${aws:ImageId}",
          "InstanceId": "\$${aws:InstanceId}",
          "InstanceType": "\$${aws:InstanceType}"
        },
        "metrics_collected": {
          "collectd": {
            "metrics_aggregation_interval": 60
          },
          "disk": {
            "measurement": ["used_percent"],
            "metrics_collection_interval": 60,
            "resources": ["*"]
          },
          "mem": {
            "measurement": ["mem_used_percent"],
            "metrics_collection_interval": 60
          },
          "statsd": {
            "metrics_aggregation_interval": 60,
            "metrics_collection_interval": 10,
            "service_address": ":8125"
          },
          "docker": {
            "measurement": [
              "docker_container_cpu_usage",
              "docker_container_memory_usage",
              "docker_container_memory_limit",
              "docker_container_network_receive_bytes",
              "docker_container_network_transmit_bytes"
            ],
            "metrics_collection_interval": 60,
            "resources": ["*"]
          }
        }
      }
    }
    EOF

    # Iniciar e habilitar o CloudWatch Agent
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
  EOT

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "ec2/platform-conversational-${var.client_name}"
  retention_in_days = 14
  tags              = var.tags
}