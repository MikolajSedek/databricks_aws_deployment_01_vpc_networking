/*
  AWS Network Firewall Routing Routes Configuration
  Documentation:
    - https://docs.aws.amazon.com/network-firewall/latest/developerguide/arch-centralized-symmetric.html
    - https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html

  Configures symmetric traffic routing for AWS Network Firewall in the Hub VPC:
    - Route from the NAT Gateway public route table directing outbound default traffic (0.0.0.0/0)
      through the Network Firewall VPC endpoint before reaching the internet.
    - Return ingress route from the Internet Gateway (IGW) route table directing incoming traffic
      for the NAT public subnet CIDRs through the Network Firewall VPC endpoint for inspection.
*/

/* Add Route from Nat Gateway to Firewall */
resource "aws_route" "db_nat_firewall" {
  route_table_id         = var.hub_nat_public_rt_id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = data.aws_vpc_endpoint.firewall.id
}

/* Add Route from Internet Gateway to Firewall */
resource "aws_route" "db_igw_nat_firewall" {
  route_table_id         = var.hub_igw_rt_id
  count                  = length(var.hub_nat_public_subnets_cidr)
  destination_cidr_block = var.hub_nat_public_subnets_cidr[count.index]
  vpc_endpoint_id        = data.aws_vpc_endpoint.firewall.id
}
