# 003.spoke_privatelink

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
| [aws_route_table.spoke_vpce_rt](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route_table) | resource |
| [aws_route_table_association.spoke_vpce_rta](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/route_table_association) | resource |
| [aws_security_group.spoke_vpce_sg](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/security_group) | resource |
| [aws_subnet.spoke_vpce_subnet](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/subnet) | resource |
| [aws_vpc_endpoint.backend_rest](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.relay](https://registry.terraform.io/providers/hashicorp/aws/6.66.0/docs/resources/vpc_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones for PrivateLink VPC endpoint subnets | `list(string)` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | ENVIRONMENT name | `string` | n/a | yes |
| <a name="input_private_dns_enabled"></a> [private\_dns\_enabled](#input\_private\_dns\_enabled) | Whether to associate a private hosted zone with the Databricks PrivateLink VPC endpoints | `bool` | `true` | no |
| <a name="input_relay_vpce_service"></a> [relay\_vpce\_service](#input\_relay\_vpce\_service) | Regional Databricks PrivateLink VPC endpoint service name for Secure Cluster Connectivity (SCC) relay | `string` | n/a | yes |
| <a name="input_sg_egress_ports"></a> [sg\_egress\_ports](#input\_sg\_egress\_ports) | Spoke Security Groups EGRESS ports used for PrivateLink VPC endpoint rules | `list(number)` | n/a | yes |
| <a name="input_spoke_db_private_subnets_cidr"></a> [spoke\_db\_private\_subnets\_cidr](#input\_spoke\_db\_private\_subnets\_cidr) | CIDR blocks of the Databricks compute private subnets in the Spoke VPC | `list(string)` | n/a | yes |
| <a name="input_spoke_vpc_id"></a> [spoke\_vpc\_id](#input\_spoke\_vpc\_id) | ID of the Databricks Customer-Managed Spoke VPC | `string` | n/a | yes |
| <a name="input_spoke_vpce_subnets_cidr"></a> [spoke\_vpce\_subnets\_cidr](#input\_spoke\_vpce\_subnets\_cidr) | CIDR blocks for the dedicated Databricks Control Plane PrivateLink VPC endpoint subnets in the Spoke VPC | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | EXTRA tags for Spoke PrivateLink networking resources | `map(string)` | `{}` | no |
| <a name="input_workspace_vpce_service"></a> [workspace\_vpce\_service](#input\_workspace\_vpce\_service) | Regional Databricks PrivateLink VPC endpoint service name for Workspace (REST API) access | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
