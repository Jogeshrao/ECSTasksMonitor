resource "aws_cloudwatch_metric_alarm" "ecs_task_count" {
  alarm_name          = "ecs-task-count-below-threshold"
  comparison_operator = "LessThan"
  evaluation_periods  = "2"
  metric_name        = "RunningTaskCount"
  namespace          = "AWS/ECS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.alarm_threshold
  alarm_description  = "This metric monitors ECS task count and alerts when it falls below ${var.alarm_threshold}"
  alarm_actions      = [aws_sns_topic.ecs_alerts.arn]
  ok_actions         = [aws_sns_topic.ecs_alerts.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}