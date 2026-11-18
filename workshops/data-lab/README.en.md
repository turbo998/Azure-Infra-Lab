# 🔬 Data Lab — Enterprise Data & AI Architecture Selection & Diamond Live Demo Lab

> **Language / 语言切换**: **[🇨🇳 中文 (`README.md`)](README.md)** | **🇬🇧 English (`README.en.md`)**  
> **⚡ Quick Access**: **[💎 Diamond Enterprise Demo Hub](demos/diamond-hub.en.html)** · **[📺 TCL × Fabric 6-Act Cockpit](demos/tcl-fabric/index.en.html)** · **[🛒 Zava × Databricks & Fabric Demo](demos/databricks-fabric/index.en.html)** · **[⚔️ Databricks vs Fabric 10-Dim Battlecard](demos/databricks-fabric/battlecard.en.html)** · **[🧭 5-Cloud TCO & Sim Workbench](index.en.html)** · **[📊 7-Card Benchmark Deck](benchmark-cards.en.html)**

An **AI Solution Architect (SA)** evaluation and live-demo lab comparing **Microsoft Fabric** (OneLake · Direct Lake · Eventhouse · Fabric IQ Ontology) with **Azure Databricks**, **Snowflake**, **GCP BigQuery**, and **AWS Lakehouse** — featuring **2 fully sanitized executive live demos (Diamond Enterprise Demo Suite)**, **77 (7×11) bilingual enterprise architecture selection FAQs**, and a **sealed reproducible benchmark suite (`347 / 348 = 99.71%`, `170 / 170` unit tests passing)**.

---

## 1. Interactive Workbenches & Live Demos (Quick Launch)

| Deliverable | SA Role & Capability | Launch Link |
| :--- | :--- | :--- |
| **💎 Diamond Enterprise Demo Hub** | Unified executive portal for TCL × Fabric and Zava × Databricks & Fabric sandboxes, speaker scripts, and scenario routing | [`demos/diamond-hub.en.html`](demos/diamond-hub.en.html) · [中文](demos/diamond-hub.html) |
| **📺 TCL Global Channel IQ × Fabric (6-Act Cockpit)** | Zero-copy OneLake EDI 852 Shortcuts + Eventhouse port-delay KQL + Fabric IQ Ontology guardrails + pipeline write-back | [`demos/tcl-fabric/index.en.html`](demos/tcl-fabric/index.en.html) · [SA Playbook](demos/tcl-fabric/playbook.en.html) |
| **🛒 Zava Omnichannel Retail × Databricks & Fabric** | Unity Catalog dynamic PII masking + 5-turn AI/BI Genie margin root-cause drilldown + Mirrored UC Direct Lake | [`demos/databricks-fabric/index.en.html`](demos/databricks-fabric/index.en.html) · [10-Dim Battlecard](demos/databricks-fabric/battlecard.en.html) |
| **🧭 5-Cloud Competitive & TCO Workbench** | 6-dimension platform scorecard, 500-viewer interactive TCO calculator, and Fabric IQ Ontology guardrail simulator | [`index.en.html`](index.en.html) · [中文](index.html) |
| **📊 7-Card 4:5 Visual Benchmark Deck** | Self-contained 7-card evaluation deck generated from sealed `reports/report.json` (`347/348 = 99.71%`, `207.6ms` mean, `DL-800` milestone, explicit `DL-23` miss) | [`benchmark-cards.en.html`](benchmark-cards.en.html) · [中文](benchmark-cards.html) |

---

## 2. 77 (7×11) Curated Enterprise Data + AI Architecture Selection FAQs

Every FAQ follows a crisp Solution Architect structure (Executive Summary, Architecture Q&A, Dataflow Diagram, 5-Cloud Decision Matrix, Implementation Checklist) focused strictly on mainstream enterprise workloads:

### A. Core Platform Architecture Selection
- **Zero-Copy & Semantic Layer**: [OneLake Shortcuts & Fabric IQ vs 4 Clouds](comparisons/fabric-onelake-iq-vs-4clouds-selection-faq.en.md)
- **Streaming & Sub-Second Analytics**: [Eventhouse KQL vs Snowflake Dynamic Tables vs Databricks Lakeflow](comparisons/fabric-realtime-eventhouse-vs-4clouds-streaming-faq.en.md)
- **Zero-ETL Database Mirroring vs CDC**: [Fabric Mirroring vs Debezium + Kafka vs Fivetran](comparisons/fabric-oltp-to-olap-zero-etl-mirroring-vs-debezium-kafka-fivetran-faq.en.md)
- **Open Table Formats**: [OneLake Iceberg ↔ Delta UniForm vs Polaris / BigLake](comparisons/fabric-onelake-iceberg-delta-uniform-vs-4clouds-faq.en.md)
- **Enterprise Vector & Hybrid Search**: [Azure AI Search + SSD DiskANN vs pgvector vs Mosaic AI vs Milvus](comparisons/fabric-enterprise-vector-hybrid-search-ai-search-pgvector-mosaic-milvus-faq.en.md)
- **Governance & Identity Passthrough**: [OneLake Catalog + Purview + Entra OBO vs Unity Catalog ABAC](comparisons/fabric-enterprise-data-governance-rls-cls-obo-catalog-faq.en.md)
- **Enterprise Text-to-SQL Agents**: [Fabric Data Agent vs Databricks AI/BI Genie vs Snowflake Cortex](comparisons/fabric-enterprise-data-agent-text2sql-fabric-genie-cortex-oss-faq.en.md)
- **Medallion Batch-Stream Unification**: [Bronze-Silver-Gold & Lambda / Kappa Selection Guide](comparisons/fabric-medallion-lakehouse-lambda-kappa-streaming-batch-architecture-faq.en.md)
- **5-Cloud TCO Inflection & Migration**: [5-Cloud Platform TCO & Zero-Downtime EDW Migration Guide](comparisons/fabric-five-cloud-data-platform-tco-inflection-migration-faq.en.md)
- **FinOps, Network Security & BCDR**: [Capacity FinOps & Surge Protection](comparisons/fabric-capacity-finops-surge-rayfin-vs-4clouds-faq.en.md) · [Managed VNet & Private Link](comparisons/fabric-private-link-managed-vnet-security-vs-4clouds-faq.en.md) · [Cross-Region BCDR & CMK](comparisons/fabric-bcdr-cross-region-cmk-recovery-vs-4clouds-faq.en.md) · [Multi-Cloud FOCUS 1.0 FinOps, AI Chargeback & SaaS ITAM](comparisons/fabric-enterprise-it-finops-cloud-cost-license-optimization-aiops-faq.en.md)

### B. Enterprise Industry Architecture Guides
- **Retail, Hospitality, E-Commerce & Supply Chain**: [Omnichannel Customer 360 & Store Replenishment](comparisons/fabric-retail-ecommerce-customer360-realtime-recommendation-agent-vs-4clouds-faq.en.md) · [Cross-Border Supply Chain & FinOps](comparisons/fabric-cross-border-ecommerce-global-supply-chain-finops-faq.en.md) · [QSR & Cold-Chain Dynamic Markdown](comparisons/fabric-qsr-fmcg-chain-store-operations-coldchain-markdown-faq.en.md) · [CPG Trade Promotion (TPO) & POS Demand Sensing](comparisons/fabric-cpg-beverage-trade-promotion-demand-sensing-hedging-faq.en.md) · [Luxury, Apparel & Footwear RFID & Returns](comparisons/fabric-luxury-apparel-footwear-merchandising-rfid-clienteling-returns-faq.en.md) · [160M-Member Composable CDP & Clean Room iROAS](comparisons/fabric-retail-loyalty-cdp-marketing-automation-cleanroom-attribution-faq.en.md) · [Hospitality & Cruise 9,200-Property Real-Time RevPAR, MICE RFP & 190M-Member Concierge](comparisons/fabric-hospitality-hotel-cruise-revenue-management-revpar-loyalty-concierge-faq.en.md)
- **Banking, Capital Markets, Insurance & Professional Services (Consulting/Legal)**: [Financial Research Hybrid RAG + NL2DAX](comparisons/fabric-financial-research-hybrid-rag-text2sql-wealth-agent-vs-4clouds-faq.en.md) · [Real-Time Fraud Graph & Claims](comparisons/fabric-banking-insurance-realtime-antifraud-graph-claims-faq.en.md) · [Consumer Credit & Collections](comparisons/fabric-retail-banking-consumer-credit-mortgage-collections-agent-faq.en.md) · [Corporate Banking ISO 20022, Trade Finance UCP 600 & pKYC](comparisons/fabric-corporate-commercial-banking-treasury-trade-finance-kyc-aml-faq.en.md) · [Asset & Wealth Mgmt Intraday Risk, Private Credit AI & 15K-RM Portal](comparisons/fabric-wealth-asset-management-portfolio-risk-esg-client-reporting-faq.en.md) · [Professional Services & Legal 180K-Practitioner PSA, WIP Realization & Ethical Wall AI](comparisons/fabric-professional-services-legal-psa-utilization-wip-billing-conflict-check-faq.en.md) · [Commercial P&C Insurance $38B GWP ACORD Triage, Subrogation & 10-Hop SIU Fraud AI](comparisons/fabric-commercial-insurance-p-and-c-underwriting-acord-subrogation-claims-faq.en.md)
- **Manufacturing, SAP ERP, EPC Construction, Commercial Real Estate & Automotive**: [Multi-ERP SAP S/4HANA ACDOCA Consolidation](comparisons/fabric-enterprise-erp-sap-s4hana-acdoca-treasury-finops-faq.en.md) · [Connected Vehicle & Supply Chain ATP](comparisons/fabric-manufacturing-automotive-supply-chain-connected-vehicle-maintenance-faq.en.md) · [Enterprise HR (Workday/SAP) Workforce Planning & Work IQ Skills](comparisons/fabric-enterprise-hr-people-analytics-workforce-planning-skills-copilot-faq.en.md) · [Enterprise Procurement S2P, Spend Cube & Contract AI](comparisons/fabric-enterprise-procurement-source-to-pay-supplier-risk-contract-ai-faq.en.md) · [B2B Wholesale 1.5M-SKU Dynamic CPQ, BOM Cross-Ref & SPA Rebates](comparisons/fabric-b2b-wholesale-distribution-dynamic-pricing-cpq-rebate-inventory-faq.en.md) · [EPC Construction $45B Backlog BIM 5D Cost Control, P6 Risk & FIDIC Change-Order AI](comparisons/fabric-epc-construction-bim-5d-schedule-risk-subcontractor-change-order-safety-faq.en.md) · [Commercial Real Estate & REITs 8,500-Building Smart BMS, Lease CAM Reconciliation & ESG AI](comparisons/fabric-commercial-real-estate-reit-smart-building-bms-lease-cam-esg-faq.en.md)
- **Healthcare, MedTech, Education, SaaS & Telecom**: [Healthcare Commercial Compliance & OMOP RWE](comparisons/fabric-healthcare-pharma-commercial-compliance-rwe-analytics-faq.en.md) · [Multi-Tenant SaaS Embedded BI](comparisons/fabric-saas-gaming-multitenant-embedded-analytics-retention-attribution-faq.en.md) · [Telecom Churn & 5G SLA](comparisons/fabric-telecom-customer-churn-network-ops-field-agent-faq.en.md) · [Life/Health Insurance AI Underwriting, PBM FWA & IFRS 17 CSM](comparisons/fabric-life-health-insurance-underwriting-pbm-pharmacy-fraud-actuarial-faq.en.md) · [Hospital Network Patient Flow, OR Scheduling & RCM Denials](comparisons/fabric-hospital-provider-network-patient-flow-revenue-cycle-denials-faq.en.md) · [Higher Education & EdTech 1.2M-Learner xAPI Adaptive Learning, Retention & Grant Compliance](comparisons/fabric-higher-education-edtech-adaptive-learning-student-retention-grant-compliance-faq.en.md) · [MedTech 680K-Device Connected Fleet Predictive RUL, FDA eMDR Vigilance & Field Service](comparisons/fabric-medtech-medical-device-connected-fleet-uptime-fda-mdr-field-service-faq.en.md)

---

## 3. 💎 Diamond Enterprise Demo Showcase (TCL × Fabric & Zava × Databricks)

1. **📺 TCL Global Channel IQ × Microsoft Fabric (6-Act Command Cockpit)**
   - **Architecture Flow**: `OneLake Shortcuts (Partner EDI 852)` → `Lakehouse & Warehouse` → `Eventhouse KQL` → `Fabric IQ Ontology (10 Entities + Contract Rules)` → `Data Agent + Operations Agent + Dispatch Pipeline`.
   - **Quantified Outcome**: Protects **`$629.7K`** EU Black Friday GMV via 48h France→Germany rebalance, saves **`$582.1K`** margin via soundbar bundle vs MSRP cut, and blocks **`$162.5K`** channel-stuffing rebate claims.
   - **Links**: [Launch 6-Act Cockpit](demos/tcl-fabric/index.en.html) · [Dual-Screen SA Playbook](demos/tcl-fabric/playbook.en.html)

2. **🛒 Zava Omnichannel Retail × Azure Databricks & Microsoft Fabric (4-Act Coexistence Workbench)**
   - **Architecture Flow**: `Lakeflow Declarative Pipelines (24 dirty rows quarantined)` → `Unity Catalog (mask_cn_phone CLS + YAML Metric View)` → `5-Turn AI/BI Genie` → `Mirrored Unity Catalog in OneLake` → `Power BI Direct Lake`.
   - **Quantified Outcome**: Isolates East China's **`-3.1pp`** margin drop to Kunshan Hub #2's **`17.3h`** dispatch bottleneck and triggers a **`1,460-case`** chilled rebalance from Jiaxing Hub #1 to Top-5 Shanghai/Suzhou flagship stores.
   - **Links**: [Launch 4-Act Workbench](demos/databricks-fabric/index.en.html) · [10-Dim SA Battlecard](demos/databricks-fabric/battlecard.en.html)

---

## 4. Verification

```bash
python -m unittest discover -s workshops/data-lab/tests -p "test_*.py"
```
- **Sealed Baseline (`reports/report.json`)**: `347 / 348` (Historic `DL-800` Scenario ID!) scenarios (`99.71%` accuracy, explicit `DL-23` single-region LRS human-escalation boundary), `207.6 ms` routing mean, **`178.72 ms` Sub-180ms ontology simulation mean (`n=83`, `625M = 25^2M` Vectors & `$65.25M` > `$65M` SLA!)**, `170 / 170` unit tests passing.
