#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

# Create the VPC
resource "aws_vpc" "vpc" {
  #checkov:skip=CKV2_AWS_11:finding is not valid and should be suppressed. Enabling VPC Flow logs is performed by cm_flow_logs based on true/false variable.
  enable_dns_hostnames = true
  enable_dns_support   = true
  ipv4_ipam_pool_id    = data.aws_ssm_parameter.ipam_env_id.value
  ipv4_netmask_length  = var.vpc_configs.vpc.size["${var.size}"][0]
  tags = {
    "Name" = "DNS and VPC Endpoint VPC"
  }
}

# Create a fully restricted default security group for the VPC
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
}

# Create subnets base on the AZs recommended Min.2
resource "aws_subnet" "endpoint_subnet" {
  count             = length(var.az)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.az[count.index]
  cidr_block        = cidrsubnet("${aws_vpc.vpc.cidr_block}", 4, "${count.index}")
  tags = {
    "Name" = "Endpoint Subnet - ${var.az[count.index]}"
  }
}

resource "aws_subnet" "tgw_subnet" {
  count             = length(var.az)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.az[count.index]
  cidr_block        = cidrsubnet("${aws_vpc.vpc.cidr_block}", 4, "${length(var.az) + count.index}")
  tags = {
    "Name" = "Transit Gateway Attachment Subnet - ${var.az[count.index]}"
  }
}

#Create VPC TGW attachment to TGW Subnet
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attach" {
  subnet_ids                                      = tolist(aws_subnet.tgw_subnet[*].id)
  transit_gateway_id                              = data.aws_ssm_parameter.tgw_id.value
  vpc_id                                          = aws_vpc.vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
    "Name" = "dns-vpc-tgw-attachment"
  }
}

# Create Route Tables for VPC
# TGW Subnet Route Tables
resource "aws_route_table" "tgw_rtb" {
  count  = length(tolist(aws_subnet.tgw_subnet[*].id))
  vpc_id = aws_vpc.vpc.id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.tgw_attach
  ]
  tags = {
    "Name" = aws_subnet.tgw_subnet[count.index].tags_all["Name"]
  }
}

# Endpoint Subnet Route Tables
resource "aws_route_table" "endpoint_rtb" {
  count  = length(tolist(aws_subnet.endpoint_subnet[*].id))
  vpc_id = aws_vpc.vpc.id
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.tgw_attach
  ]
  tags = {
    "Name" = aws_subnet.endpoint_subnet[count.index].tags_all["Name"]
  }
}

# Add route to TGW subnet route tables for TGW 
resource "aws_route" "tgw_rt" {
  count                  = length(aws_subnet.tgw_subnet.*.id)
  route_table_id         = aws_route_table.tgw_rtb[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ssm_parameter.tgw_id.value
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.tgw_attach
  ]
}

# Add route to endpoint subnet route tables for TGW 
resource "aws_route" "app_rt" {
  count                  = length(aws_subnet.endpoint_subnet.*.id)
  route_table_id         = aws_route_table.endpoint_rtb[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.aws_ssm_parameter.tgw_id.value
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.tgw_attach
  ]
}

# Associate Subnets to the Route Table
# TGW Subnets & Route Table
resource "aws_route_table_association" "tgw_rtb_assoc" {
  count          = length(tolist(aws_subnet.tgw_subnet[*].id))
  subnet_id      = aws_subnet.tgw_subnet[count.index].id
  route_table_id = aws_route_table.tgw_rtb[count.index].id
}

# Endpoint Subnets & Route Table
resource "aws_route_table_association" "endpoint_rtb_assoc" {
  count          = length(aws_subnet.endpoint_subnet.*.id)
  subnet_id      = aws_subnet.endpoint_subnet[count.index].id
  route_table_id = aws_route_table.endpoint_rtb[count.index].id
}

# Create association to the infrastructure table in Network Hub account
resource "aws_ec2_transit_gateway_route_table_association" "infrastructure_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach.id
  transit_gateway_route_table_id = data.aws_ssm_parameter.infrastructure_rtb_id.value
}

# Create propagation path in Network Hub Account for the Infrastructure Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "infrastructure_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach.id
  transit_gateway_route_table_id = data.aws_ssm_parameter.infrastructure_rtb_id.value
}

# Create propagation path in Network Hub Account for the inspection Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "inspection_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach.id
  transit_gateway_route_table_id = data.aws_ssm_parameter.inspection_rtb_id.value
}

# Create propagation path in Network Hub Account for the Security Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "security_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach.id
  transit_gateway_route_table_id = data.aws_ssm_parameter.security_rtb_id.value
}

# Create propagation path in Network Hub Account for the Ingress Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "ingress_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach.id
  transit_gateway_route_table_id = data.aws_ssm_parameter.ingress_rtb_id.value
}

# Create propagation path in Network Hub Account for the Egress Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "egress_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach.id
  transit_gateway_route_table_id = data.aws_ssm_parameter.egress_rtb_id.value
}

# Create propagation path in Network Hub Account for the SDLC1 Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "sdlc1_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach.id
  transit_gateway_route_table_id = data.aws_ssm_parameter.sdlc1_rtb_id.value
}

# Create propagation path in Network Hub Account for the SDLC2 Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "sdlc2_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach.id
  transit_gateway_route_table_id = data.aws_ssm_parameter.sdlc2_rtb_id.value
}


# Create propagation path in Network Hub Account for the SDLC3 Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "sdlc3_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach.id
  transit_gateway_route_table_id = data.aws_ssm_parameter.sdlc3_rtb_id.value
}


# Create propagation path in Network Hub Account for the SDLC4 Route Table
resource "aws_ec2_transit_gateway_route_table_propagation" "sdlc4_prop" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw_attach.id
  transit_gateway_route_table_id = data.aws_ssm_parameter.sdlc4_rtb_id.value
}

# Create Gateway Endpoint based on true/false flag
resource "aws_vpc_endpoint" "s3" {
  count             = var.gateway_endpoint_enable ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.region}.s3"
  route_table_ids = concat(
    tolist(aws_route_table.tgw_rtb[*].id),
    tolist(aws_route_table.endpoint_rtb[*].id)
  )
}

resource "aws_vpc_endpoint" "dynamodb" {
  count             = var.gateway_endpoint_enable ? 1 : 0
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  route_table_ids = concat(
    tolist(aws_route_table.tgw_rtb[*].id),
    tolist(aws_route_table.endpoint_rtb[*].id)
  )
}

# Add VPC ID to SSM Parameter Store
resource "aws_ssm_parameter" "vpc_id_param" {
  #checkov:skip=CKV2_AWS_34:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  #checkov:skip=CKV_AWS_337:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  name        = "/platform/dns-vpc/vpc-id"
  description = "ID of the VPC created by Private DNS VPC automation module"
  value       = aws_vpc.vpc.id
  type        = "String"
  overwrite   = true
}

# Add Subnet IDs to SSM Parameter Store
resource "aws_ssm_parameter" "subnet_id_param" {
  #checkov:skip=CKV2_AWS_34:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  #checkov:skip=CKV_AWS_337:finding is not valid and should be suppressed. The Parameters do not need to be encrypted as there is no sensitive information.
  name        = "/platform/dns-vpc/subnet-ids"
  description = "ID of the Endpoint Subnets created by Private DNS VPC automation module"
  value       = jsonencode(tolist(aws_subnet.endpoint_subnet[*].id))
  type        = "String"
  overwrite   = true
}

#Call the module to create VPC flow logs based on flow log enable variable
module "flow_logs" {
  source = "../flow_logs"
  count  = var.flow_log_enable ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  region = var.region
}
