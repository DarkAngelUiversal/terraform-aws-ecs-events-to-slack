provider "aws" {
  region = "us-east-1"
}

data "aws_ecs_cluster" "this" {
  cluster_name = "EXAMPLE-CLUSTER-NAME"
}

module "ecs_to_slack" {
  source            = "../terraform-aws-ecs-events-to-slack"
  name              = "amazon_q_notifications"


  # Process events "ECS Task State Change"
  # Find more infro here https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns-content-based-filtering.html
  ecs_task_state_event_rule_detail = {
    clusterArn = [data.aws_ecs_cluster.this.arn],                  # Filter by this ECS cluster ARN,
    group      = ["service:EXAMPLE-SERVICE-NAME"]                  # and only from this ECS service,
    lastStatus = ["STOPPED"]                                       # and only when the task is stopped,
    stopCode   = [{ "anything-but" = "EssentialContainerExited" }] # but not with this stopCode
  }

  # Skip all events "ECS Deployment State Change"
  ecs_deployment_state_event_rule_detail = {}

  # Process all events "ECS Service Action"
  ecs_service_action_event_rule_detail = {
    clusterArn = [data.aws_ecs_cluster.this.arn],                     # Filter by this ECS cluster ARN,
    eventName  = [{ "anything-but" = "SERVICE_TASK_START_IMPAIRED" }] # and only with this eventName
  }

  custom_event_rules = {
    # Custom rule which triggers on all started tasks of a certain service
    ECSTaskStateChange_Started = {
      detail-type = ["ECS Task State Change"]
      detail = {
        clusterArn = [data.aws_ecs_cluster.this.arn],
        lastStatus = ["STARTED"]
        group      = ["service:EXAMPLE-SERVICE-NAME"]
      }
    }

    # Custom rule which triggers on all stopped tasks with non-zero exit code of the essential container
    ECSTaskStateChange_StoppedNonZero = {
      detail-type = ["ECS Task State Change"]
      detail = {
        clusterArn = [data.aws_ecs_cluster.this.arn],
        lastStatus = ["STOPPED"]
        stopCode   = "EssentialContainerExited"
        containers = {
          exitCode = [{ "anything-but" = 0 }]
        }
      }
    }
  slack_config = {
    channel_id   = "1234567890"  # Your Slack workspace ID
    workspace_id = "1234567890"   # Your Slack channel ID
  }
  #Testing is required for teams
  # teams_config = {
  #   team_id         = "1234567890" # Your Teams id ID
  #   channel_id      = "1234567890" # Your Teams channel ID
  #   teams_tenant_id = "1234567890" # Your Teams tenant ID
  # }
  }
}


module "ecs_to_slack_no_jenkins" {
  source            = "../../"
  name              = "ecs-to-slack"


  ecs_task_state_event_rule_detail = {
    lastStatus    = ["STOPPED"]
    stoppedReason = [{ "anything-but" = "Stopped by Jenkins Amazon ECS PlugIn" }] # filter out jenkins ecs plugin events
  }
  slack_config = {
    channel_id   = "1234567890" # Your Slack workspace ID
    workspace_id = "1234567890" # Your Slack channel ID
  }
  # teams_config = {
  #   team_id         = "1234567890" # Your Teams id ID
  #   channel_id      = "1234567890" # Your Teams channel ID
  #   teams_tenant_id = "1234567890" # Your Teams tenant ID
  # }
}
