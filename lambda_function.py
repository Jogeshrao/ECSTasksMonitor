import os
import boto3
import json
import requests
from datetime import datetime

def send_pagerduty_alert(message):
    headers = {
        'Authorization': f"Token token={os.environ['PAGERDUTY_TOKEN']}",
        'Content-Type': 'application/json',
        'Accept': 'application/vnd.pagerduty+json;version=2'
    }
    
    payload = {
        "incident": {
            "type": "incident",
            "title": "ECS Task Count Alert",
            "service": {
                "id": os.environ['PAGERDUTY_SERVICE_ID'],
                "type": "service_reference"
            },
            "body": {
                "type": "incident_body",
                "details": message
            }
        }
    }
    
    response = requests.post(
        'https://api.pagerduty.com/incidents',
        headers=headers,
        json=payload
    )
    return response.status_code == 201

def update_ecs_service(ecs_client, cluster, service):
    try:
        response = ecs_client.update_service(
            cluster=cluster,
            service=service,
            desiredCount=int(os.environ['DESIRED_COUNT'])
        )
        return True
    except Exception as e:
        print(f"Error updating ECS service: {str(e)}")
        return False

def handler(event, context):
    ecs_client = boto3.client('ecs')
    cluster_name = os.environ['CLUSTER_NAME']
    service_name = os.environ['SERVICE_NAME']
    desired_count = int(os.environ['DESIRED_COUNT'])
    
    try:
        # Get running tasks
        tasks_response = ecs_client.list_tasks(
            cluster=cluster_name,
            serviceName=service_name
        )
        
        task_count = len(tasks_response['taskArns'])
        
        if task_count < desired_count:
            message = f"Alert: Only {task_count} tasks running in cluster {cluster_name}. Expected {desired_count} tasks."
            print(message)
            
            # Send PagerDuty alert
            alert_sent = send_pagerduty_alert(message)
            
            # Attempt to restore desired count
            service_updated = update_ecs_service(ecs_client, cluster_name, service_name)
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'message': message,
                    'alert_sent': alert_sent,
                    'service_updated': service_updated
                })
            }
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f"Task count is normal: {task_count} tasks running"
            })
        }
        
    except Exception as e:
        error_message = f"Error monitoring ECS tasks: {str(e)}"
        print(error_message)
        return {
            'statusCode': 500,
            'body': json.dumps({'error': error_message})
        }