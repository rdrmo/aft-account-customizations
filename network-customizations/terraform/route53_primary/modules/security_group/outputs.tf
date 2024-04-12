#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

output "security_group_id" {
  value       = aws_security_group.resolver_sg.id
  description = "ID of the created Security Group for the Route53 Resolver Endpoints"
}
