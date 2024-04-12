### Transit infrastructure

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_organizations_organization" "org" {}

locals {
  name   = "Hub"
  region = var.region
}

################################################################################
# VPC section
################################################################################

#
## Main VPC
#
resource "aws_vpc" "transit" {
  cidr_block            = var.cidr_block
  instance_tenancy      = "default"
  
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
	#Name                = var.vpc_name
	Name                = "TransitVPC"
	Project             = "SharedNetwork"
	CostCenter          = "Network"
  }
}
