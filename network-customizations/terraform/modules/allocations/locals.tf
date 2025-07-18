#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

locals {
  top_level_allocations = coalesce(lookup(var.manual_allocations, "top_level_allocations", []), [])

  manual_allocation_lists = {
    for region_key, region in coalesce(lookup(var.manual_allocations, "regions", {}), {}) :
    region_key => flatten([
      [
        for allocation in lookup(region, "region_level_allocations", []) : {
          pool_id     = var.regional_pool_ids[region_key]
          cidr        = allocation.cidr
          description = allocation.description
        }
      ],
      [
        for env_key, allocations in lookup(region, "env_level_allocations", []) : [
          for allocation in allocations : {
            pool_id     = var.environmental_pool_ids[region_key][env_key]
            cidr        = allocation.cidr
            description = allocation.description
          }
        ]
      ]
    ])
  }
}
