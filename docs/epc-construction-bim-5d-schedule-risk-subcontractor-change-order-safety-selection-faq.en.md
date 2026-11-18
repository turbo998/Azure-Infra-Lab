# Engineering, Procurement & Construction (EPC) & Capital Projects ($45B Backlog + 320 Mega-Sites) BIM 5D Cost Control, Primavera P6 Schedule Risk AI, FIDIC Change-Order Auditing & Lien-Waiver Guardrail 5-Cloud Selection FAQ

> **Purpose**: A one-page executive decision guide for EPC COOs, VPs of Project Controls, Chief Quantity Surveyors (QS), Capital Project Directors, and Cloud & AI Solution Architects comparing **Microsoft Fabric** against **Databricks, Snowflake, Google BigQuery, and AWS**.  
> **Full 6-Part Deep-Dive**: [`workshops/data-lab/comparisons/fabric-epc-construction-bim-5d-schedule-risk-subcontractor-change-order-safety-faq.en.md`](../workshops/data-lab/comparisons/fabric-epc-construction-bim-5d-schedule-risk-subcontractor-change-order-safety-faq.en.md) | [中文版](./epc-construction-bim-5d-schedule-risk-subcontractor-change-order-safety-selection-faq.md)  
> **Visual Architecture SVG**: [`192-fabric-epc-construction-bim-5d-schedule-risk-subcontractor-change-order-safety-faq.svg`](../workshops/data-lab/assets/svg/192-fabric-epc-construction-bim-5d-schedule-risk-subcontractor-change-order-safety-faq.svg)

---

## 1. 📌 Executive Summary (30-Second Pitch)

For global Engineering, Procurement & Construction (EPC) contractors, hyperscale data-center builders, and infrastructure owners managing **`$45B` in active project backlog across `320` mega-sites**, **`24,000` subcontractors**, and **`15,700` project managers, quantity surveyors (QS), schedulers, and HSE safety engineers**, the core challenges are **45-day blind spots between Primavera P6 schedules, BIM 3D models, and SAP S/4HANA WBS cost ledgers (exposing projects to `$50K–$250K/day` in Liquidated Damages), inflated or duplicate subcontractor Change Orders (Variation Claims), and mechanics' lien double-payment exposure from releasing progress payments without verified Lien Waivers**:

- **Choose Microsoft Fabric (`F64` Reserved + Oracle Primavera P6 / Procore / SAP S/4HANA PS Open Mirroring `$0` CDC + Eventhouse KQL `4ms` Jobsite IoT/RFID Material Gate & BIM 5D Earned-Value SPI/CPI Stream + Azure SQL / Cosmos DB SSD DiskANN `604M` BIM IFC Spec, FIDIC Contract & RFI/Change-Order Vectors at `$3,280/mo` `-92%` RAM + In-Engine `PREDICT` Critical-Path Delay & Change-Order Validity Scoring + Foundry IQ Scope-Overlap Block, AIA G702 Lien-Waiver Gate & OSHA Safety Guardrail + `$0` Per-Seat BI / M365 Copilot for `15,700` Project Engineers & QS)** when you need an end-to-end **`16 ms` (`4ms + 4ms + 4ms + 4ms = 4^2 ms`)** BIM 5D project-control and change-order auditing loop at **`$15,200/mo` total TCO** (saving **`-$366.3K/mo` or `-96.0%`** vs. a `$381,500/mo` stitched stack), cutting critical-path slippage **`-31%`** and eliminating **`+$19.2M/yr`** in invalid change orders and liquidated damages.
- **Choose Azure Databricks** when civil engineering research teams train custom 3D LiDAR point-cloud segmentation models over 100TB+ of raw drone photogrammetry (coexisting zero-copy with Fabric via OneLake).
- **Choose Snowflake** when infrastructure owners and surety bond syndicates standardize on Snowflake Data Clean Rooms for cross-contractor cost-index benchmarking.
- **Choose Google BigQuery** when engineering firms are 100% standardized on Google Workspace and Vertex AI Search for static drawing archives.
- **Choose AWS Lakehouse** when jobsite telemetry stacks run exclusively on AWS IoT SiteWise and Amazon EKS with dedicated OpenSearch SRE teams.

---

## 2. 📊 5-Cloud EPC BIM 5D Cost Control, Schedule Risk & Change-Order AI Matrix

| Evaluation Dimension | Microsoft Fabric (`F64` + Eventhouse + `604M` DiskANN + Foundry IQ) | Databricks (`Lakeflow` + `Mosaic AI` + `Genie`) | Snowflake (`Snowpipe` + `Cortex` + `Enterprise`) | Google BigQuery (`Stream API` + `Vertex` + `Looker`) | AWS (`SiteWise` + `OpenSearch` + `QuickSight`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Jobsite IoT / RFID + P6/SAP Sync** | **Eventhouse KQL + P6/Procore/SAP Open Mirroring `4ms` (`$0` stream tax)** | Structured Streaming (`660ms–1.9s`) | Snowpipe + Dynamic Tables (`1.1s–3.1s`) | Storage Write API (`760ms–2.2s`) | IoT SiteWise + MSK (`800ms–2.4s`) |
| **`604M` BIM IFC Spec & FIDIC Vectors** | **SSD DiskANN at `$3,280/mo` (`-92%` RAM vs `$75,000/mo` DRAM)** | Mosaic Vector Search (`~$75,000/mo` DRAM) | Cortex Search (`~$77,500/mo` Credits) | Vertex Vector Search (`~$71,500/mo`) | OpenSearch Serverless (`~$73,500/mo` OCUs) |
| **Critical-Path `PREDICT` & Claim Audit** | **In-Lake `PREDICT` + `ai.extract` `4ms` (`-31%` delay, `+$19.2M/yr` saved)** | Model Serving + Batch (`530ms–1.5s`) | Snowpark ML + Cortex (`890ms–2.5s`) | BQML + Document AI (`700ms–2.0s`) | SageMaker + Textract (`750ms–2.2s`) |
| **FIDIC Scope Gate & Lien-Waiver Guard** | **Foundry IQ `4ms` blocks 115 unwaived payouts (`+$6.20M`) + Bid CLS** | Unity Catalog ABAC + custom logic | Horizon RLS/CLS + external rules | Policy Tags + custom code | Lake Formation + external gateway |
| **`15,700` PM / QS / HSE Portal Cost** | **`$0` Power BI Viewer + `$0` M365 Copilot token tax** | Extra BI licenses or SQL Warehouse scaling | Multi-cluster Warehouse credits for 15.7K users | Looker per-seat licensing fees | QuickSight per-user/session fees |
| **Monthly Total TCO** | **`$15,200 / mo` (Baseline Best, `-96.0%` savings)** | `~$371,000 / mo` | `~$398,000 / mo` | `~$362,000 / mo` | `~$368,000 / mo` |

---

## 3. 🛠️ Presales & Production Readiness Checklist

- [ ] **Zero-ETL Primavera P6, Procore & SAP S/4HANA PS Unification**: Enable Open Mirroring for P6 CPM schedules, Procore RFIs/change orders, and SAP WBS cost ledgers into OneLake alongside `995K EPS` Eventstream crane/concrete IoT and prefabricated module RFID gate scans.
- [ ] **`604M` BIM IFC Element, CSI Spec & FIDIC Contract SSD DiskANN Index**: Index BIM element schedules, Bill of Quantities (BOQ), CSI MasterFormat specs, and FIDIC clauses in SSD DiskANN (`$3,280/mo`) for `4ms` scope-overlap verification.
- [ ] **Foundry IQ Duplicate Change-Order & Lien-Waiver Guardrail (`SOP-192`)**: Enforce `EPC-BIM5D-CHANGE-ORDER-LIEN-WAIVER-SOP-192` to reject subcontractor change orders whose scope is already covered in the baseline BIM/BOQ, block AIA G702 progress payments lacking lower-tier Unconditional Lien Waivers, and dispatch `16ms` Teams approval cards to Project Directors and Quantity Surveyors.
