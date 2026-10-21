# Databricks Customer-Managed Spoke VPC Module (`002.spoke_vpc`)

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-623CE4?logo=terraform)](https://developer.hashicorp.com/terraform/docs)
[![AWS Provider](https://img.shields.io/badge/AWS_Provider-6.66.0-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
[![Databricks](https://img.shields.io/badge/Databricks-Customer--Managed%20VPC-FF3621?logo=databricks)](https://docs.databricks.com/aws/en/administration-guide/cloud-configurations/aws/customer-managed-vpc)

---

## 1. Executive Summary

- **Purpose & Scope**:
  This module deploys a fully compliant **Databricks Customer-Managed Spoke VPC** on AWS. It provisions isolated private compute subnets for Databricks data plane clusters, dedicated subnets for AWS Transit Gateway (TGW) attachments, local AWS VPC endpoints (Amazon S3 Gateway, AWS STS Interface, Amazon Kinesis Interface), and self-referencing cluster security groups.
- **Problem Statement & Solution**:
  Databricks clusters require high-bandwidth communication between driver and worker nodes, secure outbound connectivity to the Databricks control plane, and fast access to cloud object storage without exposing worker nodes to the public internet. This module solves this by enforcing a strictly private subnet topology, keeping internal traffic on AWS private endpoints and routing external traffic through the Transit Gateway to a centralized inspection firewall.
- **Key Business & Security Outcomes**:
  - **No Public IP Addresses**: Compute instances are provisioned exclusively in private subnets with `map_public_ip_on_launch = false`.
  - **Direct S3 Gateway Routing**: High-throughput S3 traffic routes directly within the VPC without incurring NAT Gateway data processing fees.
  - **PrivateLink for Critical AWS Services**: STS and Kinesis Interface Endpoints isolate credential vending and telemetry from internet traversal.
  - **Compliant Intra-Cluster Security Group**: Implements self-referencing ingress/egress rules required for Spark inter-node networking alongside restricted egress ports for Databricks infrastructure, metastore, SCC relay, and extended internal services.

---

## 2. General Logic & Operational Flow

### 2.1 Configuration & Provisioning Lifecycle
1. **Base VPC Creation**: Calls the [`../001.generic_vpc`](file:///modules/01.networking/001.generic_vpc) module to provision the VPC container with DNS hostnames and DNS support enabled.
2. **Subnet Slicing**:
   - Provisions `aws_subnet.spoke_db_private_subnet` across the specified availability zones for Databricks compute nodes.
   - Provisions `aws_subnet.spoke_tgw_private_subnet` across availability zones for the AWS Transit Gateway VPC attachment.
3. **Route Table & Association**:
   Creates `aws_route_table.spoke_db_private_rt`, attaches private compute subnets to it, and sets it as the VPC's main route table.
4. **Security Group Configuration**:
   Provisions `aws_security_group.default_spoke_sg` in [`vpc_spoke_security_groups.tf`](file:///modules/01.networking/002.spoke_vpc/vpc_spoke_security_groups.tf) with self-referencing rules for intra-cluster protocols, plus outbound TCP egress across configured ports via `var.sg_egress_ports` (including HTTPS 443, MySQL 3306 for Hive Metastore, 6666 for Secure Cluster Connectivity, 2443 for Compliance Security Profile, and 8443–8451 for future extendability and extended services).
5. **VPC Endpoints Deployment**:
   Provisions VPC endpoints in [`vpc_spoke_endpoints.tf`](file:///modules/01.networking/002.spoke_vpc/vpc_spoke_endpoints.tf) via the `vpc-endpoints` submodule, deploying an S3 Gateway Endpoint attached to the compute route table, plus Interface Endpoints for STS and Kinesis attached to the compute subnets.

### 2.2 Network & Traffic Flow
- **Intra-Cluster Traffic**: Spark workers communicate directly with the driver across private subnets via the self-referencing security group.
- **S3 Data Access**: Routed directly to Amazon S3 via the Gateway VPC Endpoint prefix list in the private route table.
- **AWS API Traffic**: Authenticates via the local STS Interface Endpoint and sends streaming telemetry via Kinesis Interface Endpoints.
- **Egress / Control Plane Traffic**: Default route (`0.0.0.0/0`) directing into the AWS Transit Gateway is added downstream by the [`005.transit_gateway_spoke_hub`](file:///modules/01.networking/005.transit_gateway_spoke_hub) module, while private connectivity to the Databricks Control Plane is provisioned by [`003.spoke_privatelink`](file:///modules/01.networking/003.spoke_privatelink).

---

## 3. Architecture of the Module

### 3.1 Subnet Architecture

| Subnet Group | Configuration Variable | Public IP? | Primary Function |
|:---|:---:|:---:|:---|
| `spoke_db_private_subnet` | `spoke_db_private_subnets_cidr` | **No** | Reserved strictly for Databricks Spark clusters and workspace compute. |
| `spoke_tgw_private_subnet` | `spoke_tgw_private_subnets_cidr` | **No** | Reserved for AWS Transit Gateway ENIs connecting Spoke to Hub. |

### 3.2 Security Group Rules (`default_spoke_sg`)

| Direction | Protocol | Port Range | Source / Destination | Purpose |
|:---|:---:|:---|:---|\n| **Ingress** | All configured (`sg_ingress_protocols`) | All | `self = true` | Cluster inter-node communication (Spark Shuffle, RPC). |\n| **Egress** | All configured (`sg_egress_protocols`) | All | `self = true` | Cluster inter-node communication. |\n| **Egress** | TCP | `443` | `0.0.0.0/0` | HTTPS traffic to Databricks control plane, cloud data sources, and library repositories. |\n| **Egress** | TCP | `3306` | `0.0.0.0/0` | External Databricks / Hive Metastore database connections. |\n| **Egress** | TCP | `6666` | `0.0.0.0/0` | Secure Cluster Connectivity (SCC) relay / PrivateLink. |\n| **Egress** | TCP | `2443` | `0.0.0.0/0` | Databricks Compliance Security Profile (CSP) communication. |\n| **Egress** | TCP | `8443 - 8451` | `0.0.0.0/0` | Future extendability: Databricks internal services, extended metastore, and REST APIs. |

---

## 4. Architecture C4 Visualisation

### 4.1 Level 2: Container / Network Diagram

```mermaid
flowchart TD
    classDef vpc fill:#E3F2FD,stroke:#1565C0,stroke-width:2px,color:#0D47A1;
    classDef subnet fill:#FFFFFF,stroke:#42A5F5,stroke-width:1.5px,color:#1565C0;
    classDef endpoint fill:#FFF3E0,stroke:#E65100,stroke-width:1.5px,color:#BF360C;

    subgraph SpokeVPC ["Spoke VPC (Customer-Managed Databricks Network)"]
        subgraph ComputeSubnets ["Databricks Compute Subnet(s)"]
            Clusters["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/onprem/analytics/databricks.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Databricks Clusters</b><br/>(Private Compute Nodes)"]
            SG["Security Group (Self-referencing + Egress Ports 443, 3306, 6666, 2443, 8443-8451)"]
        end

        subgraph TGWSubnets ["Transit Gateway Attachment Subnet(s)"]
            TGWAttachment["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/transit-gateway.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>TGW ENIs</b><br/>(Subnet Attachment)"]
        end

        S3GW["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/storage/simple-storage-service-s3.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>S3 Gateway Endpoint</b>"]:::endpoint
        STSEP["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/endpoint.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>STS Interface Endpoint</b>"]:::endpoint
        KinesisEP["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/endpoint.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Kinesis Interface Endpoint</b>"]:::endpoint
    end
    class SpokeVPC vpc;
    class ComputeSubnets subnet;
    class TGWSubnets subnet;

    Clusters --> SG
    SG --> S3GW
    SG --> STSEP
    SG --> KinesisEP
    SG -->|"0.0.0.0/0 (via TGW)"| TGWAttachment
```

### 4.2 Level 3: Component Diagram (Terraform Resources)

```mermaid
graph TD
    classDef moduleNode fill:#ECEFF1,stroke:#455A64,stroke-width:1.5px,color:#263238;
    classDef resNode fill:#E1F5FE,stroke:#0288D1,stroke-width:1.5px,color:#01579B;

    SpokeRoot["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/vpc.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.spoke_vpc</b>"]:::moduleNode
    BaseVPC["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/vpc.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.spoke_vpc (../001.generic_vpc)</b>"]:::moduleNode
    SubnetCompute["aws_subnet.spoke_db_private_subnet[*]"]:::resNode
    SubnetTGW["aws_subnet.spoke_tgw_private_subnet[*]"]:::resNode
    RouteTable["aws_route_table.spoke_db_private_rt"]:::resNode
    SecGroup["aws_security_group.default_spoke_sg"]:::resNode
    VPCEndpoints["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/endpoint.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>module.vpc_endpoints</b><br/>(S3, STS, Kinesis)"]:::moduleNode

    SpokeRoot --> BaseVPC
    SpokeRoot --> SubnetCompute
    SpokeRoot --> SubnetTGW
    SpokeRoot --> RouteTable
    SpokeRoot --> SecGroup
    SpokeRoot --> VPCEndpoints

    BaseVPC -.->|"vpc_id"| SubnetCompute
    BaseVPC -.->|"vpc_id"| SubnetTGW
    BaseVPC -.->|"vpc_id"| RouteTable
    BaseVPC -.->|"vpc_id"| SecGroup
    RouteTable -.->|"Route Table ID"| VPCEndpoints
    SecGroup -.->|"Security Group ID"| VPCEndpoints
```

---

## 5. All Modules Used with Short Summaries

### 5.1 Submodules Invoked

| Module Name | Source Path | Version | Primary Responsibility |
|:---|:---|:---:|:---|
| `module.spoke_vpc` | [`../001.generic_vpc`](file:///modules/01.networking/001.generic_vpc) | Local | Creates the underlying Amazon VPC resource with DNS attributes enabled. |
| `module.vpc_endpoints` | `terraform-aws-modules/vpc/aws//modules/vpc-endpoints` | `3.11.0` | Creates AWS S3 Gateway endpoint and Interface endpoints for STS & Kinesis. |

---

## 6. Terraform Documentation Interface

> [!NOTE]
> Detailed inputs, outputs, provider requirements, and resource mappings are generated automatically by `terraform-docs` in [`TERRAFORM.md`](./TERRAFORM.md).

### 6.1 Essential Inputs Summary

| Variable | Type | Description | Required |
|:---|:---:|:---|:---:|
| `spoke_cidr_block` | `string` | CIDR block for the entire Spoke VPC | Yes |
| `spoke_db_private_subnets_cidr` | `list(string)` | CIDR blocks for Databricks compute private subnets | Yes |
| `spoke_tgw_private_subnets_cidr` | `list(string)` | CIDR blocks for Transit Gateway attachment subnets | Yes |
| `sg_egress_ports` | `list(number)` | List of TCP egress ports allowed for Databricks cluster outbound traffic (e.g. 443, 3306, 6666, 2443, 8443–8451) | Yes |
| `sg_egress_protocols` | `list(string)` | Protocols allowed for cluster self-referencing egress | Yes |
| `sg_ingress_protocols` | `list(string)` | Protocols allowed for cluster self-referencing ingress | Yes |
| `availability_zones` | `list(string)` | Target availability zones for subnet deployment | Yes |
| `env` | `string` | Environment name suffix (e.g. `dev`) | Yes |
| `name_prefix` | `string` | Name prefix for Spoke VPC (default: `"Spoke VPC"`) | No |

### 6.2 Essential Outputs Summary

| Output | Type | Description |
|:---|:---:|:---|
| `spoke_vpc_id` | `string` | ID of the created Databricks Spoke VPC |
| `spoke_tgw_subnet_ids` | `list(string)` | List of subnet IDs reserved for Transit Gateway attachment |
| `spoke_db_private_rt_id` | `string` | ID of the Databricks compute route table |

---

## 7. Important Links and Resources

### 7.1 Authoritative Documentation
- [Databricks Customer-Managed VPC Guide](https://docs.databricks.com/aws/en/administration-guide/cloud-configurations/aws/customer-managed-vpc) - Official Databricks specifications for VPCs and subnets.
- [Databricks Classic Private Connectivity & PrivateLink](https://docs.databricks.com/aws/en/security/network/classic/privatelink) - VPC endpoint configuration.
- [AWS VPC Endpoints User Guide](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html) - AWS documentation on Gateway and Interface endpoints.

### 7.2 Internal References
- [Terraform Contract (`TERRAFORM.md`)](./TERRAFORM.md)
- [Base VPC Primitive (`001.generic_vpc`)](file:///modules/01.networking/001.generic_vpc)
- [Spoke PrivateLink Module (`003.spoke_privatelink`)](file:///modules/01.networking/003.spoke_privatelink)
- [Authoritative README Template](file:///.ai/README_TEMPLATE.md)
