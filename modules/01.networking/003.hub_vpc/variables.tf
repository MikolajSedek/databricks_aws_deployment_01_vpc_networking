variable "hub_cidr_block" {
  description = "Hub VPC CIDR block"
  type        = string

  validation {
    condition     = can(cidrhost(var.hub_cidr_block, 0))
    error_message = "The hub_cidr_block must be a valid IPv4 CIDR block."
  }
}

variable "hub_tgw_private_subnets_cidr" {
  description = "Hub VPC PRIVATE subnets CIDRs"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.hub_tgw_private_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "All entries in hub_tgw_private_subnets_cidr must be valid IPv4 CIDR blocks."
  }
}

variable "hub_nat_public_subnets_cidr" {
  description = "Hub VPC PUBLIC subnets CIDRs"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.hub_nat_public_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "All entries in hub_nat_public_subnets_cidr must be valid IPv4 CIDR blocks."
  }
}

variable "hub_firewall_subnets_cidr" {
  description = "Hub VPC FIREWALL subnets CIDRs"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.hub_firewall_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "All entries in hub_firewall_subnets_cidr must be valid IPv4 CIDR blocks."
  }
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
