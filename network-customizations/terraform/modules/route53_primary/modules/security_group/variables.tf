#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

variable "allowed_cidr" {
  type        = string
  description = "CIDR range for ingress SG rule"
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC for the security group to be created in"
}
