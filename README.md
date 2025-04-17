[![FivexL](https://releases.fivexl.io/fivexlbannergit.jpg)](https://fivexl.io/)

# terraform-aws-ecs-events-to-slack

This module helps you to send AWS EventBrige events to Slack / Microsoft teams /Amazon Chine

## Description

This module creates EventBridge rules (`aws_cloudwatch_event_rule`) that:
1. Capture ECS events
2. Format them using `input_transformer` into the required format
3. Send them to a specified SNS topic

The SNS topic sends messages to Amazon Q Developer, which then distributes them to:
- Slack
- Amazon Chime
- Microsoft Teams

## Supported ECS Events

- ECS Task State Changes
- ECS Deployment State Changes
- ECS Service Actions


## Usage Example

```hcl
module "ecs_to_slack" {
  source = "../terraform-aws-ecs-events-to-slack"
  name   = "amazon_q_notifications"

  # Enable ECS task state change events
  enable_ecs_task_state_event_rule = true

  # Filter events for specific ECS cluster
  ecs_task_state_event_rule_detail = {
  clusterArn = ["arn:aws:ecs:us-east-1:123456789012:your-cluster/services"]
  }

  # SNS topic ARN for sending notifications to Amazon Q Developer
  sns_topic_arn = "arn:aws:sns:region:account-id:topic-name"
}
```

## Requirements

| Name      | Version   |
| --------- | --------- |
| terraform | >= 0.13.1 |
| aws       | >= 3.69   |

## Inputs

| Name                                   | Description                                                   | Type        | Default | Required |
| -------------------------------------- | ------------------------------------------------------------- | ----------- | ------- | :------: |
| name                                   | Name for all resources                                        | string      | -       |   yes    |
| sns_topic_arn                          | SNS topic ARN for sending notifications to Amazon Q Developer | string      | -       |   yes    |
| enable_ecs_task_state_event_rule       | Enable rule for ECS task state change events                  | bool        | true    |    no    |
| enable_ecs_deployment_state_event_rule | Enable rule for ECS deployment state change events            | bool        | true    |    no    |
| enable_ecs_service_action_event_rule   | Enable rule for ECS service action events                     | bool        | true    |    no    |
| custom_event_rules                     | Custom event rules                                            | any         | {}      |    no    |
| tags                                   | Tags for all resources                                        | map(string) | {}      |    no    |

## Message Format

The module formats events into the following format that is compatible with Amazon Q Developer:

```json
{
  "version": "1.0",
  "source": "custom",
  "id": "<event_id>",
  "content": {
    "textType": "client-markdown",
    "title": "<event_type>",
    "description": "<formatted_message>",
    "keywords": ["<region>"]
  },
  "metadata": {
    "threadId": "<event_id>",
    "summary": "<event_type>",
    "eventType": "<event_type>",
    "relatedResources": ["<resource_arns>"],
    "additionalContext": {
      "account": "<aws_account>",
      "time": "<event_time>"
    }
  }
}
```

## Additional Information

- [ECS Events Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_cwe_events.html)
- [EventBridge Patterns](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html)
- [EventBridge Input Transformation](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transform-target-input.html)
- [Amazon Q Developer Documentation](https://docs.aws.amazon.com/chatbot/latest/adminguide/what-is-chatbot.html)

## AWS Terraform Provider Versions

* version 0.1.2 is the last version that works with both Terraform AWS provider v3 and v4. There are no plans to update 0.1.X branch.
* all versions later (0.2.0 and above) require Terraform AWS provider v4 as a baseline

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name                                                                      | Version   |
| ------------------------------------------------------------------------- | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                   | >= 3.69   |

## Providers

| Name                                              | Version |
| ------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.69 |

## Resources

| Name                                                                                                                                                                                    | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule)                                                     | resource    |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target)                                                 | resource    |
| [aws_sns_topic.prod_chatbot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                                                     | resource    |
| [aws_sns_topic_policy.prod_chatbot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy)                                                       | resource    |
| [awscc_chatbot_slack_channel_configuration.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/chatbot_slack_channel_configuration)                     | resource    |
| [awscc_chatbot_microsoft_teams_channel_configuration.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/chatbot_microsoft_teams_channel_configuration) | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                                           | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                                             | data source |

## Inputs

| Name                                                                                                                                                           | Description                                                                                                                                                                                | Type     | Default                                                                    | Required |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | -------------------------------------------------------------------------- | :------: |
| <a name="input_cloudwatch_logs_retention_in_days"></a> [cloudwatch\_logs\_retention\_in\_days](#input\_cloudwatch\_logs\_retention\_in\_days)                  | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. | `number` | `14`                                                                       |    no    |
| <a name="input_custom_event_rules"></a> [custom\_event\_rules](#input\_custom\_event\_rules)                                                                   | A map of objects representing the custom EventBridge rule which will be created in addition to the default rules.                                                                          | `any`    | `{}`                                                                       |    no    |
| <a name="input_ecs_deployment_state_event_rule_detail"></a> [ecs\_deployment\_state\_event\_rule\_detail](#input\_ecs\_deployment\_state\_event\_rule\_detail) | The content of the `detail` section in the EvenBridge Rule for `ECS Deployment State Change` events. Use it to filter the events which will be processed and sent to Slack.                | `any`    | <pre>{<br>  "eventType": [<br>    "ERROR"<br>  ]<br>}</pre>                |    no    |
| <a name="input_ecs_service_action_event_rule_detail"></a> [ecs\_service\_action\_event\_rule\_detail](#input\_ecs\_service\_action\_event\_rule\_detail)       | The content of the `detail` section in the EvenBridge Rule for `ECS Service Action` events. Use it to filter the events which will be processed and sent to Slack.                         | `any`    | <pre>{<br>  "eventType": [<br>    "WARN",<br>    "ERROR"<br>  ]<br>}</pre> |    no    |