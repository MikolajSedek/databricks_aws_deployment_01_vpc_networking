variable "hub_vpc_id" {
  description = "HUB vpc ID"
  type        = string
}

variable "hub_tgw_subnet_ids" {
  description = "HUB tgw subnets ids list"
  type        = list(string)
}

variable "hub_tgw_private_rt_id" {
  description = "ID of Hub TGW private route table"
}

variable "hub_nat_public_rt_id" {
  description = "ID of Hub NAT public route table"
  type        = string
}




variable "spoke_vpc_id" {
  description = "SPOKE vpc ID"
  type        = string
}

variable "spoke_tgw_subnet_ids" {
  description = "SPOKE tgw subnets ids list"
  type        = list(string)
}

variable "spoke_cidr_block" {
  description = "CIDR block for Spoke VPC"
  type        = string
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
