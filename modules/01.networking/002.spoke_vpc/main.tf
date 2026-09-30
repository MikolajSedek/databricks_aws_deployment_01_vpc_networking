/*
  Databricks Spoke VPC and Subnets Configuration
  Documentation:
    - https://docs.databricks.com/en/security/network/classic/customer-managed-vpc.html
    - https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/aws-transit-gateway.html
    - https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html

  Provisions the Databricks customer-managed Spoke VPC and its private subnets:
    - Dedicated private subnets for Databricks compute data plane clusters (across availability zones).
    - Dedicated private subnets for AWS Transit Gateway (TGW) VPC attachments to enable
      routed connectivity between Spoke compute clusters and the Hub VPC.
*/

/* Create Spoke VPC. */
module "spoke_vpc" {
  source       = "../001.generic_vpc"
  cidr_block   = var.spoke_cidr_block
  name_postfix = var.env
  name_prefix  = var.name_prefix
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
    Name = "spoke-db-private-${var.env}-${element(var.availability_zones, count.index)}"
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
    Name = "spoke-tgw-private-${var.env}-${element(var.availability_zones, count.index)}"
  })
}
