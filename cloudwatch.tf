resource "aws_cloudwatch_event_rule" "config_automation_execution_rule" {
  name        = "config-automation-execution"
  description = "Capture each time Config begins a remediation flow"

  event_pattern = <<EOF
{
  "source": ["aws.ssm"],
  "detail": {
    "eventSource": ["ssm.amazonaws.com"],
    "eventName": ["StartAutomationExecution"],
    "userIdentity.invokedBy": ["config.amazonaws.com"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "config_automation_execution_lambda_target" {
  rule      = aws_cloudwatch_event_rule.config_automation_execution_rule.name
  target_id = "SendToLambda"
  arn       = module.lambda_function.lambda_function_arn
}
