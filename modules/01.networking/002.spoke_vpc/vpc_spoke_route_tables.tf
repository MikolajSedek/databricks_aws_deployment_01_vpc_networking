/*
  Databricks Spoke VPC Route Tables Configuration
  Documentation:
    - https://docs.databricks.com/en/security/network/classic/customer-managed-vpc.html#route-tables
    - https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html

  Provisions route tables and subnet associations for the Databricks Spoke VPC:
    - Dedicated route table for Spoke compute private subnets.
    - Associations linking private compute subnets to the route table.
    - Main route table association for the Spoke VPC.
*/

/* Routing table for spoke private subnet */
resource "aws_route_table" "spoke_db_private_rt" {
  vpc_id = module.spoke_vpc.vpc_id
  tags = merge(var.tags, {
    Name = "spoke-db-private-rt-${var.env}"
  })
}

/* Manage the main routing table for VPC  */
resource "aws_main_route_table_association" "spoke-set-worker-default-rt-assoc" {
  vpc_id         = module.spoke_vpc.vpc_id
  route_table_id = aws_route_table.spoke_db_private_rt.id
}

/* Routing table associations for spoke */
resource "aws_route_table_association" "spoke_db_private_rta" {
  count          = length(var.spoke_db_private_subnets_cidr)
  subnet_id      = aws_subnet.spoke_db_private_subnet[count.index].id
  route_table_id = aws_route_table.spoke_db_private_rt.id
}
