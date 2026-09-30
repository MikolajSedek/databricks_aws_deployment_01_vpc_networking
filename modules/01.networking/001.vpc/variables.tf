/*
  Amazon VPC Input Variables
  Documentation: https://docs.aws.amazon.com/vpc/latest/userguide/configure-your-vpc.html

  Defines input variables for configuring VPC IPv4 CIDR blocks, naming prefixes/postfixes,
  and resource tags.
*/

variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "The cidr_block must be a valid IPv4 CIDR block (e.g. 10.0.0.0/16)."
  }
}

variable "tags" {
  description = "Extra tags needed for the project"
  type        = map(string)
  default     = {}
}

variable "prefix" {
  description = "PREFIX for VPC name"
  type        = string
}

variable "postfix" {
  description = "POSTFIX for VPC name"
  type        = string
}
