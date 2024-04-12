#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

data "aws_region" "current" {}

data "aws_ssm_parameter" "ipam_env_id" {
  name = "/platform/ipam/${data.aws_region.current.name}/infrastructure-ipam-pool-id"
}

data "aws_ssm_parameter" "rtb_id" {
  name = "/platform/tgw/sdlc1-tgw-rt-id"
}

data "aws_ssm_parameter" "tgw_id" {
  name = "/platform/tgw/tgw-id"
}

data "aws_ssm_parameter" "inspection_rtb_id" {
  name = "/platform/tgw/inspection-tgw-rt-id"
}

data "aws_ssm_parameter" "security_rtb_id" {
  name = "/platform/tgw/security-tgw-rt-id"
}

data "aws_ssm_parameter" "infrastructure_rtb_id" {
  name = "/platform/tgw/infrastructure-tgw-rt-id"
}

data "aws_ssm_parameter" "ingress_rtb_id" {
  name = "/platform/tgw/ingress-tgw-rt-id"
}

data "aws_ssm_parameter" "egress_rtb_id" {
  name = "/platform/tgw/egress-tgw-rt-id"
}

data "aws_ssm_parameter" "sdlc1_rtb_id" {
  name = "/platform/tgw/sdlc1-tgw-rt-id"
}

data "aws_ssm_parameter" "sdlc2_rtb_id" {
  name = "/platform/tgw/sdlc2-tgw-rt-id"
}

data "aws_ssm_parameter" "sdlc3_rtb_id" {
  name = "/platform/tgw/sdlc3-tgw-rt-id"
}

data "aws_ssm_parameter" "sdlc4_rtb_id" {
  name = "/platform/tgw/sdlc4-tgw-rt-id"
}

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
