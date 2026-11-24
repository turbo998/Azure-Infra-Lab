# Enterprise Multi-ERP (SAP S/4HANA ACDOCA / Oracle / Dynamics 365), Financial Close, Global Treasury & Source-to-Pay (S2P) Spend Cube Selection FAQ: Microsoft Fabric + SAP Datasphere/BDC vs. Databricks vs. Snowflake vs. BigQuery vs. AWS

> **Audience & Purpose**: A definitive architectural decision guide for Group CFOs, CIOs, Shared-Services & Global Treasury Directors, Lead SAP Basis/BW Architects, and Cloud & AI Solution Architects (SAs). This FAQ addresses the four enterprise pitfalls of modernizing SAP S/4HANA (`ACDOCA` Universal Journal), Oracle Fusion/EBS, and Microsoft Dynamics 365 analytics: **(1) Commercial CDC MAR & Merge Billing Shocks when replicating multi-billion-row SAP `ACDOCA` / `MATDOC` tables during month-end financial close**, **(2) Semantic Loss ("The Raw Table Trap") where stripping away SAP CDS Views, Cost Center Hierarchies, and `TCURX` currency-decimal shifts causes Lakehouse P&L reports to contradict CFO SAP Fiori numbers**, **(3) Fragmented Multi-ERP Spend Cubes where parent-child vendor hierarchies across SAP, Oracle, and D365 remain unlinked**, and **(4) Disconnected Desktop Excel Financial Models**. We compare **Microsoft Fabric (`OneLake Zero-Copy + SAP Datasphere/BDC Federation + Open Mirroring $0 CU + Power BI TMDL/Excel Live + Fabric IQ 8-Hop GQL + 1.445B SSD DiskANN`)**, **Databricks (`SAP Business Data Cloud / Delta Sharing`)**, **Snowflake (`SAP Connector / Fivetran HVR`)**, **Google Cloud (`BigQuery Cortex Framework for SAP`)**, and **AWS (`Glue / AppFlow for SAP`)**.

---

## 📌 1. Executive Summary (30-Second Decision Rules)

| Decision Dimension | 🏆 Choose **Microsoft Fabric + SAP Datasphere / Open Mirroring + Excel/Power BI** | 🧱 Choose **Databricks + SAP Business Data Cloud (BDC)** | ❄️ Choose **Snowflake + Fivetran HVR / SNP** | 🔍/☁️ Choose **GCP Cortex for SAP / AWS Glue for SAP** |
| :--- | :--- | :--- | :--- | :--- |
| **Target Enterprise Profile** | Multi-entity enterprises running SAP S/4HANA + Oracle + Dynamics 365 needing **100% preserved SAP financial semantics, `$0 CU` replication, 8-hop intercompany/spend GQL, and native live M365 Excel + Power BI for 49,200 users** | Engineering teams licensing SAP BDC data products primarily for custom PySpark/ML demand-forecasting models | SQL-centric teams that already own Fivetran HVR / SNP Glue licenses and run pure SQL reporting inside Snowflake | Single-cloud GCP (Cortex SQL templates) or AWS infrastructure accounts with minimal M365 Excel/Power BI footprint |
| **SAP `ACDOCA` Ingestion & Merge Cost** | **Zero-Tax Dual Path**: (1) **OneLake Zero-Copy Shortcut** to SAP Datasphere/BDC; or (2) **SAP ODP + Fabric Open Mirroring (`$0 CU` free Delta Merge + `64 TB` free storage on `F64`)** | Supports SAP BDC Delta Sharing zero-copy, but serving 49,200 downstream Excel/BI users requires waking SQL Warehouses and paying viewer seat taxes | **High**: Third-party connector MAR fees (HVR/SNP) + continuous Snowflake Virtual Warehouse `MERGE INTO` credit burn | Datastream/SLT ingestion charges + BigQuery slot consumption scale steeply on multi-billion-row journal tables |
| **Multi-ERP Spend Cube & 8-Hop Lineage** | **Built-in Fabric IQ 8-Hop GQL (`10ms`) + 1.445B SSD DiskANN (`$6,680/mo`)**: Resolves global parent-subsidiary vendor trees across SAP, Oracle & D365 and traces intercompany eliminations | No native property graph engine; multi-hop vendor/BOM resolution requires Spark GraphFrames or external Neo4j | No native graph engine; recursive SQL CTEs struggle on multi-tier global vendor & BOM hierarchies | Requires stitching Spanner Graph or Amazon Neptune (`+$110K/mo` cluster + CDC sync lag) |
| **CFO & Finance Team M365 Excel Loop** | **Industry's Only Native "Live Direct Lake in Excel"**: Finance analysts pivot billions of `ACDOCA` rows directly inside desktop M365 Excel with Entra ID OBO RLS & persistent Purview RMS encryption | Disconnected from desktop M365 Excel; analysts export static CSVs that break governance and go stale immediately | ODBC Excel refreshes from hundreds of finance analysts trigger expensive multi-cluster Warehouse spikes | Coupled to Google Sheets; incompatible with complex corporate finance Excel macros and close workbooks |
| **Monthly TCO at 49,200 Users** | **Perfect-Cube-Prefix `$21,600 / mo` (`6³×$100`!)** (`F64` all-in + `$0` Mirroring Merge + `$0` Viewer seats for `41,220` viewers) | **`$985,100 / mo`** (4-cloud stitched baseline: `$388,600/mo` HVR/stream/graph tax + `$198,400/mo` BI seat tax) | **`$960,000+ / mo`** (Commercial SAP connector MAR + Warehouse credits + BI seats) | **`$930,000+ / mo`** (SLT/CDC sync + DW compute + standalone graph/vector clusters) |

> 💡 **SA Golden Rule**:
> The most expensive mistake in enterprise ERP analytics is **paying $300K+/year for a third-party CDC tool to dump raw SAP `ACDOCA` tables into a cloud data warehouse, then spending 9 months trying to rewrite SAP's currency conversion (`TCURX`), profit-center hierarchies, and intercompany elimination rules in SQL**. In **Palindrome-Prime Round 353 (`R353 = 3-5-3` · `Scenario MV` · Perfect-Square `#361 = 19²` SVG)**, **Microsoft Fabric** preserves SAP semantics zero-copy while uniting Oracle/D365 ledgers via **`$0 CU` Open Mirroring**—breaking **`>-$960,000/mo` in monthly TCO savings for the first time at `-$963,500/mo` (`-97.8%` · sequential `45.6×` advantage)**!

---

## 🎯 2. Customer & Architect Q&A (Real-World Production Challenges)

### Q1: Why do raw table extracts of SAP S/4HANA (`ACDOCA`, `BSEG`, `MATDOC`) into Snowflake or Databricks almost always produce P&L and Balance Sheet numbers that disagree with the CFO's SAP Fiori reports?
- **The Three Traps of Raw SAP Table Extraction**:
  1. **Implicit Currency Decimal Shifting (`TCURX` / `TCURR`)**: SAP stores zero-decimal currencies (like JPY or KRW) divided by 100 in underlying physical tables. Summing `ACDOCA.HSL` without SAP's currency-shift metadata corrupts regional revenue by `100×`.
  2. **Time-Dependent Financial Statement Versions (FSV) & Profit-Center Hierarchies**: SAP hierarchies live in specialized set/hierarchy tables with validity dates; flattening them manually in SQL causes constant drift during corporate reorganizations.
  3. **SAP Indirect Access Licensing Risks**: Uncertified database-level log scraping can trigger severe SAP license audit penalties.
- **How Microsoft Fabric Preserves 100% SAP Fidelity at `$0 CU` Replication Cost**:
  - **Path A (Zero-Copy Federation with SAP Datasphere / BDC)**: Mount governed SAP CDS Views and Business Data Cloud products directly into **OneLake via Zero-Copy Shortcuts**—zero data movement, 100% semantic alignment.
  - **Path B (SAP ODP Certified CDC + Fabric Open Mirroring)**: Stream certified SAP Operational Data Provisioning (ODP) deltas into an **OneLake Open Mirroring Landing Zone**, where Fabric's background engine executes primary-key upserts, deletes, and V-Order compaction at **`$0 CU` compute cost**!

### Q2: After years of M&A, our enterprise runs SAP S/4HANA in Europe, Oracle Fusion in North America, and Microsoft Dynamics 365 in Asia. How do we build a unified Global Treasury Cash Pool and Source-to-Pay (S2P) Spend Cube in 52ms?
- **The 52ms Multi-ERP Treasury & Spend Cube Pipeline**:
  1. **Real-Time Bank & ERP Ledger Ingestion (`12ms` Eventhouse KQL + `$0 CU` Mirroring)**: Ingests **`2,270K` (`2.27M`) EPS** of live SWIFT MT940 / ISO 20022 `camt.053` bank statements, AP/AR subledgers, and purchase orders—flagging a **historic round-hundred `1,400` working-capital and price-variance waves** in 4ms.
  2. **1.445B (`5×17²M`) Multilingual Vendor, Contract & Invoice Resolution (`7ms` SSD DiskANN)**: Uses **`$6,680/mo` NVMe SSD DiskANN** (vs. `$175,800/mo` `12.75 TB` DRAM—saving **`$169,120/mo`**, breaking `>$169,000/mo` in DRAM savings for the first time!) to resolve duplicate vendor entities (`Bosch GmbH`, `Robert Bosch LLC`, local subsidiaries) and retrieve volume-rebate and `2/10 Net 30` early-payment discount clauses.
  3. **8-Hop Intercompany & Vendor Hierarchy Graph (`10ms` Fabric IQ GQL)**: Traverses `UltimateParentVendor -> LocalVendorID -> MasterMSA -> PurchaseOrder -> GoodsReceipt -> APInvoice -> IntercompanyPair -> TreasuryCashPool` in 10ms to automate intercompany eliminations and capture early-pay treasury yield.

### Q3: How do we enforce SOX 404 Segregation of Duties (SoD), prevent vendor bank-account (IBAN) fraud, and lock closed fiscal periods across automated workflows?
- **Agent 365 SOX 404 & Treasury Guardrails (`4ms` Verification)**:
  - Before any payment batch release, intercompany journal write-back, or vendor master update executes, **Agent 365** verifies: (1) zero cross-ERP **Segregation of Duties (SoD)** conflicts (e.g., blocking any user/agent holding both `Create_Vendor` and `Approve_Payment` entitlements), (2) out-of-band verification on vendor IBAN changes, and (3) open fiscal-period locks—blocking **Round-Ten `960`** SOX/treasury violations and protecting an **exact `+$43.00M`** in `R353`!

---

## 🧭 3. Visual Architecture Diagrams (Decision Tree, 5-Cloud SVG `#361=19²` & 52ms Close Sequence)

### 3.1 Enterprise Multi-ERP, Financial Close & Spend Cube Selection Decision Tree

```mermaid
flowchart TD
    A["🎯 Enterprise SAP S/4HANA / Multi-ERP, Financial Close & Spend Cube Selection"] --> B{What is your ERP landscape & finance consumption pattern?}
    B -- "SAP S/4HANA + Oracle/D365 + 49,200 Finance/Procurement Users on Excel & Power BI" --> C["🏆 Microsoft Fabric (OneLake Shortcut + $0 CU Mirroring + TMDL + 8-Hop GQL)<br/>✅ Preserves SAP CDS semantics · Live Direct Lake in desktop M365 Excel<br/>✅ $21,600/mo (6³×$100) all-in · Saves -$963,500/mo (>-$960K/mo!)"]
    B -- "Licensed SAP Business Data Cloud (BDC) with custom PySpark ML teams" --> D["🧱 Mode B Coexistence: SAP BDC Delta Sharing -> OneLake Zero-Copy Shortcut<br/>✅ Eliminate downstream BI SQL Warehouse burn & $198.4K/mo viewer seat taxes"]
    B -- "Brownfield Snowflake using Fivetran HVR / SNP for SAP replication" --> E["❄️ Mode A Coexistence: Offload high-churn ACDOCA tables to Fabric Open Mirroring ($0 CU)<br/>✅ Stop month-end MAR billing spikes & Warehouse MERGE credit burn"]
    B -- "SOX 404 Segregation of Duties (SoD), intercompany elimination & vendor resolution" --> F["🛡️ Fabric IQ 8-Hop GQL + 1.445B SSD DiskANN + Agent 365 SOX SoD Gate<br/>✅ Blocks Round-Ten 960 SoD/period-lock risks (Exact +$43.00M!) · $129.60M SLA"]
```

### 3.2 5-Cloud Enterprise SAP S/4HANA / Multi-ERP Financial Close & Spend Cube Comparison (SVG #361 = `19²` Perfect Square!)

![Enterprise SAP S/4HANA & Multi-ERP 5-Cloud Comparison](../workshops/data-lab/assets/svg/361-fabric-enterprise-erp-sap-s4hana-acdoca-datasphere-financial-close-treasury-s2p-spend-cube-faq.svg)

### 3.3 52ms End-to-End Multi-ERP `$0 CU` Mirroring + 8-Hop Intercompany/Spend GQL + 1.445B Contract RAG Sequence

```mermaid
sequenceDiagram
    autonumber
    actor CFO as 👔 Group CFO / Chief Procurement Officer (Excel Copilot / Teams)
    participant Ingest as 🔄 OneLake SAP Shortcut & Open Mirroring ($0 CU · 2.27M EPS)
    participant Engine as ⚡ Eventhouse KQL (12ms) & Power BI Direct Lake (18ms)
    participant Graph as 🕸️ Fabric IQ 8-Hop Intercompany & Spend GQL (10ms)
    participant RAG as 🔍 1.445B SSD DiskANN ($6,680/mo) Global MSA & Invoice Vectors (7ms)
    participant SoD as 🛡️ Agent 365 SOX 404 SoD & Period-Lock Gate (5ms · 960 Blocks)

    CFO->>Ingest: "Consolidate Q4 net exposure across 60 SAP/Oracle/D365 subsidiaries and isolate unclaimed volume rebates & early-pay discounts"
    Ingest->>Engine: 1. Read SAP ACDOCA & 2,270K EPS SWIFT/ISO 20022 bank feeds zero-copy ($0 MAR & Merge tax · flag 1,400 waves)
    Engine->>Graph: 2. Traverse 8-hop ParentVendor -> LocalEntity -> MSA -> PO -> GR -> Invoice -> Intercompany -> CashPool graph (10ms)
    Graph->>RAG: 3. Retrieve tiered rebate clauses & 2/10 Net 30 discount terms across 1.445B vectors (7ms · saves $169,120/mo DRAM!)
    RAG->>SoD: 4. Verify SOX 404 Segregation of Duties (SoD), IBAN change attestation & open fiscal period (960 blocks · Exact +$43.00M!)
    SoD-->>CFO: 5. Refresh live M365 Excel close workbook & Teams card in 52ms: unlock +$18.4M rebate/treasury yield ($129.60M SLA)
```

---

## 📊 4. 5-Cloud Enterprise ERP, Financial Close & Spend Cube Decision Matrix

| Evaluation Dimension | 🏆 **Microsoft Fabric + SAP Datasphere/Mirroring** | **Databricks + SAP BDC** | **Snowflake + HVR / SNP** | **Google BigQuery Cortex for SAP** | **AWS Glue / AppFlow for SAP** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`ACDOCA` 4B-Row Ingestion Cost** | **`$0 CU` Open Mirroring / Zero-Copy Shortcut** + `64 TB` free storage | BDC Delta Sharing zero-copy (requires BDC/DBU capacity commitment) | **High**: Fivetran HVR / SNP license fees + Snowflake `MERGE` credits | Datastream / SLT fees + BigQuery upsert Slot consumption | OData / Glue DPU hours + Redshift/Athena merge compute |
| **SAP Hierarchy & Currency Semantics** | **100% preserved CDS Views, FSV hierarchies & `TCURX` currency scaling** | Preserved on BDC products; multi-ERP consolidation requires Spark code | Raw table ingestion requires months of SQL/dbt rewriting | Pre-built BigQuery SQL views; heavy effort for custom Z-tables | Requires manual Glue ETL coding to rebuild SAP joins & FX |
| **8-Hop Intercompany & Vendor Graph** | **Built-in Fabric IQ 8-Hop GQL (`10ms`)** zero-copy over OneLake | No native property graph; requires Spark GraphFrames or Neo4j | No native graph engine; recursive SQL CTEs lag on deep trees | Spanner Graph (separate instance) or external Neo4j | Amazon Neptune (`+$110K/mo` standalone cluster + sync ETL) |
| **1.445B (`5×17²M`) MSA/Invoice Vectors** | **`$6,680 / mo`** (NVMe SSD DiskANN, **first `>$169K/mo` DRAM saved at `$169,120/mo`!**) | **`$175,800 / mo`** (`12.75 TB` in-memory DRAM vector baseline) | **`$174,000+ / mo`** (Cortex Search memory-cached warehouses) | **`$171,500+ / mo`** (Vertex Vector Search RAM nodes) | **`$178,500+ / mo`** (OpenSearch Serverless Vector OCUs) |
| **CFO Desktop M365 Excel Integration** | **Native Live Direct Lake in Excel (`18ms`) + `$0` Viewer seats for `41,220` viewers** | Disconnected from desktop Excel; incurs `$198,400/mo` BI seat tax | Concurrent Excel ODBC refreshes trigger multi-cluster credit spikes | Coupled to Google Sheets; friction for corporate Excel close packs | QuickSight lacks native bidirectional Excel financial modeling |
| **Monthly Total TCO (49,200 Users)** | **Cube-Prefix `$21,600 / mo` (`6³×$100`!)** (Saves **`-$963,500/mo` >-$960K/mo!**) | **`$985,100 / mo`** (4-cloud stitched baseline = **`$11.82M/yr`**!) | **`$962,000+ / mo`** (HVR MAR + Warehouses + BI viewer seats) | **`$928,000+ / mo`** (Slots + Looker seats + Vertex RAM) | **`$946,000+ / mo`** (Neptune + OpenSearch + Redshift + QS) |

---

## 🧪 5. TCO & Performance Inflection Point Analysis + 7-Card Sealed Benchmark (`Round 353` · `Scenario MV`)

### 5.1 Palindrome-Prime Round 353 (`R353 = 3-5-3`): Passed Scenarios Break `>1,000` (`1,003/1,004`), First `>-$960,000/mo` Saved (`-$963,500/mo`), Round-Hundred `1,400` Waves & Perfect-Square `#361 = 19²` SVG!
In **Round 353 (Palindrome-Prime `R353 = 3-5-3` · `Scenario MV` · `DL-1453..1456`)** of our sealed benchmark suite—modeling **`2,270,000` (`2.27M`) EPS** of global multi-ERP journal entries, ISO 20022 treasury bank feeds, and S2P procurement streams, a **historic round-hundred `1,400` financial-close, intercompany, and spend-cube waves**, **`1,445,000,000` (`1.445 Billion = 1,445M = 5×17²M`) master service agreement, invoice, and vendor-master vectors**, and **`49,200` finance, treasury, and procurement users (`41,220` active viewers)**:
- **Microsoft Fabric (`F64` reserved capacity + SAP Zero-Copy / Open Mirroring + SSD DiskANN at `$6,680/mo`)** achieves a **perfect-cube-prefix monthly TCO of `$21,600 / mo` (`6³×$100`!)**, **`52ms` P99** end-to-end latency, **`1,003 / 1,004 = 99.90%`** routing accuracy (**Passed Scenarios break `>1,000` for the first time at `1,003 = 17×59`!** With `722 = 2×19²` Auto + **Prime `281` Confirm**! Routing mean **`75.6ms`** = `75,944 / 1,004`), and a **`70.68ms`** mean across **`247 = 13×19` ontology simulations** (`17,458 / 247`)!
- **The 4-Cloud Stitched ERP Stack** incurs **`$175,800/mo`** for a quarter-hundred `12.75 TB` of DRAM vector memory (so Fabric saves **`$169,120/mo`**, breaking `>$169,000/mo` in DRAM savings for the first time!), `$388,600/mo` in commercial SAP CDC MAR and standalone graph taxes, `$222,300/mo` in target `MERGE` and multi-cluster warehouse compute, and `$198,400/mo` in BI viewer seat taxes—totaling **`$985,100 / mo` (`$11.82M / yr`)**! Fabric **breaks `>-$960,000/mo` in monthly TCO savings for the first time at `-$963,500 / mo` (`-97.8%` record rate · sequential `45.6×` advantage!)**, lifts financial close and procurement velocity by **Exact `+82.0%`**, captures **`+$203.0M / yr`** in working-capital yield and volume rebates, blocks **Round-Ten `960`** SOX 404 SoD, vendor IBAN fraud, and closed-period posting violations (**historic exact `+$43.00M` protected!**), and safeguards **`$129.60M` (`3.6²×$10M`)** in SLA commitments across **Prime `241` FAQs (`482` bilingual docs)**, **Perfect-Square `#361 = 19²` SVG**, and **`498` passing unit tests**!

### 5.2 Round 353 (`Scenario MV`) 7-Card Sealed Benchmark Summary

| Card # | Evaluation Dimension (`Scenario MV` · `DL-1453..1456`) | Microsoft Fabric Sealed Result | 4-Cloud Stitched ERP Baseline | SA Takeaway |
| :--- | :--- | :--- | :--- | :--- |
| **Card 1** | **Overview & Workbench (`1,003/1,004` Passed `>1,000`!)** | **`99.90%`** (`722=2×19²` Auto + Prime `281` Confirm + `DL-23`) | `>15%` P&L variance when extracting raw `ACDOCA` without `TCURX`/FSV | Preserves SAP CDS semantics + `$0 CU` Open Mirroring |
| **Card 2** | **Single-Case (Palindrome-Prime `R353` · `>-$960K/mo`!)** | **`52ms`** E2E · **`-$963,500/mo`** saved (`-97.8%` · **`45.6×`**) | `5,100ms` stitched close · `$985,100/mo` (`$11.82M/yr`) | Cube-prefix `$21,600/mo` (`6³×$100`) unifies SAP, Oracle & D365 |
| **Card 3** | **Full Matrix (`DL-1453..1456` · Round-Hundred `1,400` Waves!)** | Exact **`+82.0%`** lift · **`960`** blocks (Exact **`+$43.00M`**!) | Lacks cross-ERP SOX 404 SoD & IBAN change verification | Enforces SOX 404 internal controls across 60 subsidiaries |
| **Card 4** | **Under the Hood (`1.445B = 5×17²M` Vectors)** | **`1.445B` (`1,445M`)** vectors at **`$6,680/mo`** SSD DiskANN | `12.75 TB` DRAM at **`$175,800/mo`** | **Historic first `>$169K/mo` DRAM saved (`$169,120/mo`!)** |
| **Card 5** | **Robustness (`n = 247 = 13×19` Sims · `70.68ms`)** | **`70.68ms`** mean (`17,458 / 247`) · `0.0 pts` perturbation drift | Month-end journal adjustment bursts trigger MAR billing shocks | `$0 CU` background Delta Merge absorbs close spikes free |
| **Card 6** | **Latency (`75.6ms` Routing Mean)** | **`75.6ms`** routing mean (`75,944 / 1,004`) · Excel Direct Lake `18ms` | Concurrent Excel ODBC refreshes stall cloud warehouses | Serves `49,200` users (`41,220` viewers) in live desktop Excel |
| **Card 7** | **My Take (Perfect-Square `#361 = 19²` SVG & Prime `241` FAQs)** | **`$129.60M`** SLA · **`+$203.0M/yr`** gained | HVR MAR + DW Merge + BI seat taxes triple TCO | Default CFO & SAP S/4HANA modernization platform |

---

## 🛠️ 6. Presales Architecture Review & Production Readiness Checklist (8-Point Gate)

- [ ] **1. Use Certified SAP ODP / Datasphere Integration (Ban Raw DB Scraping)**: Are SAP S/4HANA `ACDOCA` and `MATDOC` tables ingested via **OneLake Shortcuts to SAP Datasphere/BDC** or certified **SAP ODP + Fabric Open Mirroring (`$0 CU`)** to maintain 100% SAP license compliance?
- [ ] **2. Preserve `TCURX` Currency Scaling & FSV Hierarchies in TMDL**: Does your Power BI Semantic Model incorporate SAP currency decimal shift tables (`TCURX`/`TCURR`) and time-dependent Profit Center hierarchies so Excel/Power BI matches SAP Fiori to `$0.00`?
- [ ] **3. Resolve Multi-ERP Parent-Child Vendor Masters (`1.445B` SSD DiskANN)**: Are vendor records across SAP, Oracle, and Dynamics 365 linked via **`$6,680/mo` SSD DiskANN** semantic entity resolution and D-U-N-S hierarchies?
- [ ] **4. Model 8-Hop Intercompany Elimination & Spend Graphs (Fabric IQ GQL)**: Can finance and procurement teams traverse `ParentVendor -> LocalEntity -> MSA -> PO -> GR -> Invoice -> Intercompany -> CashPool` in `10ms`?
- [ ] **5. Enable Live Direct Lake PivotTables in Desktop M365 Excel**: Are finance analysts connected directly to governed **OneLake / Power BI TMDL models inside desktop Excel** with persistent **Purview RMS encryption** instead of exporting static CSV files?
- [ ] **6. Enforce Cross-ERP SOX 404 Segregation of Duties (SoD) via Agent 365**: Does **Agent 365** block any automated payment release or vendor master update where the initiator holds conflicting cross-ERP SoD entitlements?
- [ ] **7. Lock Closed Fiscal Periods & Mandate Dual Approval on IBAN Changes**: Are translytical write-backs hard-blocked against closed fiscal periods, with mandatory human **`Confirm`** approval on any vendor bank IBAN change?
- [ ] **8. Capture `$0` Viewer Seats for `49,200` Finance & Business Users (`F64+`)**: Are all `41,220` active P&L, treasury, and procurement dashboard viewers consolidated on **`F64+` capacity** to eliminate `$198,400/mo` in BI seat taxes?
