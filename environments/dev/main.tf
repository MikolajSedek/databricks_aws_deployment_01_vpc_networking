/* setup s3 backend for the project */

module "kms_key" {
  source = "../../modules/02.security/001.kms_key"

  environment         = local.env
  kms_key_alias       = "vpc_networking_backend_kms_key"
  kms_key_description = "KMS key used for backend storage security"
}

module "backend_bucket" {
  source = "../../modules/03.storage/001.env_backend_bucket"

  bucket_name = local.backend_bucket_name
  environment = local.env
  kms_key_arn = module.kms_key.kms_arn
}


