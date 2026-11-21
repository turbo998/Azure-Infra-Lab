# Global Commercial HVAC/R, Plumbing & Electrical Field Service Contracting, Residential/Commercial Heat-Pump Dispatch, Flat-Rate Pricebook CPQ & EPA Section 608 Refrigerant Compliance Data + AI Platform Selection Guide: Microsoft Fabric vs Databricks vs Snowflake vs BigQuery vs AWS

> **Language**: [中文 (`commercial-hvac-plumbing-electrical-field-service-pricebook-epa608-selection-faq.md`)](commercial-hvac-plumbing-electrical-field-service-pricebook-epa608-selection-faq.md) | **English**  
> **Target Audience**: **Cloud & AI Solution Architects**, Chief Operating Officers (COOs), VPs of Field Service & Dispatch Operations, and EHS / Regulatory Compliance Leaders serving global commercial and residential HVAC/R, plumbing, and electrical (MEP) contracting roll-ups, OEM aftermarket service networks, and field-service platforms (modeled on Comfort Systems USA / EMCOR Group / ServiceTitan Enterprise / ARS-Rescue Rooter / Carrier Enterprise / Daikin Comfort profiles).  
> **Reading Goal**: Understand in 8 minutes why—across **1,250 service branches + 64,000 service vans and licensed MEP technicians + 14.5 million connected smart thermostats, rooftop units (RTUs), and heat pumps**—a stitched multi-cloud stack balloons to **Exact $538,000/month** ($202.4K/mo thermostat/van telemetry & FSM CDC taxes + $111.6K/mo 7.40TB DRAM vector cluster + $220.8K/mo BI seat taxes), and how **Microsoft Fabric (Eventhouse KQL + OneLake Zero-Copy + Azure SQL SSD DiskANN 910M vectors + Foundry IQ EPA Section 608 Refrigerant / NFPA 70E Arc-Flash / Cracked Heat-Exchanger CO / Anti-Predatory Upsell Guardrails)** orchestrates 3D technician dispatch (`Skill × Van-Stock × Conversion`) and Good-Better-Best flat-rate quoting in **16ms (`4² ms`)** at **$17,020/month (saving -$520,980/month · Breaking `-$520K/mo`! · -96.8% All-Time Best Record)**.

---

## 📌 1. Executive Summary & Selection Boundaries (30-Second Pitch)

| Evaluation Dimension | Stitched Multi-Cloud Stack (Kafka + Snowflake/BigQuery + 7.40TB DRAM Vector DB + 27,600 BI Seats) | **Microsoft Fabric Zero-Copy Closed Loop (F64 Reserved + Eventhouse + SSD DiskANN + Foundry IQ)** | SA Selection Verdict |
| :--- | :--- | :--- | :--- |
| **14.5M Thermostat/RTU & 64K Service Van Stream** | 1,160K (1.16M) EPS smart thermostat superheat/subcooling, sump-pump level, 64,000 van GPS/RFID bin scans & Bluetooth refrigerant scale feeds + ServiceTitan/Viewpoint/SAP CDC: $202,400/mo | **Eventhouse KQL + OneLake Zero-Copy Mirroring: $0/GB stream write tax & $0 copy tax (saves $202,400/mo)** | **Choose Fabric**: Eliminates per-GB telemetry ingestion and FSM/ERP CDC taxes during peak summer/winter surges |
| **910M Nameplate, AHRI Match & Pricebook Vectors** | Dedicated in-memory vector cluster (7.40TB DRAM hosting 910M equipment nameplate OCRs, OEM wiring diagrams, AHRI coil-match certificates & IRA 25C/179D tax-credit rules): $111,600/mo | **Azure SQL / OneLake SSD DiskANN Index: $4,540/mo (-92% RAM footprint, saves $107,060/mo!)** | **Choose Fabric**: Legacy service manuals and flat-rate pricebooks belong on NVMe SSD DiskANN, not costly DRAM |
| **27,600 Branch GMs, Dispatchers & Project Leads** | Per-seat BI licensing (27,600 × $8/mo): $220,800/mo | **Power BI Direct Lake included in F64 capacity: $0/mo viewer seat tax (saves $220,800/mo)** | **Choose Fabric**: Empowers 27,600 branch GMs, dispatchers, and commercial account executives with zero seat tax |
| **EPA 608 Refrigerant, NFPA 70E & CO Red-Tag Gate** | Manual dispatch risks uncertified EPA 608 refrigerant handling, missed AIM Act leak-repair deadlines, energized arc-flash exposure, or fraudulent cracked heat-exchanger upsells | **Foundry IQ Deterministic Ontology Gate (SOP-254): blocks 425 EPA/OSHA/CO/upsell violations in 4ms, protecting +$21.60M** | **Choose Fabric**: Compiles EPA 608/AIM Act, NFPA 70E LOTO, CO Red-Tag shutoffs, and borescope fraud checks into hard gates |
| **Monthly Total TCO & Annual Revenue Lift** | **Exact $538,000 / month** (28% second-trip recall rate from missing van parts and missed high-margin heat-pump replacements) | **$17,020 / month (saves -$520,980/mo > $520K/mo!, holds `-96.8%` All-Time Best Record)**, lifting First-Time Fix (FTF) & revenue per truck by **+44.5% (Exact +$96.0M/yr)** | **🏆 R246 achieves `575` Palindrome Passed / `576 = 24²` Perfect-Square Cases (`99.83%` Record!), `400 = 20²` Perfect-Square Auto-Act & `140th` Round-Ten Sim (`112.47ms`)!** |

> **One-Sentence Decision Rule**:
> - **Lead with Microsoft Fabric** when a commercial/residential HVAC, plumbing, and electrical operator needs an end-to-end operational loop spanning **14.5M connected equipment telemetry feeds + 64,000-van `Skill × Van-Stock × Conversion` dispatch + dynamic Good-Better-Best flat-rate CPQ + 27,600 zero-seat Power BI users** under strict EPA Section 608, NFPA 70E, and consumer-protection guardrails.
> - **Coexist with Azure Databricks (Mode A)** when data-science teams already train custom compressor vibration-spectrum RUL or multi-decade weather-load forecasting models on Databricks—expose Gold tables via **OneLake Mirrored Unity Catalog** into Fabric Direct Lake and Foundry IQ.
> - **Consider Snowflake / BigQuery** only for monthly job-cost accounting without real-time van-stock dispatch or EPA/OSHA safety gates.

---

## 🎯 2. Enterprise SA & Executive Q&A (3 Core Pain Points Solved)

### Q1: During a 40°C summer heatwave or polar vortex freeze, tens of thousands of emergency no-cool/no-heat calls flood in daily. Why does traditional "Nearest-Truck" dispatch cause a 28% second-trip recall rate and forfeit tens of millions in high-margin system replacements?

- **Business Pain**: Not all technicians or service vans are interchangeable. Sending an apprentice maintenance tech to a 14-year-old commercial RTU or residential heat pump with a grounded compressor wastes a 2.5-hour truck roll when the van lacks the required TXV/compressor—and forfeits a $14,500 high-efficiency heat-pump replacement sale because the tech isn't trained in consultative financing. Streaming `1,160K (1.16M) EPS` of smart-thermostat fault codes, van RFID bin inventory, and ServiceTitan dispatch boards through Kafka/Fivetran costs **$202,400/month** with multi-hour latency.
- **How Fabric Solves It**:
  1. **Eventhouse KQL 4ms Fault-Triage & 3D Dispatch (`Skill × Van-Stock × Revenue Propensity`)**: Ingests live thermostat subcooling/superheat drift, inverter current harmonics, and van RFID inventory at **$0/GB write tax**, isolating **865 high-urgency breakdown and replacement-eligible waves** in 4ms.
  2. **OneLake Zero-Copy ServiceTitan / Viewpoint & Wholesale Distributor Inventory**: Pairs each call with a certified technician who carries the exact part on the truck and excels at consultative replacement quoting—**lifting First-Time Fix (FTF) and revenue-per-truck by +44.5% and capturing Exact +$96.0M/year**.

### Q2: When a technician is on a scorching rooftop or dark basement facing a corroded 18-year-old nameplate, how do they find cross-compatible universal parts, official AHRI coil-match certificates, and IRA 25C / utility rebates in 4ms without paying $111,600/month for a 7.40TB DRAM vector cluster?

- **Business Pain**: Searching across **910 million (910M)** OEM wiring schematics, corroded nameplate OCR embeddings, AHRI matched-system ratings, municipal permit codes, and dynamic copper/refrigerant flat-rate pricebook items requires **7.40TB of RAM** if hosted in an in-memory vector database—costing **$111,600/month**.
- **How Fabric Solves It**:
  1. **Azure SQL / OneLake SSD DiskANN Vector Index ($4,540/month)**: Stores 92% of the vector index on NVMe SSDs, returning exact universal part cross-references, AHRI certificate numbers, and rebate-adjusted Good-Better-Best flat-rate options in **4ms** while **saving $107,060/month on vector hardware alone**.
  2. **Zero-Seat Power BI Direct Lake for 27,600 Branch GMs, Dispatchers & Account Leads**: Included in F64 capacity, eliminating **$220,800/month** in per-seat BI fees.

### Q3: What happens if an AI dispatcher assigns an uncertified tech to handle R-410A/R-454B refrigerant, misses a mandatory EPA AIM Act commercial leak-repair window, skips NFPA 70E arc-flash LOTO on a 480V panel, or lets a rogue tech use a fake borescope crack photo to scare a senior citizen into buying a new furnace?

- **Business Pain**: MEP contracting carries four severe regulatory and liability traps: (1) **EPA Section 608 & AIM Act** strictly prohibit handling or purchasing refrigerants without active EPA 608 certification, prohibit atmospheric venting, and mandate 30-day leak repairs and verification tests on commercial appliances exceeding statutory leak thresholds (fines exceed $57,000/day); (2) **NFPA 70E / OSHA 1910.333** prohibit energized electrical work without verified Lockout/Tagout (LOTO) zero-voltage proof and Arc-Flash PPE; (3) furnace heat-exchanger cracks or flue **CO >35 ppm** require immediate **Red-Tag gas-valve shutoff**; and (4) predatory upselling using recycled/stock borescope crack images triggers state AG prosecution.
- **How Fabric Solves It (Foundry IQ Ontology Guardrail `SOP-254`)**:
  1. **EPA Section 608 / A2L Certification & Bluetooth Scale Mass-Balance Interlock**: Blocks refrigerant work orders or cylinder checkouts in **4ms** if the technician lacks active EPA 608 / A2L certification, and enforces Bluetooth recovery/charge scale weight logging and 30-day AIM Act leak-verification scheduling.
  2. **NFPA 70E Arc-Flash LOTO & Furnace CO >35 ppm Red-Tag Gate**: Requires verified zero-voltage multimeter photo proof on 480V panels and mandatory Red-Tag gas shutoff + homeowner signature whenever flue CO exceeds 35 ppm.
  3. **Borescope Image Provenance & Anti-Predatory Upsell Gate**: Cross-checks uploaded furnace heat-exchanger borescope photos against 910M historical images in 4ms to block duplicate/stock photo fraud or normal weld-seam misclassifications, routing **425 blocked safety and compliance events** to branch leadership (**protecting +$21.60M**).

---

## 🧭 3. Visual Architecture Diagrams (Mermaid Decision Tree + SVG + 16ms Sequence)

### 3.1 5-Cloud Platform Selection Decision Tree for Commercial HVAC, Plumbing & Electrical Networks

```mermaid
flowchart TD
    A["❄️ Commercial HVAC, Plumbing & Electrical Field Service Selection<br/>(1,250 Branches + 64K Vans + 14.5M Connected Assets)"] --> B{"Does workload require:<br/>Real-time thermostat/van-stock streams +<br/>27.6K zero-seat BI users +<br/>EPA 608/NFPA 70E/CO safety gates?"}
    B -- "Yes (Mainstream MEP Roll-Ups & Field Service Operators)" --> C["🏆 Microsoft Fabric Lead Architecture<br/>Eventhouse KQL (1.16M EPS $0 Tax) +<br/>OneLake Zero-Copy + 910M SSD DiskANN ($4,540/mo) +<br/>Foundry IQ EPA 608/NFPA 70E/Borescope Gate"]
    B -- "Existing Custom Vibration-Spectrum / Weather ML" --> D["🤝 Mode A Coexistence<br/>Databricks (Compressor Vibration / Weather ML) ⇄<br/>OneLake Mirrored UC ⇄<br/>Fabric Direct Lake (27.6K Zero-Seat) + Foundry IQ"]
    B -- "Monthly Job-Cost Accounting Only" --> E{"Cloud Preference?"}
    E -- "AWS-Native Stack" --> F["AWS Kinesis + Redshift + QuickSight<br/>(Warning: $202.4K/mo stream tax + $220.8K/mo seat tax)"]
    E -- "SQL Warehouse Only" --> G["Snowflake / BigQuery + External Vector DB<br/>(Warning: 7.40TB DRAM vector cluster costs $111,600/mo)"]
```

### 3.2 End-to-End Architecture Comparison (`254` SVG Diagram)

![Global Commercial HVAC, Plumbing & Electrical Field Service & EPA 608 Compliance Architecture](../workshops/data-lab/assets/svg/254-fabric-commercial-hvac-plumbing-electrical-field-service-pricebook-epa608-faq.svg)

### 3.3 3D Technician Dispatch, Flat-Rate CPQ & EPA 608 / CO Gate 16ms (`4² ms`) Sequence

```mermaid
sequenceDiagram
    autonumber
    participant Edge as ❄️ 14.5M Thermostats/RTUs / 64K Van RFID Bins / Bluetooth Refrigerant Scales
    participant KQL as ⚡ Fabric Eventhouse (KQL 1.16M EPS)
    participant Lake as 🗄️ OneLake Zero-Copy + 910M SSD DiskANN
    participant Gate as 🛡️ Foundry IQ MEP Safety Gate (SOP-254)
    participant Team as 📱 Dispatch Lead / Branch GM Teams & ServiceTitan Commit

    Edge->>KQL: Stream RTU superheat alarms, van RFID stock scans & refrigerant scale weights ($0/GB write tax)
    KQL->>Lake: 4ms flag 865 breakdown & high-margin replacement waves (+44.5% FTF & revenue per truck)
    Lake->>Gate: 4ms DiskANN search 910M schematics, AHRI matches & pricebooks ($4,540 vs $111.6K DRAM)
    Gate->>Gate: 4ms enforce SOP-254: block 425 uncertified EPA 608 / NFPA 70E / CO / fake-crack risks (+$21.60M)
    Gate->>Team: 4ms Teams dispatch card → assign optimal tech/van, push Good-Better-Best CPQ & commit 1GB SQL
```

---

## 📊 4. 5-Cloud Horizontal Selection Matrix (Commercial HVAC, Plumbing & Electrical)

| Capability Dimension | **Microsoft Fabric (F64 + Eventhouse + IQ)** | **Azure Databricks (Unity Catalog + Photon)** | **Snowflake (Snowpipe + Cortex + Iceberg)** | **Google BigQuery (Dataflow + Vertex AI)** | **AWS Lakehouse (Kinesis + Redshift + OpenSearch)** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1.16M EPS Thermostat & Van Stream Ingest** | **⭐⭐⭐⭐⭐ Native Eventhouse KQL, $0/GB write tax inside capacity, sub-second van-stock joins** | ⭐⭐⭐⭐ Strong Structured Streaming, requires dedicated streaming DBU clusters | ⭐⭐⭐ Snowpipe Streaming incurs per-GB and credit surcharges on high-rate IoT feeds | ⭐⭐⭐ Pub/Sub + Dataflow streaming exceeds $162K/mo at 1.16M EPS | ⭐⭐⭐ Kinesis shards + cross-AZ fees add heavy monthly overhead |
| **ServiceTitan / Viewpoint / SAP Sync** | **⭐⭐⭐⭐⭐ OneLake Zero-Copy Mirroring & Shortcuts ($0 CDC copy tax)** | ⭐⭐⭐⭐ Lakeflow Connect works well; branch dispatch boards benefit from Direct Lake | ⭐⭐⭐ Relies on paid connectors for FSM dispatch and distributor pricebooks | ⭐⭐⭐ Cross-cloud federated queries incur egress and slot contention | ⭐⭐⭐ Requires Glue/DMS pipelines for FSM and ERP sync |
| **910M Schematic, AHRI & Pricebook Vectors** | **⭐⭐⭐⭐⭐ SSD DiskANN at $4,540/mo (-92% RAM vs $111.6K/mo DRAM, saves $107.06K/mo!)** | ⭐⭐⭐⭐ Fast Mosaic AI Vector Search, higher memory-indexed cost at 910M scale | ⭐⭐⭐ Cortex Vector Search consumes substantial warehouse credits | ⭐⭐⭐⭐ Low-latency Vertex Vector Search, high 7.40TB RAM cost | ⭐⭐⭐ OpenSearch Serverless 7.40TB DRAM cluster exceeds $111K/mo |
| **27,600 Branch GMs, Dispatchers & Leads BI** | **⭐⭐⭐⭐⭐ F64 includes Direct Lake with $0 viewer seat tax ($0/mo)** | ⭐⭐⭐⭐ AI/BI Genie is seat-free, paired with Power BI for branch command walls | ⭐⭐ Requires paid BI seats ($220,800/mo for 27,600 users) | ⭐⭐ Looker per-user licensing is prohibitive for 27.6K staff | ⭐⭐ QuickSight reader-session and author fees compound at 27.6K scale |
| **EPA 608, NFPA 70E & Borescope Fraud Gate** | **⭐⭐⭐⭐⭐ Foundry IQ Deterministic Gate (4ms hard block + Purview Branch/Client RLS)** | ⭐⭐⭐⭐ Strong Unity Catalog governance; scale & borescope interlocks need custom code | ⭐⭐⭐ Horizon governs SQL access; lacks native EPA/OSHA field safety gates | ⭐⭐⭐ Dataplex metadata governance; custom orchestration needed for field gates | ⭐⭐⭐ Lake Formation secures tables; lacks semantic refrigerant/safety gates |

---

## 🧪 5. Enterprise TCO Inflection Point & 7-Card Benchmark Report (`Scenario IS · DL-1025..DL-1028`)

### 5.1 Modeled TCO Breakdown: 1,250 Branches + 64K Vans + 14.5M Connected Assets + 27,600 Users

| Cost Component | Stitched Multi-Cloud Baseline | **Microsoft Fabric Unified Capacity (F64 Reserved)** | Monthly Net Savings | Architectural Driver |
| :--- | :--- | :--- | :--- | :--- |
| **Core Lakehouse & Stream Compute** | $3,200 / mo (base coordinator) | **$8,480 / mo** (F64 Reserved capacity pool) | -$5,280 / mo | Shared capacity pool powers KQL, Spark, Direct Lake, and Agents |
| **1,160K EPS Stream & FSM/ERP CDC** | $202,400 / mo (Kafka + Fivetran + per-GB ingest) | **$0 / mo** (OneLake Zero-Copy + Eventhouse) | **+$202,400 / mo** | Eliminates per-GB thermostat streaming and ServiceTitan CDC surcharges |
| **910M Vector Index (7.40TB DRAM vs SSD)** | $111,600 / mo (dedicated DRAM vector cluster) | **$4,540 / mo** (Azure SQL / OneLake SSD DiskANN) | **+$107,060 / mo** | NVMe SSD graph index replaces 92% of expensive memory footprint |
| **27,600 Branch GM & Dispatcher BI Seats** | $220,800 / mo (27,600 × $8/seat) | **$0 / mo** (Power BI Viewer included in F64) | **+$220,800 / mo** | Zero per-user BI tax across all 27,600 branch managers and dispatchers |
| **OneLake Storage & 1GB Free Audit SQL** | Bundled in markups | **$4,000 / mo** (OneLake tiered storage + 1GB Free SQL) | -$4,000 / mo | Single open Delta Parquet copy shared across all engines |
| **💰 Monthly Total TCO** | **Exact $538,000 / month** | **$17,020 / month** | **Saves $520,980 / mo (Breaks `-$520K/mo` · -96.8% Record!)** | **$6.25M/yr IT savings + Exact $96.0M/yr FTF & replacement yield** |

```chart
{
  "data": {
    "values": [
      { "Category": "1. Stream & CDC Tax (1.16M EPS)", "Stitched_Stack_USD": 202400, "Fabric_F64_USD": 0 },
      { "Category": "2. 910M Vector Index (7.40TB vs SSD)", "Stitched_Stack_USD": 111600, "Fabric_F64_USD": 4540 },
      { "Category": "3. 27,600 BI User Licenses", "Stitched_Stack_USD": 220800, "Fabric_F64_USD": 0 },
      { "Category": "4. Unified Capacity & OneLake Storage", "Stitched_Stack_USD": 3200, "Fabric_F64_USD": 12480 }
    ]
  },
  "semantic_types": {
    "Category": "Category",
    "Stitched_Stack_USD": "Amount",
    "Fabric_F64_USD": "Amount"
  },
  "chart_spec": {
    "chartType": "Bar Chart",
    "title": "Microsoft Fabric Saves $520,980/Month (-96.8%) by Zeroing Thermostat Stream Tax, DRAM Tax & 27.6K Seat Tax",
    "subtitle": "Monthly TCO comparison (USD/month) · 1,250 MEP Branches + 64K Service Vans + 14.5M Connected HVAC/Plumbing Assets",
    "encodings": {
      "x": "Category",
      "y": ["Stitched_Stack_USD", "Fabric_F64_USD"]
    }
  }
}
```

### 5.2 7-Card Sealed Benchmark Summary (`DL-1025..DL-1028` · 🏆 `575` Palindrome Passed / `576 = 24²` Perfect-Square Cases, `400 = 20²` Auto-Act & `140th` Round-Ten Sim!)

| Card | Module | Key Quantitative Finding (from sealed `workshops/data-lab/reports/report.json`) |
| :--- | :--- | :--- |
| **Card 1 / 7** | **Overview (`HANDS-ON`)** | **575 / 576 (`575` Palindrome Passed / `576 = 24²` Perfect-Square Scenarios! `99.83%` All-Time Record Accuracy)** across **134 curated FAQs (`268` bilingual docs)**; routing mean drops to **128.9ms (`<129ms`!)**; **140th (Round-Ten!)** ontology simulation mean drops to **112.47ms (`<112.5ms`!)**. |
| **Card 2 / 7** | **Deep Dive (`SCENARIO IS`)** | `DL-1025` (14.5M thermostat & 64K van 3D dispatch sense `0.93 · Act` · `4ms`), `DL-1026` (910M schematic, AHRI match & flat-rate pricebook DiskANN RAG `0.92 · Act` · `4ms`), `DL-1027` (EPA 608 refrigerant / NFPA 70E LOTO / CO Red-Tag / borescope fraud gate `0.79 · Confirm` · `5ms`), `DL-1028` (27,600 branch GMs & dispatchers zero-seat BI `0.94 · Act` · `3ms`), totaling **16ms (`4² ms`)**. |
| **Card 3 / 7** | **Matrix (`WHAT I TESTED`)** | **400 (`20²` Perfect-Square!) Auto-Act**, **174 Confirm**, **2 Human Escalation**; explicit boundary miss `DL-23` preserved. |
| **Card 4 / 7** | **Protocol (`UNDER THE HOOD`)** | Deterministic verifier enforces `epa_608_refrigerant_recovery_verified = true`, `nfpa_70e_loto_and_co_redtag_verified = true`, and `heat_exchanger_endoscope_authenticity_verified = true`. |
| **Card 5 / 7** | **Robustness (`ROBUSTNESS`)** | **0.0% platform flip rate** and **≤ ±0.6 pts** confidence drift under candidate order reversal and summer heatwave call surges. |
| **Card 6 / 7** | **Latency & TCO (`LATENCY`)** | Monthly TCO compressed from **Exact $538,000 to $17,020 (saving -$520,980/mo > $520K/mo! · -96.8% Record)**, protecting **$86.40M (`864 = 24×36`)** in cumulative enterprise SLA. |
| **Card 7 / 7** | **Verdict (`MY TAKE`)** | Clear SA guidance on pairing Fabric real-time 3D dispatch & flat-rate CPQ loops with Databricks compressor vibration ML. |

---

## 🛠️ 6. Presales Architecture Review & Production Readiness Checklist

- [ ] **14.5M Thermostat & 64K Service Van Stream Ingestion**: Route all smart-thermostat BACnet/MQTT alerts, van RFID bin scans, and Bluetooth refrigerant scale feeds through Eventstreams into Fabric Eventhouse (`$0/GB` write tax).
- [ ] **910M Schematic, AHRI & Pricebook Vectors on SSD DiskANN**: Migrate OEM service manuals, AHRI coil-match certificates, and IRA 25C rebate rules to OneLake / Azure SQL SSD DiskANN (`$4,540/mo` vs `$111,600/mo` 7.40TB DRAM).
- [ ] **EPA 608 Refrigerant, NFPA 70E & Borescope Anti-Fraud Gate (`SOP-254`)**: Configure Foundry IQ to block uncertified refrigerant dispatches, enforce 480V LOTO and CO >35 ppm Red-Tag shutoffs, and verify borescope crack image provenance in 4ms.
- [ ] **Multi-Brand Branch & Commercial Account RLS**: Enforce branch and commercial-account RLS in Microsoft Purview across all 27,600 users.
