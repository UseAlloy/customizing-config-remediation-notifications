resource "awscc_chatbot_slack_channel_configuration" "this" {

  configuration_name = "${var.name}-chatbot-configuration"
  guardrail_policies = ["arn:aws:iam::aws:policy/AWSAccountActivityAccess"]
  iam_role_arn       = aws_iam_role.security_chatbot_role.arn
  logging_level      = "INFO"
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  user_role_required = false

  sns_topic_arns = []
}

data "aws_iam_policy_document" "chatbot" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "security_chatbot_role" {
  assume_role_policy = data.aws_iam_policy_document.chatbot.json
  name               = "AWSChatbot-security-alerting"
  path               = "/service-role/"

  inline_policy {
    name = "cloudwatch"
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "cloudwatch:Describe*",
            "cloudwatch:Get*",
            "cloudwatch:List*"
          ]
          Effect   = "Allow"
          Resource = ["*"]
        }
      ]
    })
  }

  inline_policy {
    name = "kms"
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "kms:DescribeKey",
            "kms:ListKeys"
          ]
          Effect   = "Allow"
          Resource = ["*"]
        },
        {
          Action = [
            "kms:Descrypt"
          ]
          Effect   = "Allow"
          Resource = [data.aws_kms_key.sns_key.arn]
        }
      ]
    })
  }

  inline_policy {
    name = "sns"
    policy = jsonencode({
      Statement = [
        {
          Action = [
            "sns:Get*",
            "sns:List*"
          ]
          Effect   = "Allow"
          Resource = ["*"]
        }
      ]
    })
  }
}