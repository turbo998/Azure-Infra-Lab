# 🏦 Retail Banking, Consumer Credit & Mortgage "Open-Banking Cash-Flow Underwriting + M0 Early-Delinquency Intervention + Compliant Collections Agent" Architecture Selection Guide (Architect Quick Reference)

> **Full Deep-Dive Selection Guide & 7-Card Benchmark**: See [`../workshops/data-lab/comparisons/fabric-retail-banking-consumer-credit-mortgage-collections-agent-faq.en.md`](../workshops/data-lab/comparisons/fabric-retail-banking-consumer-credit-mortgage-collections-agent-faq.en.md)  
> **Architecture Panorama SVG**: [`../workshops/data-lab/assets/svg/176-fabric-retail-banking-consumer-credit-mortgage-collections-agent-faq.svg`](../workshops/data-lab/assets/svg/176-fabric-retail-banking-consumer-credit-mortgage-collections-agent-faq.svg)  
> **中文版本**: [`retail-banking-consumer-credit-mortgage-collections-agent-selection-faq.md`](retail-banking-consumer-credit-mortgage-collections-agent-selection-faq.md)

## One-Sentence Selection Takeaway

For retail banks, card issuers, and mortgage lenders managing **45M accounts, `13,000` credit risk & branch staff, `995K EPS` open-banking cash-flow & payroll streams, and `540,000,000` (`540M`) tradeline & income-document vectors**, **Microsoft Fabric (`Eventhouse KQL + Activator` + `In-Lake Vectorized PREDICT` + `540M SSD DiskANN` + `Foundry IQ`)** compresses 14-day pre-delinquency detection, proactive hardship restructuring (`-38%` M1-to-M2 roll rate, `-$3.65M` ECL provisions), and ECOA/CFPB Reg F compliance gating from `1,240–2,390ms` down to **`23ms`** while setting a **new `-95.9%` TCO savings record** (`$14,600/mo` vs. `$352,200/mo`, **saving `$337.6K/mo`!**) and protecting **`$57.90M`** in annual credit and compliance SLAs.
