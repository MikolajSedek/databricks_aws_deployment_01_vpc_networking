/*
  Local Values and Network Topology Configuration - Dev Environment
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/locals
    - https://docs.databricks.com/en/security/network/classic/customer-managed-vpc.html
    - https://docs.databricks.com/en/security/network/firewall-rules.html
    - https://docs.databricks.com/aws/en/security/network/classic/privatelink
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-private-link-workspace

  Defines reusable local values and calculations for the dev environment:
    - Project, environment, and backend bucket naming conventions.
    - Regional Databricks endpoints map (web app, SCC relay tunnel, RDS Hive metastore, control plane CIDR, PrivateLink services).
    - CIDR subnet calculations for Spoke VPC compute, TGW attachment, and PrivateLink VPC endpoint subnets.
    - CIDR subnet calculations for Hub VPC TGW, NAT, and Network Firewall inspection subnets.
    - Security group port rules and egress firewall URL allowlists.
*/

data "aws_availability_zones" "available_azs" {
  state = "available"
}

locals {
  /* basic setup */

  owner           = "msedek" // NOTE: change it to your name
  env             = "dev"
  project_name    = "${local.owner}-aws-dbx-dep"
  subproject_name = "vpc-net"

  backend_bucket_name = "${local.project_name}-${local.subproject_name}-s3-backend"

  /* NOTE: following information is regional based - adjust it properly to your AWS setup */
  /* This is a setup for region = "eu-central-1"

  /* Databricks Regional resources map */
  db_resources_map = {
    web_app                = "frankfurt.cloud.databricks.com"
    tunnel                 = "tunnel.eu-central-1.cloud.databricks.com"
    rds                    = "mdv2llxgl8lou0.ceptxxgorjrc.eu-central-1.rds.amazonaws.com"
    control_plane          = "18.159.44.32/28"
    workspace_vpce_service = "com.amazonaws.vpce.eu-central-1.vpce-svc-081f78503812597f7"
    relay_vpce_service     = "com.amazonaws.vpce.eu-central-1.vpce-svc-08e5dfca9572c85c4"
  }

  /* networking setup
  NOTE: hub subnets are not HA in this solution, adjust it to multi-AZ solution when required
  */
  spoke_cidr_block = "10.173.0.0/16"
  hub_cidr_block   = "10.10.0.0/16"

  spoke_db_private_subnets_cidr  = [cidrsubnet(local.spoke_cidr_block, 3, 0), cidrsubnet(local.spoke_cidr_block, 3, 1)]
  spoke_tgw_private_subnets_cidr = [cidrsubnet(local.spoke_cidr_block, 3, 2), cidrsubnet(local.spoke_cidr_block, 3, 3)]
  spoke_vpce_subnets_cidr        = [cidrsubnet(local.spoke_cidr_block, 3, 4), cidrsubnet(local.spoke_cidr_block, 3, 5)]
  hub_tgw_private_subnets_cidr   = [cidrsubnet(local.hub_cidr_block, 3, 0)]
  hub_nat_public_subnets_cidr    = [cidrsubnet(local.hub_cidr_block, 3, 1)]
  hub_firewall_subnets_cidr      = [cidrsubnet(local.hub_cidr_block, 3, 2)]
  sg_basic_ports = [
    443,  # for Databricks infrastructure, cloud data sources, and library repositories
    3306, # for the metastore
    6666, # for private link
    2443, # only for use with compliance security profile
  ]
  furure_extendability_ports = range(8443, 8452) # Future extendability
  sg_egress_ports            = concat(local.sg_basic_ports, local.furure_extendability_ports)
  sg_ingress_protocols       = ["tcp", "udp"]
  sg_egress_protocols        = ["tcp", "udp"]
  availability_zones         = data.aws_availability_zones.available_azs.names

  // Resources Groups Tags

  spoke_vpc_tags = {
    ResourceGroup = "Spoke VPC for ${local.env} environment"
  }

  spoke_privatelink_tags = {
    ResourceGroup = "Spoke PrivateLink for ${local.env} environment"
  }

  hub_vpc_tags = {
    ResourceGroup = "Hub VPC for ${local.env} environment"
  }

  tgw_tags = {
    ResourceGroup = "Spoke-Hub Transit Gateway"
  }

  /* FIREWALL setup */
  // add here all URLs that need to be used for the project, including databricks workspace URLs, library repositories, and other external services
  whitelisted_urls = concat([".pypi.org", ".pythonhosted.org", ".cran.r-project.org"], var.databricks_workspaces_urls)

  // add here all bucket names that need to be used for the project,
  // including databricks root buckets names, metastore buckets names, and other external buckets names
  whitelisted_bucket_names = var.databricks_buckets_names
}
