# Enterprise Databricks AWS Hub-and-Spoke VPC Networking

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-623CE4?logo=terraform)](https://developer.hashicorp.com/terraform/docs)
[![AWS Provider](https://img.shields.io/badge/AWS_Provider-6.66.0-FF9900?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
[![Databricks Provider](https://img.shields.io/badge/Databricks_Provider-Latest-FF3621?logo=databricks)](https://registry.terraform.io/providers/databricks/databricks/latest/docs)
[![Architecture](https://img.shields.io/badge/Architecture-Hub%20%26%20Spoke%20Firewall-blue)](https://github.com/databricks/terraform-provider-databricks/blob/main/docs/guides/aws-e2-firewall-hub-and-spoke.md)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions)](file:///.github/workflows/README.md)

---

## 1. Executive Summary

- **Purpose & Scope**:
  This repository provisions an enterprise-grade AWS network foundation for **Databricks E2 Workspaces** using a centralized **Hub-and-Spoke Firewall Architecture** and **Control Plane PrivateLink Connectivity**. It implements production-ready infrastructure-as-code (IaC) via modular Terraform, isolating Databricks compute resources within private customer-managed VPCs, establishing dedicated AWS PrivateLink endpoints for Databricks Control Plane communication, and routing all external outbound traffic through a centralized inspection Hub equipped with AWS Network Firewall and AWS Transit Gateway.
- **Problem Statement & Solution**:
  Enterprise data platforms require strict perimeter security, exfiltration prevention, and compliance with zero-trust networking standards. Deploying Databricks clusters with direct public Internet access creates data exfiltration risks and regulatory non-compliance. This solution resolves that challenge by eliminating public IPs on Databricks clusters, isolating Control Plane traffic (REST APIs and Secure Cluster Connectivity relay) over AWS PrivateLink, and enforcing centralized, stateful FQDN/domain inspection on all outbound egress traffic via AWS Network Firewall and AWS Transit Gateway.
- **Key Business & Security Outcomes**:
  - **Zero Direct Internet Exposure**: Databricks worker nodes reside exclusively in private subnets with no public IPs or internet gateways.
  - **Private Control Plane Connectivity (AWS PrivateLink)**: Dedicated PrivateLink subnets, an isolated local route table, a CIDR-scoped security group, and Interface VPC Endpoints (`workspace` REST API and `scc` relay) keep compute-to-control-plane traffic entirely on the AWS private network.
  - **Centralized Egress & Exfiltration Control**: Outbound traffic is inspected by stateful AWS Network Firewall rules restricting egress to verified Databricks control plane URLs, deployed workspace URLs, authorized package repositories, and storage buckets.
  - **Comprehensive Databricks Port Hardening**: Compute cluster and PrivateLink security groups permit TCP traffic only across authorized Databricks ports (443, 3306, 6666, 2443, and 8443–8451) for data sources, metastores, PrivateLink SCC relay, compliance profiles, and extended internal services.
  - **Dual S3 FQDN Allowlisting**: Network Firewall stateful rules dynamically allow both generic (`<bucket>.s3.amazonaws.com`) and regional (`<bucket>.s3.<region>.amazonaws.com`) FQDNs for all configured root and Unity Catalog storage buckets.
  - **Complete Data Encryption**: Customer-managed KMS keys (CMKs) enforce envelope encryption at rest across Terraform state, storage buckets, and firewall logs.
  - **Scalable Multi-VPC Interconnect**: AWS Transit Gateway (TGW) serves as a cloud router, enabling multi-account and multi-workspace scalability.
  - **Automated Quality & Compliance**: Enforced pre-commit hooks featuring `tflint`, `trivy`, `checkov`, `gitleaks`, and `terraform-docs` integrated into multi-stage GitHub Actions CI/CD pipelines.

---

## 2. General Logic & Operational Flow

### 2.1 Project Lifecycle & Execution Workflow
1. **Security & State Backend Initialization**:
   The KMS key module ([`001.kms_key`](file:///modules/02.security/001.kms_key)) provisions a dedicated CMK. The backend storage module ([`001.env_backend_bucket`](file:///modules/03.storage/001.env_backend_bucket)) provisions an S3 state bucket encrypted with this CMK, featuring automated 90-day non-current version lifecycle expiration.
2. **Foundational VPC Containers**:
   Both Spoke and Hub network modules instantiate the base VPC primitive ([`001.generic_vpc`](file:///modules/01.networking/001.generic_vpc)) to establish isolated VPC containers with DNS hostnames and DNS support explicitly enabled.
3. **Spoke VPC Provisioning**:
   The Spoke VPC module ([`002.spoke_vpc`](file:///modules/01.networking/002.spoke_vpc)) allocates private compute subnets for Databricks clusters, TGW attachment subnets, self-referencing cluster security groups with configured egress ports (`sg_egress_ports`), and local VPC endpoints (Gateway S3, Interface STS, Interface Kinesis).
4. **Spoke Control Plane PrivateLink Provisioning**:
   The Spoke PrivateLink module ([`003.spoke_privatelink`](file:///modules/01.networking/003.spoke_privatelink)) provisions dedicated PrivateLink VPC endpoint subnets, an isolated local route table, a dedicated security group using `sg_egress_ports`, and the two regional AWS Interface VPC Endpoints for Databricks Workspace (REST API) and Secure Cluster Connectivity (SCC) relay.
5. **Hub VPC Provisioning**:
   The Hub VPC module ([`004.hub_vpc`](file:///modules/01.networking/004.hub_vpc)) deploys the public NAT Gateways, Internet Gateway (IGW), TGW attachment subnets, firewall subnets, and routing tables.
6. **Transit Gateway Interconnect**:
   The Transit Gateway module ([`005.transit_gateway_spoke_hub`](file:///modules/01.networking/005.transit_gateway_spoke_hub)) attaches both the Spoke and Hub VPCs to the central AWS Transit Gateway, configuring symmetric routing between VPCs.
7. **Firewall Inspection & Egress Routing**:
   The Network Firewall module ([`006.hub_networking_firewall`](file:///modules/01.networking/006.hub_networking_firewall)) provisions the AWS Network Firewall into the Hub VPC firewall subnets, wires endpoint route tables, and enforces stateful domain allowlists (supporting generic and regional S3 FQDNs).

### 2.2 End-to-End Traffic Flow
- **Databricks Control Plane Communication (In-VPC PrivateLink)**:
  Databricks compute node $\rightarrow$ Spoke VPC local route $\rightarrow$ PrivateLink security group (`spoke_pl_vpce_sg`) $\rightarrow$ Dedicated PrivateLink VPC Endpoints (`backend_rest` and `relay`) $\rightarrow$ AWS PrivateLink backbone $\rightarrow$ Databricks Control Plane.
- **Outbound Databricks Cluster Egress**:
  Databricks compute node $\rightarrow$ Spoke private subnet route table $\rightarrow$ AWS Transit Gateway $\rightarrow$ Hub TGW subnet $\rightarrow$ Hub NAT Gateway $\rightarrow$ AWS Network Firewall endpoint $\rightarrow$ Internet Gateway $\rightarrow$ Public Internet / SaaS.
- **AWS Service Traffic (In-VPC Optimization)**:
  Databricks compute nodes access Amazon S3 directly via the Gateway VPC Endpoint without leaving the Spoke VPC. STS and Kinesis traffic is routed through local Interface VPC Endpoints.

### 2.3 Automated CI/CD & Delivery Model
All changes undergo automated validation and delivery managed via GitHub Actions:
- **Quality & Security Scanning**: [`dpl-01-precommit.yml`](file:///.github/workflows/dpl-01-precommit.yml) runs static linting (`tflint`), vulnerability scanning (`trivy`), infrastructure-as-code analysis (`checkov`), and secret detection (`gitleaks`).
- **Deterministic Planning**: [`dpl-02-plan.yml`](file:///.github/workflows/dpl-02-plan.yml) validates configurations, generates speculative execution plans, and caches immutable plan artifacts (`tfplan`).
- **Gated Delivery**: [`dpl-03-apply.yml`](file:///.github/workflows/dpl-03-apply.yml) executes applies against target environments under manual review protection gates.\
- For detailed pipeline architecture, see the [GitHub Actions Documentation](file:///.github/workflows/README.md).

---

## 3. Architecture of the Project

### 3.1 Network Topology & CIDR Allocation

| Network Tier / VPC | Subnet Classification | Purpose | Route Target |
|:---|:---|:---|:---|
| **Hub VPC (`10.10.0.0/16`)** | `hub-nat-public` | Egress NAT Gateways & Bastion | Internet Gateway (`hub-igw`) |
| **Hub VPC (`10.10.0.0/16`)** | `hub-firewall-subnet` | AWS Network Firewall Endpoints | Egress Inspection Pipeline |
| **Hub VPC (`10.10.0.0/16`)** | `hub-tgw-private` | Transit Gateway Hub Attachment | NAT Gateway & TGW Router |
| **Spoke VPC (`10.173.0.0/16`)** | `spoke-db-private` | Databricks Spark Workers / Compute | Transit Gateway (`tgw`) & S3 VPCE |
| **Spoke VPC (`10.173.0.0/16`)** | `spoke-tgw-private` | Transit Gateway Spoke Attachment | Transit Gateway (`tgw`) |
| **Spoke VPC (`10.173.0.0/16`)** | `spoke-pl-vpce` | Databricks Control Plane PrivateLink Endpoints | Isolated Local VPC Route (`spoke-pl-vpce-rt`) |

### 3.2 Security Posture & Boundary Controls
- **KMS Key Management**: Customer-managed KMS key with automatic rotation, deletion protection, and root/caller identity delegation.
- **Security Groups**:
  - Default Databricks cluster security group (`default_spoke_sg`) enforcing self-referencing ingress/egress for intra-cluster communication and restricted TCP egress across required Databricks ports: 443 (HTTPS), 3306 (MySQL metastore), 6666 (Secure Cluster Connectivity PrivateLink relay), 2443 (Compliance Security Profile), and 8443–8451 (extended metastore and internal compute services).
  - Dedicated PrivateLink endpoint security group (`spoke_pl_vpce_sg`) enforcing bidirectional TCP access on `sg_egress_ports` restricted strictly to the compute private subnet CIDRs and PrivateLink endpoint subnet CIDRs.
- **Network Firewall Policy**: Stateful inspection rule groups with domain allowlists for Databricks infrastructure, metastores, external packages, and S3 storage. Dynamically generates both generic (`<bucket>.s3.amazonaws.com`) and regional (`<bucket>.s3.<region>.amazonaws.com`) FQDN allowlist entries from configured root and Unity Catalog bucket names. Provide the required bucket names in deployment configuration; do not put bucket-name values in this README.

---

## 4. Architecture C4 Visualisation

### 4.1 Level 1: System Context Diagram
Shows how the Databricks environment interacts with users, the Databricks Control Plane, AWS native services, and external endpoints.

```mermaid
flowchart TD
    classDef actor fill:#232F3E,stroke:#FF9900,stroke-width:2px,color:#FFFFFF;
    classDef system fill:#1E88E5,stroke:#0D47A1,stroke-width:2px,color:#FFFFFF;
    classDef external fill:#546E7A,stroke:#263238,stroke-width:2px,color:#FFFFFF;

    User["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/general/users.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Data Engineers & Analysts</b><br/>(Databricks Users)"]:::actor
    DatabricksCP["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/onprem/analytics/databricks.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Databricks Control Plane</b><br/>(E2 SaaS)"]:::external
    AWSServices["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/general/general.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>AWS Managed Services</b><br/>(S3, STS, Kinesis, KMS)"]:::external
    PublicInternet["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/general/internet-alt1.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Public Repositories & Internet</b><br/>(PyPI, CRAN)"]:::external

    subgraph AWSCloud ["AWS Enterprise Cloud Environment"]
        VPCNetworkRoot["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/vpc.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Databricks Hub & Spoke Foundation</b>"]:::system
    end

    User -->|"Manage Notebooks & Jobs (HTTPS/443)"| DatabricksCP
    DatabricksCP <-->|"AWS PrivateLink (REST API & SCC Relay)"| VPCNetworkRoot
    VPCNetworkRoot -->|"Direct Gateway / Interface Endpoints"| AWSServices
    VPCNetworkRoot -->|"Stateful Inspected Egress (SNI Filtered)"| PublicInternet
```

### 4.2 Level 2: Container / Network Infrastructure Diagram
Illustrates the network topology spanning the Hub VPC, Spoke VPC, PrivateLink endpoints, Transit Gateway, and AWS Network Firewall.

```mermaid
flowchart LR
    classDef hubVpc fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px,color:#1B5E20;
    classDef spokeVpc fill:#E3F2FD,stroke:#1565C0,stroke-width:2px,color:#0D47A1;
    classDef security fill:#FFF3E0,stroke:#E65100,stroke-width:2px,color:#BF360C;
    classDef transit fill:#EDE7F6,stroke:#512DA8,stroke-width:2px,color:#311B92;

    subgraph HubVPC ["Hub VPC (Central Inspection & Egress)"]
        IGW["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/internet-gateway.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Internet Gateway</b><br/>(hub-igw)"]
        NAT["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/nat-gateway.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>NAT Gateway</b><br/>(hub-nat)"]
        NFW["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/shield.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>AWS Network Firewall</b><br/>(Stateful Rules)"]:::security
        HubTGWSubnet["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/endpoint.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Hub TGW Subnets</b>"]
    end
    class HubVPC hubVpc;

    TGW["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/transit-gateway.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>AWS Transit Gateway</b><br/>(tgw-spoke-hub)"]:::transit

    subgraph SpokeVPC ["Spoke VPC (Customer-Managed Databricks Compute)"]
        SpokeTGWSubnet["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/endpoint.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Spoke TGW Subnets</b>"]
        ComputeSubnets["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/vpc.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Compute Subnets</b>"]
        PLSubnets["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/privatelink.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>PrivateLink Subnets</b><br/>(Workspace & SCC Relay VPCEs)"]:::security
        S3VPCE["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/storage/simple-storage-service-s3.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>S3 Gateway Endpoint</b>"]
        STSKinesisVPCE["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/endpoint.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>STS & Kinesis VPCEs</b>"]
        SparkNodes["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/onprem/analytics/databricks.png' width='36' height='36' style='width:36px;height:36px;max-width:36px;max-height:36px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Databricks Clusters</b>"]
    end
    class SpokeVPC spokeVpc;

    SparkNodes --> ComputeSubnets
    ComputeSubnets --> S3VPCE
    ComputeSubnets --> STSKinesisVPCE
    ComputeSubnets -->|"Local Route (PrivateLink)"| PLSubnets
    ComputeSubnets -->|"Default Egress 0.0.0.0/0"| SpokeTGWSubnet
    SpokeTGWSubnet -->|"VPC Attachment"| TGW
    TGW -->|"VPC Attachment"| HubTGWSubnet
    HubTGWSubnet --> NAT
    NAT --> NFW
    NFW --> IGW
    IGW -->|"Inspected Egress"| Internet["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/general/internet-alt1.png' width='32' height='32' style='width:32px;height:32px;max-width:32px;max-height:32px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>Public Internet</b>"]
```

### 4.3 Level 3: Component Diagram (Terraform Architecture)
Depicts the modular orchestration of Terraform components across environments and modules.

```mermaid
graph TD
    classDef env fill:#E0F7FA,stroke:#00838F,stroke-width:2px,color:#004D40;
    classDef modNet fill:#EDE7F6,stroke:#4527A0,stroke-width:1.5px,color:#311B92;
    classDef modSec fill:#FFF8E1,stroke:#F57F17,stroke-width:1.5px,color:#E65100;
    classDef modStor fill:#E8F5E9,stroke:#2E7D32,stroke-width:1.5px,color:#1B5E20;

    DevEnv["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/general/general.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>environments/dev</b><br/>(Root Orchestrator)"]:::env

    ModKMS["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/key-management-service.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>02.security/001.kms_key</b>"]:::modSec
    ModBackend["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/storage/simple-storage-service-s3.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>03.storage/001.env_backend_bucket</b>"]:::modStor
    ModBaseVPC["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/vpc.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>01.networking/001.generic_vpc</b>"]:::modNet
    ModSpokeVPC["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/vpc.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>01.networking/002.spoke_vpc</b>"]:::modNet
    ModSpokePL["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/privatelink.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>01.networking/003.spoke_privatelink</b>"]:::modNet
    ModHubVPC["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/vpc.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>01.networking/004.hub_vpc</b>"]:::modNet
    ModTGW["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/network/transit-gateway.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>01.networking/005.transit_gateway_spoke_hub</b>"]:::modNet
    ModNFW["<img src='https://raw.githubusercontent.com/mingrammer/diagrams/master/resources/aws/security/shield.png' width='28' height='28' style='width:28px;height:28px;max-width:28px;max-height:28px;display:block;margin:0 auto;object-fit:contain;' /><br/><b>01.networking/006.hub_networking_firewall</b>"]:::modNet

    DevEnv --> ModKMS
    DevEnv --> ModBackend
    DevEnv --> ModSpokeVPC
    DevEnv --> ModSpokePL
    DevEnv --> ModHubVPC
    DevEnv --> ModTGW
    DevEnv --> ModNFW

    ModSpokeVPC --> ModBaseVPC
    ModHubVPC --> ModBaseVPC

    ModKMS -.->|"KMS Key ARN"| ModBackend
    ModSpokeVPC -.->|"Spoke VPC ID"| ModSpokePL
    ModHubVPC -.->|"Hub VPC & Subnet IDs"| ModTGW
    ModSpokeVPC -.->|"Spoke VPC & Subnet IDs"| ModTGW
    ModHubVPC -.->|"Hub Route Table & Subnets"| ModNFW
```

---

## 5. All Modules Used with Short Summaries

The repository is structured into isolated, reusable Terraform modules under `modules/` and orchestrated environments under `environments/`.

### 5.1 Repository Module Inventory

| Module Path | Module Name | Primary Role & Responsibilities |
|:---|:---|:---|
| [`modules/01.networking/001.generic_vpc`](file:///modules/01.networking/001.generic_vpc) | `001.generic_vpc` | Base primitive provisioning an AWS VPC with DNS hostnames and DNS support enabled. |
| [`modules/01.networking/002.spoke_vpc`](file:///modules/01.networking/002.spoke_vpc) | `002.spoke_vpc` | Databricks customer-managed VPC with private compute subnets, cluster security groups, and VPC endpoints. |
| [`modules/01.networking/003.spoke_privatelink`](file:///modules/01.networking/003.spoke_privatelink) | `003.spoke_privatelink` | Dedicated PrivateLink subnets, isolated local route table, security group (`sg_egress_ports`), and AWS Interface VPC Endpoints for Databricks Control Plane (Workspace REST API and SCC relay). |
| [`modules/01.networking/004.hub_vpc`](file:///modules/01.networking/004.hub_vpc) | `004.hub_vpc` | Centralized Hub VPC with NAT Gateways, Internet Gateway, firewall subnets, and routing tables. |
| [`modules/01.networking/005.transit_gateway_spoke_hub`](file:///modules/01.networking/005.transit_gateway_spoke_hub) | `005.transit_gateway_spoke_hub` | AWS Transit Gateway interconnect managing VPC attachments, route tables, and cross-VPC propagation. |
| [`modules/01.networking/006.hub_networking_firewall`](file:///modules/01.networking/006.hub_networking_firewall) | `006.hub_networking_firewall` | AWS Network Firewall deploying stateful rule groups, FQDN domain allowlists (supporting generic and regional S3 FQDNs), and symmetric inspection routing. |
| [`modules/02.security/001.kms_key`](file:///modules/02.security/001.kms_key) | `001.kms_key` | Customer Managed Key (CMK) provisioning with deletion protection, automated rotation, and key policy management. |
| [`modules/03.storage/001.env_backend_bucket`](file:///modules/03.storage/001.env_backend_bucket) | `001.env_backend_bucket` | Hardened S3 state storage with SSE-KMS encryption, versioning, ownership controls, 90-day lifecycle expiration, and public access blocks. |

---

## 6. Directory Structure & Environments

```text
├── .ai/                                  # AI guidelines, governance, and templates
│   ├── README.md                         # Overview and governance guide for the .ai directory
│   ├── instructions.md                   # Authoritative system instructions & sources of truth
│   ├── README_TEMPLATE.md                # Mandatory template for all README.md files
│   └── mcp/                              # Model Context Protocol configurations
│       └── mcp.json                      # MCP server definitions (aws-docs, terraform)
├── .github/                              # CI/CD deployment pipelines & automation workflows
│   ├── copilot-instructions.md           # Authoritative AI & GitHub Copilot instructions
│   └── workflows/                        # GitHub Actions workflow definitions
│       ├── README.md                     # Comprehensive CI/CD architecture & documentation
│       ├── deploy-dev.yml                # Dev environment pipeline orchestrator
│       ├── dpl-01-precommit.yml          # Reusable pre-commit & security scans
│       ├── dpl-02-plan.yml               # Reusable Terraform plan & artifact cache
│       └── dpl-03-apply.yml              # Reusable gated Terraform apply
├── environments/                         # Deployment environment orchestration
│   └── dev/                              # Development environment configuration
│       ├── main.tf                       # Module orchestration entrypoint
│       ├── variables.tf                  # Environment input variables
│       ├── locals.tf                     # Calculated CIDRs, tags, allowlists
│       ├── providers.tf                  # AWS provider configurations
│       ├── backend.tf                    # Remote S3 state backend config
│       ├── README.md                     # Comprehensive environment documentation
│       └── TERRAFORM.md                  # Auto-generated terraform-docs contract
├── modules/                              # Reusable Terraform modules
│   ├── 01.networking/                    # Networking modules (VPC, TGW, Firewall, PrivateLink)
│   │   ├── 001.generic_vpc/              # Base VPC container primitive
│   │   ├── 002.spoke_vpc/                # Customer-managed Databricks compute VPC
│   │   ├── 003.spoke_privatelink/        # Databricks Control Plane PrivateLink endpoints & subnets
│   │   ├── 004.hub_vpc/                  # Centralized inspection and egress Hub VPC
│   │   ├── 005.transit_gateway_spoke_hub/# Transit Gateway interconnect & routing
│   │   └── 006.hub_networking_firewall/  # AWS Network Firewall & domain filtering
│   ├── 02.security/                      # Security and encryption modules
│   │   └── 001.kms_key/                  # Customer Managed Key (CMK) & policies
│   └── 03.storage/                       # Storage modules
│       └── 001.env_backend_bucket/       # Hardened S3 state storage bucket
├── .pre-commit-config.yaml               # Quality, security, and linting hooks
├── .tflint.hcl                           # TFLint configuration
├── .trivyignore                          # Trivy scanner exclusions
└── pyproject.toml                        # Python environment & tooling definitions
```

---

## 7. Terraform Documentation Interface

> [!NOTE]
> Detailed interface contracts for each module and environment are generated automatically by `terraform-docs` via pre-commit hooks and saved in dedicated `TERRAFORM.md` files:
> - Environment contract: [`environments/dev/TERRAFORM.md`](file:///environments/dev/TERRAFORM.md)
> - Module contracts: [`modules/**/TERRAFORM.md`](file:///modules)

---

## 8. Important Links and Resources

### 8.1 Authoritative Databricks Documentation
- [Databricks AWS E2 Firewall Hub and Spoke Guide](https://github.com/databricks/terraform-provider-databricks/blob/main/docs/guides/aws-e2-firewall-hub-and-spoke.md) - Official Databricks reference guide for central firewall architectures.
- [Databricks AWS PrivateLink Workspace Guide](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-private-link-workspace) - Imperative guide for creating AWS and Databricks resources required for Control Plane private connectivity.
- [Databricks Classic Private Connectivity & PrivateLink](https://docs.databricks.com/aws/en/security/network/classic/privatelink) - Imperative documentation for Control Plane PrivateLink VPC endpoint architecture and security.
- [Databricks on AWS Official Documentation](https://docs.databricks.com/aws/en/) - Core portal for Databricks cloud infrastructure.
- [Databricks Customer-Managed VPC Guide](https://docs.databricks.com/aws/en/administration-guide/cloud-configurations/aws/customer-managed-vpc) - Network and subnet specifications for Databricks compute planes.
- [Databricks Terraform Provider Documentation](https://registry.terraform.io/providers/databricks/databricks/latest/docs) - Databricks Terraform registry documentation.

### 8.2 Authoritative AWS Documentation
- [AWS Official Documentation](https://docs.aws.amazon.com/) - AWS documentation portal.
- [AWS Network Firewall Developer Guide](https://docs.aws.amazon.com/network-firewall/latest/developerguide/what-is-aws-network-firewall.html) - Technical guide for AWS Network Firewall.
- [AWS Transit Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/tgw/what-is-transit-gateway.html) - AWS Transit Gateway user guide.
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/) - Architectural best practices for cloud workloads.

### 8.3 Project Documentation References
- [AI Governance & Knowledge Framework](file:///.ai/README.md)
- [Project Guidelines & Source of Truth](file:///.ai/instructions.md)
- [GitHub Copilot Custom Instructions](file:///.github/copilot-instructions.md)
- [Authoritative README Template](file:///.ai/README_TEMPLATE.md)
- [GitHub Actions Workflows Documentation](file:///.github/workflows/README.md)
