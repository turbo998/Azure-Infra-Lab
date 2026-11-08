# 🔬 Data Lab — Microsoft Fabric × 4-Cloud Competitors (Databricks / Snowflake / GCP / AWS) Deep Research & AI Solution Architect Lab

> **Language**: [中文 (`README.md`)](README.md) | **English (Current)**  
> **Latest Daily Run**: [`2026-11-08 / 11-09`](research/daily/2026-11-08.en.md) · [`2026-11-06`](research/daily/2026-11-06.en.md) · [`2026-11-05`](research/daily/2026-11-05.en.md) · [`2026-11-04`](research/daily/2026-11-04.en.md) · [`2026-11-03`](research/daily/2026-11-03.en.md) (includes [`2026-11-02`](research/daily/2026-11-02.en.md) & [`2026-11-01`](research/daily/2026-11-01.en.md) baselines) · **Benchmark Pass Rate**: `71 / 72 (98.61%)` (`n=72` matrix mean `511.0ms` · `n=14` ontology sim mean `552.0ms`) · **Unit Tests**: `32 / 32 Passed (100%)`  
> **🌟 Flagship Architect Selection FAQs (Modeled on `ib-vs-ethernet-roce-selection-faq.md`)**:  
> - **Round 1 (Zero-Copy & Ontology Selection)**: [`comparisons/fabric-onelake-iq-vs-4clouds-selection-faq.en.md` (OneLake Zero-Copy × Fabric IQ Ontology vs. 4 Clouds Selection FAQ)](comparisons/fabric-onelake-iq-vs-4clouds-selection-faq.en.md) · [`中文版 FAQ`](comparisons/fabric-onelake-iq-vs-4clouds-selection-faq.md)  
> - **Round 2 (Real-Time Streaming Selection)**: [`comparisons/fabric-realtime-eventhouse-vs-4clouds-streaming-faq.en.md` (Eventhouse KQL 142ms vs. Snowflake Dynamic Tables 60s vs. Databricks Lakeflow FAQ)](comparisons/fabric-realtime-eventhouse-vs-4clouds-streaming-faq.en.md) · [`中文版 FAQ`](comparisons/fabric-realtime-eventhouse-vs-4clouds-streaming-faq.md)  
> - **Round 3 (Zero-ETL Mirroring vs. CDC Selection)**: [`comparisons/fabric-mirroring-zero-etl-vs-cdc-faq.en.md` (Fabric Mirroring & Open Mirroring $0 Compute vs. Fivetran MAR / Debezium / Snowflake Openflow / Databricks Lakeflow Connect FAQ)](comparisons/fabric-mirroring-zero-etl-vs-cdc-faq.en.md) · [`中文版 FAQ`](comparisons/fabric-mirroring-zero-etl-vs-cdc-faq.md)  
> - **Round 4 (Open Table Format & Catalog Selection)**: [`comparisons/fabric-onelake-iceberg-delta-uniform-vs-4clouds-faq.en.md` (OneLake Iceberg↔Delta XTable $0 Virtualization vs. Databricks Delta UniForm vs. Snowflake Polaris vs. AWS S3 Tables vs. GCP BigLake FAQ)](comparisons/fabric-onelake-iceberg-delta-uniform-vs-4clouds-faq.en.md) · [`中文版 FAQ`](comparisons/fabric-onelake-iceberg-delta-uniform-vs-4clouds-faq.md)  
> - **Round 5 (Operational HTAP & 100M+ Vector Indexing Selection)**: [`comparisons/fabric-htap-vector-sql-cosmos-vs-lakebase-unistore-faq.en.md` (Fabric SQL DB + Cosmos DB SSD DiskANN -92% RAM vs. Databricks Lakebase vs. Snowflake Unistore vs. GCP AlloyDB ScaNN vs. AWS Aurora pgvector FAQ)](comparisons/fabric-htap-vector-sql-cosmos-vs-lakebase-unistore-faq.en.md) · [`中文版 FAQ`](comparisons/fabric-htap-vector-sql-cosmos-vs-lakebase-unistore-faq.md)  
> - **Round 6 (Multi-Cloud AI Security Governance & Agent OBO Selection)**: [`comparisons/fabric-onelake-purview-obo-governance-vs-4clouds-faq.en.md` (OneLake Unified RLS/CLS/OLS + Purview + Entra Agent ID OBO -85.3% Governance TCO vs. Databricks UC ABAC vs. Snowflake Horizon vs. AWS Lake Formation vs. GCP Dataplex FAQ)](comparisons/fabric-onelake-purview-obo-governance-vs-4clouds-faq.en.md) · [`中文版 FAQ`](comparisons/fabric-onelake-purview-obo-governance-vs-4clouds-faq.md)  
> - **Round 7 (Lakehouse Native Vectorized Spark & Autoscale FinOps Selection)**: [`comparisons/fabric-spark-native-gluten-autoscale-vs-photon-snowpark-faq.en.md` (Fabric Spark Gluten+Velox C++ $0 Surcharge + Autoscale Billing -58.6% Compute TCO vs. Databricks Photon vs. Snowflake Snowpark vs. GCP Dataproc vs. AWS EMR Serverless FAQ)](comparisons/fabric-spark-native-gluten-autoscale-vs-photon-snowpark-faq.en.md) · [`中文版 FAQ`](comparisons/fabric-spark-native-gluten-autoscale-vs-photon-snowpark-faq.md)
>
> 🔍 **Data Provenance, Official URLs & Dual-Denominator Scope Disclosure**:
> - **`measured_local_harness`**: 72-scenario routing matrix (`71/72 = 98.61%` accuracy, explicit miss `DL-23` capturing `+14.2%` raw-table drift) and `32/32` Python unit tests executed locally (`0.023s`).
> - **`vendor_published_spec_as_of_2026` (Verified Official URLs `as_of: 2026-11-08`)**:
>   - [Fabric Pricing & F64 `$0` Viewer Seats](https://azure.microsoft.com/en-us/pricing/details/microsoft-fabric/) · [Fabric Licenses](https://learn.microsoft.com/en-us/fabric/enterprise/licenses)
>   - [Fabric Mirroring `$0` Compute & Free Storage Quota](https://learn.microsoft.com/en-us/fabric/database/mirrored-database/overview) · [Open Mirroring](https://learn.microsoft.com/en-us/fabric/database/mirrored-database/open-mirroring)
>   - [OneLake Iceberg ↔ Delta XTable Virtualization (`$0`)](https://learn.microsoft.com/en-us/fabric/onelake/onelake-iceberg-tables) · [OneLake Shortcuts](https://learn.microsoft.com/en-us/fabric/onelake/onelake-shortcuts)
>   - [Cosmos DB in Fabric DiskANN Vector Indexing](https://learn.microsoft.com/en-us/fabric/database/cosmos-db/index-vector-data) · [SQL DB in Fabric Billing & Overview](https://learn.microsoft.com/en-us/fabric/database/sql/overview) · [Databricks Lakebase Postgres](https://docs.databricks.com/aws/en/oltp/projects/) · [Snowflake Unistore Hybrid Tables](https://docs.snowflake.com/en/user-guide/unistore-hybrid-tables) · [GCP AlloyDB ScaNN](https://cloud.google.com/alloydb/docs/ai/work-with-embeddings) · [AWS Aurora pgvector](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html)
>   - [OneLake Unified Data Access Roles (RLS/CLS/OLS)](https://learn.microsoft.com/en-us/fabric/onelake/security/get-started-data-access-roles) · [Microsoft Purview Data Governance in Fabric](https://learn.microsoft.com/en-us/fabric/governance/microsoft-purview-fabric) · [Databricks UC ABAC](https://docs.databricks.com/aws/en/data-governance/unity-catalog/abac/) · [Snowflake Horizon Catalog](https://docs.snowflake.com/en/user-guide/snowflake-horizon) · [AWS Lake Formation Fine-Grained Access](https://docs.aws.amazon.com/lake-formation/latest/dg/what-is-lake-formation.html) · [GCP Dataplex Universal Catalog](https://cloud.google.com/dataplex/docs/introduction)
>   - [Fabric Spark Native Execution Engine (Gluten + Velox C++ `$0` Surcharge)](https://learn.microsoft.com/en-us/fabric/data-engineering/spark-native-execution-engine) · [Fabric Autoscale Billing for Spark](https://learn.microsoft.com/en-us/fabric/data-engineering/autoscale-billing-for-spark-overview) · [Databricks Photon Engine](https://docs.databricks.com/en/compute/photon.html) · [Snowflake Snowpark](https://docs.snowflake.com/en/developer-guide/snowpark/index) · [GCP Dataproc Serverless](https://cloud.google.com/dataproc-serverless/docs/overview) · [AWS EMR Serverless](https://docs.aws.amazon.com/emr/latest/EMR-Serverless-UserGuide/emr-serverless.html)
>   - [Snowflake Dynamic Tables `60s` Min Lag](https://docs.snowflake.com/en/user-guide/dynamic-tables-about) · [Snowflake Iceberg Tables](https://docs.snowflake.com/en/user-guide/tables-iceberg) · [Databricks Delta UniForm](https://docs.databricks.com/en/delta/uniform.html) · [AWS S3 Tables](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables.html) · [GCP BigLake Iceberg](https://cloud.google.com/bigquery/docs/iceberg-tables)
> - **`synthetic_scenario_model` (Deterministic Reference Model with Strictly Separated Denominators)**:
>   - **Denominator A — Routing Matrix Evaluation Mean (`scenario_evaluation.avg_latency_ms`)**: R7 **`n=72` (`DL-01..DL-72`) arithmetic mean = `511.0 ms`** (R6 historical snapshot `n=68` mean = `516.0 ms`, R5 historical snapshot `n=64` mean = `521.0 ms`, R4 historical snapshot `n=60` mean = `526.5 ms`, R3 historical snapshot `n=56` mean = `532.0 ms`).
>   - **Denominator B — Industry Ontology End-to-End Closed-Loop Simulation Mean (`ontology_simulations[].end_to_end_latency_ms`)**: R7 **`n=14` (Scenarios A..N: `[780, 640, 710, 660, 590, 560, 530, 515, 495, 480, 465, 450, 431, 422] ms`, range `422–780 ms`) arithmetic mean = `552.0 ms`** (R6 historical snapshot `n=13` mean = `562.0 ms`, R5 historical snapshot `n=12` mean = `572.92 ms`, R4 historical snapshot `n=11` mean = `584.09 ms`, R3 historical snapshot `n=10` mean = `596.0 ms`).
>   - The 500-user TCO model (`$14,048/mo`), CDC/format-conversion/HTAP+vector/governance/Spark compute TCO comparisons, and SLA/margin/duration/compliance fine/EV recall exposures (`$1.15M`/`$1.48M`/`$2.35M`/`$1.62M`/`$1.95M`/`$2.80M`/`$2.45M`) are deterministic reference simulations sealed in `reports/report.json`; live multi-cloud cluster stress runs are marked `not_measured`.

[![Data Lab Executive Visual Summary](assets/svg/01-data-lab-executive-summary-2026-11-08.svg)](assets/svg/01-data-lab-executive-summary-2026-11-08.svg)

---

## 📌 Executive Summary (3-Minute Architect Decision Guide)

1. **When to Standardize on Microsoft Fabric as the Single Control Plane**: When an enterprise has 200+ Power BI / M365 Copilot users, needs sub-second streaming telemetry (`142 ms` Eventhouse KQL) or no-code physical asset graphs (Digital Twin Builder), and wants business agents to sense, reason over governed ontologies, and write back actions (`Rayfin SDK + 1GB Free Fabric SQL`) with **zero data movement**, **Microsoft Fabric is the primary choice**—delivering **`46.1%–56.1%` lower monthly TCO** at 500 users (`$14,048/mo` vs. `$26,063–$31,990/mo`).
2. **When to Choose "Fabric + Competitor Bidirectional Zero-Copy Coexistence (Better Together)"**: When a customer already runs 70B+ distributed ML/Spark jobs in Databricks, core financial warehousing in Snowflake, or operational datasets in Salesforce Data 360 / BigQuery / AWS S3 Tables, **never pitch a rip-and-replace or nightly copy-ETL pipeline**; deploy **OneLake Shortcuts + Zero-ETL Mirroring + OneLake IQ Sharing + Apache Ossie** for bidirectional zero-copy coexistence.
3. **First-Principles Architectural Essence**: Legacy warehouses were built for humans reading static dashboards (spending 60% of budget copying data and suffering `+14.2%` KPI drift when LLMs query raw tables); **OneLake + Fabric IQ** builds a zero-copy universal adapter and governed semantic brain for AI agents—locking metric drift at **`0.0%`** and closing cross-cloud operational loops in **`515 ms–780 ms`**.

> 📖 **Full First-Principles FAQ Guide (with 4 Deep-Dive Q&As, Mermaid Selection Flowchart, Stratified Stack Comparison, Sequence Diagram & Presales Checklist)**: Read [`comparisons/fabric-onelake-iq-vs-4clouds-selection-faq.en.md`](comparisons/fabric-onelake-iq-vs-4clouds-selection-faq.en.md).

---

## 🎯 Lab Mission & Six AI Solution Architect Pillars

**Data Lab** is built from the perspective of a Principal **AI Solution Architect**, delivering daily capability breakthrough tracking, first-principles competitive FAQ guides, reference architectures, interactive H5 simulators, reproducible 7-Card 4:5 benchmarks, and presales win/coexistence playbooks across **Microsoft Fabric (Fabric IQ Ontology & Condition-Action Rules, OneLake IQ Sharing, Salesforce Data 360 Zero-Copy Shortcuts, SQL Server on Azure Local ALDO + Fabric M365 GCC High GA, Digital Twin Builder, Lakehouse Streaming Tables, On-Demand & Zero-Provisioned Compute, Project Osmos, Open-Source Rayfin SDK/CLI, Database Hub + Database Agents, Azure SQL Hyperscale 192 vCore + Native DiskANN GA, Real-Time Intelligence, Power BI Agentic Apps with 1GB Free Fabric SQL)** and its four primary cloud competitors: **Databricks, Snowflake, Google Cloud (BigQuery / AlloyDB / Spanner Graph / Vertex AI), and AWS (SageMaker Lakehouse / S3 Tables / IoT SiteWise / Aurora Zero-ETL / Bedrock)**.

| Pillar | Core Workstream | Primary Deliverables | Key Quantitative Finding (`2026-11-08 / 11-09`) |
| :--- | :--- | :--- | :--- |
| **Pillar 0** | **Daily Domain Breakthrough Tracking (Plain-Language + First Principles)** | [`2026-11-08.en.md`](research/daily/2026-11-08.en.md) · [`11-09.en.md`](research/daily/2026-11-09.en.md) · [`11-06.en.md`](research/daily/2026-11-06.en.md) · [`11-05.en.md`](research/daily/2026-11-05.en.md) | Tracks OneLake IQ Sharing (`.rdf` + `.md`), Salesforce Data 360 Zero-Copy Shortcuts, Fabric IQ Condition-Action Rules, SQL Server on Azure Local (ALDO) & GCC High GA vs. Databricks OpenSharing/UC Metric Relationships/ABAC `DENY` and Snowflake Delta Shares/Polaris v3 |
| **Pillar 1** | **Dedicated 4-Cloud Competitive FAQ & Battlecards** | [`fabric-onelake-iq-vs-4clouds-selection-faq.en.md`](comparisons/fabric-onelake-iq-vs-4clouds-selection-faq.en.md) · [`fabric-realtime-eventhouse-vs-4clouds-streaming-faq.en.md`](comparisons/fabric-realtime-eventhouse-vs-4clouds-streaming-faq.en.md) · [`battlecards-2026.en.md`](comparisons/fabric-vs-4clouds-battlecards-2026.en.md) | 6-Dimension Composite Mean: **Fabric `93.3`** vs. Databricks `86.8` vs. GCP `85.5` vs. Snowflake `85.0` vs. AWS `82.8` + Zero-Copy & Streaming Selection Decision Trees |
| **Pillar 2** | **Architecture Design (OneLake Zero-Copy × Eventhouse Dual Projection × Fabric IQ)** | [`10-realtime-faq.svg`](assets/svg/10-realtime-eventhouse-vs-dynamic-tables-dlt-faq.svg) · [`09-iq-sharing-faq.svg`](assets/svg/09-onelake-iq-sharing-salesforce-sovereign-faq.svg) · [`08-twin-zeroprov.svg`](assets/svg/08-digital-twin-builder-on-demand-zero-provisioned.svg) · [`07-dbhub-diskann.svg`](assets/svg/07-database-hub-hyperscale-diskann-mirroring.svg) | Eventhouse KQL (`142ms`) + Lakehouse Streaming Tables (`210ms`) vs. Snowflake Dynamic Tables (`60s` min lag), OneLake IQ Sharing, Salesforce Data 360 zero-copy & Azure Local ALDO edge loop |
| **Pillar 3** | **Interactive H5 Workbench & 9-Scenario Ontology Simulator** | [`live-demo.en.html` (EN)](live-demo.en.html) · [`index.html` (中文)](index.html) | Interactive 5-cloud battlecard compass, live TCO calculator, and 9 closed loops: AIDC energy (`780ms`), Airline JFK R25 (`640ms`), Cross-Cloud Retail (`710ms`), Financial Anti-Fraud (`660ms`, `$4.62M` saved), 18-WS FinOps (`590ms`), Clinical Cold-Chain DiskANN (`560ms`, `$640K` saved), 300mm Semiconductor Fab (`530ms`, `$920K` saved), Cross-Enterprise Supply Chain IQ Sharing × Salesforce (`515ms`, `$1.15M` SLA saved), and 5G URLLC Slice Eventhouse SRv6 Steering (`495ms`, `$1.48M` SLA saved) |
| **Pillar 4** | **Reproducible Benchmark & 7-Card 4:5 Deck** | [`benchmark-cards.en.html` (EN)](benchmark-cards.en.html) · [`benchmark-cards.html` (中文)](benchmark-cards.html) · [`report.json`](reports/report.json) | **`51/52` (`98.08%`)** scenario accuracy (`537.7ms` mean); `46.1%–56.1%` 500-user TCO savings; `-48.5%` streaming compute |
| **Pillar 5** | **Business Scenario & Win/Loss Playbook** | [`playbooks/scenario-win-loss-playbook.en.md`](playbooks/scenario-win-loss-playbook.en.md) · [`中文`](playbooks/scenario-win-loss-playbook.md) | End-to-end Win Themes, Coexistence Patterns, and Anti-Patterns across 9 enterprise scenarios (including Scenario 8 Supply Chain IQ Sharing & Scenario 9 5G URLLC Slice Eventhouse Steering) |

---

## 🖼️ Core Architecture Diagrams (Self-Contained SVGs)

### 1. Fabric Spark Native Execution Engine (Gluten + Velox C++ $0 Surcharge) + Autoscale Billing (-58.6% Compute TCO) vs. Databricks Photon vs. Snowflake Snowpark vs. GCP Dataproc vs. AWS EMR Serverless FAQ Architecture (`2026-11-08 / 11-09 R7` New)
[![Fabric Spark Gluten Velox Autoscale vs Databricks Photon Snowflake Snowpark FAQ Architecture](assets/svg/15-spark-gluten-velox-autoscale-vs-photon-snowpark-faq.svg)](assets/svg/15-spark-gluten-velox-autoscale-vs-photon-snowpark-faq.svg)

### 2. OneLake Unified RLS/CLS/OLS + Purview + Entra Agent ID OBO (-85.3% Governance TCO) vs. Databricks UC ABAC vs. Snowflake Horizon vs. AWS Lake Formation vs. GCP Dataplex FAQ Architecture (`2026-11-08 / 11-09 R6`)
[![OneLake Unified Security Purview Entra Agent ID OBO vs UC ABAC Horizon FAQ Architecture](assets/svg/14-onelake-purview-obo-governance-vs-uc-horizon-faq.svg)](assets/svg/14-onelake-purview-obo-governance-vs-uc-horizon-faq.svg)

### 2. Fabric SQL DB + Cosmos DB SSD DiskANN (-92% RAM) vs. Databricks Lakebase vs. Snowflake Unistore vs. GCP AlloyDB ScaNN vs. AWS Aurora HTAP FAQ Architecture (`2026-11-08 / 11-09 R5`)
[![Fabric HTAP & DiskANN vs Lakebase Unistore AlloyDB ScaNN Aurora FAQ Architecture](assets/svg/13-htap-vector-diskann-vs-lakebase-unistore-scann-faq.svg)](assets/svg/13-htap-vector-diskann-vs-lakebase-unistore-scann-faq.svg)

### 2. OneLake Iceberg↔Delta XTable ($0 Virtualization) vs. Databricks Delta UniForm vs. Snowflake Polaris vs. AWS S3 Tables vs. GCP BigLake Open Format FAQ Architecture (`2026-11-08 / 11-09 R4`)
[![OneLake Iceberg Delta XTable vs UniForm Polaris S3 Tables BigLake FAQ Architecture](assets/svg/12-onelake-iceberg-delta-uniform-polaris-s3tables-faq.svg)](assets/svg/12-onelake-iceberg-delta-uniform-polaris-s3tables-faq.svg)

### 2. Fabric Database Mirroring & Open Mirroring ($0 Compute) vs. Fivetran MAR / Debezium / Snowflake Openflow / Databricks Lakeflow Connect FAQ Architecture (`2026-11-08 / 11-09 R3` New)
[![Fabric Mirroring & Open Mirroring vs CDC Openflow Lakeflow FAQ Architecture](assets/svg/11-mirroring-zero-etl-vs-cdc-openflow-lakeflow-faq.svg)](assets/svg/11-mirroring-zero-etl-vs-cdc-openflow-lakeflow-faq.svg)

### 2. Fabric Eventhouse (KQL 142ms) + Lakehouse Streaming Tables (210ms) vs. Snowflake Dynamic Tables (60s) vs. Databricks Lakeflow Streaming FAQ Architecture (`2026-11-08 / 11-09 R2` New)
[![Fabric Eventhouse vs Dynamic Tables vs Lakeflow Streaming FAQ Architecture](assets/svg/10-realtime-eventhouse-vs-dynamic-tables-dlt-faq.svg)](assets/svg/10-realtime-eventhouse-vs-dynamic-tables-dlt-faq.svg)

### 2. OneLake Zero-Copy Trio (Shortcuts / Mirroring / IQ Sharing) × Fabric IQ Condition-Action Rules × Sovereign Edge FAQ Architecture (`2026-11-08 / 11-09 R1` New)
[![OneLake IQ Sharing & Fabric IQ Selection FAQ Architecture](assets/svg/09-onelake-iq-sharing-salesforce-sovereign-faq.svg)](assets/svg/09-onelake-iq-sharing-salesforce-sovereign-faq.svg)

### 2. Digital Twin Builder × Lakehouse Streaming Tables × On-Demand / Zero-Provisioned Compute (`2026-11-05 / 11-06`)
[![Digital Twin Builder & Zero-Provisioned Elastic Compute Architecture](assets/svg/08-digital-twin-builder-on-demand-zero-provisioned.svg)](assets/svg/08-digital-twin-builder-on-demand-zero-provisioned.svg)

### 2. Database Hub × Azure SQL Hyperscale 192-vCore DiskANN × Cross-Cloud Zero-ETL Mirroring (`2026-11-04 / 11-05`)
[![Database Hub & Hyperscale 192 vCore DiskANN Architecture](assets/svg/07-database-hub-hyperscale-diskann-mirroring.svg)](assets/svg/07-database-hub-hyperscale-diskann-mirroring.svg)

### 2. Open-Source Rayfin SDK Full-Stack Agentic Apps × Cross-Workspace Eventhouse Observability × OneLake IQ Sharing (`2026-11-04`)
[![Rayfin SDK & Cross-Workspace Eventhouse Observability Architecture](assets/svg/06-rayfin-agentic-apps-eventhouse-observability.svg)](assets/svg/06-rayfin-agentic-apps-eventhouse-observability.svg)

### 2. Project Osmos Autonomous Data Engineering × Cross-Cloud OBO Identity × Apache Ossie Semantic Interop (`2026-11-03`)
[![Project Osmos & Cross-Cloud OBO Architecture](assets/svg/05-osmos-autonomous-engineering-ossie-interop.svg)](assets/svg/05-osmos-autonomous-engineering-ossie-interop.svg)

### 3. LTAP Translytical Operational Loop vs. 4-Cloud Competitors (`2026-11-02`)
[![LTAP & Translytical Architecture](assets/svg/04-translytical-ltap-agentic-architecture.svg)](assets/svg/04-translytical-ltap-agentic-architecture.svg)

### 4. Microsoft IQ × Fabric IQ Enterprise Ontology & Multi-Agent Architecture
[![Microsoft IQ & Fabric IQ Architecture](assets/svg/02-microsoft-iq-fabric-iq-architecture.svg)](assets/svg/02-microsoft-iq-fabric-iq-architecture.svg)

### 5. OneLake Cross-Cloud Zero-Copy Coexistence Topology
[![Five Cloud Coexistence Topology](assets/svg/03-five-cloud-coexistence-topology.svg)](assets/svg/03-five-cloud-coexistence-topology.svg)

---

## ⚡ Reproduce the Benchmark & Sealed `report.json`

```powershell
# 1. Run the 20-test verification suite (20/20 passed)
python -m unittest discover -s workshops/data-lab/tests -v

# 2. Regenerate the sealed evaluation report
python workshops/data-lab/src/data_lab/benchmark_suite.py --output workshops/data-lab/reports/report.json
```
