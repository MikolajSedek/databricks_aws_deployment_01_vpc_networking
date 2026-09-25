output "hub_vpc_id" {
  description = "HUB VPC id"
  value       = module.hub_vpc.vpc_id
}

output "hub_tgw_subnet_ids" {
  description = "LIST of Hub TGW subnet ids"
  value       = aws_subnet.hub_tgw_private_subnet[*].id
}

output "hub_firewall_subnet_ids" {
  description = "LIST of Hub Firewall subnet ids"
  value       = aws_subnet.hub_firewall_subnet[*].id
}

output "hub_tgw_private_rt_id" {
  description = "ID of Hub TGW private route table"
  value       = aws_route_table.hub_tgw_private_rt.id
}

output "hub_nat_public_rt_id" {
  description = "ID of Hub Nat public route table"
  value       = aws_route_table.hub_nat_public_rt.id
}

output "hub_igw_rt_id" {
  description = "ID of Hub IGW route table"
  value       = aws_route_table.hub_igw_rt.id
}
