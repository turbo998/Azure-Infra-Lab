# 🔬 Data Lab — 企业级 Data & AI 平台架构选型与 Diamond 实战沙盘实验室

> **语言版本 / Language**: **🇨🇳 中文 (`README.md`)** | **[🇬🇧 English (`README.en.md`)](README.en.md)**  
> **⚡ 快捷入口 / Quick Access**: **[💎 Diamond 企业级演示中心](demos/diamond-hub.html)** · **[📺 TCL × Fabric 6幕指挥舱](demos/tcl-fabric/index.html)** · **[🛒 Zava × Databricks & Fabric 沙盘](demos/databricks-fabric/index.html)** · **[⚔️ Databricks vs Fabric 10维战卡](demos/databricks-fabric/battlecard.html)** · **[🧭 五云交互选型与 TCO 工作台](index.html)** · **[📊 7-Card 基准测试报告](benchmark-cards.html)**

面向 **AI Solution Architect (SA)** 的企业级数据与智能平台选型实验室：深度对标 **Microsoft Fabric**（OneLake · Direct Lake · Eventhouse · Fabric IQ Ontology）与 **Azure Databricks**、**Snowflake**、**GCP BigQuery**、**AWS Lakehouse**，提供 **2套全脱敏企业级交互实战沙盘 (Diamond Enterprise Demo Suite)**、**81=9² 篇（双语 162 篇！）企业架构选型 FAQ** 及 **密封可复现基准测试套件 (`363 / 364 = 99.73%`, 突破 Sub-200ms `199.3ms` 路由均值, `178 / 178` 单测通过)**。

---

## 一、核心交互工作台与评测报告（Quick Launch）

| 核心资产 | 面向角色与实战用途 | 在线/本地入口 |
| :--- | :--- | :--- |
| **💎 Diamond 企业级实战演示中心** | 统一汇聚 TCL × Fabric 与 Zava × Databricks & Fabric 双旗舰沙盘、双屏逐字稿与客户画像选型路由 | [`demos/diamond-hub.html`](demos/diamond-hub.html) · [English](demos/diamond-hub.en.html) |
| **📺 TCL 海外渠道智能 × Fabric (6 幕指挥舱)** | OneLake 零拷贝挂载 EDI 852 + Eventhouse 港口预警 + Fabric IQ 本体护栏 + 云端 Pipeline 调拨闭环 | [`demos/tcl-fabric/index.html`](demos/tcl-fabric/index.html) · [双屏讲稿](demos/tcl-fabric/playbook.html) |
| **🛒 Zava 全渠道生鲜 × Databricks & Fabric** | Unity Catalog 动态脱敏 (`mask_cn_phone`) + AI/BI Genie 5 轮毛利异动归因 + Mirrored UC Direct Lake | [`demos/databricks-fabric/index.html`](demos/databricks-fabric/index.html) · [10维战卡](demos/databricks-fabric/battlecard.html) |
| **🧭 Data Lab 五云选型与 TCO 仿真工作台** | 六维竞对评分罗盘、500 用户动态 TCO 计算器、Fabric IQ 行业本体与越界熔断交互仿真 | [`index.html`](index.html) · [English](index.en.html) |
| **📊 7-Card 4:5 视觉基准测试报告** | 严格基于 `reports/report.json` 生成的 7 卡纵向评测卡组（`363/364 = 99.73%` · 突破 `<200ms` 均值达 `199.3ms` · `81=9²` 篇 FAQ · `DL-23` 显式边界标注） | [`benchmark-cards.html`](benchmark-cards.html) · [English](benchmark-cards.en.html) |

---

## 二、81=9² 篇（双语 162 篇）企业级 Data + AI 架构选型 FAQ 精选索引（SA Decision Guides）

所有选型指南均遵循清晰的架构师决策范式（Executive Summary、核心场景问答、架构流向图、多云对比矩阵、落地核查清单），剔除晦涩无关的机械/物理推导，聚焦真实企业 IT 与业务架构：

### A. 平台底座核心架构选型（Core Platform Capabilities）
- **跨云零拷贝与本体选型**：[OneLake Shortcuts & Fabric IQ vs 四大云选型 FAQ](comparisons/fabric-onelake-iq-vs-4clouds-selection-faq.md) · [EN](comparisons/fabric-onelake-iq-vs-4clouds-selection-faq.en.md)
- **实时流与亚秒级闭环**：[Eventhouse KQL vs Snowflake Dynamic Tables vs Databricks Lakeflow](comparisons/fabric-realtime-eventhouse-vs-4clouds-streaming-faq.md) · [EN](comparisons/fabric-realtime-eventhouse-vs-4clouds-streaming-faq.en.md)
- **零 ETL 数据库镜像 vs CDC**：[Fabric Mirroring vs Debezium + Kafka vs Fivetran 选型 FAQ](comparisons/fabric-oltp-to-olap-zero-etl-mirroring-vs-debezium-kafka-fivetran-faq.md) · [EN](comparisons/fabric-oltp-to-olap-zero-etl-mirroring-vs-debezium-kafka-fivetran-faq.en.md)
- **开放表格式互通**：[OneLake Iceberg ↔ Delta UniForm vs Polaris / BigLake](comparisons/fabric-onelake-iceberg-delta-uniform-vs-4clouds-faq.md) · [EN](comparisons/fabric-onelake-iceberg-delta-uniform-vs-4clouds-faq.en.md)
- **企业级向量与混合检索**：[Azure AI Search + SSD DiskANN vs pgvector vs Mosaic AI vs Milvus](comparisons/fabric-enterprise-vector-hybrid-search-ai-search-pgvector-mosaic-milvus-faq.md) · [EN](comparisons/fabric-enterprise-vector-hybrid-search-ai-search-pgvector-mosaic-milvus-faq.en.md)
- **数据治理与权限透传**：[OneLake Catalog + Purview + Entra OBO vs Unity Catalog ABAC](comparisons/fabric-enterprise-data-governance-rls-cls-obo-catalog-faq.md) · [EN](comparisons/fabric-enterprise-data-governance-rls-cls-obo-catalog-faq.en.md)
- **自然语言问数智能体**：[Fabric Data Agent vs Databricks AI/BI Genie vs Snowflake Cortex](comparisons/fabric-enterprise-data-agent-text2sql-fabric-genie-cortex-oss-faq.md) · [EN](comparisons/fabric-enterprise-data-agent-text2sql-fabric-genie-cortex-oss-faq.en.md)
- **Medallion 批流一体架构**：[铜-银-金分层与 Lambda / Kappa 选型指南](comparisons/fabric-medallion-lakehouse-lambda-kappa-streaming-batch-architecture-faq.md) · [EN](comparisons/fabric-medallion-lakehouse-lambda-kappa-streaming-batch-architecture-faq.en.md)
- **五云 TCO 成本拐点与迁移**：[五大云数据平台 TCO 精算与零停机现代化迁移指南](comparisons/fabric-five-cloud-data-platform-tco-inflection-migration-faq.md) · [EN](comparisons/fabric-five-cloud-data-platform-tco-inflection-migration-faq.en.md)
- **容量治理、私有网络与容灾**：[Capacity FinOps & Surge Protection](comparisons/fabric-capacity-finops-surge-rayfin-vs-4clouds-faq.md) · [Managed VNet & Private Link](comparisons/fabric-private-link-managed-vnet-security-vs-4clouds-faq.md) · [跨区域容灾 BCDR & CMK](comparisons/fabric-bcdr-cross-region-cmk-recovery-vs-4clouds-faq.md) · [多云 FOCUS 1.0 FinOps、AI Token 分摊与 SaaS 回收](comparisons/fabric-enterprise-it-finops-cloud-cost-license-optimization-aiops-faq.md)

### B. 主流行业解决方案架构选型（Enterprise Industry Solutions）
- **零售电商、酒旅集团、民航客货运、农业食品与全渠道供应链**：[零售 Customer 360 与实时导购补货](comparisons/fabric-retail-ecommerce-customer360-realtime-recommendation-agent-vs-4clouds-faq.md) · [跨境电商海外仓 WMS 与 FinOps](comparisons/fabric-cross-border-ecommerce-global-supply-chain-finops-faq.md) · [万店餐饮生鲜冷链与动态打折](comparisons/fabric-qsr-fmcg-chain-store-operations-coldchain-markdown-faq.md) · [快消饮料 TPO 通路促销与 POS 需求感知](comparisons/fabric-cpg-beverage-trade-promotion-demand-sensing-hedging-faq.md) · [时尚鞋服与奢侈品 RFID 尺码配补与退货防伪](comparisons/fabric-luxury-apparel-footwear-merchandising-rfid-clienteling-returns-faq.md) · [1.6亿会员可组合 CDP、实时旅程与数据净室归因](comparisons/fabric-retail-loyalty-cdp-marketing-automation-cleanroom-attribution-faq.md) · [酒店集团、综合度假村与邮轮 9,200 家物业实时收益管理 RevPAR、MICE 团客报价与 1.9 亿会员礼宾](comparisons/fabric-hospitality-hotel-cruise-revenue-management-revpar-loyalty-concierge-faq.md) · [农业食品加工与大宗粮商 $52B 贸易基差对冲、地磅 NIR 混仓与 FSMA 204 / EUDR 溯源](comparisons/fabric-agribusiness-grain-trading-food-processing-commodity-risk-fsma204-faq.md) · [民航客货运、航司 IOC 运控与机务 MRO 950 架飞机防 AOG、机组恢复与 NDC 定价](comparisons/fabric-airline-aviation-ioc-crew-recovery-mro-aog-ndc-pricing-faq.md)
- **金融银行、支付收单（PayFac）、投研、保险与专业服务（咨询/律所）**：[金融投研混合 RAG + NL2DAX 智能体](comparisons/fabric-financial-research-hybrid-rag-text2sql-wealth-agent-vs-4clouds-faq.md) · [银行保险实时反欺诈与理赔图谱](comparisons/fabric-banking-insurance-realtime-antifraud-graph-claims-faq.md) · [零售信贷与智能催收合规](comparisons/fabric-retail-banking-consumer-credit-mortgage-collections-agent-faq.md) · [商业银行对公 ISO 20022 现金池、UCP 600 贸易融资 AI 审单与 pKYC](comparisons/fabric-corporate-commercial-banking-treasury-trade-finance-kyc-aml-faq.md) · [买方资管盘中归因、私募信贷 PCAP AI 与 1.5万投顾门户](comparisons/fabric-wealth-asset-management-portfolio-risk-esg-client-reporting-faq.md) · [专业服务、管理咨询、四大事务所与律所 PSA 稼动率、WIP 变现与信息屏障](comparisons/fabric-professional-services-legal-psa-utilization-wip-billing-conflict-check-faq.md) · [商业财产险（P&C）ACORD 智能核保、代位追偿挖掘与 10 跳 SIU 反欺诈图谱](comparisons/fabric-commercial-insurance-p-and-c-underwriting-acord-subrogation-claims-faq.md) · [全球支付收单、聚合支付（PayFac/PSP）4,800 万商户 ISO 8583 智能路由、Visa CE 3.0 拒付抗辩与反套现图谱](comparisons/fabric-payment-acquiring-payfac-iso8583-auth-routing-chargeback-aml-faq.md)
- **制造、SAP ERP、工程建设、商业地产、车队租赁与汽车供应链**：[集团多 ERP (SAP S/4HANA ACDOCA) 零拷贝合并与司库](comparisons/fabric-enterprise-erp-sap-s4hana-acdoca-treasury-finops-faq.md) · [制造汽车多级库存协同与车联网维保](comparisons/fabric-manufacturing-automotive-supply-chain-connected-vehicle-maintenance-faq.md) · [企业人力资源 (Workday/SAP) 编制协同与 Work IQ 技能图谱](comparisons/fabric-enterprise-hr-people-analytics-workforce-planning-skills-copilot-faq.md) · [集团战略采购 S2P、全局 Spend Cube 与合同 AI](comparisons/fabric-enterprise-procurement-source-to-pay-supplier-risk-contract-ai-faq.md) · [B2B 工业与电子分销 150 万 SKU 动态 CPQ 报价、BOM 替代与 SPA 返利核销](comparisons/fabric-b2b-wholesale-distribution-dynamic-pricing-cpq-rebate-inventory-faq.md) · [EPC 工程总承包与基建 BIM 5D 算量控本、P6 关键路径延误与分包变更 AI 审价](comparisons/fabric-epc-construction-bim-5d-schedule-risk-subcontractor-change-order-safety-faq.md) · [商业地产与 REITs 8,500 栋楼宇 BACnet 暖通削峰、ASC 842 租约抽取与 CAM 自动对账](comparisons/fabric-commercial-real-estate-reit-smart-building-bms-lease-cam-esg-faq.md) · [商用车队与重型设备租赁 120 万台资产 J1939 预测维保、退租残值与原厂保修索赔](comparisons/fabric-commercial-fleet-equipment-leasing-telematics-residual-value-remarketing-faq.md)
- **医疗医药、医疗器械（MedTech）、电信、教育与 SaaS**：[医疗医药商业合规与 RWE OMOP 分析](comparisons/fabric-healthcare-pharma-commercial-compliance-rwe-analytics-faq.md) · [B2B SaaS 与游戏多租户嵌入式分析](comparisons/fabric-saas-gaming-multitenant-embedded-analytics-retention-attribution-faq.md) · [电信客户防流失与 5G 专网 SLA](comparisons/fabric-telecom-customer-churn-network-ops-field-agent-faq.md) · [寿险健康险 AI 病历核保、PBM 处方反欺诈与 IFRS 17 精算](comparisons/fabric-life-health-insurance-underwriting-pbm-pharmacy-fraud-actuarial-faq.md) · [医院集团床位/手术室排程与 RCM 拒付申诉 AI](comparisons/fabric-hospital-provider-network-patient-flow-revenue-cycle-denials-faq.md) · [高等教育与全球 EdTech 120 万学习者 xAPI 自适应学习、退学预警与科研经费合规](comparisons/fabric-higher-education-edtech-adaptive-learning-student-retention-grant-compliance-faq.md) · [医疗器械与医学影像 68 万台在网设备预测性维保、FDA eMDR 筛查与现场服务](comparisons/fabric-medtech-medical-device-connected-fleet-uptime-fda-mdr-field-service-faq.md)

---

## 三、💎 Diamond 企业级实战演示专区（TCL × Fabric & Zava × Databricks）

为客户高管交流与架构工作坊打造的 **100% 脱敏双旗舰交互演示套件**：

1. **📺 TCL 海外多级渠道智能 × Microsoft Fabric（6 幕作战指挥舱）**
   - **架构链路**：`OneLake Shortcuts (零拷贝挂载外部代理商 EDI 852)` → `Silver/Gold Lakehouse & Warehouse` → `Eventhouse KQL (港口延误与门店 POS 秒级监控)` → `Fabric IQ Ontology (10 实体 + 价保条款护栏)` → `Data Agent + Operations Agent + Data Factory Pipeline`。
   - **量化业务价值**：法→德 48h 调拨护航 **`$629.7K`** 黑五营收；声霸卡捆绑替代全网降价净省 **`$582.1K`** 毛利；自动冻结越南渠道季度末压货异常返利 **`$162.5K`**。
   - **入口**：[启动 6 幕指挥舱 (`demos/tcl-fabric/index.html`)](demos/tcl-fabric/index.html) · [双屏逐字稿手册 (`demos/tcl-fabric/playbook.html`)](demos/tcl-fabric/playbook.html)

2. **🛒 Zava 全渠道生鲜零售 × Azure Databricks & Microsoft Fabric（4 幕零拷贝共生沙盘）**
   - **架构链路**：`Lakeflow Declarative Pipelines (自动隔离 24 条脏数据)` → `Unity Catalog (mask_cn_phone 动态脱敏 + YAML Metric View)` → `AI/BI Genie 5 轮连环归因` → `Mirrored Unity Catalog in OneLake` → `Power BI Direct Lake`。
   - **量化业务价值**：5 分钟穿透定位华东净毛利暴跌 **`-3.1pp`** 根因（昆山二号冷链仓分拣升级导致出库延迟飙升至 **`17.3h`**），自动匹配嘉兴一号仓 **`1,460 箱`**富余生鲜优先支援上海静安等 Top 5 旗舰店。
   - **入口**：[启动 4 幕沙盘 (`demos/databricks-fabric/index.html`)](demos/databricks-fabric/index.html) · [10 维选型与共生战卡 (`demos/databricks-fabric/battlecard.html`)](demos/databricks-fabric/battlecard.html)

---

## 四、本地验证与基准复现（Verification）

```bash
python -m unittest discover -s workshops/data-lab/tests -p "test_*.py"
```
- **密封评测基线 (`reports/report.json`)**：`363 / 364` 决策场景通过 (**`99.73%` 历史新高准确率**，`DL-23` 显式保留为单区 LRS 合规升级人工审批反例)，**路由矩阵均值首次突破 `<200ms` 达 `199.3 ms`**，87 项企业本体闭环仿真均值 `171.24 ms`（达成**`81 = 9²` 篇精选 FAQ（双语 162 篇）与 Sub-200ms 路由均值里程碑**），`178 / 178` 单元测试全绿。
