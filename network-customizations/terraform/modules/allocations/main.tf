#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

# Add a custom IPAM allocation for each provided CIDR in the top level pool
resource "aws_vpc_ipam_pool_cidr_allocation" "top_level_allocation" {
  for_each = { for allocation in local.top_level_allocations : allocation.cidr => allocation }

  ipam_pool_id = var.top_level_pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in us-east-1
resource "aws_vpc_ipam_pool_cidr_allocation" "us-east-1_allocation" {
  provider = aws.local-us-east-1
  for_each = { for allocation in lookup(local.manual_allocation_lists, "us-east-1", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in us-east-2
resource "aws_vpc_ipam_pool_cidr_allocation" "us-east-2_allocation" {
  provider = aws.local-us-east-2
  for_each = { for allocation in lookup(local.manual_allocation_lists, "us-east-2", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in us-west-2
resource "aws_vpc_ipam_pool_cidr_allocation" "us-west-2_allocation" {
  provider = aws.local-us-west-2
  for_each = { for allocation in lookup(local.manual_allocation_lists, "us-west-2", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in ap-northeast-1
resource "aws_vpc_ipam_pool_cidr_allocation" "ap-northeast-1_allocation" {
  provider = aws.local-ap-northeast-1
  for_each = { for allocation in lookup(local.manual_allocation_lists, "ap-northeast-1", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in ap-northeast-2
resource "aws_vpc_ipam_pool_cidr_allocation" "ap-northeast-2_allocation" {
  provider = aws.local-ap-northeast-2
  for_each = { for allocation in lookup(local.manual_allocation_lists, "ap-northeast-2", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in ap-south-1
resource "aws_vpc_ipam_pool_cidr_allocation" "ap-south-1_allocation" {
  provider = aws.local-ap-south-1
  for_each = { for allocation in lookup(local.manual_allocation_lists, "ap-south-1", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in ap-southeast-1
resource "aws_vpc_ipam_pool_cidr_allocation" "ap-southeast-1_allocation" {
  provider = aws.local-ap-southeast-1
  for_each = { for allocation in lookup(local.manual_allocation_lists, "ap-southeast-1", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in ap-southeast-2
resource "aws_vpc_ipam_pool_cidr_allocation" "ap-southeast-2_allocation" {
  provider = aws.local-ap-southeast-2
  for_each = { for allocation in lookup(local.manual_allocation_lists, "ap-southeast-2", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in ca-central-1
resource "aws_vpc_ipam_pool_cidr_allocation" "ca-central-1_allocation" {
  provider = aws.local-ca-central-1
  for_each = { for allocation in lookup(local.manual_allocation_lists, "ca-central-1", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in eu-central-1
resource "aws_vpc_ipam_pool_cidr_allocation" "eu-central-1_allocation" {
  provider = aws.local-eu-central-1
  for_each = { for allocation in lookup(local.manual_allocation_lists, "eu-central-1", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in eu-north-1
resource "aws_vpc_ipam_pool_cidr_allocation" "eu-north-1_allocation" {
  provider = aws.local-eu-north-1
  for_each = { for allocation in lookup(local.manual_allocation_lists, "eu-north-1", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in eu-west-1
resource "aws_vpc_ipam_pool_cidr_allocation" "eu-west-1_allocation" {
  provider = aws.local-eu-west-1
  for_each = { for allocation in lookup(local.manual_allocation_lists, "eu-west-1", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in eu-west-2
resource "aws_vpc_ipam_pool_cidr_allocation" "eu-west-2_allocation" {
  provider = aws.local-eu-west-2
  for_each = { for allocation in lookup(local.manual_allocation_lists, "eu-west-2", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in eu-west-3
resource "aws_vpc_ipam_pool_cidr_allocation" "eu-west-3_allocation" {
  provider = aws.local-eu-west-3
  for_each = { for allocation in lookup(local.manual_allocation_lists, "eu-west-3", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}

# Add a custom IPAM allocation for each provided CIDR in sa-east-1
resource "aws_vpc_ipam_pool_cidr_allocation" "sa-east-1_allocation" {
  provider = aws.local-sa-east-1
  for_each = { for allocation in lookup(local.manual_allocation_lists, "sa-east-1", []) : allocation.cidr => allocation }

  ipam_pool_id = each.value.pool_id
  cidr         = each.value.cidr
  description  = each.value.description
}
