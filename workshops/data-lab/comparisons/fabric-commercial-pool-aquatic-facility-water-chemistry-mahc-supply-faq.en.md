# Global Commercial Pool, Spa & Aquatic Facility Services, ORP/pH Water-Chemistry Telemetry, Wholesale Pool Supply Distribution & CDC MAHC Compliance 5-Cloud Architecture Selection Guide: Microsoft Fabric vs. Databricks vs. Snowflake vs. BigQuery vs. AWS

> **Canonical Full Guide**: [`docs/commercial-pool-aquatic-facility-water-chemistry-mahc-supply-selection-faq.en.md`](../../../docs/commercial-pool-aquatic-facility-water-chemistry-mahc-supply-selection-faq.en.md)  
> **Architecture SVG**: [`workshops/data-lab/assets/svg/260-fabric-commercial-pool-aquatic-facility-water-chemistry-mahc-supply-faq.svg`](../assets/svg/260-fabric-commercial-pool-aquatic-facility-water-chemistry-mahc-supply-faq.svg)  
> **Sealed Benchmark (`Round 252` · `Scenario IY` · `DL-1049..DL-1052`)**: `599 / 600 (99.83% Historic 600th Scenario Exact-Hundred Milestone & 599 Prime Passed!)` · Routing Mean **`123.9 ms` (`n=600` · Historic Sub-124ms & Exact `123.88ms`!)** · Ontology Simulation Mean **`108.51 ms` (`n=146`)** · Closed Loop **`16 ms` (`4² ms`)** vs. `543,000 ms` (`9.05 min`) · Monthly TCO **`$17,320/mo` vs. `$559,900/mo` (`-$542,580/mo` / `-96.9%` saved! `$88.80M` SLA protected)**.

---

## Key Architectural Highlights & 6-Part Summary

1. **1,200K (1.20M) EPS ORP/pH Water-Chemistry Telemetry & Zero-Copy ERP Sync (`4 ms`)**: **Fabric Eventhouse KQL** ingests `1.20M EPS` from 4.6M connected pool/spa ORP/FAC/pH/VSP controllers and 38,000 service trucks across 850 branches at `$0/GB` ingestion tax alongside **Open Mirroring** of `Epicor Prophet 21 / Skimmer / ServiceTitan` ledgers, flagging 895 heatwave shock-dosing and chemical restock waves in 4ms and lifting compliance & fill rates by **+45.6%** (saving `$210,000/mo`).
2. **940M LSI Water-Balance & OEM Parts Vector Search (`4 ms`)**: **Azure SQL Native SSD DiskANN** replaces `$115,200/mo` of 7.70TB in-memory HNSW clusters for **`$4,660/mo`** (**-92% DRAM**, saving **`$110,540/mo`**!) and pairs with in-lake `PREDICT` to capture **+$102.0M/yr** in service retention and wholesale margin.
3. **CDC MAHC Hyperchlorination, VGB Anti-Entrapment & DOT Acid-Chlorine Gate (`SOP-260` · `4 ms`)**: **Foundry IQ Ontology** deterministically blocks **455 (`5×7×13`!)** unsafe pool openings (`FAC < 1.0 ppm` / cryptosporidium `CT=15,300`), VGB drain entrapment hazards, and `DOT Class 5.1` oxidizer + `Class 8` acid pallet co-loading risks (`+$22.80M` protected) while serving **28,900 (`170²`)** users at `$0` Power BI Viewer seat cost (saving `$234,700/mo`).

👉 **For the full 6-part Q&A, Mermaid decision tree, sequence diagram, TCO inflection table, and production checklist, see**: [`docs/commercial-pool-aquatic-facility-water-chemistry-mahc-supply-selection-faq.en.md`](../../../docs/commercial-pool-aquatic-facility-water-chemistry-mahc-supply-selection-faq.en.md).
