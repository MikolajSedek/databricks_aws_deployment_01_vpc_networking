/*
  Amazon VPC Input Variables
  Documentation: https://docs.aws.amazon.com/vpc/latest/userguide/configure-your-vpc.html

  Defines input variables for configuring VPC IPv4 CIDR blocks, naming prefixes/postfixes,
  and resource tags.
*/

variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string
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
