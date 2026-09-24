# AI Assistant Guidelines & Sources of Truth

This project deploys AWS infrastructure for **Enterprise Databricks** using a **Hub and Spoke Firewall Architecture** via Terraform. When generating, reviewing, or modifying Terraform code, architecture, or AWS/Databricks configurations, strictly adhere to the following guidelines and authoritative sources of truth.

---

## 1. Project Context & Architectural Goal

- **Objective**: Provision an enterprise-grade AWS network and security foundation for Databricks E2 workspaces using a **Hub and Spoke** architecture with centralized firewall inspection (AWS Network Firewall / Transit Gateway).
- **Core Reference Architecture**: Follow the official Databricks guide on [AWS E2 Firewall Hub and Spoke Architecture](https://github.com/databricks/terraform-provider-databricks/blob/main/docs/guides/aws-e2-firewall-hub-and-spoke.md).

---

## 2. Authoritative Sources of Truth

Always ground implementations in official, up-to-date documentation. Do not rely on assumptions or potentially outdated training data when designing AWS architecture or writing Terraform resource definitions.

### A. Databricks E2 Hub and Spoke Architecture Guide *(Primary Architectural Reference)*
- **Hub & Spoke Firewall Guide**:
  - [Databricks AWS E2 Firewall Hub and Spoke Guide](https://github.com/databricks/terraform-provider-databricks/blob/main/docs/guides/aws-e2-firewall-hub-and-spoke.md)
- **Databricks Terraform Provider Documentation**:
  - [Databricks Terraform Registry Docs](https://registry.terraform.io/providers/databricks/databricks/latest/docs)
  - [Databricks AWS Customer-Managed VPC Requirements](https://docs.databricks.com/en/security/network/customer-managed-vpc.html)

### B. AWS Official Documentation
- **AWS Documentation MCP Server (`aws-docs`)**:
  - Use `search_documentation`, `read_documentation`, `read_sections`, and `recommend` to verify service limits, IAM policy requirements, encryption specifications, networking constraints (VPC, Transit Gateway, Network Firewall), and Well-Architected Framework guidelines.
- **Web Documentation**:
  - [AWS Official Documentation](https://docs.aws.amazon.com/)
  - [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

### C. Terraform AWS Provider & Registry
- **Terraform MCP Server (`terraform`)**:
  - Use `providerDetails`, `moduleDetails`, and available registry tools to verify provider version requirements, argument names, schema types, and deprecated attributes.
- **Web Documentation**:
  - [Terraform AWS Provider Registry Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
  - [Terraform Language Documentation](https://developer.hashicorp.com/terraform/docs)

---

## 3. MCP Server & Resource Usage Protocol

When assisting with infrastructure tasks:

1. **Align with Databricks Hub-and-Spoke Pattern**:
   - Check routing rules, subnet divisions (public, firewall, TGW attachment, spoke private data/control plane subnets), and firewall domain allowlists against the [Databricks AWS E2 Firewall Guide](https://github.com/databricks/terraform-provider-databricks/blob/main/docs/guides/aws-e2-firewall-hub-and-spoke.md).
2. **Verify Resource Syntax**:
   - Query the **Terraform MCP Server** or official registry documentation to confirm the exact arguments, required blocks, and valid attribute values for `hashicorp/aws` and `databricks/databricks` resources.
3. **Validate AWS Service Constraints & IAM Policies**:
   - Query the **AWS Documentation MCP Server (`aws-docs`)** to verify security best practices (e.g., KMS key policies, bucket policies, VPC endpoint routing, IAM cross-account roles).
4. **Check for Deprecations**:
   - Verify that new resource blocks follow modern AWS provider syntax (e.g., standalone `aws_s3_bucket_*`, `aws_route_table`, `aws_networkfirewall_*` resources).

---

## 4. Project Standards & Best Practices

- **Security First**:
  - Enforce server-side encryption with customer-managed KMS keys where applicable.
  - Enforce least privilege in IAM and KMS key policies.
  - Block public access on all S3 buckets by default unless explicitly intended.
- **Networking Integrity**:
  - Maintain strict separation of concerns between Hub VPC (Transit Gateway, Network Firewall, NAT Gateways, Internet Gateway) and Spoke VPCs (Databricks Workspace compute and storage subnets).
  - Ensure all Databricks control plane and storage traffic routes through the firewall or VPC endpoints as dictated by the architecture guide.
- **State Management**:
  - Terraform remote state is stored in versioned, KMS-encrypted S3 buckets with DynamoDB state locking (`LockID` attribute).
- **Code Organization**:
  - Follow modular architecture in `modules/` with isolated environments in `environments/<env>/`.
  - Maintain consistent file structure (`main.tf`, `variables.tf`, `locals.tf`, `outputs.tf`, `README.md`).
- **Formatting & Validation**:
  - Run `terraform fmt -recursive` and validate against configured linters (TFLint, Trivy, Checkov).
