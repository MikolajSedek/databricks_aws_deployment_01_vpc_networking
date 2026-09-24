variable "bucket_name" {
  description = "Base name of the S3 bucket for Terraform backend storage"
  type        = string
}

variable "environment" {
  description = "Environment for TF deployment"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for S3 server-side encryption"
  type        = string
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the bucket"
  type        = map(string)
  default     = {}
}
