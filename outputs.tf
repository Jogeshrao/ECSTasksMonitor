output "lambda_function_name" {
  value       = aws_lambda_function.monitor_lambda.function_name
  description = "Name of the created Lambda function"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.monitor_lambda.arn
  description = "ARN of the created Lambda function"
}

output "cloudwatch_rule_arn" {
  value       = aws_cloudwatch_event_rule.monitor_schedule.arn
  description = "ARN of the CloudWatch Event Rule"
}