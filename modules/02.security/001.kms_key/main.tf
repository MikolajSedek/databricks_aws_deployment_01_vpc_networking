terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "this" {
  description             = var.kms_key_description
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
}

resource "aws_kms_key_policy" "example" {
  key_id = aws_kms_key.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable root user permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      },
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : data.aws_caller_identity.current.arn
        },
        "Action" : "kms:*",
        "Resource" : aws_kms_key.this.arn
      }
    ]
  })
}

resource "aws_kms_alias" "this" {
  target_key_id = aws_kms_key.this.id
  name          = "alias/${local.kms_key_alias_with_env}"
}
