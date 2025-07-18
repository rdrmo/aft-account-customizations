#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

locals {
  sdlc_names = {
    "sdlc1" = data.aws_ssm_parameter.sdlc1.value
    "sdlc2" = data.aws_ssm_parameter.sdlc2.value
    "sdlc3" = data.aws_ssm_parameter.sdlc3.value
    "sdlc4" = data.aws_ssm_parameter.sdlc4.value
  }
  ipam_list = flatten([
    for region_key, region in var.ipam_configs : [
      for env_key, env in region.env : {
        region_key = region_key
        env_name   = lookup(local.sdlc_names, env_key, env_key)
        env_key    = env_key
        env_cidr   = env
        region_val = region.region
      }
    ]
  ])
  invertedsdlc = tomap({ for k, v in local.sdlc_names : v => k })
}
