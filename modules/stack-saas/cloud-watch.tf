data "aws_lambda_function" "api_gateway_alarms" {
  function_name = "api-gateway-alarms-lambda-staging-alarmNotifier"
}

module "saas_sns_alarms" {
  source      = "github.com/escaletech/terraform-modules/modules/sns"
  name        = "saas_${var.client_name}_sns_alarms"
  environment = "v0"
}

resource "aws_lambda_permission" "api_gateway_alarms_permission" {
  statement_id  = "AllowSNSInvokeSaaS${var.client_name}"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.api_gateway_alarms.function_name
  principal     = "sns.amazonaws.com"

  source_arn = module.saas_sns_alarms.topic_arn
}

resource "aws_sns_topic_subscription" "saas_sns_alarms_lambda" {
  topic_arn = module.saas_sns_alarms.topic_arn
  protocol  = "lambda"
  endpoint  = data.aws_lambda_function.api_gateway_alarms.arn
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "EC2_Platform_Conversational_CPU_${var.client_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This alarm monitors CPU utilization > 80% ${var.client_name}"

  dimensions = {
    InstanceId = aws_instance.platform_conversational.id
  }

  alarm_actions = [module.saas_sns_alarms.topic_arn]
  ok_actions    = [module.saas_sns_alarms.topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "disk_alarm" {
  alarm_name          = "EC2_Platform_Conversational_DISK_${var.client_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This alarm monitors disk utilization > 70% ${var.client_name}"

  dimensions = {
    InstanceId = aws_instance.platform_conversational.id
  }

  alarm_actions = [module.saas_sns_alarms.topic_arn]
  ok_actions    = [module.saas_sns_alarms.topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm" {
  alarm_name          = "EC2_Platform_Conversational_MEM_${var.client_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This alarm monitors memory utilization > 80% ${var.client_name}"

  dimensions = {
    InstanceId = aws_instance.platform_conversational.id
  }

  alarm_actions = [module.saas_sns_alarms.topic_arn]
  ok_actions    = [module.saas_sns_alarms.topic_arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_alarm_high" {
  alarm_name          = "EC2_Platform_Conversational_MEM_HIGH_${var.client_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "300"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "This alarm monitors memory utilization > 90% ${var.client_name} and reboot ec2 instance."

  dimensions = {
    InstanceId = aws_instance.platform_conversational.id
  }

  alarm_actions = [
    module.saas_sns_alarms.topic_arn,
    "arn:aws:swf:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:action/actions/AWS_EC2.InstanceId.Reboot/1.0"
  ]

  ok_actions          = [module.saas_sns_alarms.topic_arn]
  datapoints_to_alarm = 1

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_containers_alarms" {
  for_each            = toset(var.containers_name)
  alarm_name          = "Containers_SaaS_Memory_${each.key}_${var.client_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUsageMB"
  namespace           = "SaaS-DockerMetrics-${var.client_name}"
  period              = "300"
  statistic           = "Average"
  threshold           = "6000"
  alarm_description   = "This alarm monitors memory container ${each.key} ${var.client_name} > 600MiB"

  dimensions = {
    ContainerName = "${each.key}"
  }

  alarm_actions = [module.saas_sns_alarms.topic_arn]
  ok_actions    = [module.saas_sns_alarms.topic_arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_containers_alarms" {
  for_each            = toset(var.containers_name)
  alarm_name          = "Containers_SaaS_CPU_${each.key}_${var.client_name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUsagePercent"
  namespace           = "SaaS-DockerMetrics-${var.client_name}"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This alarm monitors cpu container ${each.key}  ${var.client_name} > 70%"

  dimensions = {
    ContainerName = "${each.key}"
  }

  alarm_actions = [module.saas_sns_alarms.topic_arn]
  ok_actions    = [module.saas_sns_alarms.topic_arn]

  tags = var.tags
}