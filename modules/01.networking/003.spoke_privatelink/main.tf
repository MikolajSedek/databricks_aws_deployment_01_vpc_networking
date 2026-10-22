/*
  Databricks Spoke VPC PrivateLink Subnets and Route Tables Configuration
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-private-link-workspace
    - https://docs.databricks.com/aws/en/security/network/classic/privatelink

  Provisions the foundational network isolation objects for Databricks Control Plane PrivateLink:
    - Dedicated private subnets in the Spoke VPC for housing data plane PrivateLink VPC endpoints.
    - Isolated local route table (with only the default VPC local route) dedicated to the PrivateLink
      VPC endpoint subnets, distinct from the Databricks compute workspace route table.
    - Route table associations linking the dedicated PrivateLink subnets to the local route table.
*/

/* Dedicated Spoke private subnets for Databricks Control Plane PrivateLink VPC endpoints */
resource "aws_subnet" "spoke_vpce_subnet" {
  vpc_id                  = var.spoke_vpc_id
  count                   = length(var.spoke_vpce_subnets_cidr)
  cidr_block              = var.spoke_vpce_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "spoke-pl-vpce-${var.env}-${element(var.availability_zones, count.index)}"
  })
}

/* Dedicated local route table for PrivateLink VPC endpoint subnets */
resource "aws_route_table" "spoke_vpce_rt" {
  vpc_id = var.spoke_vpc_id

  tags = merge(var.tags, {
    Name = "spoke-pl-vpce-rt-${var.env}"
  })
}

/* Associate PrivateLink VPC endpoint subnets with their dedicated local route table */
resource "aws_route_table_association" "spoke_vpce_rta" {
  count          = length(var.spoke_vpce_subnets_cidr)
  subnet_id      = aws_subnet.spoke_vpce_subnet[count.index].id
  route_table_id = aws_route_table.spoke_vpce_rt.id
}
