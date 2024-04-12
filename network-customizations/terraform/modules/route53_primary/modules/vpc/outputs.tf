#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

output "vpc_id" {
  description = "Outputs the ID of the VPC created to be used by the flow log module"
  value       = aws_vpc.vpc.id
}

output "subnet_ids" {
  description = "Subnet IDs for endpoints to be created"
  value       = tolist(aws_subnet.endpoint_subnet[*].id)
}
