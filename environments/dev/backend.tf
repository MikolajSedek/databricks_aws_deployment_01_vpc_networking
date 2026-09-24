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
