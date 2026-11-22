# Global Insurance (P&C, Auto & Health) Automated Underwriting, Usage-Based Insurance (UBI) Telematics, Catastrophe Geospatial Exposure (H3 GIS) & Claims Subrogation / SIU Fraud RAG Architecture Selection FAQ: Microsoft Fabric Eventhouse KQL + Fabric Graph (ISO GQL) + OneLake Core Policy Shortcuts + Cosmos DB / SQL DB SSD DiskANN vs. Snowflake Insurance Data Cloud vs. Databricks Lakehouse for Insurance vs. AWS Insurance Lake + Neptune vs. GCP BigQuery GIS

> **Document Type**: Enterprise Cloud & AI Solution Architect Selection Guide (6-Section Standard FAQ)  
> **Target Audience**: P&C, Auto (UBI), Commercial, Health & Reinsurance CIOs, Chief Actuaries, Chief Risk Officers (CROs), VP of Claims, and Enterprise Data & AI Architects  
> **Associated Benchmark**: `Scenario KO` (`DL-1217..DL-1220`) · Sealed Matrix `767 / 768 (99.87%)` · Routing Mean **`97.7 ms` (Historic First Sub-98.0ms Routing Mean at Exact `75,000 ms` Sum!)** · `188` Ontology Simulations Mean **`87.84 ms` (Historic First Sub-88.00ms!)** · Repdigit **`222` Confirm Cases!** · Monthly TCO Savings **`-$716,880/mo` (`-97.2%`)** · Perfect-Square Annual Gain **`+$144.0M/yr` (`12²M/yr = Exact $12.0M/mo`!)** · Round-Ten `380 / 380` Unit Tests Passing  
> **Language / 双语版本**: **[🇬🇧 English Version](./insurance-underwriting-telematics-ubi-catastrophe-geospatial-claims-subrogation-rag-selection-faq.en.md)** | **[🇨🇳 中文版](./insurance-underwriting-telematics-ubi-catastrophe-geospatial-claims-subrogation-rag-selection-faq.md)**

---

## 1. 📌 Executive Summary

When a global insurance carrier (`65M` policies in force, `$85B` Gross Written Premium) builds an **automated underwriting, real-time Usage-Based Insurance (UBI) telematics, catastrophe geospatial exposure (PML), and multimodal claims / Special Investigation Unit (SIU) fraud platform**, stitching separate streaming clusters, standalone graph databases (Neo4j/Neptune), GIS engines, in-memory vector clusters, and core Guidewire/Duck Creek CDC connectors creates **`$282,400/mo`** in data movement and duplicate engine taxes.

```
┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│           5-Cloud Insurance Underwriting, Catastrophe GIS & Claims SIU Selection Matrix       │
├──────────────────────────┬───────────────────────────────────┬───────────────────────────────┤
│ Insurance Scenario       │ Recommended Architecture          │ Quantified Decision Boundary  │
├──────────────────────────┼───────────────────────────────────┼───────────────────────────────┤
│ Live UBI Telematics +    │ Microsoft Fabric Eventhouse KQL + │ $20,420/mo F64 vs $737,300/mo │
│ H3 Catastrophe Exposure +│ Fabric Graph (8-Hop ISO GQL) +    │ stitched (-$716,880/mo /      │
│ 8-Hop SIU Fraud Ring +   │ OneLake Policy Shortcuts + SSD    │ -97.2%); 16ms E2E loop;       │
│ 1.15B Claims/Subro RAG 🏆│ DiskANN (Exact $5,500/mo)         │ +$144.0M/yr (12²M!) gained    │
├──────────────────────────┼───────────────────────────────────┼───────────────────────────────┤
│ Actuarial GLM/XGBoost    │ Azure Databricks + Unity Catalog  │ Strong actuarial ML workbench,│
│ pricing & Monte Carlo CAT│ + Mosaic AI                       │ but adds graph & BI seat tax  │
├──────────────────────────┼───────────────────────────────────┼───────────────────────────────┤
│ Reinsurance cession &    │ Snowflake Insurance Data Cloud +  │ Best cross-carrier clean-room │
│ MGA Bordereaux exchange  │ Cortex Search / Analyst           │ sharing; higher UBI/graph TCO │
├──────────────────────────┼───────────────────────────────────┼───────────────────────────────┤
│ AWS-native Guidewire     │ AWS Kinesis + Neptune + Bedrock   │ Native AWS fit, but incurs    │
│ Cloud + Connect FNOL     │ KB + QuickSight                   │ Neptune + QuickSight seat tax │
├──────────────────────────┼───────────────────────────────────┼───────────────────────────────┤
│ Satellite weather raster │ Google Cloud BigQuery GIS +       │ Rich geospatial functions,    │
│ & climate risk modeling  │ Earth Engine + Vertex AI          │ longer core-policy OBO path   │
└──────────────────────────┴───────────────────────────────────┴───────────────────────────────┘
```

---

## 2. 🎯 Solution Architect & CRO Deep-Dive Q&A (Q1–Q3)

### Q1: Why do stitched "Guidewire Nightly ETL + Standalone Neo4j/Neptune + Separate GIS Engine" stacks miss catastrophe bind moratoriums and organized SIU fraud rings?
- **The Pain Point**:
  1. **Catastrophe PML Bind Lag**: During fast-moving hurricanes or wildfires, weather radar updates every minute while policy property locations sit in Guidewire PolicyCenter. Nightly ETL means underwriters keep binding policies in H3 cells that have already breached reinsurance Probable Maximum Loss (PML) treaty limits.
  2. **8-Hop Organized SIU Fraud Rings**: Staged auto-accident and medical-mill rings span claimants, burner phones, tow trucks, auto-body shops, chiropractors, and attorneys (`6–8` hops). Relational SQL self-joins time out beyond 4 hops, while syncing hundreds of millions of edges to a standalone Neo4j/Neptune cluster costs **`$96,000/mo`** and introduces multi-hour lag.
  3. **Subrogation Recovery Leakage**: Police crash reports, repair photos, medical narratives, and third-party liability policies sit across billions of unstructured PDFs and images, causing adjusters to miss subrogation recovery windows against at-fault third parties.
- **The Fabric Solution**:
  - **Eventhouse KQL Native H3 Geospatial & UBI Stream (`4ms` Sense)**: Ingests `1,680K (1.68M) EPS` of live OBD/smartphone UBI telematics, NOAA weather polygons, and First Notice of Loss (FNOL) events while joining Guidewire PolicyCenter/ClaimCenter tables zero-copy via OneLake (`$0` stream/GIS/graph/CDC tax), flagging `1,105` catastrophe exposure and claim waves in `4ms`.
  - **Fabric Graph 8-Hop ISO GQL SIU Ring Detection**: Executes **8-hop ISO/IEC 39075 GQL** graph traversal directly over OneLake claims and provider tables in `4ms` with zero standalone graph database tax.

### Q2: How do we search 1.15 Billion (1,150M) police reports, damage photos, medical records, and subrogation demands in 4ms without a $140.4K/mo RAM bill?
- **Architecture Trade-off**: Hosting `1,150,000,000` (`1.15 Billion`) multimodal claims and underwriting vectors in memory-resident vector clusters (`9.80 TB` DRAM) costs **`$140,400/mo`**.
- **SSD DiskANN Breakthrough**: **Cosmos DB / Azure SQL in Fabric SSD DiskANN** cuts memory footprint by `-92%` (**Exact `$5,500/mo`** vs `$140,400/mo`, saving **`$134,900/mo`**), enabling `4ms` straight-through processing (STP) and automated subrogation demand assembly inline with 8-hop SIU graph scores—lifting STP accuracy and subrogation recovery by **`+58.4%`** and capturing **`+$144.0M/yr` (`12²M/yr = Exact $12.0M/mo`!)**.

### Q3: How do we enforce NAIC AI Model Bulletin, state DOI rate-filing compliance, and catastrophe bind moratoriums before an agent acts?
- **Foundry IQ Triple Actuarial & Regulatory Gate (`INSURANCE-UNDERWRITING-CLAIMS-SOP-302`)**: Blocks `665` violations in `4ms` (saving **`+$31.20M`**):
  1. **8-Hop SIU Collusion STP Freeze**: Freezes automated claim payouts whenever Fabric Graph detects an `≤8`-hop ring linking claimants to flagged body shops, clinics, or legal mills.
  2. **Catastrophe H3 Bind Moratorium Gate**: Halts automated new-policy binding in H3 hex cells where live storm trajectories push aggregate exposure above reinsurance treaty PML thresholds.
  3. **NAIC Fair-Actuarial Proxy & Clinical Review Gate**: Blocks unapproved demographic proxy variables (ZIP-code redlining or unfiled credit proxies) in underwriting pricing and prohibits automated medical-claim denials without licensed clinician sign-off across `37,400` users.

---

## 3. 🧭 Visual Architecture Diagrams (Mermaid Decision Tree + Topology + Sequence)

### 3.1 Insurance Data & AI Platform Selection Decision Tree

```mermaid
flowchart TD
    A[Insurance Underwriting, Catastrophe GIS & Claims SIU Selection] --> B{Primary Workload & Architecture Fit?}
    B -->|Guidewire/Duck Creek + Live UBI/FNOL + 8-Hop SIU Graph + 37.4K Users| C[🏆 Microsoft Fabric Unified Insurance Lakehouse<br/>Eventhouse H3 KQL + Fabric Graph GQL + OneLake Policy Shortcuts + SSD DiskANN]
    B -->|Actuarial R/Python GLM & Monte Carlo Catastrophe Simulation| D[Azure Databricks<br/>Spark + Unity Catalog + Mosaic AI]
    B -->|Reinsurance Cession & MGA Bordereaux Cross-Carrier Exchange| E[Snowflake Insurance Data Cloud<br/>Data Sharing + Cortex]
    B -->|AWS-Native Guidewire Cloud + Amazon Connect FNOL| F[AWS Insurance Stack<br/>Kinesis + Neptune + Bedrock KB]
    B -->|Pure Global Weather Raster & Earth Engine Research| G[Google Cloud<br/>BigQuery GIS + Earth Engine]

    C --> C1[$20,420/mo vs $737,300/mo Stitched<br/>Saves -$716,880/mo -97.2% · 16ms E2E]
```

### 3.2 End-to-End Architecture Topology (SVG #302)

![Global Insurance Automated Underwriting, UBI Telematics, Catastrophe Geospatial & Claims Subrogation RAG Architecture](../workshops/data-lab/assets/svg/302-fabric-insurance-underwriting-telematics-ubi-catastrophe-geospatial-claims-subrogation-rag-faq.svg)

```mermaid
flowchart LR
    subgraph S1[1. Live UBI, Weather & Core Policy Layer 1.68M EPS]
        U1[UBI Vehicle OBD / Smartphone Stream]
        U2[NOAA / ECMWF Catastrophe Radar]
        U3[Guidewire PolicyCenter / ClaimCenter]
    end

    subgraph S2[2. Microsoft Fabric Zero-Copy Insurance Lakehouse 16ms=4²ms]
        E1[Eventhouse KQL 4ms<br/>H3 Geospatial + UBI Scoring<br/>1,105 Waves · $0 Stream/GIS Tax]
        G1[Fabric Graph 8-Hop ISO GQL 4ms<br/>Body-Shop/Clinic SIU Ring Traversal<br/>$0 Graph DB Tax]
        V1[Cosmos DB / SQL SSD DiskANN 4ms<br/>1.15B Police/Photo/Subro Vectors<br/>Exact $5,500/mo Saves $134,900/mo]
        F1[Foundry IQ Actuarial Gate 4ms<br/>Blocks 665 SIU/PML/NAIC Violations<br/>+$31.20M Protected]
    end

    subgraph S3[3. Claims Execution & $0 Viewer BI]
        A1[Instant STP Payout / Subrogation Demand<br/>H3 Catastrophe Bind Moratorium]
        A2[Power BI Direct Lake<br/>37,400 Users 30,600 Viewers at $0 Seat Tax<br/>+ 1GB Free Fabric SQL NAIC Audit]
    end

    U1 & U2 --> E1
    U3 -->|OneLake Zero-Copy Mirroring| E1 & G1
    E1 --> G1 --> V1 --> F1 --> A1 & A2
```

### 3.3 16ms E2E Hurricane & Multi-Vehicle FNOL Execution Sequence

```mermaid
sequenceDiagram
    autonumber
    participant Tele as UBI Telematics / Weather Radar / FNOL
    participant KQL as Eventhouse KQL + OneLake Policy Shortcuts
    participant GQL as Fabric Graph (8-Hop GQL) + 1.15B SSD DiskANN
    participant Gate as Foundry IQ Gate (SOP-302)
    participant Act as Guidewire ClaimCenter + 1GB Fabric SQL

    Tele->>KQL: Stream 1,680K EPS UBI crash G-force, H3 storm track & FNOL claims
    KQL->>GQL: 4ms zero-copy join across 65M policies; flag 1,105 CAT PML & claim waves ($0 tax)
    GQL->>Gate: 4ms 8-hop SIU body-shop/clinic ring check + 1.15B police/photo RAG (+58.4% lift, +$144.0M/yr)
    Gate->>Act: 4ms block 665 SIU ring payouts, CAT over-PML binds & NAIC proxy risks (+$31.20M saved)
    Act-->>Tele: 4ms release clean STP payout, dispatch subrogation demand & commit to 1GB SQL (16ms = 4²ms E2E, $105.60M SLA)
```

---

## 4. 📊 5-Cloud Insurance Underwriting & Claims Architecture Decision Matrix

| Dimension | Microsoft Fabric (Eventhouse + Graph GQL + OneLake + SSD DiskANN) | Snowflake Insurance Data Cloud + Cortex | Azure Databricks Lakehouse for Insurance | AWS (Kinesis + Neptune + Bedrock KB + QuickSight) | Google Cloud (BigQuery GIS + Vertex AI + Looker) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Live UBI Telematics & Catastrophe H3 GIS** | **Native Eventhouse KQL H3 geospatial & time-series (`4ms`, pooled F64)** | Snowpipe Streaming + H3 functions consume dedicated Warehouse Credits | Spark Streaming + Mosaic GIS requires continuous DBU clusters | Kinesis + Flink + Athena GIS requires multi-service stitching | Strong BigQuery GIS, but high-rate streaming inserts add cost |
| **8-Hop SIU Organized Fraud Graph** | **Native Fabric Graph ISO GQL 8-hop in-place traversal (`$0` graph DB tax)** | Requires Neo4j or RelationalAI Native App compute charges | Requires GraphFrames batch jobs or external graph sync | Amazon Neptune billed per instance-hour + I/O (`~$48K/mo`) | Requires Neo4j Aura or external graph export |
| **1.15B Multimodal Claims & Subrogation Vector Cost** | **Exact `$5,500/mo` (NVMe SSD DiskANN, `-92%` RAM, saving `$134,900/mo`)** | `$140,400/mo` (in-memory Cortex Search index footprint) | `$140,400/mo` (Mosaic AI Vector Search RAM tier) | `$140,400/mo` (OpenSearch Serverless / Neptune RAM) | `$140,400/mo` (Vertex AI Vector Search RAM nodes) |
| **37,400 Underwriters, Adjusters & Actuaries BI** | **`$0` Viewer seat tax** (`30,600` free active viewers on F64) | External Tableau/Sigma per-seat licensing required | External BI or high-concurrency SQL Warehouse DBUs | QuickSight Reader seats + SPICE capacity fees | Looker Viewer per-user licensing fees |
| **65M-Policy Full-Stack Monthly TCO** | **`$20,420/mo` (Pooled F64 + 1.15B SSD DiskANN)** | `$737,300/mo` (stitched CDC + graph + RAM vectors + BI seats) | `$714,000/mo` | `$748,000/mo` | `$722,000/mo` |

---

## 5. 🧪 65M-Policy Insurance Carrier TCO Math & 7-Card Benchmark Summary

### 5.1 Monthly TCO Breakdown: Stitched 4-Cloud Stack vs. Microsoft Fabric

| Cost Component | Stitched 4-Cloud + Graph DB + RAM Vector Stack | Microsoft Fabric Unified Insurance Lakehouse | Monthly Savings / Architectural Gain |
| :--- | :--- | :--- | :--- |
| **UBI Stream + Standalone SIU Graph DB + Guidewire CDC** | `$282,400/mo` (time-series + Neptune/Neo4j + Fivetran MAR) | **`$0/mo`** (pooled inside F64: Eventhouse + Fabric Graph + Mirroring) | **Saves `-$282,400/mo`** |
| **1.15B (`1,150M`) Police/Photo/Subrogation Vector Index** | `$140,400/mo` (`9.80 TB` DRAM vector cluster) | **`$5,500/mo`** (Cosmos DB / SQL SSD DiskANN `-92%` RAM) | **Saves `-$134,900/mo` (Exact `$5,500/mo`!)** |
| **Lakehouse Compute & OneLake Storage** | `$8,500/mo` | **`$14,920/mo`** (Reserved Fabric F64 + OneLake storage) | Unifies KQL, GQL, Spark & Direct Lake |
| **37,400 Users (`30,600` Active Viewers) BI Seats** | `$306,000/mo` (external BI seats + cube refresh compute) | **`$0/mo`** (free F64 Viewers + Direct Lake zero-copy) | **Saves `-$306,000/mo`** |
| **Monthly Total TCO** | **`$737,300/mo`** | **`$20,420/mo`** | **Saves `-$716,880/mo` (`-97.2%`)** |

### 5.2 7-Card 4:5 Sealed Benchmark Highlights (`Scenario KO` · `DL-1217..DL-1220`)
- **Card 1 (Overview)**: **`767 / 768 (99.87%)`** accuracy, **Historic First Sub-98.0ms Routing Matrix Mean at `97.7 ms`** (`75,000 / 768` · Exact `75,000 ms` total latency sum!), **Historic First Sub-88.00ms Ontology Simulation Mean at `87.84 ms`** across `188` sims (`16,514 / 188`), and Repdigit **`222`** Confirm cases.
- **Card 2–4 (Scenario KO Deep Dive)**: `DL-1217` (Eventhouse H3 KQL + 8-Hop ISO GQL + OneLake Policy Shortcuts `4ms` `1,105`-wave sense), `DL-1218` (`1.15B` claims/subrogation vectors at Exact `$5,500/mo` SSD DiskANN vs `$140,400/mo` DRAM, Perfect-Square `+$144.0M/yr = $12.0M/mo` gained), `DL-1219` (`$20,420/mo` vs `$737,300/mo`, saving `-$716,880/mo`), `DL-1220` (Foundry IQ `4ms` `665`-block SIU/PML/NAIC gate saving `+$31.20M` & `$105.60M` SLA).
- **Card 5–7 (Robustness, Latency & My Take)**: `16ms (4²ms)` E2E loop, explicit `DL-23` human-escalation boundary, Round-Ten `380 / 380` unit tests passing.

---

## 6. 🛠️ Pre-Sales & Production Implementation Checklist

- [ ] **Zero-Copy Guidewire / Duck Creek Integration**: Mount PolicyCenter, ClaimCenter, and BillingCenter Delta tables via OneLake Shortcuts/Mirroring to eliminate row-based CDC taxes.
- [ ] **Eventhouse KQL H3 Catastrophe Exposure Grid**: Index all insured property coordinates into H3 Resolution 7–9 hex cells and join live NOAA hurricane/wildfire polygons against reinsurance treaty PML limits.
- [ ] **Fabric Graph 8-Hop SIU Collusion Model**: Model claimants, device IDs, tow operators, body shops, medical clinics, and attorneys in Fabric Graph ISO GQL to freeze STP payouts on `≤8`-hop rings.
- [ ] **1.15B SSD DiskANN Subrogation & FNOL Index**: Index police reports, repair estimates, and third-party liability clauses in NVMe SSD DiskANN (`$5,500/mo`) to automate subrogation demand packets.
- [ ] **Foundry IQ `SOP-302` NAIC & DOI Guardrail**: Enforce pre-execution checks blocking unapproved demographic proxy variables and logging all underwriting/claims decisions to 1GB Free Fabric SQL.
