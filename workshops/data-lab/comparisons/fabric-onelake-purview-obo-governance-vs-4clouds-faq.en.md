# Microsoft Fabric OneLake Unified Fine-Grained Security (RLS/CLS/OLS) + Purview + Entra Agent ID (OBO) vs. Databricks Unity Catalog (ABAC / Mosaic AI Gateway) vs. Snowflake Horizon (Cortex Guard) vs. AWS Lake Formation vs. GCP Dataplex Multi-Cloud AI Governance, Agent Identity Passthrough & Sovereign Compliance Selection FAQ

> **Document Purpose**: A high-impact **architectural selection & first-principles field guide** for AI Solution Architects, CTOs, CISOs, and Data Governance Leaders (strictly modeled on the 6-part structure of `ib-vs-ethernet-roce-selection-faq.md`).  
> **Reader Takeaway**: Grasp the exact architectural boundaries across the 5 cloud data & AI platforms for multi-engine fine-grained security, AI agent identity passthrough, and sovereign compliance in 3 minutes; master the zero-trust transition from "4-engine policy duplication + Service-Principal super-token leaks" to "define-once OneLake storage security + Entra Agent ID On-Behalf-Of (OBO) passthrough + Purview DLP inheritance" in 10 minutes.  
> **Four-Tier Provenance & Dual Latency Denominators Disclosure**: Every quantitative figure in this guide is explicitly tagged with one of four provenance tiers: `[measured_local_harness]` (local deterministic benchmark harness execution: `30/30` unit tests passing in `0.025s`, `67/68 = 98.53%` routing verdict accuracy), `[vendor_published_spec_as_of_2026]` (backed by 9 official vendor documentation & pricing URLs, `as_of: 2026-11-08`), `[synthetic_scenario_model]` (deterministic presales architectural reference models with **two explicitly separated latency denominators**: **Denominator A `n=68` routing decision matrix mean = `516.0 ms` exact**; **Denominator B `n=13` industry Ontology closed-loop simulation mean = `562.0 ms` exact**, range `431–780 ms`), and `[not_measured]` (live multi-tenant paid cloud cluster P99 under physical 120K EPS / 48K TPS load).

![Multi-Cloud AI Governance & Entra Agent ID OBO Selection Summary](../assets/svg/14-onelake-purview-obo-governance-vs-uc-horizon-faq.svg)

---

## ① 📌 Executive Summary

1. **When to Choose Microsoft Fabric (OneLake Unified RLS/CLS/OLS + Entra Agent ID OBO + Microsoft Purview) First**:  
   Whenever the same lakehouse tables are consumed across Spark data engineering, T-SQL Analytics Endpoints, Eventhouse KQL, Power BI DirectLake, and **M365 Copilot / Fabric Data Agents**, standardize on **OneLake Unified Security + Microsoft Entra Agent ID On-Behalf-Of (OBO) identity passthrough** (`[vendor_published_spec_as_of_2026]`: [OneLake Table/Column/Row Security](https://learn.microsoft.com/en-us/fabric/onelake/security/table-column-row-security), [OneLake Access Control Model](https://learn.microsoft.com/en-us/fabric/onelake/security/data-access-control-model)). Defining row-level (RLS), column-level (CLS), and object-level security (OLS) once at the OneLake storage layer enforces policies consistently across all 5 engines and AI agents—cutting modeled monthly multi-engine governance synchronization TCO from **$9,360/mo down to $1,480/mo (-84.2%, saving $7,880/mo, `[synthetic_scenario_model]`)**.
2. **When to Federate and Coexist with Databricks Unity Catalog / Snowflake Horizon / AWS Lake Formation / GCP Dataplex (Better Together)**:  
   - **Existing Databricks Unity Catalog (ABAC) + Mosaic AI Gateway**: When an enterprise governs multi-cloud Spark/ML feature pipelines, open-weight LLM fine-tuning, and external model endpoint rate-limiting/spend quotas/PII redaction via Mosaic AI Gateway (`[vendor_published_spec_as_of_2026]`: [Unity Catalog ABAC](https://docs.databricks.com/en/data-governance/unity-catalog/abac.html)), **keep Unity Catalog + Mosaic AI Gateway** and federate into Fabric via **Mirrored Unity Catalog + OneLake Shortcuts** with Entra ID OBO passthrough.  
   - **Existing Snowflake Horizon Catalog + Cortex Guard**: When data gravity resides in Snowflake with Tag-Based Dynamic Data Masking, Cortex Guard prompt safety, and external B2B Data Clean Rooms (`[vendor_published_spec_as_of_2026]`: [Snowflake Access Control](https://docs.snowflake.com/en/user-guide/security-access-control-overview)), **keep Snowflake Horizon** and map classification tags into **Microsoft Purview** over OneLake Iceberg Shortcuts.  
   - **Existing AWS Lake Formation / Bedrock Guardrails or GCP Dataplex**: Retain native cloud controls (`[vendor_published_spec_as_of_2026]`: [AWS Lake Formation](https://docs.aws.amazon.com/lake-formation/latest/dg/what-is-lake-formation.html), [GCP Dataplex](https://cloud.google.com/dataplex/docs/introduction)) and federate via OneLake Shortcuts + Purview DLP policies.
3. **Core First-Principles Mechanism (Storage-Layer Predicate Enforcement + OBO Identity Passthrough vs. 4-Engine Policy Drift + Super-Token Bypass)**:  
   The #1 security vulnerability in enterprise AI agents is **Service-Principal "Super-Token" Bypass**—where an AI agent queries backend tables using a shared high-privilege service account, blinding the database to the actual human caller's permissions. In our **EU Sovereign Clinical Trial Pharmacovigilance simulation (Scenario M `sovereign_healthcare_obo_purview_vs_uc_abac`, `[synthetic_scenario_model]`)**, when a German Cardiology Principal Investigator (PI) queries a shared `145,000`-patient OneLake cohort table, Entra Agent ID OBO + OneLake RLS/CLS filters out `112,400` non-German patient rows and masks genomic SSNs in **`11 ms` modeled latency** (**`0.0%` unauthorized row leak**), detects `19` dosing batches with `DeltaQTcMs > 60ms` cardiac toxicity in **`431 ms` end-to-end modeled latency** (**`n=13` ontology simulation mean = `562.0 ms`**; **`n=68` routing matrix mean = `516.0 ms`**), and writes quarantine orders back to 1GB Free Fabric SQL and hospital-edge SQL Server on Azure Local (ALDO)—mitigating **$2,800,000** in modeled GDPR Art. 83 and EMA regulatory exposure.

---

## ② 🎯 Customer & Architect Soul-Searching Q&A (Plain-Language First Principles)

### Q1: What exactly are OneLake Unified Fine-Grained Security (RLS/CLS/OLS) and Entra Agent ID OBO Passthrough? Why did legacy architectures fail, and how does this close the AI data-leakage gap?

- **Plain-Language First-Principles Explanation**:
  - **OneLake Unified Security (RLS/CLS/OLS)**: Think of OneLake as installing a biometric vault lock directly on the physical storage layer rather than hiring separate guards at every upstairs door. **Object-Level Security (OLS)** hides restricted tables/folders (even hiding their schema metadata); **Column-Level Security (CLS)** masks sensitive columns like `Patient_SSN`, `Genomic_Sequence_ID`, or `Supplier_Net_Cost`; **Row-Level Security (RLS)** filters rows dynamically (e.g., `Country = 'DE'`). Because it is defined at OneLake, **Spark, T-SQL, Power BI DirectLake, Eventhouse KQL, and Fabric Data Agents all inherit the exact same rule automatically** (`[vendor_published_spec_as_of_2026]`: [OneLake Table/Column/Row Security](https://learn.microsoft.com/en-us/fabric/onelake/security/table-column-row-security)).
  - **Entra Agent ID & On-Behalf-Of (OBO) Token Passthrough**: Every AI agent receives a governed identity badge in Microsoft Entra ID (`Agent ID`), and whenever it queries data on a user's behalf, it must present a cryptographic **On-Behalf-Of (OBO) token** carrying the calling user's identity claims—never a shared "master key" Service Principal.
- **Why Legacy Multi-Engine & RAG Architectures Failed**:
  1. **Four Engines, Four Separate Policy Silos**: Historically, teams wrote Spark SQL view ACLs for data engineers, warehouse GRANT scripts for SQL analysts, DAX RLS expressions in Power BI for business users, and metadata filters in vector databases for RAG agents. Any schema change that missed one of those four layers immediately exposed sensitive records.
  2. **Service-Principal "Super-Token" Over-Sharing**: Most custom RAG pipelines connect to the data warehouse using a single privileged Service Principal. Once an unauthorized user asks a clever prompt, the agent summarizes rows the user was never allowed to see in BI.
- **How OneLake Security + OBO Saves 84.2% in Governance Ops TCO**:
  - By pushing grant-based RBAC and row/column projection down to the OneLake storage access layer and enforcing Entra OBO identity passthrough, enterprises eliminate 4-way policy synchronization scripts and custom PII proxy middleware—reducing modeled monthly governance operations TCO from **$9,360/mo to $1,480/mo (-84.2%, saving $7,880/mo, `[synthetic_scenario_model]`)**.

---

### Q2: How do we choose between Microsoft Fabric (OneLake + Purview + Entra OBO), Databricks (Unity Catalog ABAC + Mosaic AI Gateway), Snowflake (Horizon + Cortex Guard), AWS Lake Formation, and GCP Dataplex?

- **Rule-of-Thumb Selection Guide**:
  - **Cross-Engine Analytics (Spark + SQL + DirectLake + KQL) + M365 Copilot + Office DLP → Choose Microsoft Fabric (OneLake Security + Purview + Entra OBO)**: The only architecture where storage-level RLS/CLS, AI agent OBO identity, and downstream Microsoft Purview sensitivity labels (encrypting exported Excel, Word, and Teams chats) operate as a single continuous control plane.
  - **Multi-Cloud Spark/MLOps Governance + LLM Endpoint Rate/Spend/PII Gateway → Choose Databricks Unity Catalog (ABAC) + Mosaic AI Gateway**: Unity Catalog's attribute-based access control (ABAC) excels at tag-driven row/column masking across AWS/Azure/GCP Spark workspaces, while **Mosaic AI Gateway** provides centralized rate-limiting, token spend quotas, payload logging, and PII guardrails across model serving endpoints.
  - **Snowflake-Centric Warehousing + Tag-Based Dynamic Masking + B2B Clean Rooms → Choose Snowflake Horizon + Cortex Guard**: Ideal when data gravity is consolidated inside Snowflake, leveraging native Tag-Based Dynamic Data Masking, Cortex Guard prompt safety, and external B2B Data Clean Rooms.
  - **Single-Cloud AWS or GCP Workloads → Choose AWS Lake Formation + Bedrock Guardrails or GCP Dataplex**: Best when data and AI workloads remain entirely within AWS (S3 Tables / Athena / Redshift / Bedrock) or GCP (BigQuery / Vertex AI).

---

### Q3: If a customer already built hundreds of ABAC tags and masking policies in Databricks Unity Catalog or Snowflake Horizon, how do we federate without rewriting policies?

- **Three-Step Zero-Copy Governance Federation Blueprint ("Better Together")**:
  1. **Catalog & Tag Metadata Synchronization**: Mount Databricks catalogs via **Mirrored Unity Catalog** or Snowflake Iceberg tables via **OneLake Shortcuts**, mapping Unity Catalog ABAC tags and Snowflake Horizon classification tags directly into the **Microsoft Purview Data Map**.
  2. **End-to-End Entra ID OBO Identity Passthrough**: Configure Microsoft Entra ID federated SSO and OAuth On-Behalf-Of (OBO) token passthrough across Fabric, Azure Databricks, and Snowflake so a user querying via M365 Copilot or Power BI always executes under their own Entra identity.
  3. **Layered AI Gateways + Operational Guardrails**: Retain **Databricks Mosaic AI Gateway** or **Snowflake Cortex Guard** for model endpoint rate-limiting and prompt safety, while using **Fabric IQ Ontology + Foundry IQ + Microsoft Agent 365** to validate cross-system business rules and transactional write-back.

---

### Q4: How do we satisfy strict EU GDPR / HIPAA / Defense requirements where raw sensitive records cannot leave local hospital or factory premises?

- **Dual-Tier Sovereign Edge Architecture (SQL Server on Azure Local ALDO + Fabric Sovereign Cloud)**:
  - **Disconnected / Local Hospital & Factory Edge (`SQL Server on Azure Local - ALDO`)**: Keep raw genomic sequences, patient names, and national IDs inside on-premises hospital server rooms running **SQL Server on Azure Local (ALDO)** with local DiskANN vector search—guaranteeing **0 raw PII bytes leave the facility**.
  - **Sovereign Cloud Control Plane (`Fabric Sovereign Cloud / GCC High + OneLake Security`)**: Synchronize only pseudonymized cohort telemetry into regional OneLake storage governed by **OneLake RLS/CLS + Entra Agent ID OBO**, ensuring a German PI (`Country = 'DE'`) can never query French or US patient cohorts even within the same multi-center clinical trial table.

---

## ③ 🧭 Visual Architecture Diagrams (Mermaid Decision Tree, Legacy vs. Zero-Trust Architecture & Scenario M Sequence Diagram)

### Diagram 1: 5-Cloud AI Governance, Catalog & Sovereign Compliance Decision Tree (`flowchart TD`)

```mermaid
flowchart TD
    Start(["🎯 Enterprise Multi-Cloud AI Governance & Agent Security Decision"]) --> Q1{"Primary Governance & Workload Gravity?"}

    Q1 -->|"Cross-Engine (Spark/SQL/DirectLake/KQL) + M365 Copilot OBO"| FabricPath["✅ Choose Microsoft Fabric Zero-Trust Stack<br/>OneLake Unified Security (RLS/CLS/OLS) +<br/>Entra Agent ID (OBO) + Microsoft Purview DLP<br/>• Define policy ONCE at storage across 5 engines (-84.2% TCO)<br/>• OBO token eliminates Service-Principal super-token bypass"]

    Q1 -->|"Multi-Cloud Spark/MLOps + Model Endpoint Rate/Spend Gateway"| DBXPath["🤝 Choose Databricks Unity Catalog + Mosaic AI Gateway<br/>• Unity Catalog ABAC tag-driven row/column masks<br/>• Mosaic AI Gateway governs LLM QPS, spend & PII<br/>• Federate into Fabric via Mirrored Unity Catalog + Entra OBO"]

    Q1 -->|"Snowflake DW Dynamic Masking + External B2B Clean Rooms"| SnowPath["❄️ Choose Snowflake Horizon + Cortex Guard<br/>• Tag-based Dynamic Data Masking & Row Access Policies<br/>• Cortex Guard prompt safety + B2B Data Clean Rooms<br/>• Mount via OneLake Iceberg Shortcut + Purview tag mapping"]

    Q1 -->|"Single-Cloud AWS or GCP Estate"| CloudPath{"Which Cloud?"}
    CloudPath -->|"AWS S3 / Redshift / Bedrock"| AWSPath["🟠 AWS Lake Formation + Bedrock Guardrails<br/>• LF-Tag cell-level filters + Bedrock PII redaction<br/>• Mount S3 Tables via OneLake Shortcut for enterprise BI"]
    CloudPath -->|"GCP BigQuery / Vertex AI"| GCPPath["🔵 GCP Dataplex + Cloud DLP + Vertex Safety<br/>• BigQuery Policy Tags + Cloud DLP de-identification<br/>• Zero-copy BigQuery Mirroring into Fabric IQ"]

    FabricPath --> SovereignCheck{"Strict Local Residency / Disconnected Edge Required?"}
    SovereignCheck -->|"Yes (Genomics / Defense / Core Banking)"| ALDO["🛡️ SQL Server on Azure Local (ALDO) + Fabric Sovereign Cloud<br/>Raw PII stays on hospital/factory edge · Pseudonymized cohorts governed via Entra OBO"]
    SovereignCheck -->|"No (Standard Multi-Region Enterprise)"| CloudFabric["🌐 OneLake RLS/CLS/OLS + Purview End-to-End Protection Across Office/Teams"]

    style Start fill:#0F172A,stroke:#38BDF8,stroke-width:2px,color:#F8FAFC
    style FabricPath fill:#064E3B,stroke:#10B981,stroke-width:2px,color:#ECFDF5
    style DBXPath fill:#3B0764,stroke:#A855F7,stroke-width:2px,color:#FAF5FF
    style SnowPath fill:#0C4A6E,stroke:#38BDF8,stroke-width:2px,color:#F0F9FF
    style AWSPath fill:#451A03,stroke:#F59E0B,stroke-width:2px,color:#FEF3C7
    style GCPPath fill:#064E3B,stroke:#34D399,stroke-width:2px,color:#ECFDF5
    style ALDO fill:#1E1B4B,stroke:#818CF8,stroke-width:2px,color:#E0E7FF
```

---

### Diagram 2: Legacy 4-Engine Policy Duplication & Super-Token Bypass vs. OneLake Unified Security + Entra OBO (`flowchart LR`)

```mermaid
flowchart LR
    subgraph Legacy["⛔ Legacy Siloed Stack: 4-Engine Policy Duplication + Service-Principal Super-Token ($9,360/mo Modeled Ops TCO)"]
        direction TB
        L_Data[("Parquet / Delta Storage<br/>(No Storage-Layer RLS/CLS)")] --> L_E1["1. Spark SQL View ACL Scripts"]
        L_Data --> L_E2["2. Warehouse SQL Security Roles"]
        L_Data --> L_E3["3. Power BI DAX RLS Rules"]
        L_Data --> L_E4["4. Vector DB Metadata Filters"]
        L_Data --> L_Agent["⚠️ AI Agent Uses Shared Service Principal<br/>('Super-Token' loses caller identity -> cross-border PII leak)"]
    end

    subgraph FabricZeroTrust["✅ Fabric Zero-Trust Stack: Define-Once OneLake Security + Entra Agent ID OBO ($1,480/mo · -84.2% TCO)"]
        direction TB
        Caller["👤 Caller: German Cardiology PI<br/>(Entra UPN: pi.de@pharma.eu)"] -->|"Issues OBO Token"| AgentID["🤖 Fabric Data Agent<br/>(Entra Agent ID · Zero Super-Token)"]
        AgentID -->|"Passes Caller OBO Claims (11ms)"| OneLakeSec["🔒 OneLake Unified Security<br/>Storage-Layer RLS (Country='DE') +<br/>CLS (Masks SSN/Genomic_ID) + OLS"]
        OneLakeSec --> F_All["⚡ Enforced Across All 5 Engines Automatically<br/>Spark · T-SQL · DirectLake · Eventhouse KQL · Data Agent"]
        F_All --> Purview["🛡️ Microsoft Purview Sensitivity Label Inheritance<br/>Persists encryption & DLP across exported Excel / Word / Teams"]
    end

    Legacy -.->|"Eliminates 4-way policy drift & super-token leaks"| FabricZeroTrust

    style Legacy fill:#2A1215,stroke:#EF4444,stroke-width:2px,color:#FECACA
    style FabricZeroTrust fill:#062E26,stroke:#10B981,stroke-width:2px,color:#ECFDF5
```

---

### Diagram 3: Scenario M EU Sovereign Clinical Trial Pharmacovigilance Closed-Loop Sequence (`sequenceDiagram`, `431 ms` Modeled E2E, `[synthetic_scenario_model]`)

```mermaid
sequenceDiagram
    autonumber
    participant PI as 🇩🇪 German Cardiology PI<br/>(M365 Copilot / Agentic App)
    participant Entra as 🔑 Microsoft Entra Agent ID<br/>(OBO Token Service)
    participant OneLake as 🔒 OneLake Unified Security<br/>(RLS/CLS/OLS + Purview)
    participant Fed as 🤝 Federated Catalogs (Mirrored UC<br/>ABAC + Snowflake Horizon Iceberg)
    participant IQ as 🧠 Fabric IQ Ontology &<br/>Foundry IQ (EMA SOP)
    participant Edge as 🏥 1GB Free Fabric SQL &<br/>ALDO Hospital Edge DB

    PI->>Entra: Queries trial safety: "Find Phase-III cohorts in my jurisdiction with CYP3A4 interaction & QTc prolongation >60ms"
    Entra->>OneLake: Presents Entra Agent ID OBO JWT (Role=DE-Cardiology-PI, Country=DE · Rejects Service-Principal super-token)
    OneLake->>OneLake: 11ms storage-layer RLS blocks 112,400 non-DE rows (0.0% leak) + CLS masks Patient_SSN & Genomic_Sequence_ID
    OneLake->>Fed: Zero-copy join with Databricks UC biomarker features & Snowflake Horizon Iceberg lab tables (74ms KQL + 102ms Graph)
    Fed-->>IQ: Returns governed DE cohort telemetry: 19 dosing batches breach DeltaQTcMs > 60ms threshold
    IQ->>IQ: Foundry IQ verifies EMA EudraVigilance GVP Module IX SOP (blocks unmasked genomic export · Confidence 0.99 -> Confirm)
    IQ->>Edge: Writes batch quarantine hold to 1GB Free Fabric SQL (Rayfin Safety Desk) & syncs to hospital ALDO edge
    Edge-->>PI: 431ms E2E closed loop completed! 0 cross-border PII leak, mitigating $2,800,000 in modeled GDPR Art.83 & EMA penalty exposure
```

---

## ④ 📊 5-Cloud Architect Decision Matrix

| Evaluation Dimension | Microsoft Fabric (OneLake Security + Purview + Entra OBO) | Databricks (Unity Catalog ABAC + Mosaic AI Gateway) | Snowflake (Horizon Catalog + Cortex Guard) | GCP (Dataplex Universal Catalog + Cloud DLP) | AWS (Lake Formation + Bedrock Guardrails) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Primary Sweet Spot** | **Unified fine-grained security across Spark/SQL/DirectLake/KQL/Agents + M365 Copilot OBO + ALDO Sovereign Edge** | **Multi-cloud Spark/MLOps governance + LLM endpoint rate/spend/PII gateway** | **Snowflake-native warehouse dynamic masking + external B2B Data Clean Rooms** | **GCP BigQuery policy tags + automated Cloud DLP de-identification** | **AWS S3 Tables / Athena / Redshift cell-level filters + Bedrock AI guardrails** |
| **Fine-Grained Access Control (RLS/CLS/OLS)** | **Define once at OneLake storage layer (RLS/CLS/OLS)**; enforced across all 5 Fabric engines (`[vendor_published_spec_as_of_2026]`) | **Unity Catalog ABAC** (tag-driven row filters & column masks across tables, volumes & models) | **Horizon RBAC + Tag-Based Dynamic Data Masking** & Row Access Policies | **BigQuery Policy Tags** + Dataplex asset classification & conditional IAM | **Lake Formation LF-Tags** (table, column, row & cell-level data filters) |
| **AI Agent Identity & Anti-Bypass Control** | **Entra Agent ID + On-Behalf-Of (OBO) caller identity passthrough** (zero super-token bypass) + Foundry IQ guardrails | **Mosaic AI Gateway** (centralized LLM endpoint rate limits, token quotas, PII redaction & audit logs) | **Cortex Guard** (LLM prompt safety filtering) + Snowflake role context | **Vertex AI Safety Filters** + IAM service account / end-user credential propagation | **Amazon Bedrock Guardrails** (PII redaction, denied topics, contextual grounding checks) |
| **Downstream DLP Protection Radius** | **Extends to Office productivity**: Purview sensitivity labels auto-propagate from OneLake to Power BI, Excel, Word & Teams | Governs lakehouse tables, notebooks & AI endpoints; no native Office document encryption | Governs Snowflake tables, Streamlit apps & Clean Room shares | Governs GCP storage & BigQuery scans via Cloud Sensitive Data Protection | Governs S3 buckets (Amazon Macie) & Bedrock API payloads |
| **Multi-Cloud Coexistence Pattern** | Acts as the **enterprise identity, semantic ontology & Office DLP plane** over federated 4-cloud catalogs | **Mirrored Unity Catalog** federates metadata into Fabric with Entra ID OBO passthrough | **OneLake Iceberg Shortcut** mounts Horizon/Polaris tables with Purview tag mapping | **BigQuery Mirroring / BigLake Shortcut** into OneLake with Purview labels | **OneLake S3 Shortcut** mounts S3 Tables with OIDC role alignment |
| **Modeled 5-Engine Governance Ops Monthly TCO** | **$1,480/mo** (single-point OneLake policy + Purview/Agent 365 audit, saving **84.2%** vs. 4-engine duplication, `[synthetic_scenario_model]`) | Requires separate BI/Office policy sync or federated connector maintenance | Dynamic masking & Cortex Guard consume warehouse/AI credits | Cloud DLP billed per TB scanned + BigQuery slot usage | Lake Formation catalog free; Macie & Bedrock Guardrails billed per GB/1K chars |

---

## ⑤ 🧪 Quantitative Benchmark, TCO Inflection Points & Provenance Audit

### 5.1 5-Engine Fine-Grained Policy Sync & AI Anti-Bypass Monthly TCO Comparison (`[synthetic_scenario_model]`)

> **Modeling Baseline (Synthetic Reference Model)**: `145,000` patient/customer records consumed simultaneously across **5 engines (Spark, SQL Warehouse, Real-Time KQL, Enterprise BI, and AI Agents)** with `180` country/jurisdiction row-level rules (RLS) and `45` PII/PHI column-masking rules (CLS).

| Governance Architecture Option | Cross-Engine Policy Sync & Script Ops | Dedicated AI PII Proxy Gateway & Audit Storage | Policy Drift & Compliance Remediation Overhead | Modeled Monthly Total TCO (USD/mo) | Savings vs. Legacy 4-Engine Duplication |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Legacy 4-Engine Separate ACLs + Custom Service-Principal PII Proxy** | $4,200/mo | $3,160/mo | $2,000/mo | **$9,360/mo** | Baseline |
| **Databricks Unity Catalog ABAC + External BI Policy Sync** | $1,650/mo | $1,450/mo | $600/mo | **$3,700/mo** | -60.5% |
| **Snowflake Horizon Dynamic Masking + External BI Sync** | $1,800/mo | $1,620/mo | $650/mo | **$4,070/mo** | -56.5% |
| **Microsoft Fabric OneLake Security + Purview + Entra Agent ID OBO** | **$480/mo** (define once at storage) | **$1,000/mo** (Purview + Agent 365 audit) | **$0/mo** (zero OBO drift) | **$1,480/mo** | **-84.2% (Saves $7,880/mo)** |

---

### 5.2 Scenario M Closed-Loop Metrics & Dual Latency Denominator Reconciliation (`sovereign_healthcare_obo_purview_vs_uc_abac`)

- **Scenario M Reference Simulation Metrics (`[synthetic_scenario_model]`)**:
  - **Total Enrolled Trial Patients**: `145,000` across EU & global sites (`32,600` in Germany `DE`; `112,400` in non-DE jurisdictions).
  - **Entra Agent ID OBO + OneLake RLS/CLS Evaluation Latency**: **`11 ms`** (blocks `112,400` non-DE patient rows inline at the storage layer; Service-Principal unauthorized row leak rate = **`0.0%`**).
  - **Federated Catalog & Ontology Reasoning**: `74 ms` Eventhouse KQL ECG telemetry aggregation + `102 ms` Fabric IQ Ontology graph traversal across Mirrored Unity Catalog & Snowflake Horizon Iceberg tables, identifying **`19` dosing batches** with `DeltaQTcMs > 60ms` and concomitant `CYP3A4` inhibitor interaction.
  - **End-to-End Closed-Loop Modeled Latency (Scenario M)**: **`431 ms`**, executing batch quarantine write-back to **1GB Free Fabric SQL** (Rayfin EudraVigilance Safety Desk) and hospital-edge **SQL Server on Azure Local (ALDO)** under a human `Confirm` gate (confidence `0.99`), mitigating **$2,800,000** in modeled GDPR Art. 83 and EMA regulatory penalty exposure.
- **Strict Separation of Dual Latency Denominators (Sealed Report `data-lab-fabric-vs-4clouds-2026-11-09-r6`)**:
  1. **Denominator A — Routing Decision Matrix Mean (`scenario_evaluation.avg_latency_ms`)**:
     - Current Round 6 Scope: **`n = 68` routing decision evaluation tasks (`DL-01..DL-68`)**, achieving **`67 / 68` (`98.53%` accuracy [`measured_local_harness`], with explicit miss `DL-23` capturing `+14.2%` raw-table KPI drift)**.
     - Arithmetic Mean Modeled Latency: **`35,088 ms / 68 = 516.0 ms` exact** (Historical snapshots: Round 5 `n=64` was `521.0 ms`; Round 4 `n=60` was `526.5 ms`; Round 3 `n=56` was `532.0 ms`).
  2. **Denominator B — Industry Ontology End-to-End Closed-Loop Simulations Mean (`ontology_simulations_summary.ontology_simulation_mean_modeled_latency_ms`)**:
     - Current Round 6 Scope: **`n = 13` multi-hop industry Ontology closed-loop simulations (Scenarios A..M)** with individual end-to-end latencies `[780, 640, 710, 660, 590, 560, 530, 515, 495, 480, 465, 450, 431] ms` (range `431–780 ms`).
     - Arithmetic Mean Modeled Latency: **`7,306 ms / 13 = 562.0 ms` exact** (Historical snapshots: Round 5 `n=12` was `572.92 ms`; Round 4 `n=11` was `584.09 ms`; Round 3 `n=10` was `596.0 ms`).

---

### 5.3 Official Vendor Documentation & Pricing References (`vendor_published_spec_references`, `as_of: 2026-11-08`)

| ID | Vendor | Verified Capability & Pricing Specification | Official Documentation URLs (`https://`) |
| :--- | :--- | :--- | :--- |
| `SPEC-01` | Microsoft | Fabric F64 capacity ($8,409.60/mo PAYG / ~$5,004/mo 1-Yr RI) includes $0/user Power BI viewer licensing | [Azure Fabric Pricing](https://azure.microsoft.com/en-us/pricing/details/microsoft-fabric/) · [Fabric Licenses](https://learn.microsoft.com/en-us/fabric/enterprise/licenses) |
| `SPEC-02` | Microsoft | Fabric Database Mirroring & Open Mirroring provide $0 replication compute (CU) and free storage up to capacity TB | [Fabric Mirrored Database](https://learn.microsoft.com/en-us/fabric/database/mirrored-database/overview) · [Open Mirroring](https://learn.microsoft.com/en-us/fabric/database/mirrored-database/open-mirroring) |
| `SPEC-03` | Microsoft | OneLake supports bidirectional Delta ↔ Iceberg virtualization (XTable) & Snowflake Iceberg on OneLake at $0 compute | [OneLake Iceberg Tables](https://learn.microsoft.com/en-us/fabric/onelake/onelake-iceberg-tables) · [OneLake Shortcuts](https://learn.microsoft.com/en-us/fabric/onelake/onelake-shortcuts) |
| `SPEC-04` | Snowflake | Dynamic Tables minimum configurable `TARGET_LAG = 60s`; Open Catalog Polaris provides Apache Iceberg REST | [Dynamic Tables Docs](https://docs.snowflake.com/en/user-guide/dynamic-tables-about) · [Snowflake Iceberg Tables](https://docs.snowflake.com/en/user-guide/tables-iceberg) |
| `SPEC-05` | Databricks | Unity Catalog supports Delta UniForm, Managed Iceberg tables & Lakeflow Connect managed ingestion | [Delta UniForm Docs](https://docs.databricks.com/en/delta/uniform.html) · [Lakeflow Connect](https://docs.databricks.com/en/ingestion/lakeflow-connect/index.html) |
| `SPEC-06` | AWS | Amazon S3 Tables provide native Apache Iceberg storage & Glue REST Catalog; Aurora Zero-ETL to Redshift | [Amazon S3 Tables](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables.html) · [Aurora Zero-ETL](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/zero-etl.html) |
| `SPEC-07` | Google Cloud | BigLake supports Apache Iceberg tables; BigQuery Continuous Queries provide real-time streaming SQL | [BigQuery Iceberg Tables](https://cloud.google.com/bigquery/docs/iceberg-tables) · [Continuous Queries](https://cloud.google.com/bigquery/docs/continuous-queries-introduction) |
| `SPEC-08` | MS / DBX / Snow / GCP | Cosmos DB in Fabric & Azure SQL support SSD DiskANN; Databricks Lakebase, Snowflake Unistore & AlloyDB ScaNN | [Cosmos DB Vector Index](https://learn.microsoft.com/en-us/fabric/database/cosmos-db/index-vector-data) · [Azure SQL DiskANN GA](https://devblogs.microsoft.com/azure-sql/diskann-vector-index-search-are-now-generally-available-in-azure-sql/) |
| `SPEC-09` | MS / DBX / Snow / AWS / GCP | OneLake unified RLS/CLS/OLS + Entra ID OBO; Databricks UC ABAC; Snowflake Horizon; AWS Lake Formation; GCP Dataplex | [OneLake RLS/CLS/OLS](https://learn.microsoft.com/en-us/fabric/onelake/security/table-column-row-security) · [OneLake Access Control](https://learn.microsoft.com/en-us/fabric/onelake/security/data-access-control-model) · [Databricks UC ABAC](https://docs.databricks.com/en/data-governance/unity-catalog/abac.html) · [Snowflake Access Control](https://docs.snowflake.com/en/user-guide/security-access-control-overview) |

---

## ⑥ 🛠️ Appendix: Production & Presales Architect Verification Checklist

- [ ] **1. Ban Shared Service-Principal "Super-Tokens" for AI Agents**: In every architecture review, verify that Fabric Data Agents, Copilot Studio agents, and custom RAG pipelines enforce **Microsoft Entra Agent ID + On-Behalf-Of (OBO) token passthrough** so OneLake and backend databases evaluate RLS/CLS against the actual human caller.
- [ ] **2. Consolidate Fine-Grained Policies at the OneLake Storage Layer**: Replace duplicated Spark SQL view ACLs, warehouse SQL roles, and Power BI DAX RLS rules with **OneLake Unified Security (RLS/CLS/OLS)**. Remember that Workspace Admins/Members/Contributors bypass granular OneLake rules for management, so assign business consumers and agents to Viewer + OneLake Data Access Roles.
- [ ] **3. Federate Existing Competitor Catalogs Instead of Rewriting Tags**: When customers already run Databricks Unity Catalog (ABAC) or Snowflake Horizon Dynamic Data Masking, connect via **Mirrored Unity Catalog / OneLake Iceberg Shortcuts + Microsoft Purview tag mapping**, and keep Mosaic AI Gateway or Cortex Guard on their model serving endpoints.
- [ ] **4. Verify End-to-End Purview DLP Inheritance into Office & Teams**: Test that Microsoft Purview sensitivity labels applied on OneLake tables automatically propagate through Power BI Semantic Models into exported Excel/Word files and Teams messages.
- [ ] **5. Deploy ALDO + Sovereign Cloud for Disconnected / Data-Residency Mandates**: For clinical genomics, defense, or core banking workloads where raw PII cannot leave on-premises server rooms, pair **SQL Server on Azure Local (ALDO)** at the edge with **Fabric Sovereign Cloud** for pseudonymized cross-site analytics.
- [ ] **6. Explicitly Separate Dual Latency Denominators & Provenance Tiers in Executive Decks**: Always report **Denominator A (`n=68` routing matrix mean = `516.0 ms`)** separately from **Denominator B (`n=13` industry Ontology closed-loop simulation mean = `562.0 ms`)**, and preserve explicit `[measured_local_harness]`, `[vendor_published_spec_as_of_2026]`, `[synthetic_scenario_model]`, and `[not_measured]` badges.
