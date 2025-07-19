#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################


  # IPAM top level CIDR blocks
  main_pool_cidr_list = ["10.0.0.0/8"]

  # Primary region where IPAM is deployed. Should match provider belwo
  operating_region = "us-east-1"

  # Specify whether to create a sandbox environment IPAM scope and pools. Must be set to true or false.
  # If omitted, the default is true.
  create_sandbox = false

  # IPAM sandbox pools top level CIDR blocks
  sandbox_top_level_CIDR_List = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]

  # Specify the CIDR block for each region's Sandbox pool
  sandbox_regions_cidrs = {
    "us-east-1" = "10.0.0.0/16"
    "us-west-2" = "172.16.0.0/16"
  }

  # Define any manual allocations which should be added to the IPAM pools, which will prevent IPAM from using this IP space
  # Empty sections may be omitted (e.g. sdlc3 = [] is unneeded). An example based on the default IP space is provided below.
  # manual_allocations = {
  #   top_level_allocations = [
  #     {
  #       cidr        = "10.8.0.0/14"
  #       description = "top level description"
  #     }
  #   ]
  #   regions = {
  #     "us-east-1" = {
  #       region_level_allocations = [
  #         {
  #           cidr        = "10.2.0.0/24",
  #           description = "desc 1"
  #         },
  #         {
  #           cidr        = "10.2.1.0/24",
  #           description = "desc 2"
  #         }
  #       ]
  #       env_level_allocations = {
  #         sdlc1 = [
  #           {
  #             cidr        = "10.0.0.0/24",
  #             description = "lskdfslkj"
  #           },
  #           {
  #             cidr        = "10.0.1.0/24",
  #             description = "lskdfslkj"
  #           }
  #         ]
  #         sdlc2          = []
  #         sdlc3          = []
  #         sdlc4          = []
  #         Infrastructure = []
  #         Security       = []
  #       }
  #     }
  #     "us-west-2" = {
  #       region_level_allocations = []
  #       env_level_allocations = {
  #         sdlc1 = [
  #           {
  #             cidr        = "10.4.0.0/24",
  #             description = "lskdjfdlksjf"
  #           }
  #         ]
  #         sdlc2          = []
  #         sdlc3          = []
  #         sdlc4          = []
  #         Infrastructure = []
  #         Security       = []
  #       }
  #     }
  #   }
  # }

  user_defined_tags = var.user_defined_tags

  providers = {
    # Main provider for IPAM deployment
    aws = aws.local-us-west-2

    # Other providers used to create manual allocations
    aws.local-us-east-1      = aws.local-us-east-1
    aws.local-us-east-2      = aws.local-us-east-2
    aws.local-us-west-2      = aws.local-us-west-2
    aws.local-ap-northeast-1 = aws.local-ap-northeast-1
    aws.local-ap-northeast-2 = aws.local-ap-northeast-2
    aws.local-ap-south-1     = aws.local-ap-south-1
    aws.local-ap-southeast-1 = aws.local-ap-southeast-1
    aws.local-ap-southeast-2 = aws.local-ap-southeast-2
    aws.local-ca-central-1   = aws.local-ca-central-1
    aws.local-eu-central-1   = aws.local-eu-central-1
    aws.local-eu-north-1     = aws.local-eu-north-1
    aws.local-eu-west-1      = aws.local-eu-west-1
    aws.local-eu-west-2      = aws.local-eu-west-2
    aws.local-eu-west-3      = aws.local-eu-west-3
    aws.local-sa-east-1      = aws.local-sa-east-1
  }
}
