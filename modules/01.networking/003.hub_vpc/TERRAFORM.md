# 003.hub_vpc

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_hub_vpc"></a> [hub\_vpc](#module\_hub\_vpc) | ../001.vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eip.hub_nat_eip](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/eip) | resource |
| [aws_internet_gateway.hub_igw](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/internet_gateway) | resource |
| [aws_main_route_table_association.set-worker-default-rt-assoc](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/main_route_table_association) | resource |
| [aws_nat_gateway.hub_nat](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/nat_gateway) | resource |
| [aws_route.db_firewall_public_gtw](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route) | resource |
| [aws_route.db_private_nat_gtw](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route) | resource |
| [aws_route_table.hub_firewall_rt](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route_table) | resource |
| [aws_route_table.hub_igw_rt](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route_table) | resource |
| [aws_route_table.hub_nat_public_rt](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route_table) | resource |
| [aws_route_table.hub_tgw_private_rt](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route_table) | resource |
| [aws_route_table_association.hub_firewall_rta](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route_table_association) | resource |
| [aws_route_table_association.hub_igw_rta](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route_table_association) | resource |
| [aws_route_table_association.hub_nat_rta](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route_table_association) | resource |
| [aws_route_table_association.hub_tgw_rta](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route_table_association) | resource |
| [aws_subnet.hub_firewall_subnet](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/subnet) | resource |
| [aws_subnet.hub_nat_public_subnet](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/subnet) | resource |
| [aws_subnet.hub_tgw_private_subnet](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | LIST of AZs for Hub VPC networking | `list(string)` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | ENVIRONMENT name | `string` | n/a | yes |
| <a name="input_hub_cidr_block"></a> [hub\_cidr\_block](#input\_hub\_cidr\_block) | Hub VPC CIDR block | `string` | n/a | yes |
| <a name="input_hub_firewall_subnets_cidr"></a> [hub\_firewall\_subnets\_cidr](#input\_hub\_firewall\_subnets\_cidr) | Hub VPC FIREWALL subnets CIDRs | `list(string)` | n/a | yes |
| <a name="input_hub_nat_public_subnets_cidr"></a> [hub\_nat\_public\_subnets\_cidr](#input\_hub\_nat\_public\_subnets\_cidr) | Hub VPC PUBLIC subnets CIDRs | `list(string)` | n/a | yes |
| <a name="input_hub_tgw_private_subnets_cidr"></a> [hub\_tgw\_private\_subnets\_cidr](#input\_hub\_tgw\_private\_subnets\_cidr) | Hub VPC PRIVATE subnets CIDRs | `list(string)` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | NAME prefix for Hub VPC | `string` | `"Hub VPC"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | EXTRA tags for Hub VPC and networking | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hub_firewall_subnet_ids"></a> [hub\_firewall\_subnet\_ids](#output\_hub\_firewall\_subnet\_ids) | LIST of Hub Firewall subnet ids |
| <a name="output_hub_igw_rt_id"></a> [hub\_igw\_rt\_id](#output\_hub\_igw\_rt\_id) | ID of Hub IGW route table |
| <a name="output_hub_nat_public_rt_id"></a> [hub\_nat\_public\_rt\_id](#output\_hub\_nat\_public\_rt\_id) | ID of Hub Nat public route table |
| <a name="output_hub_tgw_private_rt_id"></a> [hub\_tgw\_private\_rt\_id](#output\_hub\_tgw\_private\_rt\_id) | ID of Hub TGW private route table |
| <a name="output_hub_tgw_subnet_ids"></a> [hub\_tgw\_subnet\_ids](#output\_hub\_tgw\_subnet\_ids) | LIST of Hub TGW subnet ids |
| <a name="output_hub_vpc_id"></a> [hub\_vpc\_id](#output\_hub\_vpc\_id) | HUB VPC id |
<!-- END_TF_DOCS -->
