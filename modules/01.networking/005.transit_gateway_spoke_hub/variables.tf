variable "hub_vpc_id" {
  description = "HUB vpc ID"
  type        = string

  validation {
    condition     = startswith(var.hub_vpc_id, "vpc-")
    error_message = "The hub_vpc_id must start with 'vpc-'."
  }
}

variable "hub_tgw_subnet_ids" {
  description = "HUB tgw subnets ids list"
  type        = list(string)
}

variable "hub_tgw_private_rt_id" {
  description = "ID of Hub TGW private route table"
  type        = string
}

variable "hub_nat_public_rt_id" {
  description = "ID of Hub NAT public route table"
  type        = string
}

variable "spoke_vpc_id" {
  description = "SPOKE vpc ID"
  type        = string

  validation {
    condition     = startswith(var.spoke_vpc_id, "vpc-")
    error_message = "The spoke_vpc_id must start with 'vpc-'."
  }
}

variable "spoke_tgw_subnet_ids" {
  description = "SPOKE tgw subnets ids list"
  type        = list(string)
}

variable "spoke_cidr_block" {
  description = "CIDR block for Spoke VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.spoke_cidr_block, 0))
    error_message = "The spoke_cidr_block must be a valid IPv4 CIDR block."
  }
}

variable "spoke_db_private_rt_id" {
  description = "ID of Spoke DB private route table"
  type        = string
}

variable "env" {
  description = "ENVIRONMENT name"
  type        = string
}

variable "tags" {
  description = "EXTRA tags for Hub VPC and networking"
  type        = map(string)
  default     = {}
}
