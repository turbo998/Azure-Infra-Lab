# 🧭 AI Solution Architect Business Scenario & Win/Loss Playbook (Win Themes · Coexistence · Anti-Patterns)

> **Language**: [中文 (`scenario-win-loss-playbook.md`)](scenario-win-loss-playbook.md) | **English (Current)**  
> **Architect Lens**: Practical guidance on when to lead with **Full-Stack Microsoft Fabric**, when to deploy **Multi-Cloud Zero-Copy Coexistence (Better Together)**, and which **Anti-Patterns** to avoid.

[![Microsoft IQ & Fabric IQ Reference Architecture](../assets/svg/02-microsoft-iq-fabric-iq-architecture.svg)](../assets/svg/02-microsoft-iq-fabric-iq-architecture.svg)

---

## 1. Five Flagship Industry Reference Solutions

### Scenario 1: AI Compute Center (AIDC) Peak Energy Orchestration & Shaving
- **Business Pain**: 10,000-GPU training clusters experience sharp power spikes during summer peak tariffs, risking 2x demand-charge penalties when approaching the `20.0 MW` utility cap. OT systems (SCADA, DCIM liquid cooling, BESS batteries) and IT schedulers (Kubernetes/Slurm) are siloed.
- **Reference Architecture**:
  1. **Sense (`142 ms`)**: SCADA, DCIM, and GPU telemetry stream via **Eventstream** into **Eventhouse KQL**.
  2. **Model (`186 ms`)**: **Fabric IQ Ontology** maps `Campus → Substation → Transformer → BESS → RackRow → GPUCluster → TrainingJob` with embedded safety rules.
  3. **Optimize & Verify (`336 ms`)**: **Foundry Multi-Agent Orchestrator** combines **`2.00 MW` BESS discharge + `1.10 MW` batch inference deferral + `0.35 MW` from raising liquid cooling supply temp `+1.0°C`**, while **Foundry IQ** verifies compliance against `SOP-DC-COOL-04` (`max +1.5°C`).
  4. **Act & Govern (`116 ms`)**: Dispatches a **Teams Adaptive Card** for human-in-the-loop approval, writes back audit records to **1GB free Fabric SQL** and the Ontology graph, governed end-to-end by **Microsoft Agent 365**.
- **Quantified ROI**: **`780 ms`** end-to-end latency, **`3.45 MW`** peak shaved (`94.2% → 76.95%` utilization), and **`$42,800/mo`** projected savings per campus.

---

### Scenario 2: Aviation & Hub Logistics Real-Time Digital Twin (JFK Runway R25 Case)
- **Business Pain**: Winter wet-snow contamination drops runway friction (`0.24 < 0.30`), causing cascading delays across terminals, de-icing trucks, gates, and connecting passengers.
- **Reference Architecture**:
  1. **One-Click Ontology Bootstrap**: Upgrade existing **Power BI flight operations semantic models** directly into a **Fabric IQ Ontology**.
  2. **Live Signal Binding**: Bind Eventhouse runway sensor streams to `Runway:R25`.
  3. **Graph Cascade & Pre-Authorized Action**: Trace impact across `14 active flights` and `28 ground tasks` (`164 ms`); **Operations Agent** automatically dispatches `Snowplow Fleet-Alpha (4 vehicles)` and reallocates `6 gates` to `R13L`.
- **Quantified ROI**: **`640 ms`** end-to-end resolution, **`38-minute`** reduction in cascading delays, and **`$68,500`** saved per severe weather event.

---

### Scenario 3: Cross-Cloud Omnichannel Retail Flash-Sale & Fabric IQ Planning Write-back (BigQuery + Snowflake + AWS S3 + Fabric)
- **Business Pain**: Flash-sale marketing attribution lives in **GCP BigQuery (Google Ads / GA4)**, supplier POs and financial accounting live in **Snowflake**, carrier telemetry lives in **AWS S3 Tables**, and 2,000 business users operate in **Microsoft 365 / Teams / Power BI**.
- **Reference Architecture (Coexistence Modes A + C + D · Simulation `retail_cross_cloud_planning` / `DL-26`)**:
  1. **Zero-ETL Sense (`134 ms`)**: **GA OneLake BigQuery Mirroring**, **Snowflake Mirroring**, and **S3 Shortcuts** detect a **`+240%`** conversion surge (`12,400 orders/hr`) on `SmartWatch-Pro-X`, dropping `EU-Central-02` inventory to **`1.8 days-of-supply`** (`< 3.0d` floor).
  2. **Ontology Graph & Planning Optimization (`352 ms`)**: **Fabric IQ Ontology** traverses the 6-hop cross-cloud graph and pairs with **Fabric IQ Planning (Preview)** to reallocate **`4,500 units`** from `DE-South`, trigger an **`8,000-unit`** emergency PO in Snowflake ERP, and allocate **`+$185,000`** in Q4 promo budget.
  3. **Margin Guardrail & 1GB Free SQL Write-back (`224 ms`)**: **Foundry IQ** verifies post-reallocation net margin (**`24.6% >= 22.0%`**); merchandising lead approves in **Power BI Agentic App**, writing back to **1GB Free Fabric SQL** and refreshing DirectLake visuals.
- **Quantified ROI**: **`710 ms`** end-to-end resolution, inventory restored to **`6.4 days`**, **`$312,000`** revenue protected per flash sale, and **`47.6%–56.1%`** lower 500-user monthly TCO.

---

### Scenario 4: Multi-Cloud Financial Real-Time Wire Fraud Ring & Project Osmos Autonomous Schema Remediation (AWS S3 + Databricks + Snowflake + Fabric)
- **Business Pain**: Mobile device telemetry lives in **AWS S3 Tables**, GNN fraud features run in **Azure Databricks (Unity Catalog)**, and core customer ledgers sit in **Snowflake**. Upstream ISO-20022 payment schema changes frequently break cross-cloud ETL, leaving fraud ops unable to block coordinated synthetic-identity wire bursts in sub-second windows.
- **Reference Architecture (Coexistence Modes A + B + D · Simulation `financial_multi_cloud_fraud` / `DL-29 & DL-30`)**:
  1. **Real-Time KQL Sense & Project Osmos Self-Healing (`270 ms`)**: **Eventhouse KQL** and an outbound-protected **OneLake S3 Shortcut** detect **38 synthetic-identity accounts** initiating **`$4.85M`** in cross-border wires within 90s (`score 0.97 > 0.85`), while **Fabric Data Engineering Agent (Project Osmos)** autonomously repairs an unmapped `ultmtDbtrId` schema drift in `152 ms`.
  2. **6-Hop Cross-Cloud Graph Traversal + DiskANN Vector Match (`160 ms`)**: **Fabric IQ Ontology** traverses AWS S3, Eventhouse, **Databricks UC (via Supervisor OBO)**, and **Snowflake (via Apache Ossie YAML)** while matching **4 historical fraud ring subgraphs** on **Azure SQL Hyperscale (192 vCore + native DiskANN vector index GA)**.
  3. **Foundry IQ AML Guardrail & Dual-DB Write-back (`230 ms`)**: Validates `FIN-AML-SAR-SOP-12` (`1.4% <= 3.0%` false-positive ceiling), automatically holds all 38 wires (`Act automatically`, confidence `0.97`), and writes back the SAR case to **Azure SQL Hyperscale** and **1GB Free Fabric SQL**.
- **Quantified ROI**: **`660 ms`** end-to-end resolution, **`$4,620,000`** net fraud loss prevented per coordinated ring attack, and **zero-downtime** schema drift remediation.

---

### Scenario 5: 18-Workspace Capacity Surge RCA & Rayfin SDK Full-Stack Agentic App Remediation (`finops_rayfin_observability`)
- **Customer Pain Point**: Enterprise platform teams managing 18+ departmental workspaces face sudden F64 capacity throttling (`>110% CU`) caused by unindexed ad-hoc cross-join queries, threatening executive SLA dashboards and treasury apps that consume external partner ontologies.
- **Reference Architecture (Simulation `finops_rayfin_observability` / `DL-33 & DL-34`)**:
  1. **Cross-Workspace Single Eventhouse Sense (`108 ms`)**: **Workspace Monitoring** streams telemetry from 18 production workspaces into a **single Eventhouse**; **Monitor Hub Capacity Headroom** flags a **`114.8%`** F64 surge and isolates query `Q-8841` in `WS-FIN-PROD-07`.
  2. **6-Hop Impact Graph & Dual-Agent Optimization (`282 ms`)**: **Fabric IQ Ontology** traces impact across **OneLake IQ Sharing (S&P Global RDF Ontology)** and the **Rayfin SDK Treasury Portal**; **Operations Agent** throttles `Q-8841`, **Database Agent for SQL** injects **DiskANN + composite index hints**, and **On-Demand Billing** attaches **`+16 CU` burst headroom** for 25 minutes (`$48.50 <= $250` guardrail).
  3. **Rayfin TypeScript Function Execution & 1GB Free SQL Write-back (`200 ms`)**: After verifying `FINOPS-SURGE-SOP-09` and **Private-by-Default / Secret Store** policies via **Foundry IQ**, the **Rayfin SDK** backend function `fn_remediateCapacityAndLogAudit()` writes the audit record to **1GB Free Fabric SQL**.
- **Quantified ROI**: **`590 ms`** end-to-end remediation, capacity utilization reduced from **`114.8%` to `71.2%` (`-43.6%`)**, and **`$28,400`** in avoided SLA penalties per surge event.

---

### Scenario 6: Cross-Cloud Clinical Trial Cold-Chain Ontology × Database Hub × Hyperscale 192-vCore DiskANN (`healthcare_clinical_supply_diskann`)
- **Customer Pain Point**: Global biopharma teams store lot ledgers in **Oracle ERP**, Phase-III clinical trial cohorts in **GCP BigQuery**, and 18M+ stability kinetic curves and FDA 21 CFR Part 11 SOPs in operational databases. When a cold-chain temperature excursion occurs in transit, manual cross-cloud investigation takes hours, risking patient dosing delays or administration of compromised biologics.
- **Reference Architecture (Simulation `healthcare_clinical_supply_diskann` / `DL-37 & DL-38`)**:
  1. **Real-Time IoT Excursion Sense & Cross-Cloud Graph Traversal (`242 ms`)**: **Eventhouse KQL** detects biologics lot `LOT-BIO-209` at **`6.8°C > 2.0°C`** for 42 minutes; **Fabric IQ Ontology** traverses **OneLake Oracle Mirroring** (**420 at-risk vials** across 3 depots) and **GA BigQuery Mirroring** (**128 Phase-III patients** scheduled within 48 hours).
  2. **Hyperscale 192-vCore DiskANN Vector Search & Database Hub Auto-Tuning (`168 ms`)**: Queries **18M stability vectors** in **Azure SQL Hyperscale 192 vCore** via SSD-backed **DiskANN** (`19 ms` P99, `98.4%` recall) to match `SOP-FDA-21CFR11-BIO-08`, while **Database Hub + Database Agent** (`64` monitored DBs) resolves a blocking lock on the Oracle-mirrored ledger.
  3. **Foundry IQ Regulatory Block & Rayfin Clinical Portal Write-back (`150 ms`)**: **Foundry IQ** blocks administration of the excursed lot; **Rayfin SDK** writes `QUARANTINED` to **1GB Free Fabric SQL** and dispatches **420 replacement vials** from Zurich backup depot `DEPOT-ZRH-02`.
- **Quantified ROI**: **`560 ms`** end-to-end resolution, **`100.0%` patient dosing continuity (`128 / 128`)**, and **`$640,000`** saved in biologics waste and avoided trial disruption.

---

### Scenario 7: 300mm Semiconductor Fab Digital Twin Builder × Lakehouse Streaming Tables × Zero-Provisioned Elastic Burst (`manufacturing_digital_twin_zeroprov`)
- **Customer Pain Point**: 300mm semiconductor fabs stream **85,000 EPS** of OPC-UA telemetry from EUV lithography scanners (`EUV-Scanner-04`, requiring Managed Private Link and CMK encryption), while spare parts inventory sits in **AWS S3**, wafer die-map defect catalogs sit in **GCP BigQuery**, and heavy Monte Carlo thermal yield simulations run only in 15-minute bursts every 4 hours.
- **Reference Architecture (Simulation `manufacturing_digital_twin_zeroprov` / `DL-41..DL-44`)**:
  1. **Private-Link Stream Sense & Sub-Second Streaming Table (`96 ms`)**: **Eventstream (Managed Private Link + CMK)** ingests 85K EPS into a **OneLake Lakehouse Streaming Table** (**`210 ms` lag**, immediately queryable via DirectLake), detecting overlay drift at **`1.85 nm > 0.90 nm`** across 75 300mm wafers.
  2. **Digital Twin Builder Graph Cascade & Zero-Provisioned Burst (`286 ms`)**: **Digital Twin Builder** traverses AWS S3 Cached Shortcuts and GA BigQuery Mirroring die maps, then wakes a **Zero-Provisioned On-Demand** pool (**`+24 CU` burst** at **`$14.20` pay-per-job cost** with **`0.0%` base F64 throttling**) to compute the optimal **`-0.42°C` chuck thermal offset** and `180s` micro-purge cycle.
  3. **Foundry IQ Process Guardrail & Rayfin Fab-Ops Write-back (`148 ms`)**: **Foundry IQ** validates compliance against `SOP-SEMI-EUV-14` (`±0.60°C` pre-authorized envelope) and writes the calibration receipt to **1GB Free Fabric SQL** via **Rayfin SDK**.
- **Quantified ROI**: **`530 ms`** end-to-end resolution, overlay restored to **`0.58 nm`**, **`99.4%` wafer yield preserved across 75 wafers**, and **`$920,000`** saved in avoided wafer scrap.

---

## 2. Presales Decision Matrix: Win Themes vs. Coexistence vs. Anti-Patterns

| Category | Customer Signals & Workload Profile | Recommended Architect Play |
| :--- | :--- | :--- |
| **✅ Primary Win (Full-Stack Fabric)** | • Enterprise standardized on M365 E3/E5, Teams, Power BI, and M365 Copilot<br>• Moving from passive dashboards to proactive **Operations Agents** & write-back apps<br>• Cross-domain OT/IT entity cascade problems (Energy, Aviation, Manufacturing, Retail) | Lead with **OneLake + Fabric IQ Ontology + Foundry IQ + Agent 365**, highlighting `$0` extra Copilot token cost and 1GB free Fabric SQL |
| **🤝 Coexistence Win (Better Together)** | • Heavy existing investments in Snowflake, Databricks, BigQuery, or AWS S3<br>• Data engineering refuses to rewrite battle-tested Spark DLT or core warehouse pipelines<br>• Pain points center on BI concurrency spikes, metric drift, and multi-cloud silos | **Never pitch "rip-and-replace"!** Lead with **OneLake Mirroring / Shortcuts + Apache Ossie + IQ Sharing** to deliver an AI/BI layer in days without touching source pipelines |
| **⛔ Anti-Patterns (When NOT to Use)** | • **Anti-Pattern 1**: Exposing ungrounded LLM Text-to-SQL directly on raw lakehouse tables without a semantic model/Ontology (`DL-23` caused `+14.2%` EBITDA drift)<br>• **Anti-Pattern 2**: Allowing autonomous agents to write unsafe physical control setpoints (e.g., `+3.5°C` cooling override) without Foundry IQ SOP guardrails and HITL approval<br>• **Anti-Pattern 3**: Running 70B+ foundation model pre-training or `< 5 ms` HFT matching inside analytical lakehouse capacities | Route 70B+ model training to **Azure AI Foundry / Azure Databricks**, and enforce **Ontology Rules + Foundry IQ SOP guardrails + HITL** for physical operations |
