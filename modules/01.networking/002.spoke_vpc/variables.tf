variable "spoke_cidr_block" {
  description = "CIDR block for Spoke VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.spoke_cidr_block, 0))
    error_message = "The spoke_cidr_block must be a valid IPv4 CIDR block."
  }
}

variable "spoke_db_private_subnets_cidr" {
  description = "CIDR blocks for private subnets in Spoke VPC - used for Databricks compute clusters"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.spoke_db_private_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "All entries in spoke_db_private_subnets_cidr must be valid IPv4 CIDR blocks."
  }
}

variable "spoke_tgw_private_subnets_cidr" {
  description = "CIDR blocks for private subnets in Spoke VPC - used for AWS Transit Gateway communication"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.spoke_tgw_private_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "All entries in spoke_tgw_private_subnets_cidr must be valid IPv4 CIDR blocks."
  }
}

variable "sg_egress_ports" {
  description = "Spoke Security Groups EGRESS ports"
  type        = list(number)

  validation {
    condition     = alltrue([for port in var.sg_egress_ports : port >= 1 && port <= 65535])
    error_message = "All ports in sg_egress_ports must be valid TCP/UDP ports between 1 and 65535."
  }
}

variable "sg_egress_protocols" {
  description = "Spoke Security Groups EGRESS protocols"
  type        = list(string)
}

variable "sg_ingress_protocols" {
  description = "Spoke Security Groups INGRESS protocols"
  type        = list(string)
}

variable "name_prefix" {
  description = "NAME prefix for Spoke VPC"
  type        = string
  default     = "Spoke VPC"
}

variable "env" {
  description = "ENVIRONMENT name"
  type        = string
}

variable "availability_zones" {
  description = "LIST of AZs for Spoke VPC networking"
  type        = list(string)
}

variable "tags" {
  description = "EXTRA tags for Spoke VPC and networking"
  type        = map(string)
  default     = {}
}
