resource "awscc_chatbot_slack_channel_configuration" "this" {

  configuration_name = "${var.name}-chatbot-configuration"
  guardrail_policies = ["arn:aws:iam::aws:policy/AWSAccountActivityAccess"]
  iam_role_arn       = aws_iam_role.chatbot_role.arn
  logging_level      = "INFO"
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  user_role_required = false

  sns_topic_arns = [module.config_autoremediation_execution_sns.topic_arn]
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

resource "aws_iam_role" "chatbot_role" {
  assume_role_policy = data.aws_iam_policy_document.chatbot.json
  name               = "${var.name}-chatbot-role"
}

resource "aws_iam_policy" "chatbot_policy" {
  name        = "chatbot-policy"
  description = "Policy for Chatbot"

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

resource "aws_iam_role_policy_attachment" "role_attachment" {
  role       = aws_iam_role.chatbot_role.name
  policy_arn = aws_iam_policy.chatbot_policy.arn
}