## Required Inputs
- `config_remediation_role_arn` - the role ARN which is assumed by ssm.amazonaws.com to execute SSM Documents to remediate resources
- `cloudtrail_log_group_arn` - the ARN of the CloudTrail CloudWatch log group in the same account where this infrastructure is deployed. At the moment, the infrastructure doesn't support cross account role assumption. However, if you set the resource policy on the CloudWatch log group to allow cross-account access from the lambda role, the existing infrastructure can be used without modification.
- `slack_channel_id` - The id of the Slack channel where Chatbot will post messages
- `slack_workspace_id` - The id of the Slack workspace where the slack_channel_id resides.

## Pre-requisite Set Up Steps
- You must manually enable AWS Chatbot (Amazon Q Developer in chat applications) the first time in a given account before the above resources can be deployed
- This infrastructure doesn't include configuring AWS Config rules nor remediations on Config rules. Please ensure the `AutomationAssumeRole` of the remediation matches the value for `config_remediation_role_arn`.