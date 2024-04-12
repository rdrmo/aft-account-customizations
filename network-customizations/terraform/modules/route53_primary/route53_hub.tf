#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

# Call module to create VPC
module "vpc" {
  source                  = "./modules/vpc/"
  vpc_configs             = var.vpc_configs
  size                    = var.vpc_size
  az                      = var.vpc_az
  region                  = var.region
  gateway_endpoint_enable = var.gateway_endpoint_enable
  flow_log_enable         = var.flow_log_enable
}

# Call the child module to create a Security Group
module "security_group" {
  source       = "./modules/security_group"
  allowed_cidr = var.allowed_cidr
  vpc_id       = module.vpc.vpc_id
}

# Call the child module to create the Route53 Private Hosted zone and resolver endpoints
module "route_53" {
  source = "./modules/route_53"

  vpc_id             = module.vpc.vpc_id
  sg_id              = module.security_group.security_group_id
  hub_phz_mame       = var.hub_phz_name
  subnets            = module.vpc.subnet_ids
  parent_dns_domain  = var.parent_dns_domain
  enable_on_prem_dns = var.enable_on_prem_dns
  on_prem_dns1       = var.on_prem_dns1
  on_prem_dns2       = var.on_prem_dns2
  on_prem_dns_domain = var.on_prem_dns_domain
  region             = var.region
}
