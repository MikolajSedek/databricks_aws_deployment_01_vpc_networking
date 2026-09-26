/*
  AWS Network Firewall Stateful Rule Groups Configuration
  Documentation:
    - https://docs.databricks.com/en/security/network/firewall-rules.html
    - https://docs.aws.amazon.com/network-firewall/latest/developerguide/rule-groups.html
    - https://docs.aws.amazon.com/network-firewall/latest/developerguide/stateful-rule-groups-domain-names.html

  Provisions stateful rule groups for egress inspection from Databricks compute nodes:
    - FQDN / Domain Allowlist Rule Group: Enforces strict TLS SNI and HTTP Host allowlisting
      for Databricks web application, Secure Cluster Connectivity (SCC) relay tunnel, regional
      Hive metastore RDS database, whitelisted external URLs (PyPI, CRAN), and S3 storage endpoints.
    - Control Plane Rule Group: Permits TCP port 443 outbound traffic to Databricks control plane CIDR.
    - Protocol Deny Rule Group: Blocks insecure/unauthorized protocols (ICMP, FTP, SSH) originating from HOME_NET.
*/

/* Firewall Rule group for accessing hive metastore and public repositories */
resource "aws_networkfirewall_rule_group" "databricks_fqdns_rg" {
  capacity = 100
  name     = "databricks-fqdns-rg-${var.env}"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["TLS_SNI", "HTTP_HOST"]
        targets = concat(
          [local.db_web_app, local.db_tunnel, local.db_rds],
          var.whitelisted_urls, local.fully_qualified_bucket_names
        )
      }
    }
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.spoke_cidr_block, var.hub_cidr_block]
        }
      }
    }
  }
  tags = var.tags
}

/* Firewall Rule group that allows control plane traffic from the VPC */
resource "aws_networkfirewall_rule_group" "allow_db_cpl_protocols_rg" {
  capacity    = 100
  description = "Allows control plane traffic traffic from source"
  name        = "allow-db-cpl-protocols-rg-${var.env}"
  type        = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.spoke_cidr_block, var.hub_cidr_block]
        }
      }
    }
    rules_source {
      dynamic "stateful_rule" {
        for_each = var.protocols_control_plane
        content {
          action = "PASS"
          header {
            destination      = local.db_control_plane
            destination_port = "443"
            protocol         = stateful_rule.value
            direction        = "ANY"
            source_port      = "ANY"
            source           = "ANY"
          }
          rule_option {
            keyword = "sid:${stateful_rule.key + 1}"
          }
        }
      }
    }
  }
  tags = var.tags
}

/* Firewall Rule group for dropping ICMP, FTP, SSH */
resource "aws_networkfirewall_rule_group" "deny_protocols_rg" {
  capacity    = 100
  description = "Drops FTP,ICMP, SSH traffic from source"
  name        = "deny-protocols-rg-${var.env}"
  type        = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.spoke_cidr_block, var.hub_cidr_block]
        }
      }
    }
    rules_source {
      dynamic "stateful_rule" {
        for_each = var.blocked_protocols
        content {
          action = "DROP"
          header {
            destination      = "ANY"
            destination_port = "ANY"
            protocol         = stateful_rule.value
            direction        = "ANY"
            source_port      = "ANY"
            source           = "ANY"
          }
          rule_option {
            keyword = "sid:${stateful_rule.key + 1}"
          }
        }
      }
    }
  }

  tags = var.tags
}
