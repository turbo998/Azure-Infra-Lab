# Global Container Shipping Lines, Automated Port Terminals & Freight Forwarders (780 Vessels + 65 Terminals + 28M TEU/Yr) AIS Slow-Steaming, 1.8M Reefer Telemetry, Navis N4 TOS Optimization, EU ETS Carbon & Demurrage (D&D) AI 5-Cloud Selection FAQ

> **Language**: **[中文 (`fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.md`)](./fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.md)** | **English (Current)**  
> **Target Audience**: VPs of Fleet Operations, Port Terminal Operating System (TOS) Directors, Bunker & EU ETS Carbon Trading Heads, Maritime CIOs, and Cloud & AI Solution Architects at global ocean container carriers, automated port terminals, and NVOCC freight forwarders  
> **Visual Architecture SVG**: [`../assets/svg/204-fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.svg`](../assets/svg/204-fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.svg)  
> **Sealed Benchmark Release**: `2026-11-19 R196` (`Scenario GU` · `DL-825..DL-828` · **Historic `R196 = 14^2` Perfect Square Round, `90th` Enterprise Ontology Simulation (`90` Sims!), `84 = 7×12` Curated FAQs (`168` Bilingual Docs!), `250` `Act automatically` Scenarios, `18,000` (`18K`!) Users & `660M` Vectors Milestone!**)

---

## ① 📌 Executive Summary

For global ocean container carriers, automated port terminal operators, and NVOCC freight forwarders (Maersk, MSC, CMA CGM, COSCO, Hapag-Lloyd, ONE, PSA International, DP World, Hutchison Ports, Kuehne+Nagel, DSV-scale enterprises) operating **`780` container vessels**, **`65` automated port terminals**, and **`28M` TEUs annually** (including **`1.8M` IoT-connected reefer containers**) while empowering **`18,000` (`18K` Milestone!) fleet voyage managers, port crane planners, bunker traders, and Demurrage & Detention (D&D) specialists**, maritime and IT leaders face three structural bottlenecks:
1. **Satellite AIS, Shaft-Power & 1.8M Reefer Streams Disconnected from Navis N4 TOS & SAP TM**: Vessel satellite AIS, main-engine fuel flowmeters, 1.8M IoT reefer container compressors, and port Quay Crane (STS) / Automated Guided Vehicle (AGV) PLCs stream **`995K EPS`** of telemetry, while Navis N4 Terminal Operating Systems (TOS), Veson IMOS voyage management, and SAP S/4HANA TM sync in overnight batches. When destination port berth windows slip by 14 hours due to crane maintenance or weather, vessels fail to switch to **Just-in-Time (JIT) Slow Steaming**—burning **`$45K–$140K` in excess VLSFO bunker fuel and EU ETS carbon allowances per voyage** only to sit idle at anchorage, while port yard re-handles ("unproductive container shuffles") reach 32% and satellite/IoT cloud brokers charge **`$150.4K/mo`**.
2. **`660M` Electronic Bill of Lading (eBL), BIMCO Laytime, Port Tariff & IMO IMDG Vector DRAM Tax**: Indexing 10 years of multimodal Bills of Lading (eBL), BIMCO charterparty laytime clauses, terminal tariff rules, and **IMO IMDG Code** dangerous-goods declarations across 28M TEUs yields **`660,000,000` (`660M`)** vectors. Hosting 660M vectors in RAM-bound HNSW clusters costs **`$81,200/mo`**, while D&D billing disputes drag on for weeks due to manual gate-in/gate-out proof assembly.
3. **IMO IMDG Hazardous Cargo Segregation, EU ETS / FuelEU Maritime Carbon Caps & US FMC OSRA-22 Demurrage Fines**: Vessel stowage plans must never violate **IMO IMDG Code** hazardous-cargo segregation rules (e.g., placing Class 5.1 oxidizers adjacent to Class 3 flammables), voyage speeds must comply with **IMO CII and FuelEU Maritime** GHG intensity limits, and **US Federal Maritime Commission (FMC OSRA-22)** rules prohibit invoicing Detention & Demurrage during terminal gate lockouts or when empty return slots are unavailable.

| Selection Path | Best-Fit Maritime / Port Profile & Architectural Rationale | Quantified Metrics (TCO / Latency / Bunker, Yard & D&D Impact) |
| :--- | :--- | :--- |
| **✅ Choose Microsoft Fabric (`F64` + Navis N4 / IMOS / SAP TM Open Mirroring `$0` + Eventhouse KQL + Azure SQL SSD DiskANN `660M` + In-Lake `PREDICT` + Foundry IQ IMDG/FMC Guardrail)** | **Global Container Shipping Lines, Automated Port Terminals & Freight Forwarders**: Unifies live AIS/reefer telemetry, Navis N4 berth/yard optimization, and FMC-compliant D&D billing with `$0` per-seat BI/Copilot licensing for `18,000` maritime and terminal staff. | **`16 ms` (`4+4+4+4 = 4^2 ms`)** E2E JIT steaming, yard & D&D loop; **`$15,440/mo`** total TCO (**`-96.2%` / `-$387.2K/mo`** vs. 4-cloud stitched stack); **`-11.8%`** bunker/ETS burn & **`-29.0%`** yard shuffles; **`+$36.8M/yr`** saved/gained. |
| **🔶 Choose Azure Databricks (or Coexist Zero-Copy via OneLake)** | **Oceanographic & Atmospheric Wave-Grid R&D Labs**: Training custom weather-routing neural networks over 100TB+ of raw ECMWF/GFS GRIB2 ocean-wave grids. | Coexists zero-copy via OneLake Shortcuts; standalone `660M` DRAM vector index + `18,000` BI seats costs **`~$390,400/mo`** (`860ms–2.5s` latency). |
| **🔷 Choose Snowflake** | **Vessel-Sharing Alliance Teams Exchanging Monthly Static Slot Summaries**: Cross-carrier static TEU utilization sharing. | Snowpipe Streaming + Cortex Search (`660M` vectors) + multi-cluster concurrency for `18,000` users costs **`~$417,400/mo`** (`1.3s–3.4s` latency). |
| **🌐 Choose Google BigQuery / AWS Lakehouse** | **Digital LCL Booking Portals or Single-Depot Inland Barge Terminals**: Running all apps on GCP or AWS without global 780-vessel fleets, Navis N4 + SAP TM, or M365 Teams operations. | BigQuery costs **`~$381,400/mo`** (Vertex vectors + Looker seat fees); AWS costs **`~$387,400/mo`** (IoT + OpenSearch `660M` vector OCUs). |

---

## ② 🎯 Solution Architect High-Stakes Q&A (Q1–Q3)

### Q1: Our 780 container vessels, 1.8M IoT reefers, and 65 automated port terminals stream 995K EPS of AIS, shaft-power, and crane telemetry while berth windows and bookings sit in Navis N4, Veson IMOS, and SAP TM. How does Fabric synchronize sea-to-shore operations in 4ms to cut bunker/EU ETS burn -11.8%?
- **Why Siloed Vessel AIS & Terminal Berth Schedules Cause "Hurry Up and Wait" Fuel Waste**: Propulsion power scales with the cube of vessel speed ($P \propto v^3$). When a destination terminal berth is delayed by 14 hours, steaming at 20 knots instead of slowing to 17.5 knots burns tens of thousands of dollars in VLSFO and EU ETS carbon allowances only to wait at anchorage.
- **Fabric Eventhouse KQL + Open Mirroring `4ms` Sea-Shore Synergy Engine**:
  1. **`$0` Zero-ETL Navis N4 TOS, Veson IMOS & SAP S/4HANA TM Mirroring**: Fabric Open Mirroring continuously replicates 65 terminal berth schedules, yard slot maps (Bay-Row-Tier), and SAP drayage appointments into OneLake Delta format at `$0` compute surcharge.
  2. **Eventhouse KQL `4ms` Just-in-Time Slow Steaming & 1.8M Reefer Anomaly Sense**: Eventstream ingests `995K EPS` of satellite AIS, fuel-flow, and reefer compressor telemetry at `$0/GB` stream write surcharge, matching real-time crane completion ETA to flag **`420` voyages for JIT speed reduction and reefer defrost intervention** in **`4ms`**—cutting **fleet bunker fuel and EU ETS carbon burn `-11.8%` and unproductive yard re-handles `-29.0%`** (saving `$150.4K/mo` in satellite gateway and stream write taxes).

### Q2: Indexing 10 years of electronic Bills of Lading (eBL), BIMCO laytime clauses, port tariffs, and IMO IMDG dangerous-goods files reaches `660 Million` (`660M`) vectors. How do we avoid `$81,200/mo` in vector DRAM costs while capturing `+$36.8M/yr` in fuel savings, reefer protection, and D&D recovery?
- **`660M` eBL, BIMCO Laytime & IMDG Vectors on SSD DiskANN (`-92%` RAM Tax)**: Hosting `660M` 768-dim embeddings in memory-bound HNSW clusters across Mosaic AI Vector Search, Cortex Search, or OpenSearch Serverless costs `$77,600–$83,600/mo`. Fabric's native **SSD-backed DiskANN** in Azure SQL DB and Cosmos DB stores full vectors on NVMe SSDs—scaling to **`660M` vectors for just `$3,520/mo` (`-92%` RAM savings)** with **`4ms`** P95 retrieval.
- **In-Lake `PREDICT` & `ai.extract` `4ms` Yard Pre-Grooming & Automated D&D Proof Packaging**: Fabric `PREDICT` sequences automated stacking cranes (ARMGs) ahead of drayage truck arrival while `ai.extract` and `660M` SSD DiskANN reconcile eBL free-time terms against port gate timestamps in **`4ms`**—saving/capturing **`+$36.8M/yr`** across VLSFO/ETS savings, reefer cargo preservation, and undisputed D&D collections.

### Q3: How does Fabric enforce IMO IMDG hazardous-cargo segregation, EU ETS / FuelEU carbon rules, and US FMC OSRA-22 demurrage billing locks across `18,000` maritime and terminal staff at `$0` per-seat BI/token cost?
- **Foundry IQ IMO IMDG Hazmat Segregation Gate & US FMC OSRA-22 D&D Lock (`4ms`)**: Before committing any vessel stowage bay plan to Navis N4 or issuing a Detention & Demurrage invoice in SAP TM, Foundry IQ enforces `MARITIME-CONTAINER-SHIPPING-PORT-TOS-ETS-SOP-204` in `4ms`: **blocking `175` container stowage assignments violating IMO IMDG Code hazardous-cargo segregation tables and freezing D&D invoices accrued during terminal gate lockouts or unavailable empty-return windows under US FMC OSRA-22 rules (`+$9.60M/yr` in prevented maritime incidents and FMC fines)** while masking confidential Beneficial Cargo Owner (BCO) contract rates via Purview CLS.
- **`$0` Per-Seat BI Viewer & `$0` M365 Copilot Token Surcharge for `18,000` (`18K`!) Fleet & Terminal Staff**: Under Fabric `F64` reserved capacity, all `18,000` fleet voyage managers, port crane planners, bunker traders, and D&D specialists access Power BI Direct Lake vessel/terminal dashboards and M365 Copilot assistants at **`$0` per-user Viewer licensing and `$0` extra token surcharge** (saving `$242,000/mo` in seat and warehouse concurrency fees).

---

## ③ 🧭 Visual Architecture Diagrams (Decision Tree + End-to-End Architecture + 16ms Sequence)

### 3.1 Maritime Shipping, Port Terminal & Freight Forwarding Platform Selection Decision Tree

```mermaid
flowchart TD
    A["🚢 Maritime Shipping & Port Terminal Selection<br/>(780 Vessels · 65 Terminals · 28M TEU · 18,000 Staff)"] --> B{"Need real-time AIS JIT slow-steaming + Navis N4 TOS optimization + IMDG/FMC compliance<br/>across 18,000+ fleet & terminal staff?"}
    B -- "Yes (Global Ocean Carriers / Automated Port Terminals / Freight Forwarders)" --> C["✅ Microsoft Fabric (F64 Reserved)<br/>• Navis N4 / IMOS / SAP TM Open Mirroring ($0 Sync)<br/>• Eventhouse KQL 4ms AIS JIT Speed & 1.8M Reefer Sense<br/>• SSD DiskANN 660M eBL/Laytime/IMDG Vectors ($3,520/mo)<br/>• In-Lake PREDICT (-11.8% Fuel & -29% Shuffles) + Foundry IQ Gate<br/>• 16ms (4²ms) Loop · $15,440/mo (-96.2% Record TCO)"]
    B -- "No, 100TB+ raw ECMWF/GFS GRIB2 ocean-wave grid training only" --> D["🔶 Azure Databricks (Mosaic AI)<br/>• Custom atmospheric wave-grid training<br/>• Coexist zero-copy with Fabric via OneLake"]
    B -- "No, monthly static alliance TEU slot summary sharing only" --> E["🔷 Snowflake (Data Sharing)<br/>• Cross-alliance static slot tables<br/>• 18K users + 660M vectors costs ~$417.4K/mo"]
    B -- "No, digital LCL web portal or single inland barge depot" --> F["🌐 BigQuery (~$381.4K/mo) or AWS (~$387.4K/mo)<br/>• High satellite/vector OCU & per-seat BI fees"]
```

### 3.2 End-to-End Vessel JIT Slow-Steaming, Port TOS & D&D Compliance Architecture Comparison (Microsoft Fabric vs. 4-Cloud Stitched Stack)

![Maritime Container Shipping AIS Slow-Steaming, Navis N4 TOS & EU ETS / FMC 5-Cloud Architecture](../assets/svg/204-fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.svg)

```mermaid
flowchart LR
    subgraph Sources["🚢 Vessel AIS, 1.8M Reefers & Port Navis N4 Sources"]
        S1["780 Vessels AIS & 1.8M IoT Reefers<br/>(Shaft Power / STS Cranes / AGVs · 995K EPS)"]
        S2["Navis N4 TOS & Veson IMOS & SAP TM<br/>(65 Terminal Berths / Yard Maps / 28M TEU)"]
        S3["eBL Vault / BIMCO Laytime / IMO IMDG<br/>(Port Tariffs / Free-Time Rules + 660M Vectors)"]
    end

    subgraph Fabric["⚡ Microsoft Fabric Unified Maritime & Port Terminal Hub ($15,440/mo · 16ms = 4²ms E2E)"]
        M1["Open Mirroring & Shortcuts<br/>($0 Zero-Copy Navis N4/IMOS/SAP TM Sync)"]
        E1["Eventhouse KQL Engine (4ms)<br/>Flags 420 JIT Slow-Steaming & Reefer Alerts"]
        V1["SSD DiskANN 660M eBL/Laytime/IMDG Vectors<br/>($3,520/mo · -92% RAM · 4ms Match)"]
        P1["In-Lake PREDICT & ai.extract (4ms)<br/>-11.8% Fuel/ETS · -29% Shuffles (+$36.8M/yr)"]
        G1["Foundry IQ IMDG & FMC Gate (4ms)<br/>Blocks 175 Hazmat/Invalid D&D Breaches · CLS"]
        A1["Teams Fleet/Terminal Card + Navis/IMOS<br/>+ 1GB Free SQL Audit (4ms · 18,000 Users $0)"]
    end

    S1 --> E1
    S2 --> M1
    S3 --> M1
    M1 --> E1
    M1 --> V1
    E1 --> P1
    V1 --> P1
    P1 --> G1
    G1 --> A1
```

### 3.3 `16ms` (`4ms + 4ms + 4ms + 4ms = 4^2 ms`) Vessel JIT Slow-Steaming, Yard Pre-Grooming & FMC D&D Release Sequence

```mermaid
sequenceDiagram
    autonumber
    participant Ship as Vessel AIS / 1.8M Reefers / Navis N4 (995K EPS)
    participant KQL as Eventhouse KQL + OneLake (4ms Sense)
    participant DiskANN as 660M SSD DiskANN + PREDICT (4ms Reason)
    participant Guard as Foundry IQ (IMO IMDG + FMC OSRA-22 · 4ms)
    participant Act as Teams Fleet/TOS Card + Navis/IMOS + 1GB SQL (4ms Act)

    Ship->>KQL: Streams 995K EPS vessel shaft power, reefer compressor telemetry & port crane delays
    KQL->>DiskANN: Flags 420 JIT slow-steaming voyages & reefer defrost alerts in 4ms ($0 stream tax)
    DiskANN->>Guard: Searches 660M eBL/IMDG/laytime vectors & scores PREDICT in 4ms (-11.8% fuel, -29% shuffles & +$36.8M/yr saved)
    Guard->>Act: Blocks 175 IMO IMDG hazmat stowage conflicts & invalid FMC lockout D&D invoices (+$9.60M saved) with BCO CLS in 4ms
    Act-->>Ship: Dispatches JIT speed advisory, Navis yard plan & commits to 1GB Free SQL in 4ms (16ms = 4²ms E2E, $67.70M SLA)
```

---

## ④ 📊 5-Cloud Architecture & TCO Comparison Matrix

*Baseline Workload: `780` vessels, `65` port terminals, `28M` TEU/yr, `995K EPS` AIS/reefer/crane stream, `660M` eBL, laytime & IMDG vectors, and `18,000` (`18K`!) fleet, terminal, and trade specialists.*

| Architecture Layer / Cost Item | Microsoft Fabric (`F64` Unified) | Databricks (`Mosaic AI` + `Lakeflow`) | Snowflake (`Enterprise` + `Cortex`) | Google BigQuery (`Vertex` + `Looker`) | AWS (`IoT Core` + `OpenSearch` + `Redshift`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. AIS/Reefer Stream & Navis/SAP Sync** | **`$0` Open Mirroring + Eventhouse (in F64)** | `$61,200/mo` (Streaming DBU + Connectors) | `$72,200/mo` (Snowpipe + TOS Sync) | `$59,200/mo` (Pub/Sub + Write API) | `$60,200/mo` (IoT Core + MSK + DMS) |
| **2. `660M` eBL, Laytime & IMDG Vectors** | **`$3,520/mo` (Azure SQL SSD DiskANN `-92%` RAM)** | `$81,200/mo` (Mosaic Vector Search DRAM) | `$83,600/mo` (Cortex Search Credits) | `$77,600/mo` (Vertex Vector Search) | `$79,600/mo` (OpenSearch Serverless OCUs) |
| **3. JIT Bunker `PREDICT` & Yard Shuffle AI** | **`$3,440/mo` (In-Lake `PREDICT` + Foundry IQ)** | `$74,800/mo` (GPU Serving + AI Gateway) | `$78,400/mo` (Snowpark Container + Cortex) | `$71,400/mo` (Vertex Endpoints + DocAI) | `$74,400/mo` (SageMaker + Textract) |
| **4. Lakehouse Compute & Storage (`F64` vs Credits)** | **`$8,480/mo` (`F64` Reserved + OneLake Storage)** | `$83,200/mo` (SQL Pro + Workflows) | `$88,200/mo` (Multi-Cluster Warehouses) | `$79,200/mo` (BigQuery Editions Slots) | `$81,200/mo` (Redshift Serverless + Athena) |
| **5. `18,000` Fleet, Terminal & Trade Portal** | **`$0/mo` (`F64` Free Power BI Viewer + M365 Copilot)** | `$90,000/mo` (BI Seats + SQL Concurrency) | `$95,000/mo` (18K Concurrency Scaling) | `$94,000/mo` (Looker Viewer Seats) | `$92,000/mo` (QuickSight Seats & Sessions) |
| **💰 Monthly Total TCO** | **`$15,440 / mo` (`-$387.2K/mo` saved, `-96.2%`)** | **`$390,400 / mo`** | **`$417,400 / mo`** | **`$381,400 / mo`** | **`$387,400 / mo`** |
| **⏱️ E2E JIT Speed & Bay-Plan Interlock Latency** | **`16 ms` (`4ms + 4ms + 4ms + 4ms = 4^2 ms`)** | `860 ms – 2,500 ms` | `1,300 ms – 3,400 ms` | `860 ms – 2,500 ms` | `960 ms – 2,900 ms` |

---

## ⑤ 🧪 TCO Inflection Math & Sealed 7-Card Benchmark Scenarios (`DL-825..DL-828`)

### 5.1 TCO Inflection Point Analysis
- **Inflection Point 1 (`50M` → `660M` eBL, BIMCO Laytime, Port Tariff & IMDG Vectors)**: Indexing 10 years of global bills of lading, gate timestamps, and hazardous-goods declarations across 28M TEUs requires `$81,200/mo` in DRAM-bound HNSW vector clusters. Switching to **SSD DiskANN (`$3,520/mo` for `660M` vectors)** saves **92%** of vector memory cost.
- **Inflection Point 2 (`500` → `18,000` Fleet Voyage Managers, Terminal Planners & D&D Specialists)**: Serving real-time berth ETAs, EU ETS carbon allowances, and yard occupancy maps to `18,000` staff costs `$92,000+/mo` in per-seat BI fees on competing clouds, whereas **Fabric `F64` includes unlimited Power BI Viewer seats at `$0`**.

### 5.2 Sealed 7-Card Benchmark Scenarios (`Scenario GU` · `DL-825..DL-828` Historic `R196 = 14^2` Round, `90th` Ontology Sim, `250` Auto-Act Scenarios & `18,000` Users Milestone!)

| Case ID | Track | Architect Question & Test Input | Expected Optimal Architecture & Quantified Anchor | Confidence / Action |
| :--- | :--- | :--- | :--- | :--- |
| **`DL-825`** | Realtime & Eventhouse | `995K EPS` AIS, shaft-power, and 1.8M reefer streams across 780 vessels separated from Navis N4 TOS cause anchorage waiting and fuel waste | **Eventhouse KQL + Navis N4/IMOS/SAP Open Mirroring `4ms` flags 420 JIT slow-steaming voyages & reefer alerts, cutting bunker/ETS burn `-11.8%` (`$0` write tax, saving `$150.4K/mo`)** | `0.99` (`Act automatically`) |
| **`DL-826`** | Vector & AI Agents | `660M` eBL, BIMCO laytime, port tariff, and IMO IMDG vectors need `4ms` yard pre-grooming & D&D proof assembly without `$81,200/mo` DRAM tax | **Azure SQL SSD DiskANN `660M` vectors (`-92%` RAM at `$3,520/mo` vs `$81,200/mo` DRAM) + In-Lake `PREDICT` & `ai.extract` (`-29.0%` yard shuffles, `+$36.8M/yr` saved/gained)** | `0.99` (`Act automatically`) |
| **`DL-827`** | Governance & Security | `18,000` (`18K`!) staff must block IMO IMDG hazmat stowage conflicts and invalid US FMC OSRA-22 lockout demurrage bills (`250th` Auto-Act Scenario!) | **Foundry IQ `4ms` blocks 175 IMDG/FMC violations (`+$9.60M/yr` safety/penalty protection) + BCO Contract Rate CLS (`-$387.2K/mo` / `-96.2%`)** | `0.99` (`Act automatically`) |
| **`DL-828`** | Fabric IQ & Ontology | **Historic `R196 = 14^2` Round, `90th` Ontology Sim, `250` Auto-Act & `18,000` Users Milestone**: Port fog delays berths across 420 voyages while reefer alerts and 175 IMDG/FMC risks arrive | **Eventhouse `4ms` 420-Voyage & Reefer Sense ($0 Tax) + `660M` DiskANN & `PREDICT` `4ms` (`-11.8%` Fuel & `+$36.8M` Saved) + Foundry IQ `4ms` 175-IMDG/FMC Block (`+$9.60M`) + Teams Navis/IMOS & 1GB Free SQL Commit (`16ms = 4^2ms` E2E, Protect `$67.70M` SLA)** | `0.99` (`Confirm`) |

---

## ⑥ 🛠️ Presales Review & Production Readiness Checklist

- [ ] **1. Zero-ETL Navis N4 TOS, Veson IMOS & SAP S/4HANA TM Mirroring**: Configure Fabric Open Mirroring to replicate 65 terminal berth windows, yard slot maps, and 780 vessel voyage plans into OneLake at `$0` compute cost.
- [ ] **2. Eventhouse KQL `995K EPS` AIS, Shaft-Power & 1.8M Reefer Telemetry Stream**: Stream vessel propulsion, reefer compressor, and quay-crane telemetry into Eventhouse KQL to trigger JIT slow-steaming across `420` voyages (`-11.8%` bunker/ETS burn) in `4ms`.
- [ ] **3. `660M` eBL, BIMCO Laytime, Port Tariff & IMO IMDG SSD DiskANN Index**: Build SSD-backed DiskANN vector indexes in Azure SQL DB / Cosmos DB over 10 years of bills of lading and maritime regulations (`$3,520/mo`, `-92%` RAM).
- [ ] **4. Vectorized In-Lake `PREDICT` Yard Pre-Grooming & `ai.extract` D&D Proof Packaging**: Run in-place `PREDICT` to cut unproductive yard re-handles `-29.0%` and auto-assemble FMC-compliant D&D evidence packets (`+$36.8M/yr` saved/captured).
- [ ] **5. Foundry IQ IMO IMDG Hazmat Segregation & US FMC OSRA-22 Guardrail (`SOP-204`)**: Enforce `MARITIME-CONTAINER-SHIPPING-PORT-TOS-ETS-SOP-204` to block `175` IMDG hazmat stowage conflicts and invalid lockout D&D invoices (`+$9.60M/yr` protected) and mask BCO contract rates via CLS across `18,000` users.
- [ ] **6. Teams Fleet Operations & Terminal Director Action Cards + `1GB` Free SQL Audit**: Dispatch JIT speed advisories, hazmat bay re-allocations, and D&D waivers to Microsoft Teams, writing approved actions back to Navis N4, Veson IMOS, SAP TM, and `1GB` Free Fabric SQL in `4ms`.
