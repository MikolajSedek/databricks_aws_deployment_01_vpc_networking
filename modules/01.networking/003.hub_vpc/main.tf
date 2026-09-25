/*
  Hub VPC and Networking Infrastructure Configuration
  Documentation:
    - https://docs.databricks.com/en/security/network/classic/customer-managed-vpc.html
    - https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html
    - https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html

  Provisions the centralized Hub VPC and its core routing infrastructure:
    - Hub VPC instance with DNS support enabled.
    - Private subnets for AWS Transit Gateway (TGW) attachment.
    - Public subnets for NAT Gateways and egress routing.
    - Dedicated subnets for AWS Network Firewall endpoint deployment and traffic inspection.
    - Internet Gateway (IGW), Elastic IP (EIP), and NAT Gateway for controlled outbound egress.
*/

/* Create VPC */
module "hub_vpc" {
  source     = "../001.vpc"
  cidr_block = var.hub_cidr_block
  postfix    = var.env
  prefix     = var.name_prefix
  tags       = var.tags
}

/* Private subnet for Hub TGW Databricks */
resource "aws_subnet" "hub_tgw_private_subnet" {
  vpc_id                  = module.hub_vpc.vpc_id
  count                   = length(var.hub_tgw_private_subnets_cidr)
  cidr_block              = var.hub_tgw_private_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "hub-tgw-private-${var.env}-${element(var.availability_zones, count.index)}"
  })
}

/* NAT Public subnet */
resource "aws_subnet" "hub_nat_public_subnet" {
  vpc_id                  = module.hub_vpc.vpc_id
  count                   = length(var.hub_nat_public_subnets_cidr)
  cidr_block              = var.hub_nat_public_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "hub-nat-public-${var.env}-${element(var.availability_zones, count.index)}"
  })
}

/* Firewall subnet */
resource "aws_subnet" "hub_firewall_subnet" {
  vpc_id                  = module.hub_vpc.vpc_id
  count                   = length(var.hub_firewall_subnets_cidr)
  cidr_block              = var.hub_firewall_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "hub-firewall-public-${var.env}-${element(var.availability_zones, count.index)}"
  })
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "hub_igw" {
  vpc_id = module.hub_vpc.vpc_id
  tags = merge(var.tags, {
    Name = "hub-igw-${var.env}"
  })
}

/* Elastic IP for NAT */
resource "aws_eip" "hub_nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.hub_igw]
}

/* Hub NAT Gateway */
resource "aws_nat_gateway" "hub_nat" {
  allocation_id = aws_eip.hub_nat_eip.id
  subnet_id     = aws_subnet.hub_nat_public_subnet.*.id[0]
  depends_on    = [aws_internet_gateway.hub_igw]
  tags = merge(var.tags, {
    Name = "hub-nat-${var.env}"
  })
}
