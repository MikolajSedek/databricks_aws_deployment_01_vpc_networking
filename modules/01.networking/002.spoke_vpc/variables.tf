variable "spoke_cidr_block" {
  description = "CIDR block for Spoke VPC"
  type        = string
}

variable "spoke_db_private_subnets_cidr" {
  description = "CIDR blocks for private subnets in Spoke VPC - used for Databricks compute clusters"
  type        = list(string)
}

variable "spoke_tgw_private_subnets_cidr" {
  description = "CIDR blocks for private subnets in Spoke VPC - used for AWS Transit Gateway communication"
  type        = list(string)
}

variable "sg_egress_ports" {
  description = "Spoke Security Groups EGRESS ports"
  type        = list(number)
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
