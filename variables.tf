# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "role_name" {
  description = "The string which will be used for the name of Lambda IAM role"
  type        = string
  default     = null
}

variable "enable_ecs_task_state_event_rule" {
  description = "Enable ECS task state change event rule"
  type        = bool
  default     = false
}

variable "enable_ecs_deployment_state_event_rule" {
  description = "Enable ECS deployment state change event rule"
  type        = bool
  default     = false
}

variable "enable_ecs_service_action_event_rule" {
  description = "Enable ECS service action event rule"
  type        = bool
  default     = false
}

variable "ecs_task_state_event_rule_detail" {
  description = "ECS task state change event rule detail"
  type        = map(list(string))
  default     = {}
}

variable "ecs_deployment_state_event_rule_detail" {
  description = "ECS deployment state change event rule detail"
  type        = map(list(string))
  default     = {}
}

variable "ecs_service_action_event_rule_detail" {
  description = "ECS service action event rule detail"
  type        = map(list(string))
  default     = {}
}

variable "custom_event_rules" {
  description = "Custom event rules"
  type = map(object({
    detail-type = list(string)
    detail      = map(list(string))
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "recreate_missing_package" {
  description = "Whether to recreate missing Lambda package if it is missing locally or not."
  type        = bool
  default     = true
}

variable "cloudwatch_logs_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
  type        = number
  default     = 14
}

variable "lambda_memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime. Valid value between 128 MB to 10,240 MB (10 GB), in 64 MB increments."
  type        = number
  default     = 256
}

variable "slack_config" {
  description = "Slack configuration, example: slack_config= {channel_id = '' workspace_id = ''}"
  type        = any
  default     = {}
}

variable "teams_config" {
  description = "Microsoft Teams configuration"
  type        = any
  default     = {}
}
