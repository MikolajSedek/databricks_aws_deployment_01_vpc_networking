/*
  Databricks Control Plane PrivateLink VPC Endpoints Configuration
  Documentation:
    - https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-private-link-workspace
    - https://docs.databricks.com/aws/en/security/network/classic/privatelink#create-vpc-endpoints

  Provisions the two AWS Interface VPC Endpoints required for Databricks Control Plane private connectivity:
    - Back-end Workspace (REST API) VPC Endpoint: Enables classic compute clusters to privately invoke
      Databricks Control Plane REST APIs over AWS PrivateLink.
    - Back-end Secure Cluster Connectivity (SCC) Relay VPC Endpoint: Enables classic compute clusters
      to establish private SCC relay tunnels to the Databricks Control Plane without public internet traversal.
*/

/* Back-end VPC Endpoint for Databricks Workspace (REST APIs) */
resource "aws_vpc_endpoint" "backend_rest" {
  vpc_id              = var.spoke_vpc_id
  service_name        = var.workspace_vpce_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.spoke_vpce_sg.id]
  subnet_ids          = aws_subnet.spoke_vpce_subnet[*].id
  private_dns_enabled = var.private_dns_enabled
  depends_on          = [aws_subnet.spoke_vpce_subnet]

  tags = merge(var.tags, {
    Name = "databricks-workspace-vpce-${var.env}"
  })
}

/* Back-end VPC Endpoint for Databricks Secure Cluster Connectivity (SCC) Relay */
resource "aws_vpc_endpoint" "relay" {
  vpc_id              = var.spoke_vpc_id
  service_name        = var.relay_vpce_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.spoke_vpce_sg.id]
  subnet_ids          = aws_subnet.spoke_vpce_subnet[*].id
  private_dns_enabled = var.private_dns_enabled
  depends_on          = [aws_subnet.spoke_vpce_subnet]

  tags = merge(var.tags, {
    Name = "databricks-scc-relay-vpce-${var.env}"
  })
}
