
variable "kms_key_description" {
  description = "Custom KMS key description"
  type        = string
}

variable "enable_key_rotation" {
  description = "KMS key rotation enablement"
  type        = bool
  default     = true
}

variable "deletion_window_in_days" {
  description = "Number of days for key deletion"
  type        = number
  default     = 30
}

variable "kms_key_alias" {
  description = "KMS key alias"
  type        = string
}

variable "environment" {
  description = "Environment for TF deployment"
  type        = string
}
