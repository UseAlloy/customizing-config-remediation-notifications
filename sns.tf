data "aws_iam_policy_document" "config_autoremediation_execution_sns_topic_policy" {
  policy_id = "SNS Topic Policy"

  statement {
    sid = "allow account to receive events"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      module.config_autoremediation_execution_sns.topic_arn,
    ]
  }

  statement {
    sid = "allow events to publish to topic"
    actions = [
      "SNS:Publish"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    resources = [
      module.config_autoremediation_execution_sns.topic_arn,
    ]
  }
}

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
        type        = "AWS"
        identifiers = ["events.amazonaws.com"]
      }]
    },
  }
}
