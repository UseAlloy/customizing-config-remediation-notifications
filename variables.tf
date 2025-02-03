variable "name" {
  description = "Base name for resources created"
  type        = string
  default     = "customizing-config-remediation-notifications"
}

variable "config_remediation_role_arn" {
  description = "ARN of the global IAM role used for remediation"
  type        = string
}

variable "cloudtrail_log_group_arn" {
  description = "ARN of the CloudTrail log group"
  type        = string
}

variable "slack_channel_id" {
  description = "The id of the Slack channel"
  type        = string
}

variable "slack_workspace_id" {
  description = "The id of the Slack workspace"
  type        = string
}