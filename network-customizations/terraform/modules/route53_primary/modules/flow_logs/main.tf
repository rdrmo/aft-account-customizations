#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

# Create and configure KMS key for Flow Log group
resource "aws_kms_key" "log_group_key" {
  description         = "Key is used for VPC Flow Log group"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.flow_log_kms_key_policy.json

  tags = {
    "Name" = "dns-vpc-flow-log-kms-key"
  }
}

# Create and configure VPC Flow log log group
resource "aws_cloudwatch_log_group" "access_logs" {
  retention_in_days = 365
  kms_key_id        = aws_kms_key.log_group_key.arn
  name_prefix       = "dns-vpc-flow-log"
}

#Create IAM Role necessary for VPC flow logs interacting with CloudWatch
resource "aws_iam_role" "vpc_flow_log_role" {
  name_prefix        = "dns_vpc_flow_log_role_${var.region}"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_log_assume_pol.json
  description        = "IAM role to allow VPC Flow logs to enter logs to CloudWatch Log Group for Flow logs"
}

# Create policy for the flow log role
resource "aws_iam_role_policy" "flow_log_policy" {
  name   = "flow_log_policy"
  role   = aws_iam_role.vpc_flow_log_role.id
  policy = data.aws_iam_policy_document.vpc_flow_log_role_policy.json
}

# Enable flow logs
resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = aws_cloudwatch_log_group.access_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
  iam_role_arn         = aws_iam_role.vpc_flow_log_role.arn

  tags = {
    Name = "dns-vpc-flow-log"
  }
}
