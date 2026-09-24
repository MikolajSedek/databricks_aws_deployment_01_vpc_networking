variable "table_name" {
  description = "Base name of the DynamoDB table for Terraform backend state locking"
  type        = string
}

variable "environment" {
  description = "Environment for TF deployment"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for DynamoDB table encryption"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "point_in_time_recovery_enabled" {
  description = "Enable DynamoDB point-in-time recovery"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the DynamoDB table"
  type        = map(string)
  default     = {}
}
