/*
  Databricks Spoke VPC Security Group Configuration
  Documentation:
    - https://docs.databricks.com/en/security/network/classic/customer-managed-vpc.html#security-groups
    - https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html

  Provisions the default security group for Databricks compute clusters in the Spoke VPC:
    - Ingress: Allows self-referencing communication among cluster nodes within the security group across configured protocols.
    - Egress: Allows internal inter-node communication as well as outbound egress traffic on required TCP ports
      (such as HTTPS 443, MySQL 3306 for Hive Metastore, and 6666 for Secure Cluster Connectivity).
*/

resource "aws_security_group" "default_spoke_sg" {
  name        = "default_spoke_sg-${var.env}"
  description = "Default security group to allow inbound/outbound from the Spoke VPC"
  vpc_id      = module.spoke_vpc.vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress_protocols
    content {
      from_port = 0
      to_port   = 65535
      protocol  = ingress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_protocols
    content {
      from_port = 0
      to_port   = 65535
      protocol  = egress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = merge(var.tags, {
    Name = "default_spoke_sg-${var.env}"
  })
}
