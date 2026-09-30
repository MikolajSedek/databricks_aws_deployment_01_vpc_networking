# 002.spoke_vpc

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
| <a name="module_spoke_vpc"></a> [spoke\_vpc](#module\_spoke\_vpc) | ../001.generic_vpc | n/a |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 3.11.0 |

## Resources

| Name | Type |
|------|------|
| [aws_main_route_table_association.spoke-set-worker-default-rt-assoc](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/main_route_table_association) | resource |
| [aws_route_table.spoke_db_private_rt](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route_table) | resource |
| [aws_route_table_association.spoke_db_private_rta](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route_table_association) | resource |
| [aws_security_group.default_spoke_sg](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/security_group) | resource |
| [aws_subnet.spoke_db_private_subnet](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/subnet) | resource |
| [aws_subnet.spoke_tgw_private_subnet](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | LIST of AZs for Spoke VPC networking | `list(string)` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | ENVIRONMENT name | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | NAME prefix for Spoke VPC | `string` | `"Spoke VPC"` | no |
| <a name="input_sg_egress_ports"></a> [sg\_egress\_ports](#input\_sg\_egress\_ports) | Spoke Security Groups EGRESS ports | `list(number)` | n/a | yes |
| <a name="input_sg_egress_protocols"></a> [sg\_egress\_protocols](#input\_sg\_egress\_protocols) | Spoke Security Groups EGRESS protocols | `list(string)` | n/a | yes |
| <a name="input_sg_ingress_protocols"></a> [sg\_ingress\_protocols](#input\_sg\_ingress\_protocols) | Spoke Security Groups INGRESS protocols | `list(string)` | n/a | yes |
| <a name="input_spoke_cidr_block"></a> [spoke\_cidr\_block](#input\_spoke\_cidr\_block) | CIDR block for Spoke VPC | `string` | n/a | yes |
| <a name="input_spoke_db_private_subnets_cidr"></a> [spoke\_db\_private\_subnets\_cidr](#input\_spoke\_db\_private\_subnets\_cidr) | CIDR blocks for private subnets in Spoke VPC - used for Databricks compute clusters | `list(string)` | n/a | yes |
| <a name="input_spoke_tgw_private_subnets_cidr"></a> [spoke\_tgw\_private\_subnets\_cidr](#input\_spoke\_tgw\_private\_subnets\_cidr) | CIDR blocks for private subnets in Spoke VPC - used for AWS Transit Gateway communication | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | EXTRA tags for Spoke VPC and networking | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_spoke_db_private_rt_id"></a> [spoke\_db\_private\_rt\_id](#output\_spoke\_db\_private\_rt\_id) | ID of Spoke DB private route table |
| <a name="output_spoke_tgw_subnet_ids"></a> [spoke\_tgw\_subnet\_ids](#output\_spoke\_tgw\_subnet\_ids) | LIST of Spoke TGW subnet ids |
| <a name="output_spoke_vpc_id"></a> [spoke\_vpc\_id](#output\_spoke\_vpc\_id) | SPOKE VPC id |
<!-- END_TF_DOCS -->
