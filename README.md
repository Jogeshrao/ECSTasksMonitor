# ECSTasksMonitor


I'll help you create a Terraform configuration for PagerDuty alerts integrated with AWS CloudWatch alarms for ECS task monitoring. I'll also provide the manual steps needed for PagerDuty setup.

First, let's go through the manual PagerDuty setup, then implement the AWS side with Terraform.

Manual Steps in PagerDuty:

Log in to PagerDuty

Create a new Service:

Go to Services → Add Service
Name: "ECS Task Monitor"
Integration Type: Select "AWS CloudWatch"
After creation, copy the Integration Key (you'll need this for Terraform)
Create an Escalation Policy:

Go to People → Escalation Policies → New
Set up your escalation rules
Assign team members and notification timeframes
Now, let's create the Terraform configuration with proper separation of concerns:

Terraform Configuration for PagerDuty and AWS CloudWatch Integration

variables.tf
providers.tf
sns.tf
cloudwatch.tf
outputs.tf
terraform.tfvars.example
To use this Terraform configuration:

Create a terraform.tfvars file based on the example provided and fill in your values:


aws_region = "your-region"
ecs_cluster_name = "your-cluster-name"
ecs_service_name = "your-service-name"
pagerduty_integration_key = "your-pagerduty-integration-key"
alarm_threshold = 2
Initialize and apply the Terraform configuration:


terraform init
terraform plan
terraform apply
This configuration:

Creates an SNS topic that will receive CloudWatch alarm notifications
Sets up a CloudWatch alarm that monitors ECS task count
Configures the alarm to trigger when task count is below 2 for two consecutive evaluation periods (10 minutes total)
Creates an SNS topic subscription that forwards alerts to PagerDuty
Uses proper security policies to allow CloudWatch to publish to the SNS topic
The files are organized as follows:

variables.tf: Defines all input variables
providers.tf: Configures the AWS provider
sns.tf: Sets up SNS topic and PagerDuty integration
cloudwatch.tf: Creates the CloudWatch alarm
outputs.tf: Defines useful output values
terraform.tfvars.example: Example variable values
The CloudWatch alarm will:

Monitor the ECS service every 5 minutes (300 seconds)
Trigger if the task count is below 2 for two consecutive checks
Send notifications to PagerDuty through SNS when the alarm state changes
Include both alarm and recovery notifications
Make sure to:

Replace the PagerDuty integration key with the one you copied from the PagerDuty service
Update the AWS region and ECS cluster/service names in your terraform.tfvars
Ensure your AWS credentials have the necessary permissions to create these resources
This setup provides a robust monitoring solution that will alert your team through PagerDuty whenever your ECS task count drops below the specified threshold.


Report Issue

183K daily tokens remaining.Subscribe to Pro for 50x more usage

