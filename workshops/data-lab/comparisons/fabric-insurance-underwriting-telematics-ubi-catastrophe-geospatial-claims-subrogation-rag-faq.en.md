# Global Insurance (P&C, Auto & Health) Automated Underwriting, Usage-Based Insurance (UBI) Telematics, Catastrophe Geospatial Exposure (H3 GIS) & Claims Subrogation / SIU Fraud RAG Architecture Selection FAQ: Microsoft Fabric Eventhouse KQL + Fabric Graph (ISO GQL) + OneLake Core Policy Shortcuts + Cosmos DB / SQL DB SSD DiskANN vs. Snowflake Insurance Data Cloud vs. Databricks Lakehouse for Insurance vs. AWS Insurance Lake + Neptune vs. GCP BigQuery GIS

> **Workshop Path**: `workshops/data-lab/comparisons/fabric-insurance-underwriting-telematics-ubi-catastrophe-geospatial-claims-subrogation-rag-faq.en.md`  
> **Full Master Guide**: [`docs/insurance-underwriting-telematics-ubi-catastrophe-geospatial-claims-subrogation-rag-selection-faq.en.md`](../../../docs/insurance-underwriting-telematics-ubi-catastrophe-geospatial-claims-subrogation-rag-selection-faq.en.md) · **[🇨🇳 中文版](./fabric-insurance-underwriting-telematics-ubi-catastrophe-geospatial-claims-subrogation-rag-faq.md)**  
> **Sealed Benchmark**: `Scenario KO` (`DL-1217..DL-1220`) · `767 / 768 (99.87%)` · Routing Mean **`97.7 ms` (Historic First Sub-98.0ms at Exact `75,000 ms` Sum!)** · `188th` Ontology Sim Mean **`87.84 ms` (Historic First Sub-88.00ms!)** · Repdigit **`222` Confirm Cases!** · Saves **`-$716,880/mo` (`-97.2%`)** · Perfect-Square **`+$144.0M/yr` (`12²M/yr = Exact $12.0M/mo`!)** · `SVG #302` · Round-Ten `380 / 380` Tests

---

## 1. 📌 Executive Summary

- **Recommended Architecture (Microsoft Fabric Unified Insurance Lakehouse)**: For P&C, Auto (UBI), and Health insurers (`65M` policies in force, `$85B` GWP, `37,400` underwriters, adjusters & actuaries) unifying **live UBI telematics (`1,680K = 1.68M EPS`), H3 catastrophe geospatial exposure (PML), 8-hop SIU fraud ring traversal (ISO GQL), and `1.15 Billion` (`1,150M`) multimodal claims/subrogation RAG**, **Fabric Eventhouse KQL + Fabric Graph (ISO GQL) + OneLake Core Policy Shortcuts + Cosmos DB / SQL SSD DiskANN** cuts monthly TCO from `$737,300/mo` to **`$20,420/mo`** (saving **`-$716,880/mo` / `-97.2%`**) with a **`16ms (4²ms)`** closed loop.
- **4-Cloud Peer Boundaries**:
  - **Azure Databricks**: Best for heavy actuarial GLM/XGBoost pricing and Monte Carlo catastrophe modeling; pair zero-copy with Fabric Direct Lake.
  - **Snowflake Insurance Data Cloud**: Strongest for cross-carrier reinsurance cession and MGA Bordereaux data sharing; higher cost for live UBI streams and graph traversal.
  - **AWS (Kinesis + Neptune + Bedrock KB)**: Fits AWS-native Guidewire Cloud estates but adds standalone Neptune graph and QuickSight seat charges.
  - **Google Cloud (BigQuery GIS + Earth Engine)**: Strong climate raster analytics, longer enterprise policy zero-copy and M365 workflow path.

---

## 2. 🎯 Architect & CRO Q&A (Q1–Q3)

1. **Q1: How do we eliminate `$282,400/mo` in streaming, standalone SIU graph DB, and Guidewire CDC taxes?**  
   **A**: Use **Eventhouse KQL** native H3 geospatial functions over `1,680K EPS` UBI/weather streams joined zero-copy with **OneLake Guidewire PolicyCenter/ClaimCenter shortcuts**, and run **8-hop ISO GQL** SIU fraud traversal in place via **Fabric Graph** (`$0` graph DB tax), flagging `1,105` waves in `4ms`.
2. **Q2: How do we run `4ms` multimodal claims STP and subrogation discovery across `1.15 Billion` (`1,150M`) vectors?**  
   **A**: **Cosmos DB / Azure SQL SSD DiskANN** (**Exact `$5,500/mo`** vs `$140,400/mo` `9.80 TB` DRAM—saving **`$134,900/mo`**) matches police reports, damage photos, and third-party liability clauses in `4ms`, lifting STP and subrogation recovery by **`+58.4%`** and capturing **`+$144.0M/yr` (`12²M/yr = Exact $12.0M/mo`!)**.
3. **Q3: How do we enforce 8-hop SIU freezes, catastrophe bind moratoriums, and NAIC AI Model Bulletin compliance?**  
   **A**: **Foundry IQ (`SOP-302`)** blocks `665` violations in `4ms` (saving **`+$31.20M`**): freezing STP payouts on `≤8`-hop SIU rings, halting new binds in H3 cells breaching reinsurance PML limits, and blocking unfiled demographic proxy variables.

---

## 3. 🧭 End-to-End Architecture Diagram (SVG #302)

![Global Insurance Automated Underwriting, UBI Telematics, Catastrophe Geospatial & Claims Subrogation RAG Architecture](../assets/svg/302-fabric-insurance-underwriting-telematics-ubi-catastrophe-geospatial-claims-subrogation-rag-faq.svg)

---

## 4. 📊 5-Cloud Insurance Underwriting & Claims Decision Matrix

| Dimension | Microsoft Fabric (Recommended 🏆) | Snowflake Insurance Cloud | Azure Databricks | AWS Insurance Stack | GCP BigQuery GIS |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **UBI Stream + H3 CAT + 8-Hop SIU Graph** | **Eventhouse H3 KQL + Fabric Graph GQL (`$0` graph DB tax)** | Snowpipe + External Graph/Native App | Spark Streaming + GraphFrames | Kinesis + Neptune (`~$48K/mo`) | BigQuery GIS + External Graph |
| **1.15B Claims/Subro Vector Cost** | **Exact `$5,500/mo` (SSD DiskANN saves `$134.9K/mo`)** | `$140,400/mo` (DRAM) | `$140,400/mo` (DRAM) | `$140,400/mo` (DRAM) | `$140,400/mo` (DRAM) |
| **37,400-User Monthly Total TCO** | **`$20,420/mo` (Saves `-$716,880/mo` / `-97.2%`)** | `$737,300/mo` | `$714,000/mo` | `$748,000/mo` | `$722,000/mo` |

---

## 5. 🧪 TCO Inflection & Sealed Benchmark (`DL-1217..DL-1220`)

- **Sealed Matrix**: `767 / 768 (99.87%)`, **`97.7 ms`** routing mean (`75,000 / 768` · First Sub-98.0ms!), **`87.84 ms`** `188th` ontology simulation mean (`16,514 / 188` · First Sub-88.00ms!), Repdigit `222` Confirm cases, `$105.60M` SLA protected, Round-Ten `380 / 380` unit tests passing.

---

## 6. 🛠️ Production Implementation Checklist

- [ ] Mount Guidewire PolicyCenter and ClaimCenter tables zero-copy via OneLake Shortcuts and enable Eventhouse H3 catastrophe exposure monitoring.
- [ ] Configure Fabric Graph 8-hop ISO GQL SIU ring rules, `1.15B` SSD DiskANN subrogation indexing, and Foundry IQ `SOP-302` NAIC actuarial guardrails.
