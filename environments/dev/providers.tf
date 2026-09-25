/*
  Terraform and AWS Provider Configuration - Dev Environment
  Documentation:
    - https://registry.terraform.io/providers/hashicorp/aws/latest/docs

  Defines Terraform version constraints, AWS provider requirements, and provider configuration:
    - Sets the target AWS region, profile, and allowed account IDs for safe deployment.
    - Applies default tags (Environment, ManagedBy, Project) to all resources managed in this environment.
*/

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
}

provider "aws" {
  profile             = var.profile
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "DatabricksDeployment"
    }
  }
}
