/*
  Local Values and Network Topology Configuration - Dev Environment
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/locals
    - https://docs.databricks.com/en/security/network/classic/customer-managed-vpc.html
    - https://docs.databricks.com/en/security/network/firewall-rules.html

  Defines reusable local values and calculations for the dev environment:
    - Project, environment, and backend bucket naming conventions.
    - Regional Databricks endpoints map (web app, SCC relay tunnel, RDS Hive metastore, control plane CIDR).
    - CIDR subnet calculations for Spoke VPC compute and TGW attachment subnets.
    - CIDR subnet calculations for Hub VPC TGW, NAT, and Network Firewall inspection subnets.
    - Security group port rules and egress firewall URL allowlists.
*/

locals {
  /* basic setup */

  env             = "dev"
  project_name    = "msedek-aws-dbx-dep"
  subproject_name = "vpc-net"

  backend_bucket_name = "${local.project_name}-${local.subproject_name}-s3-backend"

  /* NOTE: following information is regional based - adjust it properly to your AWS setup */
  region = "eu-central-1"

  db_resources_map = {
    web_app       = "frankfurt.cloud.databricks.com"
    tunnel        = "tunnel.eu-central-1.cloud.databricks.com"
    rds           = "mdv2llxgl8lou0.ceptxxgorjrc.eu-central-1.rds.amazonaws.com"
    control_plane = "18.159.44.32/28"
  }

  /* networking setup
  NOTE: hub subnets are not HA in this solution, adjust it to multi-AZ solution when required
  */
  spoke_cidr_block = "10.173.0.0/16"
  hub_cidr_block   = "10.10.0.0/16"

  spoke_db_private_subnets_cidr  = [cidrsubnet(local.spoke_cidr_block, 3, 0), cidrsubnet(local.spoke_cidr_block, 3, 1)]
  spoke_tgw_private_subnets_cidr = [cidrsubnet(local.spoke_cidr_block, 3, 2), cidrsubnet(local.spoke_cidr_block, 3, 3)]
  hub_tgw_private_subnets_cidr   = [cidrsubnet(local.hub_cidr_block, 3, 0)]
  hub_nat_public_subnets_cidr    = [cidrsubnet(local.hub_cidr_block, 3, 1)]
  hub_firewall_subnets_cidr      = [cidrsubnet(local.hub_cidr_block, 3, 2)]
  sg_egress_ports                = [443, 3306, 6666]
  sg_ingress_protocols           = ["tcp", "udp"]
  sg_egress_protocols            = ["tcp", "udp"]
  az_postfixes                   = ["a", "b", "c"]
  availability_zones             = [for az in local.az_postfixes : "${local.region}${az}"]

  spoke_vpc_tags = {
    VpcDomain = "Spoke VPC for ${local.env} environment"
  }

  hub_vpc_tags = {
    VpcDomain = "Hub VPC for ${local.env} environment"
  }

  tgw_tags = {
    VpcDomain = "Spoke-Hub Transit Gateway"
  }

  /* FIREWALL setup */
  whitelisted_urls = [".pypi.org", ".pythonhosted.org", ".cran.r-project.org"]

  // add here all bucket names that need to be used for the project
  whitelisted_bucket_names = []
}
