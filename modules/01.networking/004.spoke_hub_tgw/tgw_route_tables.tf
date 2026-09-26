/*
  Transit Gateway Routing and VPC Route Propagation Configuration
  Documentation:
    - https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html

  Manages Transit Gateway routing and VPC routing table integrations:
    - Default route (0.0.0.0/0) in TGW route table directing egress traffic toward the Hub VPC attachment.
    - Default route (0.0.0.0/0) in Spoke compute route tables directing egress traffic into the Transit Gateway.
    - Reverse routes in Hub private and NAT subnets directing return traffic back to the Spoke CIDR via the Transit Gateway.
*/

# Create Route to Internet
resource "aws_ec2_transit_gateway_route" "spoke_to_hub" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.hub.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}

# Add route for Spoke Db to TGW
resource "aws_route" "spoke_db_to_tgw" {
  route_table_id         = var.spoke_db_private_rt_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Add routes from Hub private and NAT subnets to Spoke through TGW
resource "aws_route" "hub_tgw_private_subnet_to_tgw" {
  route_table_id         = var.hub_tgw_private_rt_id
  destination_cidr_block = var.spoke_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "hub_nat_to_tgw" {
  route_table_id         = var.hub_nat_public_rt_id
  destination_cidr_block = var.spoke_cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}
