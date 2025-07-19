#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

# Provision IPAM and Pools
# No.of Pools depends on the ipam_configs variable
module "ipam" {
  source              = "./modules/ipam/"
  main_pool_cidr_list = var.main_pool_cidr_list
  ipam_configs        = var.ipam_configs
  ipam_list           = local.ipam_list
  inverted_sdlc_names = local.invertedsdlc
}

# Provision Sandbox IPAM Scope and Pools
module "sandbox" {
  count                       = var.create_sandbox ? 1 : 0
  source                      = "./modules/sandbox"
  sandbox_top_level_CIDR_List = var.sandbox_top_level_CIDR_List
  ipam_id                     = module.ipam.ipam_id
  sandbox_regions_cidrs       = var.sandbox_regions_cidrs
}

module "manual_allocations" {
  source = "./modules/allocations"

  providers = {
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

  top_level_pool_id      = module.ipam.top_level_pool_id
  regional_pool_ids      = module.ipam.regional_pool_ids
  environmental_pool_ids = module.ipam.environmental_pool_ids
  manual_allocations     = var.manual_allocations
}
