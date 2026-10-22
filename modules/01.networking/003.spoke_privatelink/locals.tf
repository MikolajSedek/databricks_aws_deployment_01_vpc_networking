locals {
  vpce_allowed_cidrs = distinct(concat(var.spoke_vpce_subnets_cidr, var.spoke_db_private_subnets_cidr))
}
