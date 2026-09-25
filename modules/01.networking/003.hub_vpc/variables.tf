variable "hub_cidr_block" {
  description = "Hub VPC CIDR block"
  type        = string
}

variable "hub_tgw_private_subnets_cidr" {
  description = "Hub VPC PRIVATE subnets CIDRs"
  type        = list(string)
}

variable "hub_nat_public_subnets_cidr" {
  description = "Hub VPC PUBLIC subnets CIDRs"
  type        = list(string)
}

variable "hub_firewall_subnets_cidr" {
  description = "Hub VPC FIREWALL subnets CIDRs"
  type        = list(string)
}


variable "name_prefix" {
  description = "NAME prefix for Hub VPC"
  type        = string
  default     = "Hub VPC"
}

variable "env" {
  description = "ENVIRONMENT name"
  type        = string
}

variable "availability_zones" {
  description = "LIST of AZs for Hub VPC networking"
  type        = list(string)
}

variable "tags" {
  description = "EXTRA tags for Hub VPC and networking"
  type        = map(string)
  default     = {}
}
