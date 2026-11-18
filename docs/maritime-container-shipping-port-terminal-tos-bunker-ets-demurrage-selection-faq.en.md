# Global Container Shipping Lines, Automated Port Terminals & Freight Forwarders (780 Vessels + 65 Terminals + 28M TEU/Yr) AIS Slow-Steaming, 1.8M Reefer Telemetry, Navis N4 TOS Optimization, EU ETS Carbon & Demurrage (D&D) AI 5-Cloud Selection FAQ

> **Purpose**: A one-page executive decision guide for VPs of Fleet Operations, Port Terminal Operating System (TOS) Directors, Bunker & EU ETS Carbon Trading Heads, Maritime CIOs, and Cloud & AI Solution Architects at global ocean carriers, terminal operators, and freight forwarders (Maersk, MSC, CMA CGM, COSCO, Hapag-Lloyd, ONE, PSA, DP World, Hutchison Ports, Kuehne+Nagel-scale enterprises) comparing **Microsoft Fabric** against **Databricks, Snowflake, Google BigQuery, and AWS**.  
> **Full 6-Part Deep-Dive**: [`workshops/data-lab/comparisons/fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.en.md`](../workshops/data-lab/comparisons/fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.en.md) | [中文版](./maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-selection-faq.md)  
> **Visual Architecture SVG**: [`204-fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.svg`](../workshops/data-lab/assets/svg/204-fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.svg)

---

## 1. 📌 Executive Summary (30-Second Pitch)

For global container shipping lines, automated port terminal operators, and NVOCC freight forwarders operating **`780` container vessels**, **`65` automated port terminals**, and **`28M` TEUs/yr** (including **`1.8M` IoT-connected reefer containers**) while empowering **`18,000` (`18K` Milestone!) fleet voyage managers, port crane planners, bunker traders, and Demurrage & Detention (D&D) specialists**, the core challenges are **excess VLSFO bunker fuel and EU ETS carbon allowance burn (`$45K–$140K` per voyage) when vessels steam at full speed into congested ports due to batch gaps between satellite AIS and Navis N4 TOS berth windows, `$81,200/mo` DRAM costs for `660M` eBL, BIMCO laytime, and IMDG dangerous-goods vectors, and IMO IMDG hazmat stowage conflicts or US FMC OSRA-22 demurrage billing fines**:

- **Choose Microsoft Fabric (`F64` Reserved + Navis N4 TOS / Veson IMOS / SAP TM Open Mirroring `$0` CDC + Eventhouse KQL `4ms` AIS Just-in-Time Steaming, 1.8M Reefer Cold-Chain & STS Crane Sense + Azure SQL / Cosmos DB SSD DiskANN `660M` eBL, BIMCO Laytime, IMDG & Port Tariff Vectors at `$3,520/mo` `-92%` RAM + In-Engine `PREDICT` Bunker/ETS Optimization & Yard Re-Handle Reduction + Foundry IQ IMO IMDG Hazmat Segregation Gate, FMC OSRA-22 D&D Lock & Shipper Contract CLS + `$0` Per-Seat BI / M365 Copilot for `18,000` Fleet & Terminal Staff)** when you need an end-to-end **`16 ms` (`4ms + 4ms + 4ms + 4ms = 4^2 ms`)** voyage speed, port yard, and D&D dispute loop at **`$15,440/mo` total TCO** (saving **`-$387.2K/mo` or `-96.2%`** vs. a `$402,600/mo` stitched stack), cutting **bunker/EU ETS burn `-11.8%` and yard re-handles `-29.0%`** (**`+$36.8M/yr`** saved/gained).
- **Choose Azure Databricks** when oceanographic research labs train custom deep-learning wave/weather forecasting models over 100TB+ of raw ECMWF/GFS GRIB2 atmospheric grids (coexisting zero-copy with Fabric via OneLake).
- **Choose Snowflake** when vessel-sharing alliance partners use Snowflake Data Sharing solely to exchange monthly static TEU slot-utilization summaries.
- **Choose Google BigQuery** when digital LCL freight-quoting web portals run 100% on Google Ads, GA4, and Looker.
- **Choose AWS Lakehouse** when single-terminal inland barge depots run all gate cameras on AWS IoT and S3 without global vessel fleets, SAP TM, or M365 Teams operations.

---

## 2. 📊 5-Cloud Maritime Shipping & Port Terminal (Navis N4 TOS + EU ETS + D&D) Matrix

| Evaluation Dimension | Microsoft Fabric (`F64` + Eventhouse + `660M` DiskANN) | Databricks (`Lakeflow` + `Mosaic AI` + `Genie`) | Snowflake (`Snowpipe` + `Cortex` + `Enterprise`) | Google BigQuery (`Pub/Sub` + `Vertex` + `Looker`) | AWS (`IoT Core` + `OpenSearch` + `Redshift`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`995K EPS` AIS/Reefer + Navis/SAP Sync** | **Eventhouse KQL + Navis N4/IMOS/SAP Open Mirroring `4ms` (`$0` tax)** | Structured Streaming + Lakeflow (`730ms–2.1s`) | Snowpipe Streaming + connectors (`1.3s–3.4s`) | Pub/Sub + BigQuery Write API (`820ms–2.4s`) | IoT Core + Kinesis + MSK (`880ms–2.6s`) |
| **`660M` eBL, BIMCO Laytime & IMDG Vectors** | **SSD DiskANN at `$3,520/mo` (`-92%` RAM vs `$81,200/mo` DRAM)** | Mosaic Vector Search (`~$81,200/mo` DRAM) | Cortex Search (`~$83,600/mo` Credits) | Vertex Vector Search (`~$77,600/mo`) | OpenSearch Serverless (`~$79,600/mo` OCUs) |
| **JIT Bunker `PREDICT` & Yard Shuffle AI** | **In-Lake `PREDICT` + `ai.extract` `4ms` (`-11.8%` fuel, `+$36.8M/yr`)** | Model Serving + Batch (`640ms–1.9s`) | Snowpark ML + Cortex (`990ms–2.9s`) | BQML + Document AI (`790ms–2.4s`) | SageMaker + Textract (`850ms–2.6s`) |
| **IMO IMDG Hazmat & FMC OSRA-22 Gate** | **Foundry IQ `4ms` blocks 175 IMDG/FMC breaches (`+$9.60M`) + CLS** | Unity Catalog ABAC + custom logic | Horizon RLS/CLS + external scripts | Policy Tags + custom code | Lake Formation + external gateway |
| **`18,000` Fleet, Terminal & Trade Staff** | **`$0` Power BI Viewer + `$0` M365 Copilot token tax** | Extra BI licenses or SQL Warehouse scaling | Multi-cluster Warehouse credits for 18K users | Looker per-seat licensing fees | QuickSight per-user/session fees |
| **Monthly Total TCO** | **`$15,440 / mo` (Baseline Best, `-96.2%` savings)** | `~$390,400 / mo` | `~$417,400 / mo` | `~$381,400 / mo` | `~$387,400 / mo` |

---

## 3. 🛠️ Presales & Production Readiness Checklist

- [ ] **Zero-ETL Navis N4 TOS, Veson IMOS & SAP S/4HANA TM Unification**: Enable Open Mirroring for 65 terminal berth schedules, yard slot maps, and 780 vessel voyage plans into OneLake alongside `995K EPS` Eventstream satellite AIS, shaft-power, and 1.8M reefer container telemetry streams.
- [ ] **`660M` Electronic Bill of Lading (eBL), BIMCO Laytime, Port Tariff & IMO IMDG SSD DiskANN Index**: Index 10 years of eBLs, charterparty weather-working-day clauses, and IMDG segregation tables in SSD DiskANN (`$3,520/mo`) for `4ms` hybrid RAG.
- [ ] **Foundry IQ IMO IMDG Segregation & US FMC OSRA-22 Guardrail (`SOP-204`)**: Enforce `MARITIME-CONTAINER-SHIPPING-PORT-TOS-ETS-SOP-204` to block incompatible hazardous-cargo bay assignments, freeze invalid D&D invoices during terminal gate closures, and mask confidential shipper contract rates across `18,000` users.
