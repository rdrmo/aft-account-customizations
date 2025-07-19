#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

variable "sandbox_top_level_CIDR_List" {
  description = "IPAM main pool CIDR"
  type        = list(string)
}

variable "ipam_id" {
  type        = string
  description = "ID of the IPAM instance to create the Sandbox scope and pools in."
}

variable "sandbox_regions_cidrs" {
  type        = map(string)
  description = "Variable for all Regions and CIDRs to be used for a Sandbox environment"
}
