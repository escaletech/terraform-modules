resource "aws_cloudwatch_event_rule" "autoscaling" {
  count = var.enable_event_bridge ? 1 : 0
  for_each = {
    ScaleUp   = { alarmName = "OpenSearch_Scale_Up", cloudWatch_alarm = aws_cloudwatch_metric_alarm.autoscaling_alarm[0].arn },
    ScaleDown = { alarmName = "OpenSearch_Scale_Down", cloudWatch_alarm = aws_cloudwatch_metric_alarm.autoscaling_alarm_down[0].arn }
  }

  name        = each.value.alarmName
  description = each.value.alarmName
  state       = "ENABLED"

  event_pattern = jsonencode({
    "detail-type" = ["CloudWatch Alarm State Change"]
    "resources"   = [each.value.cloudWatch_alarm]
    "source"      = ["aws.cloudwatch"]
  })
}

# ... (adicione count = var.enable_event_bridge ? 1 : 0 para os outros recursos: aws_cloudwatch_event_target, aws_lambda_permission)