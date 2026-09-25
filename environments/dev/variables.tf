/*
  Input Variables Definition - Dev Environment
  Documentation:
    - https://developer.hashicorp.com/terraform/language/values/variables

  Declares configuration variables for the dev environment:
    - Target AWS region and deployment profile.
    - Allowed AWS Account ID with validation constraint ensuring 12-digit format.
    - Environment name tag.
*/

variable "aws_region" {
  description = "The AWS region where resources will be deployed."
  type        = string
  default     = "eu-central-1"
}

variable "aws_account_id" {
  description = "The allowed AWS Account ID to prevent accidental deployment to the wrong account."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "The AWS Account ID must be a 12-digit number."
  }
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "profile" {
  description = "AWS CLI user profile"
  type        = string
  default     = "default"
}
