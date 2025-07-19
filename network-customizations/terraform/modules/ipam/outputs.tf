#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

output "ipam_id" {
  value = aws_vpc_ipam.ipam.id
}

output "top_level_pool_id" {
  value = aws_vpc_ipam_pool.ipam_top_pool.id
}

output "regional_pool_ids" {
  value = { for key, pool in aws_vpc_ipam_pool.ipam_regional_pool : pool.locale => pool.id }
}

output "environmental_pool_ids" {
  value = {
    for region, obj in var.ipam_configs :
    obj.region => {
      for idx, env_pool in var.ipam_list :
      env_pool.env_key => aws_vpc_ipam_pool.ipam_env_pool[idx].id if env_pool.region_key == region
    }
  }
}
