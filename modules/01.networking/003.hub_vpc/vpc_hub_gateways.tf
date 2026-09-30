
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
  subnet_id     = aws_subnet.hub_nat_public_subnet[0].id
  depends_on    = [aws_internet_gateway.hub_igw]
  tags = merge(var.tags, {
    Name = "hub-nat-${var.env}"
  })
}
