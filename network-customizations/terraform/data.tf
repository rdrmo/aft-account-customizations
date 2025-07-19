#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

data "aws_ssm_parameter" "network_hub_acct_id" {
  name = "/organization/network-hub-account-id"
}
