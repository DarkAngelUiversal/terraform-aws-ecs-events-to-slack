#tfsec:ignore:AWS016 This SNS topic  is for observability
resource "aws_sns_topic" "ecs_events" {
  name_prefix = "ecs_events_${var.ecs_cluster_name}"
  tags        = var.tags
}

data "aws_iam_policy_document" "sns_ecs_events" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]
    resources = [
      aws_sns_topic.ecs_events.arn
    ]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_sns_topic_policy" "ecs_events" {
  arn    = aws_sns_topic.ecs_events.arn
  policy = data.aws_iam_policy_document.sns_ecs_events.json
}

resource "aws_cloudwatch_event_rule" "ecs_task" {
  name_prefix   = "ecs_task_${var.ecs_cluster_name}"
  event_pattern = <<EOF
{
  "source": [
    "aws.ecs"
  ],
  "detail-type": [
    "ECS Task State Change"
  ],
  "detail": {
    "clusterArn": [
      "${data.aws_ecs_cluster.this.arn}"
    ],
    "lastStatus": [
      "STOPPED"
    ]
  }
}
EOF
  tags          = var.tags
}

resource "aws_cloudwatch_event_rule" "ecs_service" {
  name_prefix   = "ecs_service_${var.ecs_cluster_name}"
  event_pattern = <<EOF
{
  "source": [
    "aws.ecs"
  ],
  "detail-type": [
    "ECS Service Action"
  ],
  "detail": {
    "clusterArn": [
      "${data.aws_ecs_cluster.this.arn}"
    ],
    "eventType": [
      "WARN",
      "ERROR"
    ]
  }
}
EOF
  tags          = var.tags
}

resource "aws_cloudwatch_event_rule" "ecs_deployment" {
  name_prefix   = "ecs_deployment_${var.ecs_cluster_name}"
  event_pattern = <<EOF
{
  "source": [
    "aws.ecs"
  ],
  "detail-type": [
    "ECS Deployment State Change"
  ],
  "detail": {
    "eventType": [
      "ERROR"
    ]
  }
}
EOF
  tags          = var.tags
}

resource "aws_cloudwatch_event_target" "ecs_task" {
  target_id = "ecs_task_${var.ecs_cluster_name}"
  arn       = aws_sns_topic.ecs_events.arn
  rule      = aws_cloudwatch_event_rule.ecs_task.name
}

resource "aws_cloudwatch_event_target" "ecs_service" {
  target_id = "ecs_service_${var.ecs_cluster_name}"
  arn       = aws_sns_topic.ecs_events.arn
  rule      = aws_cloudwatch_event_rule.ecs_service.name
}

resource "aws_cloudwatch_event_target" "ecs_deployment" {
  target_id = "ecs_deployment_${var.ecs_cluster_name}"
  arn       = aws_sns_topic.ecs_events.arn
  rule      = aws_cloudwatch_event_rule.ecs_deployment.name
}

module "slack_notifications" {
  source                            = "terraform-aws-modules/lambda/aws"
  version                           = "2.5.0"
  function_name                     = "ecs_slack_notifications_${var.ecs_cluster_name}"
  description                       = "Used to receive events from EventBridge via SNS and send them to Slack"
  handler                           = "slack_notifications.lambda_handler"
  source_path                       = "${path.module}/functions/slack_notifications.py"
  runtime                           = "python3.8"
  timeout                           = 30
  publish                           = true
  cloudwatch_logs_retention_in_days = 14
  allowed_triggers = {
    AllowExecutionFromSNS = {
      principal  = "sns.amazonaws.com"
      source_arn = aws_sns_topic.ecs_events.arn
    }
  }
  environment_variables = {
    SKIP_TASK_STOP_CODES      = join(",", var.skip_task_stop_codes)
    SKIP_TASK_STOPPED_REASONS = join(",", var.skip_task_stopped_reasons)
    HOOK_URL                  = var.slack_hook_url
    LOG_EVENTS                = "True" # For enable please use - "True"
  }
  tags = var.tags
}

resource "aws_sns_topic_subscription" "sns_notify_slack" {
  topic_arn = aws_sns_topic.ecs_events.arn
  protocol  = "lambda"
  endpoint  = module.slack_notifications.lambda_function_arn
}

