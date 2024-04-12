#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

# Create the Security Group that will be used for the Route53 resolver endpoints

resource "aws_security_group" "resolver_sg" {
  #checkov:skip=CKV2_AWS_5:finding is not valid and should be suppressed. This Security group is attached to resolvers when created in other child modules.
  description = "Security Group for Route 53 resolvers"
  vpc_id      = var.vpc_id
  name_prefix = "dns-vpc-route53-resolvers"

  ingress {
    description = "Allowing UDP DNS Traffic"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    description = "Allowing TCP DNS Traffic"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    description = "Allowing UDP DNS Traffic"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    description = "Allowing TCP DNS Traffic"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
}
