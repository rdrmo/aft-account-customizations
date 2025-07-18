#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

# Create Org IPAM and Scope
resource "aws_vpc_ipam" "ipam" {
  description = "Organization IPAM"
  dynamic "operating_regions" {
    for_each = var.ipam_configs
    content {
      region_name = operating_regions.value.region
    }
  }
  tags = {
    "Name" = "ipam"
  }
}

resource "aws_vpc_ipam_scope" "ipam_scope" {
  ipam_id     = aws_vpc_ipam.ipam.id
  description = "Custom Scope for Private IP Addresses"
  tags = {
    "Name" = "custom_ipam_scope"
  }
}

# Create IPAM top pool and assoc. CIDR

resource "aws_vpc_ipam_pool" "ipam_top_pool" {
  description    = "Top Level Pool"
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam_scope.ipam_scope.id
  tags = {
    "Name" = "top-level-pool"
  }
}

resource "aws_vpc_ipam_pool_cidr" "ipam_top_cidr" {
  for_each     = toset(var.main_pool_cidr_list)
  ipam_pool_id = aws_vpc_ipam_pool.ipam_top_pool.id
  cidr         = each.key
  depends_on = [
    aws_vpc_ipam_pool.ipam_top_pool
  ]
}

# Create IPAM regional pools and assoc. CIDR

resource "aws_vpc_ipam_pool" "ipam_regional_pool" {
  for_each            = var.ipam_configs
  description         = "IPAM Pool for Region ${each.value.region}"
  address_family      = "ipv4"
  auto_import         = true
  ipam_scope_id       = aws_vpc_ipam_scope.ipam_scope.id
  locale              = each.value.region
  source_ipam_pool_id = aws_vpc_ipam_pool.ipam_top_pool.id
  depends_on = [
    aws_vpc_ipam_pool_cidr.ipam_top_cidr
  ]
  tags = {
    "Name" = "ipam-regional-pool-${each.value.region}"
  }
}

resource "aws_vpc_ipam_pool_cidr" "ipam_regional_cidr" {
  for_each     = var.ipam_configs
  ipam_pool_id = aws_vpc_ipam_pool.ipam_regional_pool[each.key].id
  cidr         = each.value.cidr_list
  depends_on = [
    aws_vpc_ipam_pool.ipam_regional_pool
  ]
}

# Create IPAM pools for each environment and assoc.CIDRS

resource "aws_vpc_ipam_pool" "ipam_env_pool" {
  for_each            = { for idx, record in var.ipam_list : idx => record }
  description         = "IPAM Environment Pool for ${each.value.env_name} in region ${each.value.region_val}"
  address_family      = "ipv4"
  auto_import         = true
  ipam_scope_id       = aws_vpc_ipam_scope.ipam_scope.id
  locale              = each.value.region_val
  source_ipam_pool_id = aws_vpc_ipam_pool.ipam_regional_pool[each.value.region_key].id
  depends_on = [
    aws_vpc_ipam_pool.ipam_regional_pool
  ]
  tags = {
    "Name" = "${each.value.env_name} Pool ${each.value.region_val}"
  }
}


resource "aws_vpc_ipam_pool_cidr" "ipam_env_cidr" {
  for_each     = { for idx, record in var.ipam_list : idx => record }
  ipam_pool_id = aws_vpc_ipam_pool.ipam_env_pool[each.key].id
  cidr         = each.value.env_cidr
  depends_on = [
    aws_vpc_ipam_pool.ipam_env_pool
  ]
}

# Create RAM shares for each environment and IPAM pools and associations

resource "aws_ram_resource_share" "ram_shares" {
  count                     = length([for ipam_env in aws_vpc_ipam_pool.ipam_env_pool : ipam_env.arn])
  name                      = "RAM Share for ${aws_vpc_ipam_pool.ipam_env_pool[count.index].description}"
  allow_external_principals = false
  permission_arns           = ["arn:aws:ram::aws:permission/AWSRAMDefaultPermissionsIpamPool"]
  depends_on = [
    aws_vpc_ipam_pool_cidr.ipam_env_cidr
  ]
}

resource "aws_ram_principal_association" "ram_shares_prin_assoc" {
  count              = length([for ipam_share in aws_ram_resource_share.ram_shares : ipam_share.id])
  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.ram_shares[count.index].arn
  depends_on = [
    aws_ram_resource_share.ram_shares
  ]
}

resource "aws_ram_resource_association" "share_assoc" {
  count              = length([for ipam_env in aws_vpc_ipam_pool.ipam_env_pool : ipam_env.arn])
  resource_arn       = aws_vpc_ipam_pool.ipam_env_pool[count.index].arn
  resource_share_arn = aws_ram_resource_share.ram_shares[count.index].arn
  depends_on = [
    aws_ram_principal_association.ram_shares_prin_assoc
  ]
}

# Add IPAM pool environment IDS in the SSM parameter store
resource "aws_ssm_parameter" "ipam_configs" {
  #checkov:skip=CKV2_AWS_34:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  #checkov:skip=CKV_AWS_337:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  for_each    = { for idx, record in var.ipam_list : idx => record }
  name        = lower("/platform/ipam/${each.value.region_val}/${lookup(var.inverted_sdlc_names, each.value.env_name, each.value.env_name)}-ipam-pool-id")
  description = "The IPAM Pool ID of the ${each.value.env_name} environment"
  value       = aws_vpc_ipam_pool.ipam_env_pool[each.key].id
  type        = "String"
  overwrite   = true
}

# Add IPAM Regional Pool CIDR to SSM Parameter Store
resource "aws_ssm_parameter" "regional_cidr" {
  #checkov:skip=CKV2_AWS_34:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  #checkov:skip=CKV_AWS_337:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  for_each    = var.ipam_configs
  name        = "/platform/ipam/${each.value.region}/cidr-block"
  description = "CIDR Block used for the IPAM ${each.value.region} regional pool"
  value       = each.value.cidr_list
  type        = "String"
  overwrite   = true
}

# Add IPAM Top Level Pool CIDR to SSM Parameter Store
resource "aws_ssm_parameter" "top_level_cidr" {
  #checkov:skip=CKV2_AWS_34:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  #checkov:skip=CKV_AWS_337:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  name        = "/platform/ipam/top-level-cidr-blocks"
  description = "CIDR Blocks used in the Top Level IPAM pool"
  value       = join(",", var.main_pool_cidr_list)
  type        = "String"
  overwrite   = true
}
