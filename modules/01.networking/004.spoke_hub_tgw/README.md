# 004.spoke_hub_tgw

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.66.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_route.spoke_to_hub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.hub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.spoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_route.hub_nat_to_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.hub_tgw_private_subnet_to_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.spoke_db_to_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | ENVIRONMENT name | `string` | n/a | yes |
| <a name="input_hub_nat_public_rt_id"></a> [hub\_nat\_public\_rt\_id](#input\_hub\_nat\_public\_rt\_id) | ID of Hub NAT public route table | `string` | n/a | yes |
| <a name="input_hub_tgw_private_rt_id"></a> [hub\_tgw\_private\_rt\_id](#input\_hub\_tgw\_private\_rt\_id) | ID of Hub TGW private route table | `any` | n/a | yes |
| <a name="input_hub_tgw_subnet_ids"></a> [hub\_tgw\_subnet\_ids](#input\_hub\_tgw\_subnet\_ids) | HUB tgw subnets ids list | `list(string)` | n/a | yes |
| <a name="input_hub_vpc_id"></a> [hub\_vpc\_id](#input\_hub\_vpc\_id) | HUB vpc ID | `string` | n/a | yes |
| <a name="input_spoke_cidr_block"></a> [spoke\_cidr\_block](#input\_spoke\_cidr\_block) | CIDR block for Spoke VPC | `string` | n/a | yes |
| <a name="input_spoke_db_private_rt_id"></a> [spoke\_db\_private\_rt\_id](#input\_spoke\_db\_private\_rt\_id) | ID of Spoke DB private route table | `string` | n/a | yes |
| <a name="input_spoke_tgw_subnet_ids"></a> [spoke\_tgw\_subnet\_ids](#input\_spoke\_tgw\_subnet\_ids) | SPOKE tgw subnets ids list | `list(string)` | n/a | yes |
| <a name="input_spoke_vpc_id"></a> [spoke\_vpc\_id](#input\_spoke\_vpc\_id) | SPOKE vpc ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | EXTRA tags for Hub VPC and networking | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
