#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

variable "main_pool_cidr_list" {
  type        = list(string)
  description = "Define the CIDRs to use in the top level pool for IPAM"
}

variable "ipam_configs" {
  type = map(object({
    cidr_list = string
    env       = map(string)
    region    = string
  }))
}

variable "operating_region" {
  description = "Operating region used for Terraform provider"
  type        = string
}

variable "user_defined_tags" {
  type = map(string)
  validation {
    condition = alltrue([
      for k, v in var.user_defined_tags :
      substr(k, 0, 4) != "aws:"
      && can(regex("^[\\w\\s_.:=+-@/]{0,128}$", k))
    && can(regex("^[\\w\\s_.:=+-@/]{0,256}$", v))])
    error_message = "Must match the allowable values for a Tag Key/Value. The Key must NOT begin with 'aws:'. Both can only contain alphanumeric characters or specific special characters _.:/=+-@ up to 128 characters for Key and 256 characters for Value."
  }
}

variable "sandbox_regions_cidrs" {
  type        = map(string)
  description = "Variable for all Regions and CIDRs to be used for a Sandbox environment"
}

variable "create_sandbox" {
  type        = bool
  description = "Variable to set whether to create the IPAM scope and pools for Sandbox or not"
  default     = true
}

variable "sandbox_top_level_CIDR_List" {
  description = "IPAM main pool CIDR"
  type        = list(string)
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
