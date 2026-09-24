# dev

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.66.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backend_bucket"></a> [backend\_bucket](#module\_backend\_bucket) | ../../modules/03.storage/001.env_backend_bucket | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | ../../modules/02.security/001.kms_key | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The allowed AWS Account ID to prevent accidental deployment to the wrong account. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region where resources will be deployed. | `string` | `"eu-central-1"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment name (e.g. dev, staging, prod). | `string` | `"dev"` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | AWS CLI user profile | `string` | `"default"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
