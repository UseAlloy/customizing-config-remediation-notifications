## Customizing Config Remediation Notifications
This infrastructure deploys a Lambda function, SNS topic, Chatbot configuration, SSM Parameter and CloudWatch event rule. 

The CloudWatch event rule watches for Config initiating an SSM document-based remediation flow. The Cloudwatch event rule then invokes the Lambda function. The Lambda function runs a lookup via the SSM Parameter for the query to determine which resources were updated via the Config remediation SSM Document. After determining the query, the lambda runs the query on the CloudTrail CloudWatch log group. Due to the delayed nature of CloudWatch logs, the Lambda retries and waits for the query to find results in the CloudWatch logs group. The Lambda also puts the original message on the SNS topic. If results are found, the lambda additionally constructs a custom slack message to include the resource(s) affected and puts it on the SNS topic. The chatbot configuration is subscribed to the SNS topic to forward messages to Slack. 

### Required Inputs
- `config_remediation_role_arn` - the role ARN which is assumed by ssm.amazonaws.com to execute SSM Documents to remediate resources
- `cloudtrail_log_group_arn` - the ARN of the CloudTrail CloudWatch log group in the same account where this infrastructure is deployed. At the moment, the infrastructure doesn't support cross account role assumption. However, if you set the resource policy on the CloudWatch log group to allow cross-account access from the lambda role, the existing infrastructure can be used without modification.
- `slack_channel_id` - The id of the Slack channel where Chatbot will post messages
- `slack_workspace_id` - The id of the Slack workspace where the slack_channel_id resides.

### Pre-requisite Set Up Steps
- You must manually enable AWS Chatbot (Amazon Q Developer in chat applications) the first time in a given account before the above resources can be deployed
- This infrastructure doesn't include configuring AWS Config rules nor remediations on Config rules. Please ensure the `AutomationAssumeRole` of the remediation matches the value for `config_remediation_role_arn`.
- You must install the Amazon Q developer app into your Slack workspace and configure to send messages to your desired channel.
- If you change the `lambda_function.py`, you must re-create the deployment package following these steps: https://docs.aws.amazon.com/lambda/latest/dg/python-package.html#python-package-create-dependencies

### Additional recommendations
- We recommend setting up the Slack integration to enable threading messages. This can be done by commenting `@Amazon Q preferences` in a channel whwere the app is installed, choosing `Set Preferences` and then selecting `Notification Threading Preferences` 