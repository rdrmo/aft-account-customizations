#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

variable "top_level_pool_id" {
  type        = string
  description = "The IPAM Pool ID of the top level pool"
}

variable "regional_pool_ids" {
  type        = map(string)
  description = "A map of all IPAM Pool IDs for each region"
}

variable "environmental_pool_ids" {
  type        = map(map(string))
  description = "A map of all IPAM Pool IDs for each environment, grouped by region"
}

variable "manual_allocations" {
  description = "Define existing CIDR blocks for which to create manual allocations"
  type = object({
    top_level_allocations = list(object({
      cidr        = string,
      description = string
    })),
    regions = map(object({
      region_level_allocations = list(object({
        cidr        = string,
        description = string
      })),
      env_level_allocations = map(list(object({
        cidr        = string,
        description = string
      })))
    }))
  })
  default = {
    top_level_allocations = []
    regions               = {}
  }
}
