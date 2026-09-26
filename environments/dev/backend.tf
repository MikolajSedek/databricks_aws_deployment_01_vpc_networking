/*
  Terraform Remote Backend Configuration - Dev Environment
  Documentation:
    - https://developer.hashicorp.com/terraform/language/settings/backends/s3

  Configures the remote S3 state backend for the dev environment:
    - Stores the Terraform state in an encrypted Amazon S3 bucket.
    - Enables state locking using S3 native lockfile support (use_lockfile = true).
    - Uses the designated AWS CLI profile and regional settings.
*/

terraform {
  backend "s3" {
    bucket       = "msedek-aws-dbx-dep-vpc-net-s3-backend-dev"
    key          = "01_setup_vpc_networking/dev/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
    profile      = "production-admin"
  }
}
