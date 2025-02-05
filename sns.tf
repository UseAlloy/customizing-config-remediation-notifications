module "config_autoremediation_execution_sns" {

  source  = "terraform-aws-modules/sns/aws"
  version = ">= 6.0.0"

  name                        = "${var.name}-sns-topic"
  create_topic_policy         = true
  enable_default_topic_policy = true

  topic_policy_statements = {
    pub = {
      actions = ["sns:Publish"]
      principals = [{
        type        = "Service"
        identifiers = ["events.amazonaws.com"]
      }]
    },

    receive = {
      actions = [
        "SNS:Subscribe",
        "SNS:SetTopicAttributes",
        "SNS:RemovePermission",
        "SNS:Receive",
        "SNS:Publish",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:DeleteTopic",
      "SNS:AddPermission", ]
      principals = [{
        type        = "AWS"
        identifiers = ["*"]
      }]
    },
  }
}
