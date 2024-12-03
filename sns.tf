resource "aws_sns_topic" "ecs_alerts" {
  name = "ecs-task-count-alerts"
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.ecs_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowCloudWatchAlarms"
        Effect   = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.ecs_alerts.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "pagerduty" {
  topic_arn = aws_sns_topic.ecs_alerts.arn
  protocol  = "https"
  endpoint  = "https://events.pagerduty.com/integration/${var.pagerduty_integration_key}/enqueue"
}