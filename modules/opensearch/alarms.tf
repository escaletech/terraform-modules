# data "aws_lambda_function" "api_gateway_alarms" {
#   count = var.enable_alarms ? 1 : 0
#   function_name = "api-gateway-alarms-lambda-saas-alarmNotifier"
# }

# module "opensearch_sns_alarms" {
#   count   = var.enable_alarms ? 1 : 0
#   source  = "github.com/escaletech/terraform-modules/modules/sns"
#   name    = "opensearch_sns_alarms"
#   environment = "v0"
# }

# resource "aws_lambda_permission" "api_gateway_alarms_permission" {
#   count         = var.enable_alarms ? 1 : 0
#   statement_id  = "AllowSNSInvokeOpenSearch"
#   action        = "lambda:InvokeFunction"
#   function_name = data.aws_lambda_function.api_gateway_alarms[0].function_name
#   principal     = "sns.amazonaws.com"
#   source_arn    = module.opensearch_sns_alarms[0].topic_arn
# }

# resource "aws_sns_topic_subscription" "opensearch_sns_alarms_lambda" {
#   count     = var.enable_alarms ? 1 : 0
#   topic_arn = module.opensearch_sns_alarms[0].topic_arn
#   protocol  = "lambda"
#   endpoint  = data.aws_lambda_function.api_gateway_alarms[0].arn
# }

# resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
#   count               = var.enable_alarms ? 1 : 0
#   alarm_name          = "OpenSearch_CPU"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/ES"
#   period              = "300"
#   statistic           = "Average"
#   threshold           = "80"
#   datapoints_to_alarm = "1"
#   alarm_description   = "OpenSearch CPU Utilization > 60%"
#   alarm_actions       = [module.opensearch_sns_alarms[0].topic_arn]
#   ok_actions          = [module.opensearch_sns_alarms[0].topic_arn]
#   dimensions          = local.dimensions
# }

# # ... (adicione os outros alarms similares com count = var.enable_alarms ? 1 : 0 para cada recurso)
# # Nota: Faça o mesmo para disk_alarm, memory_alarm, autoscaling_alarm, autoscaling_alarm_down.
# # Para brevidade, mostro o padrão; aplique a todos.