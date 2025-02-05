module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = ">= 7.0.0"

  function_name          = "${var.name}-lambda"
  description            = "Customize the messaging for Config remedations sent to Slack"
  handler                = "lambda_function.lambda_handler"
  runtime                = "python3.12"
  ephemeral_storage_size = 10240
  architectures          = ["x86_64"]
  create_package         = false

  local_existing_package = "${path.module}/function_code/my_deployment_package.zip"

  environment_variables = {
    "SNS_TOPIC_ARN"              = module.config_autoremediation_execution_sns.topic_arn
    "REMEDIATION_ROLE_ARN"       = var.config_remediation_role_arn
    "SSM_MAPPING_PARAMETER_NAME" = aws_ssm_parameter.config_custom_chatbot_notification_mapping_parameter.name
  }

  policy_statements = {
    sns_publish = {
      effect    = "Allow"
      actions   = ["sns:Publish"]
      resources = [module.config_autoremediation_execution_sns.topic_arn]
    }
    cw_execute_query = {
      effect = "Allow"
      actions = [
        "logs:GetQueryResults",
        "logs:PutQueryDefinition",
        "logs:StartQuery",
        "logs:StopQuery",
        "logs:GetQueryResults"
      ]
      resources = ["${var.cloudtrail_log_group_arn}*"]
    }
    parameter_store = {
      effect = "Allow"
      actions = [
        "ssm:GetParameter"
      ]
      resources = [aws_ssm_parameter.config_custom_chatbot_notification_mapping_parameter.arn]
    }

  }
}