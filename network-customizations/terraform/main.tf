module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.1"
}

#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

##################################################################
##               Network Hub Account Module Calls               ##
##################################################################

# module "route53_privatedns_primary" {
#   source = "./modules/route53_primary"

#   allowed_cidr = "10.0.0.0/8"
#   region       = "us-east-1"

#   hub_phz_name      = "aws.caprica.cafe"
#   parent_dns_domain = "caprica.cafe"

#   enable_on_prem_dns = true # if false, the below three variables may be omitted
#   on_prem_dns1       = "1.1.1.1"
#   on_prem_dns2       = "9.9.9.9"
#   on_prem_dns_domain = "onprem.caprica.cafe"

#   vpc_size                = "small"
#   flow_log_enable         = false
#   gateway_endpoint_enable = true
#   vpc_az                  = ["us-east-1a", "us-east-1b"]
#   vpc_configs = {
#     "vpc" = {
#       size = {
#         # vpc_size = ["vpccidr"]
#         "small"  = ["24"]
#         "medium" = ["22"]
#         "large"  = ["20"]
#       }
#     }
#   }

#   user_defined_tags = var.user_defined_tags

#   # providers = {
#   #   aws = aws.local-us-east-1
#   # }
  
#   providers = {
#     #aws          = aws.local-us-west-2
#     aws.hub_main = aws.local-us-east-1
#   }
  
# }