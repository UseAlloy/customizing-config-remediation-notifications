resource "aws_ssm_parameter" "config_custom_chatbot_notification_mapping_parameter" {
  name = "${var.name}-mapping-parameter"
  type = "StringList"
  value = jsonencode(
    {
      "AWSConfigRemediation-RestrictBucketSSLRequestsOnly" : "fields requestParameters.bucketName as resource | filter eventName=\"PutBucketPolicy\" and userIdentity.sessionContext.sessionIssuer.arn = \"${var.config_remediation_role_arn}\"",
      "AWS-EnableS3BucketEncryption" : "fields requestParameters.bucketName as resource | filter eventName=\"PutBucketEncryption\" and userIdentity.sessionContext.sessionIssuer.arn = \"${var.config_remediation_role_arn}\"",
      "AWSConfigRemediation-ConfigureS3BucketPublicAccessBlock" : "fields @timestamp, requestParameters.bucketName as resource | filter eventName=\"PutBucketPublicAccessBlock\" and userIdentity.sessionContext.sessionIssuer.arn = \"${var.config_remediation_role_arn}\"",
      "AWS-DisableIncomingSSHOnPort22" : "fields requestParameters.groupId as resource | filter eventName=\"RevokeSecurityGroupIngress\" and requestParameters.ipPermissions.items.0.fromPort =22 and requestParameters.ipPermissions.items.0.toPort=22 and userIdentity.sessionContext.sessionIssuer.arn = \"${var.config_remediation_role_arn}\"",
    }
  )
}
