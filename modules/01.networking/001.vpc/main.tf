/*
  Amazon Virtual Private Cloud (Amazon VPC) Resource Definition
  Documentation: https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html

  Manages an Amazon VPC which provides a logically isolated virtual network
  for deploying AWS resources with custom CIDR blocks and DNS support.
*/

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = "${var.prefix}-${var.postfix}"
  })
}
