#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

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

variable "allowed_cidr" {
  type        = string
  description = "CIDR range for ingress SG rule"
}

variable "region" {
  type        = string
  description = "Region for the solution to be deployed in"
}

variable "parent_dns_domain" {
  type        = string
  description = "Parent DNS Domain for all the child DNS domains to be used by Workload Accounts on AWS"
}

variable "enable_on_prem_dns" {
  type        = bool
  description = "Enable to forward DNS queries for the on-premises DNS domain to an on-prem DNS server"
  default     = false
}

variable "on_prem_dns_domain" {
  type        = string
  description = "On-Premise DNS Domain to be resolved by Application Accounts on AWS"
  default     = null
}

variable "on_prem_dns1" {
  type        = string
  description = "IP address of the Primary on-premise DNS Server to forward the queries for the On-Premise DNS Domain"
  default     = null
}

variable "on_prem_dns2" {
  type        = string
  description = "IP address of the Secondary on-premise DNS Server to forward the queries for the On-Premise DNS Domain"
  default     = null
}


variable "hub_phz_name" {
  type        = string
  description = "Domain name for the Hub Private Hosted Zone"
}

variable "flow_log_enable" {
  type        = bool
  description = "Boolean variable to determine whether to create VPC Flow Logs for the VPC"
}

variable "gateway_endpoint_enable" {
  type        = bool
  description = "Boolean variable for whether to create Gateway Endpoints in the VPC"
}

variable "vpc_configs" {
  type = map(object({
    size = map(list(string))
  }))
  description = "Defined VPC CIDR sizes"
}

variable "vpc_size" {
  type = string

  validation {
    condition     = contains(["small", "medium", "large"], var.vpc_size)
    error_message = "Valid values for VPC Size are (small, medium, large)."
  }
  description = "Variable to be used to select size of VPC, references the vpc_configs variable for actual CIDR size"
}


variable "vpc_az" {
  type        = list(any)
  description = "List of Availability Zones subnets should be created in"
}
