#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

locals {
  sdlc_names = {
    "sdlc1" = data.aws_ssm_parameter.sdlc1.value
    "sdlc2" = data.aws_ssm_parameter.sdlc2.value
    "sdlc3" = data.aws_ssm_parameter.sdlc3.value
    "sdlc4" = data.aws_ssm_parameter.sdlc4.value
  }
}
