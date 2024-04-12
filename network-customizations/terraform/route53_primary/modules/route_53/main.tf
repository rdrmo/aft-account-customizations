#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

# Create the Hub Account Private Hosted Zone
resource "aws_route53_zone" "private" {
  #checkov:skip=CKV2_AWS_38: Finding is not valid and should be suppressed. This is a private hosted zone. DNSSEC should be enabled on all public hosted zones.
  #checkov:skip=CKV2_AWS_39: Finding is not valid and should be suppressed. DNS Query logging is not necessary to be set up by default on private hosted zone for internal traffic.
  name = var.hub_phz_mame

  vpc {
    vpc_id = var.vpc_id
  }

  lifecycle {
    ignore_changes = [vpc]
  }
}

# Create Inbound Resolver Endpoint
resource "aws_route53_resolver_endpoint" "inbound_endpoint" {
  name               = "Central Inbound Resolver Endpoint"
  direction          = "INBOUND"
  security_group_ids = [var.sg_id]

  dynamic "ip_address" {
    for_each = var.subnets
    content {
      subnet_id = ip_address.value
    }
  }
}

# Create Outbound Resolver Endpoint
resource "aws_route53_resolver_endpoint" "outbound_endpoint" {
  name               = "Central Outbound Resolver Endpoint"
  direction          = "OUTBOUND"
  security_group_ids = [var.sg_id]

  dynamic "ip_address" {
    for_each = var.subnets
    content {
      subnet_id = ip_address.value
    }
  }
}

# Create Forwarding Rule for Application DNS Domains on AWS to be resolved by all accounts on AWS
resource "aws_route53_resolver_rule" "internal_dns_resolution" {
  domain_name          = var.parent_dns_domain
  name                 = "InternalDNSResolution"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_endpoint.id

  dynamic "target_ip" {
    for_each = aws_route53_resolver_endpoint.inbound_endpoint.ip_address.*.ip
    content {
      ip = target_ip.value
    }
  }
}

# Create Forwarding Rule for On-Premise DNS Domain
resource "aws_route53_resolver_rule" "onprem_dns_resolution" {
  count = var.enable_on_prem_dns == true ? 1 : 0

  domain_name          = var.on_prem_dns_domain
  name                 = "OnPremiseDNSResolution"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_endpoint.id

  target_ip {
    ip = var.on_prem_dns1
  }

  target_ip {
    ip = var.on_prem_dns2
  }
}

# Create Forwarding Rule for VPC Endpoint Resolution
resource "aws_route53_resolver_rule" "vpc_endpoint_resolution" {
  domain_name          = "${var.region}.amazonaws.com"
  name                 = "VPCEndpointResolution"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_endpoint.id

  dynamic "target_ip" {
    for_each = aws_route53_resolver_endpoint.inbound_endpoint.ip_address.*.ip
    content {
      ip = target_ip.value
    }
  }
}

# Create Resource Access Manager to share the Resolver Rules with the Organization
resource "aws_ram_resource_share" "rule_ram_shares" {
  name = "Route53 Resolver Rules Organizational Share"
}

# Create Resource Access Manager association with the Principal (OU/AWS Account)
resource "aws_ram_principal_association" "rule_ram_shares_principal_assoc" {
  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.rule_ram_shares.arn
  depends_on = [
    aws_ram_resource_share.rule_ram_shares
  ]
}

# Associate Internal DNS Resolver Rule with the Resource Access Manager
resource "aws_ram_resource_association" "internal_rule_ram_share_resource_assoc" {
  resource_arn       = aws_route53_resolver_rule.internal_dns_resolution.arn
  resource_share_arn = aws_ram_resource_share.rule_ram_shares.arn
}

# Associate OnPrem DNS Resolver Rule with the Resource Access Manager
resource "aws_ram_resource_association" "onprem_rule_ram_share_resource_assoc" {
  count = var.enable_on_prem_dns == true ? 1 : 0

  resource_arn       = aws_route53_resolver_rule.onprem_dns_resolution[0].arn
  resource_share_arn = aws_ram_resource_share.rule_ram_shares.arn
}

# Associate VPC Endpoint DNS Resolver Rule with the Resource Access Manager
resource "aws_ram_resource_association" "vpc_endpoint_rule_ram_share_resource_assoc" {
  resource_arn       = aws_route53_resolver_rule.vpc_endpoint_resolution.arn
  resource_share_arn = aws_ram_resource_share.rule_ram_shares.arn
}

# Add On Prem Resolver Rule to SSM Parameter Store
resource "aws_ssm_parameter" "on_prem_forwarding_param" {
  count = var.enable_on_prem_dns == true ? 1 : 0

  #checkov:skip=CKV2_AWS_34:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  #checkov:skip=CKV_AWS_337:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  name        = "/platform/route53/on-prem-resolver-rule"
  description = "ID of the forwarding Resolver Rule for On Prem DNS"
  value       = aws_route53_resolver_rule.onprem_dns_resolution[0].id
  type        = "String"
  overwrite   = true
}

# Add Internal DNS Resolver Rule to SSM Parameter Store
resource "aws_ssm_parameter" "internal_dns_forwarding_param" {
  #checkov:skip=CKV2_AWS_34:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  #checkov:skip=CKV_AWS_337:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  name        = "/platform/route53/internal-dns-resolver-rule"
  description = "ID of the forwarding Resolver Rule for Internal DNS"
  value       = aws_route53_resolver_rule.internal_dns_resolution.id
  type        = "String"
  overwrite   = true
}

# Add On Prem Resolver Rule to SSM Parameter Store
resource "aws_ssm_parameter" "endpoint_forwarding_param" {
  #checkov:skip=CKV2_AWS_34:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  #checkov:skip=CKV_AWS_337:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  name        = "/platform/route53/endpoint-resolver-rule"
  description = "ID of the forwarding Resolver Rule for AWS endpoints"
  value       = aws_route53_resolver_rule.vpc_endpoint_resolution.id
  type        = "String"
  overwrite   = true
}

# Add Hosted Zone ID to SSM Parameter Store
resource "aws_ssm_parameter" "hosted_zone_param" {
  #checkov:skip=CKV2_AWS_34:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  #checkov:skip=CKV_AWS_337:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  name        = "/platform/route53/private-hosted-zone-id"
  description = "ID of the Private Hosted Zone for Route 53"
  value       = aws_route53_zone.private.id
  type        = "String"
  overwrite   = true
}
