/*
  AWS Network Firewall and Firewall Policy Configuration
  Documentation:
    - https://docs.aws.amazon.com/network-firewall/latest/developerguide/what-is-aws-network-firewall.html
    - https://docs.databricks.com/en/security/network/firewall-rules.html
    - https://docs.aws.amazon.com/network-firewall/latest/developerguide/arch-centralized-symmetric.html

  Provisions AWS Network Firewall in the Hub VPC for centralized outbound egress inspection:
    - Network Firewall Policy aggregating stateful rule groups (FQDN allowlist, protocol controls).
    - Network Firewall instance deployed across designated firewall subnets in the Hub VPC.
    - Data source querying VPC endpoints created by Network Firewall for route table traffic steering.
*/

/* Create Firewall Policy using Firewall Rule Groups */
resource "aws_networkfirewall_firewall_policy" "egress_policy" {
  name = "firewall-egress-policy-${var.env}"
  firewall_policy {
    stateless_default_actions          = [local.fp_actions]
    stateless_fragment_default_actions = [local.fp_actions]
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.databricks_fqdns_rg.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.deny_protocols_rg.arn
    }
    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.allow_db_cpl_protocols_rg.arn
    }
  }
  tags = var.tags
}

/* Create Networking Exfiltration Firewall */
resource "aws_networkfirewall_firewall" "exfiltration_firewall" {
  name                = "network-exfiltration-firewall-${var.env}"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.egress_policy.arn
  vpc_id              = var.hub_vpc_id
  dynamic "subnet_mapping" {
    for_each = var.hub_firewall_subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }
  tags = var.tags
}
