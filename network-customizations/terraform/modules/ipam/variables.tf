#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

variable "main_pool_cidr_list" {
  description = "IPAM main pool CIDR"
  type        = list(string)
}

variable "ipam_configs" {
  description = "Input map of IPAM values"
  type        = map(any)
}

variable "ipam_list" {
  description = "Input list of IPAM values"
  type        = list(any)
}

variable "inverted_sdlc_names" {
  type = map(string)
}
