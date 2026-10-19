locals {
  # Databricks regional endpoints extracted from db_resources_map
  db_web_app       = lookup(var.db_resources_map, "web_app", "")
  db_tunnel        = lookup(var.db_resources_map, "tunnel", "")
  db_rds           = lookup(var.db_resources_map, "rds", "")
  db_control_plane = lookup(var.db_resources_map, "control_plane", "")

  # create fully qualified domain names for s3 buckets used in the firewall allowlist
  generic_bucket_name_postfix = "s3.amazonaws.com"
  generic_qualified_bucket_names = [
    for bucket_name in var.whitelisted_bucket_names :
    "${bucket_name}.${local.generic_bucket_name_postfix}"
  ]
  regional_bucket_name_postfix = "s3.${var.region}.amazonaws.com"

  regional_fully_qualified_bucket_names = [
    for bucket_name in var.whitelisted_bucket_names :
    "${bucket_name}.${local.regional_bucket_name_postfix}"
  ]
  qualified_bucket_names = concat(local.generic_qualified_bucket_names, local.regional_fully_qualified_bucket_names)

  # firewall policy actions
  fp_actions = "aws:forward_to_sfe"
}
