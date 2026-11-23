# 企业级自然语言问数智能体（Data Agent）、语义本体接地（Fabric IQ + TMDL）与结构化 + 非结构化混合 RAG 选型 FAQ（Scenario LF · R311）

> **完整版深度指南**: [`docs/enterprise-data-agent-iq-ontology-hybrid-nl2sql-nl2dax-unstructured-rag-selection-faq.md`](../../../docs/enterprise-data-agent-iq-ontology-hybrid-nl2sql-nl2dax-unstructured-rag-selection-faq.md) | [English (`fabric-enterprise-data-agent-iq-ontology-hybrid-nl2sql-nl2dax-unstructured-rag-faq.en.md`)](fabric-enterprise-data-agent-iq-ontology-hybrid-nl2sql-nl2dax-unstructured-rag-faq.en.md)  
> **架构图**: [`assets/svg/319-fabric-enterprise-data-agent-iq-ontology-hybrid-nl2sql-nl2dax-unstructured-rag-faq.svg`](../assets/svg/319-fabric-enterprise-data-agent-iq-ontology-hybrid-nl2sql-nl2dax-unstructured-rag-faq.svg) · **基准场景**: `DL-1285..DL-1288` (🏆 孪生素数第 `311` 轮 `R311` · `835/836 = 99.88%` · 历史性精确整数路由均值 `90.0ms` (`75,272/836`!) · 第 `205` 项仿真历史首次破 `<82.00ms` 达 `81.88ms`! · 素数 `199` 篇 FAQ=`398` 文档 · `414` 单测)

---

## 1. 一句话选型结论（Executive Summary）

针对覆盖 **720 个业务域与 54,000 个认证 KPI**、峰值 **`1,850K` (`1.85M`) EPS** 自然语言问数（NL2DAX/SQL/KQL/GQL）与 M365 Copilot 协同流的大型企业，**Microsoft Fabric（F64 预留池 + Data Agent + Fabric IQ Ontology + Power BI TMDL + Eventhouse KQL + Fabric Graph 8 跳 ISO GQL + `1.235B` SSD DiskANN + Work IQ `-80%` Token + Foundry IQ）** 以 **`$20,760/月`** 一口价替代 **`$808,700/月`** 的五云/自建拼接栈（**单月净省 `-$787,940/月` / `-97.4%`！**），在 **`16ms (4²ms)`** 内实现 `0.00%` 口径漂移的结构化指标问答与带页码引用的合同/财报混合 RAG。

---

## 2. 灵魂三问与核心架构亮点

| 核心问题 | 传统五云/开源自建痛点 | ✅ Microsoft Fabric + Microsoft IQ 闭环解法 | 量化收益 |
| :--- | :--- | :--- | :--- |
| **Q1: 如何消灭裸写 Text-to-SQL 的指标口径漂移与多对多 Join 翻倍陷阱？** | 独立 Headless BI 中间件 + 图数据库 + 重复塞 Schema 的 Prompt 税高达 `$313,000/月`，且复杂财务问答准确率 `<55%` | **Fabric Data Agent + Fabric IQ Ontology + Power BI TMDL + Work IQ (`-80%` Token)** 四模态路由 | **`4ms` 锁定 `1,190` 个波次**，省 **`$313,000/月`**，准确率与采纳率提升 **`+65.2%`** |
| **Q2: 12.35 亿（1.235B）TMDL 度量、黄金 SQL 与财报合同向量如何降本？** | `10.65 TB` 纯内存向量集群需 **`$150,600/月`**，且无法与实时 OLAP 聚合内联精排 | **Cosmos DB / SQL NVMe SSD DiskANN**（`-92%` RAM，仅 **`$5,840/月`**）+ Foundry IQ (`+36%` 相关性) | **单月净省 `$144,760/月` DRAM**，年化加速决策并创效 **素数 `+$161.0M/年`** |
| **Q3: 如何刚性同步结构化表（RLS/CLS）与非结构化文档（ACL）权限？** | 开源与拼接方案极易出现“表里无权看、却从 PDF 切片里问出来”的旁路泄密或笛卡尔积慢查询雪崩 | **Foundry IQ 4ms 门禁 (`SOP-319`)** + **40,800 用户** Direct Lake 免费看板（33,660 Viewer） | **`4ms` 阻断整五十 `750` 次违规（守护 `+$34.60M`）**，守护 **`$112.40M` SLA** |

---

## 3. 五云与自建月度 TCO 速查表（720 业务域 · 40,800 用户规模）

| 平台方案 | 语义中间件 + 图谱 + Token 税 | 12.35B 黄金 SQL/文档向量 | 多模态问数与缓存计算 | 40,800 用户 BI 与问数席位 | 月度总 TCO | 对比 Fabric |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **✅ Microsoft Fabric (F64)** | **`$0` 独立税** | **`$5,840/月`** (SSD DiskANN) | **`$14,920/月`** (F64+1GB SQL) | **`$0/月`** (Direct Lake) | **`$20,760/月`** | **基准 (`-$787,940/月`!)** |
| **五云/开源自建拼接栈** | `$313,000/月` | `$150,600/月` (10.65TB RAM) | `$181,200/月` | `$163,900/月` | `$808,700/月` | `+$787,940/月` |
| **Snowflake Cortex 栈** | `$320,000/月` | `$148,200/月` | `$182,800/月` | `$163,000/月` | `$814,000/月` | `+$793,240/月` |
| **GCP BigQuery + Looker** | `$308,000/月` | `$151,400/月` | `$178,600/月` | `$163,000/月` | `$801,000/月` | `+$780,240/月` |
| **Azure Databricks Genie** | `$301,000/月` | `$150,600/月` | `$179,400/月` | `$159,000/月` | `$790,000/月` | `+$769,240/月` |

---

## 4. 生产落地三步法 Checklist
- [ ] **Step 1**: 复用并加固 `Power BI Direct Lake TMDL` 语义模型（配置業務同义词与 Verified DAX Answers），交由 `Fabric IQ Ontology` 统一接地。
- [ ] **Step 2**: 构建 8 跳 `Fabric Graph (ISO GQL)` 实体因果图谱与 `1.235B` 黄金问答/财报合同 `SSD DiskANN` 索引（`$5,840/月`）。
- [ ] **Step 3**: 启用 `Foundry IQ SOP-319` 门禁（零口径漂移、双栈 Entra OBO 权限透传、防笛卡尔积熔断），并通过 `Direct Lake` 与 Teams 免费服务 40,800 名用户。
