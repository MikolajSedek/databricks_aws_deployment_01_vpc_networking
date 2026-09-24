/* Spoke Default Security Group */
resource "aws_security_group" "default_spoke_sg" {
  name        = "${var.env}-default_spoke_sg"
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

  tags = var.tags
}