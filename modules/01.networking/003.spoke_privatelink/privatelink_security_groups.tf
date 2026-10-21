/*
  Databricks Spoke VPC PrivateLink Security Group Configuration
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-private-link-workspace
    - https://docs.databricks.com/aws/en/security/network/classic/privatelink#create-security-groups

  Provisions the dedicated security group for Databricks Control Plane PrivateLink VPC endpoints:
    - Enforces bidirectional TCP traffic rules across the configured sg_egress_ports
      (e.g., 443, 6666, 2443, 3306, 8443-8451) scoped strictly to the PrivateLink endpoint
      subnet CIDRs and Databricks compute private subnet CIDRs.
*/

resource "aws_security_group" "spoke_vpce_sg" {
  name        = "spoke_pl_vpce_sg-${var.env}"
  description = "Security group shared with Databricks SCC relay and workspace REST API PrivateLink endpoints"
  vpc_id      = var.spoke_vpc_id

  dynamic "ingress" {
    for_each = toset(var.sg_egress_ports)

    content {
      description = "Allow inbound TCP traffic to PrivateLink VPC endpoints from compute and endpoint subnets"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = local.vpce_allowed_cidrs
    }
  }

  dynamic "egress" {
    for_each = toset(var.sg_egress_ports)

    content {
      description = "Allow outbound TCP traffic from PrivateLink VPC endpoints to compute and endpoint subnets"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = local.vpce_allowed_cidrs
    }
  }

  tags = merge(var.tags, {
    Name = "spoke_pl_vpce_sg-${var.env}"
  })
}
