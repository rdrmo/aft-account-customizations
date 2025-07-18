#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.52.0"

      configuration_aliases = [
        aws.local-us-east-1,
        aws.local-us-east-2,
        aws.local-us-west-2,
        aws.local-ap-northeast-1,
        aws.local-ap-northeast-2,
        aws.local-ap-south-1,
        aws.local-ap-southeast-1,
        aws.local-ap-southeast-2,
        aws.local-ca-central-1,
        aws.local-eu-central-1,
        aws.local-eu-north-1,
        aws.local-eu-west-1,
        aws.local-eu-west-2,
        aws.local-eu-west-3,
        aws.local-sa-east-1
      ]
    }
  }
}
