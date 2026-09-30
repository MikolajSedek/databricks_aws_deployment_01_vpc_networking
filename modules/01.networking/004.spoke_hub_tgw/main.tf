/*
  AWS Transit Gateway (TGW) and VPC Attachments Configuration
  Documentation:
    - https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html

  Provisions the central AWS Transit Gateway interconnecting Hub and Spoke VPCs:
    - AWS EC2 Transit Gateway acting as the central cloud router.
    - VPC attachment connecting the Hub VPC via dedicated TGW subnets.
    - VPC attachment connecting the Databricks Spoke VPC via dedicated TGW subnets.
    - Enables DNS support and default route table association and propagation.
*/

# Create transit gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "Transit Gateway for Hub/Spoke"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags = merge(var.tags, {
    Name = "tgw-spoke-hub-${var.env}"
  })
}

# Attach Hub VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "hub" {
  subnet_ids         = var.hub_tgw_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.hub_vpc_id
  dns_support        = "enable"

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  tags = merge(var.tags, {
    Name    = "hub-vpc-tgw-attachment-${var.env}"
    Purpose = "Transit Gateway Attachment - Hub VPC"
  })
}

//# Attach Spoke VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  subnet_ids         = var.spoke_tgw_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.spoke_vpc_id
  dns_support        = "enable"

  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true
  tags = merge(var.tags, {
    Name    = "spoke-vpc-tgw-attachment-${var.env}"
    Purpose = "Transit Gateway Attachment - Spoke VPC"
  })
}
