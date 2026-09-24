locals {
  /* basic setup */


  env             = "dev"
  project_name    = "msedek-aws-dbx-dep"
  subproject_name = "vpc-net"

  backend_bucket_name = "${local.project_name}-${local.subproject_name}-s3-backend"

  /* networking setup
  NOTE: hub subnets are not HA in this solution, adjust it to multi-AZ solution when required
  */
  spoke_cidr_block  =  "10.173.0.0/16"
  hub_cidr_block = "10.10.0.0/16"

  spoke_db_private_subnets_cidr  = [cidrsubnet(local.spoke_cidr_block, 3, 0), cidrsubnet(local.spoke_cidr_block, 3, 1)]
  spoke_tgw_private_subnets_cidr = [cidrsubnet(local.spoke_cidr_block, 3, 2), cidrsubnet(local.spoke_cidr_block, 3, 3)]
  hub_tgw_private_subnets_cidr   = [cidrsubnet(local.hub_cidr_block, 3, 0)]
  hub_nat_public_subnets_cidr    = [cidrsubnet(local.hub_cidr_block, 3, 1)]
  hub_firewall_subnets_cidr      = [cidrsubnet(local.hub_cidr_block, 3, 2)]
  sg_egress_ports                = [443, 3306, 6666]
  sg_ingress_protocol            = ["tcp", "udp"]
  sg_egress_protocol             = ["tcp", "udp"]
  availability_zones             = ["${local.region}a", "${local.region}b"]



  /* NOTE: following information is regional based - adjust it properly to your AWS setup */
  region = "eu-central-1"
  db_web_app = "frankfurt.cloud.databricks.com"
  db_tunnel = "tunnel.eu-central-1.cloud.databricks.com"
  db_rds = "mdv2llxgl8lou0.ceptxxgorjrc.eu-central-1.rds.amazonaws.com"
  db_control_plane = "18.159.44.32/28"

  /* FIREWALL setup */
  whitelisted_urls = [".pypi.org", ".pythonhosted.org", ".cran.r-project.org"]

}
