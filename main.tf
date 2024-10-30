terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "ecs_monitor_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "ecs_monitor_lambda_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ecs:UpdateService",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "monitor_schedule" {
  name                = "ecs-monitor-schedule"
  description         = "Schedule for ECS monitoring Lambda"
  schedule_expression = "rate(5 minutes)"
}

# CloudWatch Event Target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.monitor_schedule.name
  target_id = "ECSMonitorLambda"
  arn       = aws_lambda_function.monitor_lambda.arn
}

# Lambda Permission for CloudWatch Events
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowCloudWatchInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.monitor_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.monitor_schedule.arn
}

# Lambda Function
resource "aws_lambda_function" "monitor_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "ecs_task_monitor"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.9"
  timeout         = 30

  environment {
    variables = {
      CLUSTER_NAME     = var.ecs_cluster_name
      SERVICE_NAME     = var.ecs_service_name
      PAGERDUTY_TOKEN  = var.pagerduty_token
      PAGERDUTY_SERVICE_ID = var.pagerduty_service_id
      DESIRED_COUNT    = "2"
    }
  }
}