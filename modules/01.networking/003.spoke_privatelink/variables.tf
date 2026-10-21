variable "spoke_vpc_id" {
  description = "ID of the Databricks Customer-Managed Spoke VPC"
  type        = string

  validation {
    condition     = startswith(var.spoke_vpc_id, "vpc-")
    error_message = "The spoke_vpc_id must start with 'vpc-'."
  }
}

variable "spoke_db_private_subnets_cidr" {
  description = "CIDR blocks of the Databricks compute private subnets in the Spoke VPC"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.spoke_db_private_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "All entries in spoke_db_private_subnets_cidr must be valid IPv4 CIDR blocks."
  }
}

variable "spoke_vpce_subnets_cidr" {
  description = "CIDR blocks for the dedicated Databricks Control Plane PrivateLink VPC endpoint subnets in the Spoke VPC"
  type        = list(string)

  validation {
    condition     = alltrue([for cidr in var.spoke_vpce_subnets_cidr : can(cidrhost(cidr, 0))])
    error_message = "All entries in spoke_vpce_subnets_cidr must be valid IPv4 CIDR blocks."
  }
}

variable "availability_zones" {
  description = "List of availability zones for PrivateLink VPC endpoint subnets"
  type        = list(string)
}

variable "workspace_vpce_service" {
  description = "Regional Databricks PrivateLink VPC endpoint service name for Workspace (REST API) access"
  type        = string

  validation {
    condition     = startswith(var.workspace_vpce_service, "com.amazonaws.vpce.")
    error_message = "The workspace_vpce_service must be a valid AWS PrivateLink service name starting with 'com.amazonaws.vpce.'."
  }
}

variable "relay_vpce_service" {
  description = "Regional Databricks PrivateLink VPC endpoint service name for Secure Cluster Connectivity (SCC) relay"
  type        = string

  validation {
    condition     = startswith(var.relay_vpce_service, "com.amazonaws.vpce.")
    error_message = "The relay_vpce_service must be a valid AWS PrivateLink service name starting with 'com.amazonaws.vpce.'."
  }
}

variable "sg_egress_ports" {
  description = "Spoke Security Groups EGRESS ports used for PrivateLink VPC endpoint rules"
  type        = list(number)

  validation {
    condition     = alltrue([for port in var.sg_egress_ports : port >= 1 && port <= 65535])
    error_message = "All ports in sg_egress_ports must be valid TCP/UDP ports between 1 and 65535."
  }
}

variable "private_dns_enabled" {
  description = "Whether to associate a private hosted zone with the Databricks PrivateLink VPC endpoints"
  type        = bool
  default     = true
}

variable "env" {
  description = "ENVIRONMENT name"
  type        = string
}

variable "tags" {
  description = "EXTRA tags for Spoke PrivateLink networking resources"
  type        = map(string)
  default     = {}
}
