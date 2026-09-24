/* Create VPC Endpoints
They allow to route traffic through AWS backbone instead of public internet.
NOTE: if you plan to communicate with extra AWS services from Databricks compute clusters
 running in private subnets of Spoke - add them here.
 */
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id             = module.spoke_vpc.vpc_id
  security_group_ids = [aws_security_group.default_spoke_sg.id]

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        aws_route_table.spoke_db_private_rt.id
      ])
      tags = {
        Name = "${var.env}-s3-vpc-endpoint"
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = aws_subnet.spoke_db_private_subnet[*].id
      tags = {
        Name = "${var.env}-sts-vpc-endpoint"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = aws_subnet.spoke_db_private_subnet[*].id
      tags = {
        Name = "${var.env}-kinesis-vpc-endpoint"
      }
    },

  }

  tags = var.tags
}