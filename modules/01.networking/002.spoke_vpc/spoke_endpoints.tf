/*
  Databricks Spoke VPC Endpoints Configuration
  Documentation:
    - https://docs.databricks.com/en/security/network/classic/privatelink.html
    - https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html

  Provisions AWS VPC Endpoints in the Databricks Spoke VPC:
    - Gateway VPC Endpoint for Amazon S3 to enable direct, high-throughput, private access
      from Databricks compute clusters to S3 buckets without traversing NAT or internet gateways.
    - Interface VPC Endpoints (AWS PrivateLink) for AWS STS and Amazon Kinesis to keep
      internal AWS authentication and streaming data traffic on the AWS private network backbone.
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
        Name = "s3-vpc-endpoint-${var.env}"
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = aws_subnet.spoke_db_private_subnet[*].id
      tags = {
        Name = "sts-vpc-endpoint-${var.env}"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = aws_subnet.spoke_db_private_subnet[*].id
      tags = {
        Name = "kinesis-vpc-endpoint-${var.env}"
      }
    },

  }

  tags = var.tags
}
