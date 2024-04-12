#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

variable "vpc_configs" {
  type = map(object({
    size = map(list(string))
  }))
}

variable "size" {
  type = string

  validation {
    condition     = contains(["small", "medium", "large"], var.size)
    error_message = "Valid values for VPC Size are (small, medium, large)."
  }
}

variable "az" {
  type = list(any)
}

variable "region" {
  type = string
}

variable "gateway_endpoint_enable" {
  type        = bool
  description = "Boolean variable for whether to create Gateway Endpoints in the VPC"
}

variable "flow_log_enable" {
  type        = bool
  description = "Boolean variable to determine whether to create VPC Flow Logs for the VPC"
}
