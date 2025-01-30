variable "name" {
  description = "Name for things"
  type        = string
  default     = "customizing-config-remediation-notifications"
}

variable "config_remediation_role_arn" {
  description = "ARN of the global IAM role used for remediation"
  type        = string
}

variable "sns_topic_name" {
  description = "Name of SNS topic for delivery notifications"
  type        = string
  default     = null
}

variable "cloudtrail_log_group_arn" {
  description = "ARN of the CloudTrail log group"
  type        = string
}

variable "slack_channel_id" {}
variable "slack_workspace_id" {}