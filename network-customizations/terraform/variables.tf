#####################################################################
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. 
# SPDX-License-Identifier: MIT-0
#
# Version: 2.1.0
######################################################################

variable "user_defined_tags" {
  type = map(string)
  validation {
    condition = alltrue([
      for k, v in var.user_defined_tags :
      substr(k, 0, 4) != "aws:"
      && can(regex("^[\\w\\s_.:=+-@/]{0,128}$", k))
    && can(regex("^[\\w\\s_.:=+-@/]{0,256}$", v))])
    error_message = "Must match the allowable values for a Tag Key/Value. The Key must NOT begin with 'aws:'. Both can only contain alphanumeric characters or specific special characters _.:/=+-@ up to 128 characters for Key and 256 characters for Value."
  }
}
