/*
  Amazon DynamoDB State Locking Backend Definition
  Documentation:
    - https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html
    - https://developer.hashicorp.com/terraform/language/settings/backends/s3#dynamodb-state-locking

  Provisions an Amazon DynamoDB table used for Terraform distributed state locking:
    - LockID primary partition key required by Terraform S3 backend state locking.
    - Server-side encryption enabled with customer-managed KMS key.
    - Point-in-time recovery (PITR) support for table backup and restoration.
*/

resource "aws_dynamodb_table" "this" {
  name         = local.table_name_with_env
  billing_mode = var.billing_mode
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  tags = merge(
    {
      Name        = local.table_name_with_env
      Environment = var.environment
    },
    var.tags
  )
}
