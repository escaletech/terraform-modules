output "application_id" {
  description = "The ID of the AppConfig application."
  value       = aws_appconfig_application.app.id
}

output "application_arn" {
  description = "The ARN of the AppConfig application."
  value       = aws_appconfig_application.app.arn
}

output "environment_id" {
  description = "The ID of the AppConfig environment."
  value       = aws_appconfig_environment.env.id
}

output "environment_arn" {
  description = "The ARN of the AppConfig environment."
  value       = aws_appconfig_environment.env.arn
}

output "configuration_profile_id" {
  description = "The ID of the AppConfig configuration profile."
  value       = aws_appconfig_configuration_profile.profile.id
}

output "configuration_version" {
  description = "The version number of the deployed configuration."
  value       = var.configuration_content != null ? aws_appconfig_hosted_configuration_version.config_version[0].version_number : null
}

output "deployment_strategy_id" {
  description = "The ID of the deployment strategy."
  value       = aws_appconfig_deployment_strategy.strategy.id
}
