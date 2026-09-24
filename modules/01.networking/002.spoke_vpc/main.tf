/* Create Spoke VPC. */

module "spoke_vpc" {
  source           = "../001.vpc"
  cidr_block       = var.spoke_cidr_block
  postfix          = var.env
  prefix           = var.name_prefix
}

/* Spoke private subnet for dataplane cluster
NOTE: these networks will be used for Databricks Compute clusters
DON't deploy any AWS resources in these networks!
 */
resource "aws_subnet" "spoke_db_private_subnet" {
  vpc_id                  = module.spoke_vpc.vpc_id
  count                   = length(var.spoke_db_private_subnets_cidr)
  cidr_block              = var.spoke_db_private_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${var.env}-spoke-db-private-${element(var.availability_zones, count.index)}"
  })
}

/* Spoke private subnet for AWS transit gateway communication */
resource "aws_subnet" "spoke_tgw_private_subnet" {
  vpc_id                  = module.spoke_vpc.vpc_id
  count                   = length(var.spoke_tgw_private_subnets_cidr)
  cidr_block              = element(var.spoke_tgw_private_subnets_cidr, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${var.env}-spoke-tgw-private-${element(var.availability_zones, count.index)}"
  })
}

/* Routing table for spoke private subnet */
resource "aws_route_table" "spoke_db_private_rt" {
  vpc_id = module.spoke_vpc.vpc_id
  tags = merge(var.tags, {
    Name = "${var.env}-spoke-db-private-rt"
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
  subnet_id      = aws_subnet.spoke_db_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.spoke_db_private_rt.id
}
