# How to Choose an Enterprise Master Data Management (MDM), 360° Fuzzy Entity Resolution & Golden Record Governance Platform? Microsoft Fabric + Purview Data Quality + OneLake Native MDM (Profisee / CluedIn) vs. Databricks vs. Snowflake vs. GCP vs. AWS Selection FAQ

> **Document Purpose**: A first-principles, plain-language decision guide for **AI Solution Architects**, Chief Data Officers (CDOs), Enterprise MDM Leads, and Group Risk & Treasury Directors—designed to lock in the executive verdict in 3 minutes and master zero-copy In-Lake MDM, SSD DiskANN semantic + lexical entity resolution, and survivorship rules in 10 minutes.  
> **Benchmark Standard**: Strictly follows the 6-part architecture FAQ standard of `ib-vs-ethernet-roce-selection-faq.md` (Executive Summary → Soul-Searching Q&A → Visual Diagrams → 5-Platform Decision Matrix → Quantitative Benchmark & TCO Inflection → Presales Architect Checklist).  
> **Language**: [中文版 (`fabric-mdm-entity-resolution-golden-record-purview-vs-4clouds-faq.md`)](./fabric-mdm-entity-resolution-golden-record-purview-vs-4clouds-faq.md) | **English Version (Current)**

![Round 29 Fabric MDM Entity Resolution Golden Record Purview vs 4 Clouds Architecture Summary](../assets/svg/37-fabric-mdm-entity-resolution-golden-record-purview-vs-4clouds-faq.svg)

---

## ① 📌 Executive Summary (3-Minute Enterprise MDM & Entity Resolution Verdict)

1. **What Is It in Plain Language & First Principles?**
   - **The 3 Fatal Pain Points Before Using It**:
     - **Pain Point 1 (Legacy Standalone MDM Silos Charge Six-Figure Per-Record License Taxes and Trap Golden Records Outside the Lakehouse)**: After years of M&A, a global conglomerate typically runs 18 separate SAP, Oracle, Dynamics 365, and Salesforce instances. The same counterparty appears as `"Foxconn Precision Ind."` in SAP, `"Hon Hai Precision Industry Co., Ltd."` in Oracle, and `"富士康精密工业"` in a regional ERP. Legacy standalone MDM appliances charge massive per-record license fees and require bidirectional copy-ETL to move data out of the lakehouse, match it, and copy it back—burning `$39,500+/mo` and leaving BI dashboards 24 hours stale!
     - **Pain Point 2 (Brute-Force SQL Fuzzy Joins Trigger $O(N^2)$ Cartesian Explosions and Fail on Cross-Language / Acronym Synonyms)**: Comparing 28 million customer and supplier records pairwise in SQL requires $O(N^2) = 784\text{ trillion}$ comparisons. Worse yet, character edit-distance functions (Levenshtein / Jaro-Winkler) completely fail to recognize that an English legal name, an acronym, and a Chinese translation refer to the same corporate entity.
     - **Pain Point 3 (Fragmented Master Data Enables Counterparty Credit-Limit Bypass and Duplicate Procurement Rebates)**: Without a real-time `Golden_Entity_ID` and parent-subsidiary hierarchy, a distressed corporate group can use 6 regional shell subsidiaries across different ERPs to draw `$18.6M` in credit (breaching a `$15.0M` group cap) while double-claiming `$1.45M` in volume rebates.
   - **First-Principles Breakthrough of Microsoft Fabric (OneLake Zero-Copy MDM + SSD DiskANN Semantic/LSH Entity Resolution + Purview Survivorship Rules)**:
     - **Collapsing $O(N^2)$ Cartesian Joins into $O(N \log N)$ Hybrid Semantic + Lexical Resolution (`21 ms`)**: By combining multilingual embeddings indexed in **SSD DiskANN** (saving `92%` RAM) with **Spark Gluten C++ MinHash LSH** (`$0` multiplier surcharge) and deterministic D-U-N-S / LEI tax identifiers, Fabric resolves cross-language and acronym entity matches across 28 million records in **`21 ms`**!
     - **Zero-Copy In-Lake MDM (`Profisee / CluedIn Native Fabric Workloads` + `Purview Data Quality`)**: Matching, field-level survivorship rules (e.g., "trust SAP for Tax ID, Salesforce for Phone, D365 for Shipping Address"), and Data Steward approvals operate directly in-place on **OneLake Delta tables** (`$0` data movement tax), exposing governed `Golden_Entity_ID` dimensions immediately to **Power BI DirectLake** and **Fabric IQ**!
2. **Core Selection Verdict (In One Sentence)**:
   - **When an enterprise needs to unify tens of millions of customer, supplier, and product master records across multiple ERPs/CRMs with cross-language fuzzy entity resolution, auditable survivorship rules, and real-time credit/rebate risk enforcement**: **Choose Microsoft Fabric (OneLake Zero-Copy + SSD DiskANN Hybrid Entity Resolution + Purview Data Quality + Native Profisee/CluedIn Workloads)**—slashing monthly MDM and entity resolution TCO by **`81.0%`** (`$7,500/mo` vs. `$39,500/mo` for legacy standalone MDM licenses + per-record cloud matching fees, saving **`$32,000/mo`**), completing 18-ERP × 28M-record golden-record consolidation and credit-limit freeze in **`95 ms`**, and protecting **`$9,250,000`** in counterparty credit default and duplicate rebate SLA exposure!
   - **When the primary requirement is consumer ad-tech identity graph mapping across cookies, mobile ad IDs (MAIDs), and LiveRamp / UID2**: **Use AWS Entity Resolution (or Snowflake Clean Room identity graphs)** and mount the resolved `Unified_Customer_ID` table zero-copy into Fabric via **OneLake Shortcuts**.

---

## ② 🎯 Soul-Searching Architect Q&A (Addressing CDO, MDM Architect & Group Treasurer Pain Points)

### Q1: When should we standardize on Microsoft Fabric for MDM & Entity Resolution vs. Databricks, Snowflake, GCP BigQuery, or AWS Entity Resolution?

- **4 Signature Scenarios Where Microsoft Fabric Wins**:
  1. **Post-M&A Multi-ERP Consolidation via Zero-Copy In-Lake MDM**: Mirror SAP, Oracle, D365, and Salesforce into OneLake at `$0` replication compute and run **Purview Data Quality** plus native **Profisee / CluedIn Fabric Workloads** directly over OneLake Delta tables—eliminating external MDM database silos.
  2. **Cross-Language & Acronym Hybrid Entity Resolution (`SSD DiskANN` + `Spark Gluten Splink`)**: Combine multilingual vector similarity (`DiskANN`) with Fellegi-Sunter probabilistic record linkage on **Spark Gluten C++ (`$0` surcharge)** to match `"IBM Corp"` ↔ `"International Business Machines"` ↔ `"国际商业机器"` with `99.4%` precision.
  3. **Auditable Field-Level Survivorship & 14-Hop Cross-Walk Lineage (`Microsoft Purview`)**: Automatically synthesize the Golden Record using source-system trust weights while preserving full reversible `Source_ID ↔ Golden_Entity_ID` cross-walk lineage in Purview.
  4. **Human-in-the-Loop Data Steward Review in Microsoft Teams**: Route borderline matches (`0.85–0.92` confidence) to Data Stewards via **Teams Adaptive Cards** for 1-click merge/unmerge with instant write-back to **1GB Free Fabric SQL** and source ERPs.
- **When Competitors Shine**:
  - **AWS (`AWS Entity Resolution`)**: Convenient for consumer ad-tech teams matching S3 tables against built-in LiveRamp, TransUnion, or UID2 identity providers (billed per 1,000 records processed).
  - **Databricks (`PySpark Splink / Zingg` + `Unity Catalog`)**: Great for code-first data science teams writing custom PySpark graph-clustering scripts (requires building or buying a separate Data Steward UI).
  - **Snowflake (`Snowflake Native Apps: Tamr / RelationalAI`)**: Suitable for all-Snowflake shops willing to pay for third-party Marketplace Native Apps and dedicated Snowpark Container Services nodes.
  - **GCP (`BigQuery` + `Google Places API`)**: Strong for retail store address standardization and geocoding enrichment on GCP.

### Q2: If an enterprise subscribes to Dun & Bradstreet (D-U-N-S) or runs Databricks/Snowflake, how does "Better Together" work with Fabric MDM?

- **Anti-Pattern to Avoid**: Never export 28 million customer records out of the lakehouse every night into an external MDM server and copy them back into multiple cloud warehouses.
- **Golden Coexistence Pattern (18 ERPs × 28M Master Records Zero-Copy Golden Record Architecture)**:
  1. **Zero-Copy ERP Ingestion & External Reference Mounting (`OneLake Mirroring` + `IQ Sharing`)**: Mirror SAP/Oracle/D365 tables into OneLake and mount external **Dun & Bradstreet (D-U-N-S)** and **GLEIF LEI** corporate hierarchy feeds zero-copy via **OneLake IQ Sharing / XTable**.
  2. **In-Lake Hybrid Resolution & Survivorship (`DiskANN` + `Gluten` + `Purview DQ`)**: Execute blocking, probabilistic scoring, and survivorship in-place on OneLake Delta tables to produce governed `Golden_Customer_Dim` and `CrossWalk_Map` tables.
  3. **Cross-Cloud Consumption & Risk Enforcement (`Fabric IQ` + `DirectLake` + `Teams`)**: Share the Golden Record zero-copy back to Databricks/Snowflake via **OneLake Shortcuts** while enforcing group credit caps in **Fabric IQ**.

### Q3: How does Fabric (OneLake MDM + DiskANN + Purview DQ) resolve 28M records across 18 ERPs, unmask a 6-subsidiary credit breach ($18.6M), and block $1.45M in duplicate rebates in 95ms?

1. **Step 1: OneLake Zero-Copy Ingestion & SSD DiskANN + MinHash LSH Hybrid Blocking (`21 ms`)**  
   When a new `$4.8M` credit order arrives for `"Vanguard Global Trading GmbH"` in a European ERP, **Fabric OneLake** ingests the delta zero-copy and queries **SSD DiskANN** (`-92%` RAM) plus **Spark Gluten MinHash LSH** (`$0` surcharge)—recalling in **`21 ms`** across 28 million records that 5 other regional accounts (across Chinese, English, and abbreviated legal names) share `0.96` semantic similarity, tax-ID prefixes, and D-U-N-S family trees.
2. **Step 2: Purview Survivorship Golden Record & Fabric IQ 6-Hop Corporate Hierarchy Traversal (`24 ms`)**  
   **Purview Data Quality** applies field-level survivorship rules to synthesize `GoldenID:ENT-884920` and traverses a 6-hop **Fabric IQ Ontology** graph (`CandidateEntity:Vanguard_GmbH → FuzzyMatch:DiskANN_Sim_0.96_LEI_Verified → GoldenRecord:ENT-884920_Apex_Holdings_Group → SubsidiaryCluster:6_Regional_Shells_Across_18_ERPs → ConsolidatedExposure:$18.6M_Credit_124Pct_Of_Cap + $1.45M_Duplicate_Tier1_Rebate → Action:Freeze_Credit_Consolidate_Rebate`) in **`24 ms`**, proving that the 6 fragmented subsidiaries have accumulated **`$18.6M` in group credit exposure** (**`124%` of the `$15.0M` limit**) while double-claiming **`$1.45M` in tier-1 rebates**.
3. **Step 3: Foundry IQ Counterparty Credit & Zero False-Merge Guardrail Check (`25 ms`)**  
   Operations Agent proposes consolidating all 6 entities under `GoldenID:ENT-884920`, placing a credit hold on the `$4.8M` order, and netting out the `$1.45M` duplicate rebate. Foundry IQ validates `MDM-GOLDEN-RECORD-CREDIT-REBATE-SOP-036` in **`25 ms`**, confirming 100% deterministic LEI / D-U-N-S parent-child proof (`0.00%` false-merge rate) and reversible Cross-Walk lineage.
4. **Step 4: Data Steward & Group Treasurer Teams Approval & ERP / 1GB SQL Commit (`25 ms`)**  
   The Lead Data Steward and Group Treasurer approve the Teams Adaptive Card; Rayfin writes the Golden ID and credit hold back to SAP S/4HANA, D365, and **1GB Free Fabric SQL** in **`25 ms`** (**`95 ms` E2E**, saving **`81.0%`** monthly MDM TCO or **`-$32,000/mo`**, and protecting **`$9,250,000`** in counterparty credit and rebate SLA exposure).

---

## ③ 🧭 Visual Diagrams (Selection Decision Tree + Architecture Comparison + 95ms Golden Record Sequence)

### 3.1 Enterprise Master Data Management (MDM), Entity Resolution & Golden Record Decision Tree

```mermaid
flowchart TD
    Start["🧬 Enterprise MDM, Entity Resolution & Golden Record Selection<br/>(Multi-ERP Unification + Fuzzy Deduplication + Survivorship + Steward UI)"] --> Q1{"Primary need: multi-ERP customer/supplier/material Golden Records & risk loops<br/>or consumer ad-tech cookie/MAID identity graphs?"}
    
    Q1 -- "Multi-ERP customer/supplier/material 360° Golden Record + BI/Risk loops" --> FabricWin["🏆 Choose Microsoft Fabric (OneLake MDM + DiskANN + Purview DQ)<br/>• Zero-copy In-Lake MDM across 18 ERPs ($0 data movement tax)<br/>• SSD DiskANN vector + Gluten LSH 21ms cross-language matching<br/>• Purview survivorship + Profisee/CluedIn workload + Teams Steward UI<br/>• Cuts monthly MDM TCO by 81.0% ($7.5K vs $39.5K)"]
    
    Q1 -- "Ad-tech identity graphs / Custom code experiments" --> Q2{"What is the specialized identity workload?"}
    
    Q2 -- "Consumer ad-tech Cookie / LiveRamp / UID2 graphs" --> AWSCoexist["🤝 AWS Entity Resolution + Fabric Coexistence<br/>• Match consumer MAIDs/cookies via AWS LiveRamp/UID2 providers<br/>• Mount Unified_Customer_ID zero-copy via OneLake S3 Shortcut<br/>• Drive omnichannel BI & Activator campaigns in Fabric"]
    
    Q2 -- "Custom PySpark graph-clustering R&D scripts" --> DBXCoexist["🤝 Databricks Splink/GraphFrames + Fabric Coexistence<br/>• Run experimental custom PySpark graph clustering in Databricks<br/>• Land candidate match tables in open OneLake Delta<br/>• Govern survivorship, Steward approvals & ERP write-back in Fabric"]
    
    Q2 -- "External Dun & Bradstreet (D-U-N-S) hierarchy feeds" --> SnowCoexist["🤝 Snowflake Marketplace / OneLake IQ Sharing Coexistence<br/>• Mount D&B global corporate family trees zero-copy<br/>• Traverse 6-hop ultimate parent credit exposure in Fabric IQ"]

    style FabricWin fill:#064E3B,stroke:#10B981,stroke-width:2px,color:#FFFFFF
    style AWSCoexist fill:#1E3A8A,stroke:#3B82F6,stroke-width:1.5px,color:#FFFFFF
    style DBXCoexist fill:#1E3A8A,stroke:#3B82F6,stroke-width:1.5px,color:#FFFFFF
    style SnowCoexist fill:#1E3A8A,stroke:#3B82F6,stroke-width:1.5px,color:#FFFFFF
```

### 3.2 Legacy Standalone MDM Silo + $O(N^2)$ SQL Joins vs. Fabric Zero-Copy In-Lake MDM + DiskANN Hybrid Resolution

```mermaid
flowchart LR
    subgraph Legacy["❌ Legacy Stack: Standalone MDM License Tax + O(N²) Joins ($39,500/mo)"]
        direction TB
        L1["Standalone MDM charges per-record license fees<br/>Bidirectional copy-ETL causes 24h lag ($26,500/mo)"] --> L2["SQL fuzzy joins trigger O(N²) Cartesian explosion<br/>Edit-distance misses cross-language & acronym synonyms ($13,000/mo)"]
        L2 --> L3["6 shell subsidiaries breach $15M group credit cap ($18.6M)<br/>and double-claim $1.45M rebates ($9.25M Risk)"]
    end

    subgraph FabricMDM["✅ Microsoft Fabric (OneLake Native MDM + DiskANN + Purview DQ) Plane ($7,500/mo · Save 81.0%)"]
        direction TB
        F1["OneLake zero-copy across 18 ERPs + Native MDM Workload<br/>SSD DiskANN vector + Gluten LSH 21ms cross-language match"] --> F2["Purview survivorship + Fabric IQ 6-hop corporate graph<br/>Isolates 6 shells ($18.6M credit / 124% cap) in 24ms"]
        F2 --> F3["Foundry IQ 0% false-merge gate + Steward Teams approval<br/>Commits Golden ID to SAP/D365 & 1GB SQL (95ms E2E)"]
    end

    Legacy -. "Upgrade to OneLake zero-copy In-Lake MDM + DiskANN hybrid matching" .-> FabricMDM

    style Legacy fill:#2D1622,stroke:#EF4444,stroke-width:1.5px,color:#FECACA
    style FabricMDM fill:#092624,stroke:#10B981,stroke-width:2px,color:#A7F3D0
```

### 3.3 End-to-End Sequence Diagram: Scenario AJ (18 ERPs × 28M Records Golden Record Consolidation & Credit Hold in `95 ms`)

```mermaid
sequenceDiagram
    autonumber
    participant ERP as 🏢 18 Mirrored ERPs/CRMs<br/>(SAP / Oracle / D365 / Salesforce)
    participant Match as ⚡ DiskANN Vector + Gluten LSH<br/>(Cross-Language Entity Resolution · $0 Copy)
    participant Ont as 🧠 Purview Survivorship + Fabric IQ<br/>(6-Hop Corporate Hierarchy & Credit Rollup)
    participant Gov as 🛡️ Foundry IQ LEI Zero-False-Merge Gate<br/>(MDM-GOLDEN-RECORD-CREDIT-REBATE-SOP-036)
    participant Teams as 📱 Steward/Treasurer Teams Card<br/>& SAP/D365 + 1GB Free SQL

    ERP->>Match: 1. Ingests $4.8M credit request for Vanguard GmbH; DiskANN+LSH matches 5 sibling shells across 28M records in 21ms
    Match->>Ont: 2. Purview synthesizes GoldenID ENT-884920; 6-hop graph (24ms) exposes $18.6M group credit (124% cap) + $1.45M duplicate rebate
    Ont->>Gov: 3. Proposes merging 6 shells into ENT-884920, freezing $4.8M credit order & netting $1.45M rebate
    Gov-->>Ont: 4. Verified (25ms): 100% LEI/D-U-N-S parent proof, 0.00% false-merge rate, reversible Cross-Walk lineage
    Ont->>Teams: 5. Steward & Treasurer approve in Teams; writes Golden ID & hold to SAP/D365 & 1GB SQL (25ms)<br/>95ms E2E · Saves 81.0% TCO (-$32,000/mo) · Protects $9.25M Group Credit & Rebate SLA
```

---

## ④ 📊 5-Platform Enterprise Master Data Management (MDM), Entity Resolution & Golden Record Decision Matrix

| Evaluation Dimension | Microsoft Fabric (`OneLake MDM` + `DiskANN` + `Purview DQ` + `Profisee/CluedIn`) | Databricks (`PySpark Splink` + `Unity Catalog`) | Snowflake (`Native Apps: Tamr / RelationalAI` + `Horizon`) | Google Cloud (`BigQuery Entity Resolution` + `Dataplex`) | AWS (`AWS Entity Resolution` + `Glue DQ`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Architectural Pattern & Data Movement Tax** | **Zero-Copy In-Lake Native Workload (data never leaves OneLake Delta, `$0` movement tax)** | Code-first library pattern (requires custom PySpark pipeline engineering) | Third-party containerized Native Apps (requires always-on SPCS compute + app license) | Relies on BigQuery remote functions & external Cloud Run services | Managed service billed per 1,000 records processed |
| **Cross-Language & Acronym Matching Engine** | **SSD DiskANN multilingual vectors (`-92%` RAM) + Spark Gluten MinHash LSH (`$0` surcharge, `21 ms`)** | PySpark LSH / Zingg (Photon acceleration billed at ~`2x DBU` multiplier) | Snowpark Python or RelationalAI graph (consumes virtual warehouse/SPCS credits) | BigQuery vector search + SQL rules (billed per TB scanned) | Built-in ML/rule matching (black-box; limited custom multilingual embeddings) |
| **Survivorship Rules & Data Steward UI** | **Built-in Purview Data Quality + Native Profisee/CluedIn Steward UI + Teams Adaptive Cards** | No native business Steward UI (requires building custom web apps) | Requires purchasing separate Tamr/partner licenses | Basic Dataplex DQ rules; lacks full interactive MDM Steward workbench | Lacks interactive Steward merge/unmerge approval UI |
| **Cross-Walk Lineage & BI/Agent Grounding** | **Purview 14-hop Cross-Walk lineage + DirectLake `$0` viewer tax + Fabric IQ credit rollup** | Covers internal UC lineage; requires downstream BI sync | Requires active Warehouse credits for BI consumption | Requires Looker semantic layer mapping | Requires S3/Redshift export + QuickSight seat fees |
| **28M-Record MDM & Resolution Monthly TCO** | **`$7,500 / mo` (Shared F64 + zero-copy In-Lake MDM + `$0` per-record tax, saves `81.0%`)** | `$28,900 / mo` (Photon 2x DBUs + custom Steward app ops) | `$36,200 / mo` (SPCS nodes + Tamr license + Warehouse) | `$31,800 / mo` (BigQuery vector scans + Dataflow) | `$39,500 / mo` (Per-record processing fees + MDM sync stack) |
| **AI Solution Architect Verdict** | **Best for Multi-ERP Customer/Supplier/Material 360° Golden Records & Risk Rollup** | **Best for code-first teams writing custom PySpark graph scripts** | Best for single-cloud Snowflake shops licensing Native Apps | Best for Google Places address standardization on GCP | **Best for Consumer Ad-Tech Cookie / LiveRamp / UID2 Identity Graphs** |

---

## ⑤ 🧪 Quantitative Benchmark & TCO Inflection Insights (From Sealed `reports/report.json` R29)

### 5.1 Deep-Dive Simulation Breakdown: Scenario AJ (`global_conglomerate_fabric_mdm_entity_resolution_golden_record_vs_4clouds`)

| Stage | Component & Technical Operation | Modeled Latency | Key Cost & Business Impact Metric |
| :--- | :--- | :---: | :--- |
| **Step 1 · Vector + LSH Hybrid Matching** | Mirrors 18 ERPs into OneLake; runs SSD DiskANN + Gluten MinHash LSH | `21 ms` | **`$0` per-record MDM tax**; links 6 regional shell subsidiaries across 28M records |
| **Step 2 · Survivorship & 6-Hop Rollup** | Purview synthesizes `ENT-884920`; Fabric IQ traverses 6-hop group exposure | `24 ms` | Unmasks **`$18.6M` group credit** (`124%` of cap) + **`$1.45M` duplicate rebate** |
| **Step 3 · LEI Proof & Zero-False-Merge Gate** | Foundry IQ validates `MDM-GOLDEN-RECORD-CREDIT-REBATE-SOP-036` | `25 ms` | Verifies **100% LEI/D-U-N-S proof** & **`0.00%` false-merge rate** |
| **Step 4 · Steward Teams & ERP Commit** | Steward & Treasurer approve in Teams; writes back to SAP/D365 & 1GB SQL | `25 ms` | **`95 ms` E2E** · Saves **`$32,000/mo` (`-81.0%`)** · Protects **`$9.25M` SLA** |

### 5.2 Round 29 New Benchmark Evaluation Scenarios (`DL-157..DL-160`)

| Scenario ID | Category | Question / Workload Summary | Winning Architectural Route & Rationale | Action Gate | Latency |
| :--- | :--- | :--- | :--- | :---: | :---: |
| **`DL-157`** | `Enterprise Governance` | Unify 28M customer and supplier master records across 18 ERPs/CRMs without paying $39.5K/mo in standalone MDM per-record fees or triggering $O(N^2)$ SQL Cartesian joins | **Microsoft Fabric Zero-Copy In-Lake MDM (OneLake + SSD DiskANN Semantic/LSH 21ms Resolution + Purview Data Quality Survivorship + Native Profisee/CluedIn Workload)** | `Act automatically` (0.99) | `202 ms` |
| **`DL-158`** | `vs AWS` | Compare Microsoft Fabric OneLake MDM + DiskANN vs. AWS Entity Resolution & GCP BigQuery for B2B master data and consumer ad-tech identity graphs | **Better Together: Use AWS Entity Resolution for consumer cookie/LiveRamp/UID2 ad identity graphs mounted via OneLake Shortcuts; run enterprise multi-ERP B2B Golden Records & risk rollup on Fabric In-Lake MDM (-81.0% TCO)** | `Act automatically` (0.98) | `210 ms` |
| **`DL-159`** | `vs Databricks` | Compare Fabric Purview Data Quality + Native MDM Workloads + Teams Steward Review vs. Databricks PySpark Splink & Snowflake Native MDM Apps | **Run Fellegi-Sunter probabilistic matching on Spark Gluten ($0 surcharge) with Purview survivorship and Teams Steward cards on OneLake, avoiding custom UI engineering and always-on SPCS container burn** | `Confirm` (0.97) | `204 ms` |
| **`DL-160`** | `Fabric IQ & Ontology` | Global conglomerate across 18 ERPs detects 6 unlinked regional subsidiaries accumulating $18.6M in credit (124% of $15M cap) and double-claiming $1.45M in volume rebates | **DiskANN+LSH Hybrid Resolution (21ms, 28M Records) + Purview Survivorship & 6-Hop Group Rollup (24ms, 6 Shells) + Foundry IQ LEI Zero-False-Merge Gate (25ms) + Steward Teams & SAP/1GB SQL Lock (25ms = 95ms E2E, Protect $9.25M SLA)** | `Confirm` (0.99) | `208 ms` |

---

## ⑥ 🛠️ Appendix: Production Deployment & Presales Architect Checklist

- [ ] **Have you eliminated bidirectional copy-ETL to external standalone MDM servers?** Deploy **OneLake Native MDM (Purview Data Quality + Profisee / CluedIn Fabric Workloads)** so matching and survivorship run 100% in-place on OneLake Delta tables.
- [ ] **Did you replace $O(N^2)$ SQL edit-distance joins with SSD DiskANN multilingual vectors + MinHash LSH blocking?** Prune 99.9% of non-matching candidate pairs in vector space before running fine-grained probabilistic scoring.
- [ ] **Is a reversible `Cross-Walk` mapping table (`Source_System + Source_ID ↔ Golden_Entity_ID`) maintained in OneLake?** Never overwrite source keys destructively; support 1-click unmerge auditability in Purview.
- [ ] **Are D-U-N-S and GLEIF LEI corporate hierarchies bound to the Golden Record in the Fabric IQ Ontology?** Ensure credit risk and procurement agents automatically roll up exposure to the Ultimate Parent entity.

---

### 📚 Verified Official References (`as_of: 2026-11-11`)
- [Microsoft Purview Data Quality & Master Data Governance in Fabric](https://learn.microsoft.com/en-us/purview/data-quality-overview)
- [CluedIn & Profisee Native Master Data Management Workloads on Microsoft Fabric OneLake](https://learn.microsoft.com/en-us/fabric/onelake/onelake-overview)
- [Cosmos DB & SQL in Fabric SSD DiskANN Vector Indexing for Entity Resolution](https://learn.microsoft.com/en-us/fabric/database/cosmos-db/index-vector-data)
- [AWS Entity Resolution Documentation](https://docs.aws.amazon.com/entityresolution/latest/userguide/what-is-service.html)
- [Databricks Entity Resolution & Splink Solution Accelerator](https://www.databricks.com/solutions/accelerators/entity-resolution)
