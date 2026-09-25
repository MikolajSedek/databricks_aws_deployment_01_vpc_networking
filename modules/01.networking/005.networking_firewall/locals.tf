locals {
  # Databricks regional endpoints extracted from db_resources_map
  db_web_app       = lookup(var.db_resources_map, "web_app", lookup(var.db_resources_map, "db_web_app", ""))
  db_tunnel        = lookup(var.db_resources_map, "tunnel", lookup(var.db_resources_map, "db_tunnel", ""))
  db_rds           = lookup(var.db_resources_map, "rds", lookup(var.db_resources_map, "db_rds", ""))
  db_control_plane = lookup(var.db_resources_map, "control_plane", lookup(var.db_resources_map, "db_control_plane", ""))

  # create fully qualified domain names for s3 buckets used in the firewall allowlist
  bucket_name_postfix = "s3.amazonaws.com"
  fully_qualified_bucket_names = [
    for bucket_name in var.whitelisted_bucket_names :
    "${bucket_name}.${local.bucket_name_postfix}"
  ]

  # firewall policy actions
  fp_actions = "aws:forward_to_sfe"
}
