#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

variable "sg_id" {
  type        = string
  description = "ID of Security Group for Route53 Resolvers"
}

variable "vpc_id" {
  type        = string
  description = "ID of VPC for the Hosted Zone"
}

variable "region" {
  type        = string
  description = "Region for the solution to be deployed in"
}

variable "hub_phz_mame" {
  type        = string
  description = "Domain name for the Hub Private Hosted Zone"
}

variable "subnets" {
  type        = list(string)
  description = "List of Subnet IDs for the Network Hub accounts VPC"
}

variable "parent_dns_domain" {
  type        = string
  description = "Parent DNS Domain for all the child DNS domains to be used by Application Accounts on AWS"
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
