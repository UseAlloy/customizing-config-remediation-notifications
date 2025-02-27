## Customizing Config Remediation Notifications
This infrastructure deploys a lambda function, SNS topic, Chatbot configuration, SSM Parameter and CloudWatch event rule. The CloudWatch event rule watches for Config initiating an SSM document-based remediation flow. The Cloudwatch event rule invokes the lambda function. The Lambda function runs a lookup via the SSM Parameter for a query to find which resources were updated via the SSM Document. After determining the query, the lambda runs the query on the CloudTrail CloudWatchlog group. Due the delayed nature of CloudWatch logs, the lambda retries and waits for the query to find results in the CloudWatch logs group. The lambda also puts the original message on the SNS topic. If results are found, the lambda additionally constructs a custom slack message to include the resource(s) affected and puts it on the SNS topic. The chatbot configuration is subscribed to the SNS topic to forward messages to Slack. 

### Required Inputs
- `config_remediation_role_arn` - the role ARN which is assumed by ssm.amazonaws.com to execute SSM Documents to remediate resources
- `cloudtrail_log_group_arn` - the ARN of the CloudTrail CloudWatch log group in the same account where this infrastructure is deployed. At the moment, the infrastructure doesn't support cross account role assumption. However, if you set the resource policy on the CloudWatch log group to allow cross-account access from the lambda role, the existing infrastructure can be used without modification.
- `slack_channel_id` - The id of the Slack channel where Chatbot will post messages
- `slack_workspace_id` - The id of the Slack workspace where the slack_channel_id resides.

### Pre-requisite Set Up Steps
- You must manually enable AWS Chatbot (Amazon Q Developer in chat applications) the first time in a given account before the above resources can be deployed
- This infrastructure doesn't include configuring AWS Config rules nor remediations on Config rules. Please ensure the `AutomationAssumeRole` of the remediation matches the value for `config_remediation_role_arn`.
- You must install the Amazon Q developer app into your Slack workspace and configure to send messages to your desired channel.

### Additional recommendations
- We recommend setting up the Slack integration to enable threading messages. This can be done by commenting `@Amazon Q preferences` in a channel whwere the app is installed, choosing `Set Preferences` and then selecting `Notification Threading Preferences` 