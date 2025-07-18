#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

data "aws_organizations_organization" "org" {} // Provides information about the organization that current account belongs to.

data "aws_caller_identity" "current" {} // Get access to the effective Account ID, User ID, and ARN in which Terraform is authorized.

data "aws_ssm_parameter" "sdlc1" {
  name = "/organization/sdlc-name-1"
}

data "aws_ssm_parameter" "sdlc2" {
  name = "/organization/sdlc-name-2"
}

data "aws_ssm_parameter" "sdlc3" {
  name = "/organization/sdlc-name-3"
}

data "aws_ssm_parameter" "sdlc4" {
  name = "/organization/sdlc-name-4"
}

data "aws_ssm_parameter" "sdlc5" {
  name = "/organization/sdlc-name-5"
}
