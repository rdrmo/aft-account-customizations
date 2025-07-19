#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

# Create the scope for the Sandbox IPAM pools
resource "aws_vpc_ipam_scope" "sandbox_ipam_scope" {
  ipam_id     = var.ipam_id
  description = "Custom Scope for Sandbox Environment"
  tags = {
    "Name" = "sandbox_ipam_scope"
  }
}

# Create IPAM top pool and assoc. CIDR

resource "aws_vpc_ipam_pool" "sandbox_top_pool" {
  description    = "Top-level IPAM Pool for Sandbox"
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam_scope.sandbox_ipam_scope.id
  tags = {
    "Name" = "Sandbox OU Top-level Pool"
  }
}

resource "aws_vpc_ipam_pool_cidr" "sandbox_top_cidr" {
  for_each     = toset(var.sandbox_top_level_CIDR_List)
  ipam_pool_id = aws_vpc_ipam_pool.sandbox_top_pool.id
  cidr         = each.key
  depends_on = [
    aws_vpc_ipam_pool.sandbox_top_pool
  ]
}

# Create IPAM regional pools and assoc. CIDR

resource "aws_vpc_ipam_pool" "sandbox_regional_pool" {
  for_each            = var.sandbox_regions_cidrs
  description         = "Sandbox Pool for Region ${each.key}"
  address_family      = "ipv4"
  auto_import         = true
  ipam_scope_id       = aws_vpc_ipam_scope.sandbox_ipam_scope.id
  locale              = each.key
  source_ipam_pool_id = aws_vpc_ipam_pool.sandbox_top_pool.id
  depends_on = [
    aws_vpc_ipam_pool_cidr.sandbox_top_cidr
  ]
  tags = {
    "Name" = "Sandbox Pool for ${each.key}"
  }
}

resource "aws_vpc_ipam_pool_cidr" "sandbox_regional_cidr" {
  for_each     = var.sandbox_regions_cidrs
  ipam_pool_id = aws_vpc_ipam_pool.sandbox_regional_pool[each.key].id
  cidr         = each.value
}

# Create RAM shares for each environment and IPAM pools and associations

resource "aws_ram_resource_share" "sandbox_ram_shares" {
  for_each                  = aws_vpc_ipam_pool.sandbox_regional_pool
  name                      = "RAM Share for ${each.value.description}"
  allow_external_principals = false
  permission_arns           = ["arn:aws:ram::aws:permission/AWSRAMDefaultPermissionsIpamPool"]
  depends_on = [
    aws_vpc_ipam_pool_cidr.sandbox_regional_cidr
  ]
}

resource "aws_ram_principal_association" "sandbox_ram_shares_prin_assoc" {
  for_each           = aws_ram_resource_share.sandbox_ram_shares
  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = each.value.arn
  depends_on = [
    aws_ram_resource_share.sandbox_ram_shares
  ]
}

resource "aws_ram_resource_association" "sandbox_share_assoc" {
  for_each           = aws_vpc_ipam_pool.sandbox_regional_pool
  resource_arn       = each.value.arn
  resource_share_arn = aws_ram_resource_share.sandbox_ram_shares[each.key].arn
  depends_on = [
    aws_ram_principal_association.sandbox_ram_shares_prin_assoc
  ]
}

# Add Sandbox regional pool IDS in the SSM parameter store
resource "aws_ssm_parameter" "sandbox_id_params" {
  #checkov:skip=CKV2_AWS_34:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  #checkov:skip=CKV_AWS_337:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  for_each    = var.sandbox_regions_cidrs
  name        = "/platform/ipam/${each.key}/sandbox-ipam-pool-id"
  description = "The IPAM Pool ID of for the Sandbox ${each.key} pool"
  value       = aws_vpc_ipam_pool.sandbox_regional_pool[each.key].id
  type        = "String"
  overwrite   = true
}

# Add Sandbox regional pool CIDRs in the SSM parameter store
resource "aws_ssm_parameter" "sandbox_cidr_params" {
  #checkov:skip=CKV2_AWS_34:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  #checkov:skip=CKV_AWS_337:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  for_each    = var.sandbox_regions_cidrs
  name        = "/platform/ipam/${each.key}/sandbox-cidr-block"
  description = "The IPAM cidr block of for the Sandbox ${each.key} pool"
  value       = each.value
  type        = "String"
  overwrite   = true
}

# Add Sandbox top level pool CIDR to SSM Parameter Store
resource "aws_ssm_parameter" "top_level_cidr" {
  #checkov:skip=CKV2_AWS_34:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  #checkov:skip=CKV_AWS_337:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  name        = "/platform/ipam/sandbox-top-level-cidr-blocks"
  description = "CIDR Blocks used in the Top Level sandbox pool"
  value       = join(",", var.sandbox_top_level_CIDR_List)
  type        = "String"
  overwrite   = true
}
