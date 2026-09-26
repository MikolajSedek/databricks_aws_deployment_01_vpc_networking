variable "spoke_cidr_block" {
  description = "CIDR block for Spoke VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.spoke_cidr_block, 0))
    error_message = "The spoke_cidr_block must be a valid IPv4 CIDR block."
  }
}

variable "hub_cidr_block" {
  description = "CIDR block for Hub VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.hub_cidr_block, 0))
    error_message = "The hub_cidr_block must be a valid IPv4 CIDR block."
  }
}

variable "hub_vpc_id" {
  description = "HUB vpc ID"
  type        = string

  validation {
    condition     = startswith(var.hub_vpc_id, "vpc-")
    error_message = "The hub_vpc_id must start with 'vpc-'."
  }
}

variable "hub_firewall_subnet_ids" {
  description = "List of Hub VPC Firewall subnet IDs"
  type        = list(string)
}

variable "hub_nat_public_rt_id" {
  description = "ID of Hub NAT public route table"
  type        = string
}

variable "hub_igw_rt_id" {
  description = "ID of Hub IGW public route table"
  type        = string
}

variable "hub_nat_public_subnets_cidr" {
  description = "Hub VPC PUBLIC subnets CIDRs"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.hub_nat_public_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "All entries in hub_nat_public_subnets_cidr must be valid IPv4 CIDR blocks."
  }
}

variable "db_resources_map" {
  description = "Map of Databricks regional endpoints and resources (web_app, tunnel, rds, control_plane)"
  type        = map(string)
}

variable "blocked_protocols" {
  description = "List of protocols to drop/block from the VPC"
  type        = list(string)
  default     = ["ICMP", "FTP", "SSH"]
}

variable "protocols_control_plane" {
  description = "List of protocols allowed for Databricks control plane communication"
  type        = list(string)
  default     = ["TCP"]
}

variable "whitelisted_urls" {
  description = "List of external URLs/domains to whitelist in the firewall"
  type        = list(string)
}

variable "whitelisted_bucket_names" {
  description = "NAMES of the firewall whitelisted S3 buckets"
  type        = list(string)
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
