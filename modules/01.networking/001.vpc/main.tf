/*
  Amazon Virtual Private Cloud (Amazon VPC) Resource Definition
  Documentation:
    - https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html
    - https://docs.databricks.com/en/security/network/classic/customer-managed-vpc.html

  Manages a base Amazon VPC resource which provides a logically isolated virtual network
  used as the foundation for Databricks Spoke and Hub networking topologies, configuring
  custom CIDR blocks, DNS hostnames, and DNS resolution support.
*/

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = "${var.prefix}-${var.postfix}"
  })
}
