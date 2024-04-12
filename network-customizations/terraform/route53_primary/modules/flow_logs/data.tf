#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

# Get access to the effective Account ID, User ID, and ARN in which Terraform is authorized.
data "aws_caller_identity" "current" {}

# Create policy that will be attached to the VPC Flow Log Role
data "aws_iam_policy_document" "vpc_flow_log_role_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    effect = "Allow"
    resources = [
      "${aws_cloudwatch_log_group.access_logs.arn}",
      "${aws_cloudwatch_log_group.access_logs.arn}:log-stream:*"
    ]
  }

}

# Create assume role policy for VPC Flow Log Role that will be used by Flow Log service
data "aws_iam_policy_document" "vpc_flow_log_assume_pol" {

  statement {
    actions = [
      "sts:AssumeRole",
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    sid = "SSMAssumeRole"
  }
}

# Create policy for KMS Key for VPC flow log group
data "aws_iam_policy_document" "flow_log_kms_key_policy" {
  #checkov:skip=CKV_AWS_109:finding is not valid and should be suppressed. IAM policy below is a Key policy that is attached directly to key. The only resource affected is the key it is attached to.
  #checkov:skip=CKV_AWS_111: finding is not valid and should be suppressed. IAM policy below is a Key policy that is attached directly to key. The only resource affected is the key it is attached to.
  #checkov:skip=CKV_AWS_356: finding is not valid and should be suppressed. IAM policy below is a Key policy that is attached directly to key. The only resource affected is the key it is attached to.
  statement {
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
    resources = ["*"]
    sid       = "service"
  }
  statement {
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:TagResource",
      "kms:UntagResource"
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    resources = ["*"]
    sid       = "AdministrationofKey"
  }
}
