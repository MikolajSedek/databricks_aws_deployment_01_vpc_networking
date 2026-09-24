output "spoke_vpc_id" {
  description = "SPOKE VPC id"
  value = module.spoke_vpc.vpc_id
}

output "spoke_tgw_subnet_ids" {
  description = "LIST of Spoke TGW subnet ids"
  value = aws_subnet.spoke_tgw_private_subnet[*].id
}