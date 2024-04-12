#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 3.0.0
######################################################################

output "primary_hosted_zone_id" {
  value = module.route_53.hosted_zone_id
}
