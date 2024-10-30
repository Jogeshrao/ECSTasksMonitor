variable "ecs_cluster_name" {
  type        = string
  description = "Name of the ECS cluster to monitor"
}

variable "ecs_service_name" {
  type        = string
  description = "Name of the ECS service to monitor"
}

variable "pagerduty_token" {
  type        = string
  description = "PagerDuty API token"
  sensitive   = true
}

variable "pagerduty_service_id" {
  type        = string
  description = "PagerDuty service ID"
}