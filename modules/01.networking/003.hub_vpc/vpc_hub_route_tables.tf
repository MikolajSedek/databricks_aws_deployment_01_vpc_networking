/*
  Hub VPC Route Tables and Routing Associations Configuration
  Documentation:
    - https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html
    - https://docs.aws.amazon.com/network-firewall/latest/developerguide/arch-centralized-symmetric.html

  Provisions route tables, associations, and gateway routes in the Hub VPC:
    - Private TGW subnet route table routing outbound default traffic (0.0.0.0/0) to the NAT Gateway.
    - Public NAT subnet route table for handling NAT outbound and ingress traffic.
    - Dedicated Network Firewall route table for inspecting transit traffic.
    - Internet Gateway (IGW) route table with ingress routing rules directed to the firewall endpoint.
    - Subnet-to-route-table associations for TGW, NAT, Firewall, and IGW resources.
*/

/* Routing table for hub private subnet */
resource "aws_route_table" "hub_tgw_private_rt" {
  vpc_id = module.hub_vpc.vpc_id
  tags = merge(var.tags, {
    Name = "hub-tgw-private-rt-${var.env}"
  })
}

/* Routing table for hub nat public subnet */
resource "aws_route_table" "hub_nat_public_rt" {
  vpc_id = module.hub_vpc.vpc_id
  tags = merge(var.tags, {
    Name = "hub-nat-rt-${var.env}"
  })
}

/* Routing table for spoke nat public subnet */
resource "aws_route_table" "hub_firewall_rt" {
  vpc_id = module.hub_vpc.vpc_id
  tags = merge(var.tags, {
    Name = "hub-firewall-rt-${var.env}"
  })
}

/* Routing table for internet gateway */
resource "aws_route_table" "hub_igw_rt" {
  vpc_id = module.hub_vpc.vpc_id
  tags = merge(var.tags, {
    Name = "hub-igw-rt-${var.env}"
  })
}

/* Routing table associations for hub tgw */
resource "aws_route_table_association" "hub_tgw_rta" {
  count          = length(var.hub_tgw_private_subnets_cidr)
  subnet_id      = aws_subnet.hub_tgw_private_subnet.*.id[count.index]
  route_table_id = aws_route_table.hub_tgw_private_rt.id
}

resource "aws_route_table_association" "hub_nat_rta" {
  count          = length(var.hub_nat_public_subnets_cidr)
  subnet_id      = aws_subnet.hub_nat_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.hub_nat_public_rt.id
}

resource "aws_route_table_association" "hub_firewall_rta" {
  count          = length(var.hub_firewall_subnets_cidr)
  subnet_id      = aws_subnet.hub_firewall_subnet.*.id[count.index]
  route_table_id = aws_route_table.hub_firewall_rt.id
}

resource "aws_route_table_association" "hub_igw_rta" {
  gateway_id     = aws_internet_gateway.hub_igw.id
  route_table_id = aws_route_table.hub_igw_rt.id
}

/* Adding routes to route tables */
resource "aws_route" "db_private_nat_gtw" {
  route_table_id         = aws_route_table.hub_tgw_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.hub_nat.id
}

resource "aws_route" "db_firewall_public_gtw" {
  route_table_id         = aws_route_table.hub_firewall_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hub_igw.id
}

/* Manage the main routing table for VPC  */
resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  vpc_id         = module.hub_vpc.vpc_id
  route_table_id = aws_route_table.hub_firewall_rt.id
}
