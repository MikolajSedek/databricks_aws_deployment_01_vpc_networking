/*
  Databricks Hub-and-Spoke Infrastructure Orchestration - Dev Environment
  Documentation:
    - https://docs.databricks.com/en/security/network/classic/customer-managed-vpc.html
    - https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/aws-transit-gateway.html
    - https://docs.aws.amazon.com/network-firewall/latest/developerguide/arch-centralized-symmetric.html

  Root module orchestrating the end-to-end networking stack for Databricks in AWS:
    - Security & Backend Storage: Customer Managed KMS key and S3 state backend bucket.
    - Spoke VPC: Private compute subnets for Databricks clusters and VPC endpoints (S3, STS, Kinesis).
    - Hub VPC: Centralized egress VPC with public NAT Gateways, Internet Gateway, and inspection subnets.
    - AWS Transit Gateway: Interconnects Spoke and Hub VPCs with centralized routing.
    - AWS Network Firewall: Stateful traffic inspection and FQDN filtering for outbound traffic.
*/

/* setup s3 backend for the project */

module "kms_key" {
  source = "../../modules/02.security/001.kms_key"

  environment         = local.env
  kms_key_alias       = "vpc_networking_backend_kms_key"
  kms_key_description = "KMS key used for backend storage security"
}

module "backend_bucket" {
  source = "../../modules/03.storage/001.env_backend_bucket"

  bucket_name = local.backend_bucket_name
  environment = local.env
  kms_key_arn = module.kms_key.kms_arn
}

/* deploy Hub and Spoke AWS architecture for Databricks */

// SPOKE VPC deployment
module "spoke_vpc" {
  source = "../../modules/01.networking/002.spoke_vpc"

  availability_zones             = local.availability_zones
  env                            = local.env
  sg_egress_ports                = local.sg_egress_ports
  sg_egress_protocols            = local.sg_egress_protocols
  sg_ingress_protocols           = local.sg_ingress_protocols
  spoke_cidr_block               = local.spoke_cidr_block
  spoke_db_private_subnets_cidr  = local.spoke_db_private_subnets_cidr
  spoke_tgw_private_subnets_cidr = local.spoke_tgw_private_subnets_cidr
  tags                           = local.spoke_vpc_tags
}

// HUB VPC deployment
// Note: in this demo project it's currently HA with single AZs for subnets
module "hub_vpc" {
  source                       = "../../modules/01.networking/003.hub_vpc"
  availability_zones           = local.availability_zones
  env                          = local.env
  hub_cidr_block               = local.hub_cidr_block
  hub_firewall_subnets_cidr    = local.hub_firewall_subnets_cidr
  hub_nat_public_subnets_cidr  = local.hub_nat_public_subnets_cidr
  hub_tgw_private_subnets_cidr = local.hub_tgw_private_subnets_cidr
  tags                         = local.hub_vpc_tags
}

// Transit Gateway deployment
// DEPENDS ON: Spoke and Hub VPCs

module "spoke_hub_transit_gateway" {
  source                 = "../../modules/01.networking/004.spoke_hub_tgw"
  env                    = local.env
  hub_nat_public_rt_id   = module.hub_vpc.hub_nat_public_rt_id
  hub_tgw_private_rt_id  = module.hub_vpc.hub_tgw_private_rt_id
  hub_tgw_subnet_ids     = module.hub_vpc.hub_tgw_subnet_ids
  hub_vpc_id             = module.hub_vpc.hub_vpc_id
  spoke_cidr_block       = local.spoke_cidr_block
  spoke_db_private_rt_id = module.spoke_vpc.spoke_db_private_rt_id
  spoke_tgw_subnet_ids   = module.spoke_vpc.spoke_tgw_subnet_ids
  spoke_vpc_id           = module.spoke_vpc.spoke_vpc_id
  tags                   = local.tgw_tags
}

// Hub Networking Anti-Exfiltration Firewall deployment
module "hub_vpc_network_firewall" {
  source                      = "../../modules/01.networking/005.networking_firewall"
  db_resources_map            = local.db_resources_map
  env                         = local.env
  hub_cidr_block              = local.hub_cidr_block
  hub_firewall_subnet_ids     = local.hub_firewall_subnets_cidr
  hub_igw_rt_id               = module.hub_vpc.hub_igw_rt_id
  hub_nat_public_rt_id        = module.hub_vpc.hub_nat_public_rt_id
  hub_nat_public_subnets_cidr = local.hub_nat_public_subnets_cidr
  hub_vpc_id                  = module.hub_vpc.hub_vpc_id
  spoke_cidr_block            = local.spoke_cidr_block
  whitelisted_bucket_names    = local.whitelisted_bucket_names
  whitelisted_urls            = local.whitelisted_urls
}
