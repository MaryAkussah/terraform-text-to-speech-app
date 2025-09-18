output "s3_bucket_website_url" {
  value = aws_s3_bucket_website_configuration.tts_site_website.website_endpoint
}

output "api_gateway_endpoint" {
  value = aws_apigatewayv2_stage.prod_stage.invoke_url
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.tts_user_pool.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.tts_user_pool_client.id
}



output "s3_lifecycle_policy" {
  description = "S3 lifecycle policy for audio files cleanup"
  value = "Audio files will be automatically deleted after 7 days"
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups for monitoring"
  value = {
    lambda_logs     = aws_cloudwatch_log_group.lambda_logs.name
    api_gateway_logs = aws_cloudwatch_log_group.api_gateway_logs.name
  }
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alerts"
  value = aws_sns_topic.alerts.arn
}

output "monitoring_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:dashboard/${aws_cloudwatch_dashboard.tts_dashboard.dashboard_name}"
}

