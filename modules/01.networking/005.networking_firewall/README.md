# 005.networking_firewall

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.66.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.66.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_networkfirewall_firewall.exfiltration_firewall](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/networkfirewall_firewall) | resource |
| [aws_networkfirewall_firewall_policy.egress_policy](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.allow_db_cpl_protocols_rg](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.databricks_fqdns_rg](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.deny_protocols_rg](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/networkfirewall_rule_group) | resource |
| [aws_route.db_igw_nat_firewall](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route) | resource |
| [aws_route.db_nat_firewall](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route) | resource |
| [aws_vpc_endpoint.firewall](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/data-sources/vpc_endpoint) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_blocked_protocols"></a> [blocked\_protocols](#input\_blocked\_protocols) | List of protocols to drop/block from the VPC | `list(string)` | <pre>[<br/>  "ICMP",<br/>  "FTP",<br/>  "SSH"<br/>]</pre> | no |
| <a name="input_db_resources_map"></a> [db\_resources\_map](#input\_db\_resources\_map) | Map of Databricks regional endpoints and resources (web\_app, tunnel, rds, control\_plane) | `map(string)` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | ENVIRONMENT name | `string` | n/a | yes |
| <a name="input_hub_cidr_block"></a> [hub\_cidr\_block](#input\_hub\_cidr\_block) | CIDR block for Hub VPC | `string` | n/a | yes |
| <a name="input_hub_firewall_subnet_ids"></a> [hub\_firewall\_subnet\_ids](#input\_hub\_firewall\_subnet\_ids) | List of Hub VPC Firewall subnet IDs | `list(string)` | n/a | yes |
| <a name="input_hub_igw_rt_id"></a> [hub\_igw\_rt\_id](#input\_hub\_igw\_rt\_id) | ID of Hub IGW public route table | `string` | n/a | yes |
| <a name="input_hub_nat_public_rt_id"></a> [hub\_nat\_public\_rt\_id](#input\_hub\_nat\_public\_rt\_id) | ID of Hub NAT public route table | `string` | n/a | yes |
| <a name="input_hub_nat_public_subnets_cidr"></a> [hub\_nat\_public\_subnets\_cidr](#input\_hub\_nat\_public\_subnets\_cidr) | Hub VPC PUBLIC subnets CIDRs | `list(string)` | n/a | yes |
| <a name="input_hub_vpc_id"></a> [hub\_vpc\_id](#input\_hub\_vpc\_id) | HUB vpc ID | `string` | n/a | yes |
| <a name="input_protocols_control_plane"></a> [protocols\_control\_plane](#input\_protocols\_control\_plane) | List of protocols allowed for Databricks control plane communication | `list(string)` | <pre>[<br/>  "TCP"<br/>]</pre> | no |
| <a name="input_spoke_cidr_block"></a> [spoke\_cidr\_block](#input\_spoke\_cidr\_block) | CIDR block for Spoke VPC | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | EXTRA tags for Hub VPC and networking | `map(string)` | `{}` | no |
| <a name="input_whitelisted_bucket_names"></a> [whitelisted\_bucket\_names](#input\_whitelisted\_bucket\_names) | NAMES of the firewall whitelisted S3 buckets | `list(string)` | n/a | yes |
| <a name="input_whitelisted_urls"></a> [whitelisted\_urls](#input\_whitelisted\_urls) | List of external URLs/domains to whitelist in the firewall | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
