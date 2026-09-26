locals {
  kms_key_alias_with_env = "${var.kms_key_alias}-${var.environment}"
}
