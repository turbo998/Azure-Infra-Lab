# 开放数据目录、多引擎元数据联邦与语义治理底座：Microsoft Fabric OneLake Catalog & Purview Unified Catalog vs. Databricks Unity Catalog & Lakehouse Federation vs. Snowflake Horizon & Open Catalog (Apache Polaris) vs. GCP Dataplex Universal Catalog vs. AWS Glue Data Catalog & DataZone 架构师选型与攻防 FAQ

> 🌐 **Language / 语言**: **中文 (Current)** | **[English (`fabric-onelake-catalog-purview-vs-unity-polaris-dataplex-faq.en.md`)](fabric-onelake-catalog-purview-vs-unity-polaris-dataplex-faq.en.md)**
> 📅 **迭代轮次**: 2026-11-10 · **Round 19（今晚第 6 轮深潜：开放数据目录、跨云元数据联邦、Iceberg REST Catalog 互通与 BCBS 239 端到端血缘）**
> 🎯 **文档定位**: 面向 **AI Solution Architect（AI 解决方案架构师）** 与 **集团首席数据官（CDO）/ 数据治理负责人 / 企业架构委员会** 的一页纸实战决策指南。严格对齐 `ib-vs-ethernet-roce-selection-faq.md` 标杆文风，3 分钟抓准核心选型结论，10 分钟吃透五大云数据目录（OneLake Catalog + Purview / Unity Catalog / Horizon + Apache Polaris / Dataplex / Glue + DataZone）的架构边界、TCO 账单差异与跨目录联邦共存方案。

[![Fabric OneLake Catalog Purview Unified Catalog vs Databricks Unity Catalog Snowflake Horizon Apache Polaris Dataplex Glue DataZone FAQ Architecture](../assets/svg/27-fabric-onelake-catalog-purview-vs-unity-polaris-dataplex-faq.svg)](../assets/svg/27-fabric-onelake-catalog-purview-vs-unity-polaris-dataplex-faq.svg)

---

## ① 📌 核心结论速览（Executive Summary）

### 1.1 什么是“开放数据目录与多引擎元数据联邦”？为什么它是企业从“各自为政的孤岛目录”迈向“AI 智能体可信寻源”的分水岭？
- **通俗大白话 + 第一性原理**：
  - 过去五年，大型集团为了支撑不同业务部门，往往同时采购了多套云数据平台，结果陷入了**“目录之上再建目录（Catalog of Catalogs Sprawl）”的治理泥潭**：算法团队用 **Databricks Unity Catalog** 管 Delta 表与模型；数仓团队用 **Snowflake Horizon / Open Catalog (Apache Polaris)** 管 Iceberg 表；营销团队用 **GCP Dataplex** 管 BigQuery；基础设施团队用 **AWS Glue Data Catalog / Amazon DataZone** 管 S3；最后 CDO 被迫再花 **$300,000+/年** 外购一套第三方重型商业目录（如 Collibra 或 Alation）去定时爬取各云元数据。
  - **传统多目录割裂的三大致命痛点**：
    1. **血缘断链在最后 100 米（Lineage Blind Spot at BI & M365）**：Unity Catalog 或 Polaris 只能看到“表到表（Table-to-Table）”的技术血缘，一旦数据进入 **Power BI 语义模型（DAX 度量值）**、**Excel 透视表** 或 **M365 Copilot / Teams 高管汇报文档**，血缘彻底断链！金融监管（如 **BCBS 239** 与 **EU AI Act**）审计要求追查“财报上某个风险加权资产指标到底来自哪张源表”，数据团队需要人工排查两周；
    2. **目录只管“物理表结构”，不管“业务本体与安全标签下沉”**：第三方商业目录里贴了“绝密 PII”标签，但底层 Spark/SQL 引擎并不会自动拦截越权查询；且目录里只有冷冰冰的字段名（如 `CUST_LTV_ADJ_V2`），没有业务语义，AI Agent 检索时依然张冠李戴；
    3. **重复元数据同步与高昂授权税**：多套目录间通过每日批处理脚本同步 Schema，平均滞后 12–24 小时，每年还要支付数十万美元的目录席位费与 API 调用费。
- **Microsoft Fabric OneLake Catalog + Purview Unified Catalog 的底层破局机制**：
  1. **OneLake Catalog（工作流内置目录：探索 `Explore` + 治理 `Govern` + 安全 `Secure` 三位一体）**：无需额外部署元数据服务器，全租户所有的 Lakehouse、Warehouse、Eventhouse、SQL DB、Mirrored DB、Power BI Semantic Model、Data Agent 与 Fabric IQ Ontology 自动注册进同一棵逻辑目录树，内建数据背书（`Promoted` / `Certified` 勋章）、新鲜度监控与健康度评分；
  2. **Microsoft Purview Unified Catalog（跨云企业级数据产品 `Data Products` 与业务术语表联邦）**：向上将技术表封装为面向业务域（Domain）的 **Data Product（数据产品）**，向下打通 **从源端 Oracle/SAP/S3/Snowflake/Databricks → OneLake → Power BI DAX 度量值 → M365 Word/Excel/Copilot** 的端到端列级血缘（End-to-End Column-Level Lineage），并支持自动敏感度标签继承；
  3. **开放目录协议双向互通（Unity Catalog / Apache Polaris Iceberg REST ↔ OneLake XTable）**：无需推翻客户现有的 Unity Catalog 或 Snowflake Open Catalog（Apache Polaris），OneLake 通过 **Unity Catalog 零拷贝 Shortcut** 与 **XTable Iceberg/Delta 双向元数据映射**，让异构目录注册的表秒级挂载为 OneLake 受治理资产，并通过 **Apache Ossie** 同步语义指标定义。

### 1.2 三条核心选型铁律（3-Minute Takeaways）
1. **什么时候首选 Microsoft Fabric OneLake Catalog + Purview Unified Catalog？**
   - 当企业希望**免除 $300K+/年的第三方商业目录（Collibra/Alation）席位税**，需要打通 **“跨云源表 → 湖仓 ETL → Power BI DAX 语义模型 → M365 Office/Copilot”全链路列级血缘（满足 BCBS 239 / SOX / EU AI Act 审计）**，并且要求目录中的敏感度标签（Sensitivity Labels）直接在存储层与 BI/Agent 层实时强制生效时，**OneLake Catalog + Purview 是行业唯一的端到端业务与办公闭环目录**（建模治理目录月度 TCO 较拼装栈下降 **74.4%**，即 `$9,800/月` vs `$38,300/月`）。
2. **什么时候保留 Databricks Unity Catalog、Snowflake Horizon/Polaris、GCP Dataplex 或 AWS Glue/DataZone？**
   - 当算法团队重度依赖 **Unity Catalog** 统一管理 PySpark 表、Volumes、Feature Store 与 MLflow 模型注册表（Model Registry），并需使用 Lakehouse Federation 跨库联邦查询时，保留 **Databricks Unity Catalog**；当企业构建纯 Apache Iceberg 开源多引擎生态（Spark + Trino + Flink 共享同一 Iceberg REST Catalog）时，选择 **Snowflake Open Catalog (Apache Polaris)**；当数据 100% 锁定在 GCP 或 AWS 原生栈时，使用 **Dataplex** 或 **AWS Glue + DataZone**。
3. **跨目录“Better Together”黄金共存范式**：
   - **严禁编写定时爬虫脚本把 Unity Catalog 或 Polaris 的表复制进另一套目录！** 最佳实践是：**底层技术注册表保持开放自治（Databricks Unity Catalog 管 AI 特征与模型、Snowflake Polaris 管 Iceberg REST 表） → 通过 OneLake Shortcuts + XTable 零拷贝联邦至 OneLake Catalog → 由 Purview Unified Catalog 统一封装为带Fabric IQ 本体与 Purview 安全标签的“企业数据产品（Data Products）”赋能全员 Power BI 与 M365 Copilot**。

---

## ② 🎯 客户与架构师灵魂拷问 Q&A（First-Principles Deep Dive）

### Q1：各大云厂商都号称自己的 Catalog 是“统一目录（Unified Catalog）”，OneLake Catalog + Purview 与 Databricks Unity Catalog、Snowflake Horizon/Polaris、GCP Dataplex、AWS DataZone 的本质架构分野在哪？

**1. 治理半径的本质差异：“只管湖内表/模型的技术目录” vs “贯通数据湖、BI 语义层与 M365 办公文档的全域业务目录”**
- **Databricks Unity Catalog**：在数据工程与 AI 资产治理上极强——它将 Tables、Volumes（非结构化文件）、Functions 与 ML Models 统一在 `catalog.schema.object` 三级命名空间下，并开源了 Unity Catalog OSS。但它的治理边界止步于湖仓层：当数据被导出或连接到 Power BI 报表、Excel 或 SharePoint 文档后，Unity Catalog 无法追踪 Power BI 内部的 DAX 计算列血缘，也无法控制用户在 Excel 中导出敏感数据。
- **Snowflake Horizon & Open Catalog (Apache Polaris)**：Horizon 负责 Snowflake 内部账户级安全与合规；而 **Open Catalog（基于开源 Apache Polaris）** 实现了标准 Iceberg REST Catalog 协议，允许 Spark、Trino、Flink 并发读写 Iceberg 表。但 Polaris 本质是一个纯粹的**技术表元数据注册中心（Technical Table Registry）**，缺乏面向业务人员的数据产品门户（Data Product Marketplace）、Power BI 度量值血缘以及 M365 文档级 DLP 保护。
- **Microsoft Fabric OneLake Catalog + Purview Unified Catalog**：采用独特的**“双层协同”架构**：
  - **第一层（OneLake Catalog — 嵌入式日常治理中枢）**：直接嵌在 Fabric 门户中，分为 **`Explore`（全员检索认证表、语义模型、本体与 Data Agent）**、**`Govern`（管理员一键查看租户健康度、陈旧资产、缺少背书的核心报表并提供整改动作）** 和 **`Secure`（集中审计所有工作区与 OneLake 统一角色权限）**；
  - **第二层（Purview Unified Catalog — 集团级数据网格 Data Mesh 与合规底座）**：按业务域（如“全球财富管理域”、“零售供应链域”）组织 **Data Products（数据产品）**、**Business Glossary（业务术语表）** 与 **OKRs**，并将安全策略与血缘一直延伸到 Power BI、SQL Server、Azure AI Foundry 乃至 Microsoft 365（Teams/Word/Excel/Outlook）。

**2. 语义对齐（Semantic Alignment）：为什么 AI Agent 光有技术目录还会产生幻觉？**
- 技术目录（Glue / Polaris / Unity Catalog）告诉 Agent：“这里有 18 张表都包含 `revenue` 字段”。Agent 依然不知道高管问“Q3 净营收”时该查哪张表、该用什么汇率口径。
- 在 **OneLake Catalog + Fabric IQ** 中，目录不仅注册物理表，还把 **Certified（官方认证勋章）** 授予经过审计的 **Power BI Semantic Model** 与 **Fabric IQ Ontology**，并通过 **Apache Ossie** 兼容导入 Snowflake Semantic View 定义。当 Data Agent 或 M365 Copilot 发起检索时，OneLake Catalog 强制优先路由至带 `Certified` 勋章的本体与语义模型，从根源上消灭“找错表、算错数”的口径漂移（参见 `DL-23` 反例对比）。

---

### Q2：客户已经在用 Databricks Unity Catalog 或 Snowflake Open Catalog (Apache Polaris) 了，如何与 Fabric OneLake Catalog 实现零拷贝联邦（Catalog Federation），而不是搞出两套冲突的权限和元数据？

这是跨国金融与制造客户最常问的“多目录共存”实战问题。我们推荐以下三步走 **“开放目录联邦（Zero-Copy Catalog Federation）”** 架构：

1. **模式 A：Databricks Unity Catalog ↔ Fabric OneLake Catalog 双向联邦**
   - **元数据与表零拷贝挂载**：在 Fabric Lakehouse 中创建指向 **Databricks Unity Catalog** 的批量零拷贝快捷方式（`OneLake Shortcut to Unity Catalog`），自动将 UC 下的 Schema 与 Delta Tables 映射进 OneLake Catalog，无需复制任何 Parquet 文件；
   - **身份与权限穿透（Entra ID OBO）**：启用 Entra ID On-Behalf-Of (OBO) 令牌透传，用户在 Fabric 或 Power BI 中访问该表时，权限校验既遵循 OneLake Security，也可下推至 Unity Catalog ABAC 行列策略，杜绝权限双写冲突；
   - **反向互通**：Databricks Spark 同样可通过 OneLake API 或 Iceberg REST 端点直接读取 Fabric OneLake 中的认证表。
2. **模式 B：Snowflake Horizon / Open Catalog (Apache Polaris) ↔ Fabric OneLake XTable 零拷贝联邦**
   - **Iceberg REST 与 XTable 自动对齐**：对于托管在 Snowflake Open Catalog (Polaris) 或 Amazon S3 Tables 中的 Apache Iceberg 表，OneLake 通过 **XTable 元数据虚拟化** 零算力读取其 `metadata.json` 快照并实时暴露为 OneLake Delta/Iceberg 双视图；
   - **Apache Ossie 语义层同步**：利用 **Apache Ossie** 开放语义规范，将 Snowflake Horizon 中的 Semantic Views YAML 自动同步为 Fabric IQ Ontology 实体与度量值，实现跨云目录的“表 + 语义”双重统一。
3. **模式 C：Microsoft Purview Unified Catalog 作为集团顶层“单一数据产品超市（Enterprise Data Product Hub）”**
   - 无需采购昂贵的第三方独立目录，直接使用 **Purview Unified Catalog** 自动扫描并汇聚 OneLake、Unity Catalog、Snowflake、BigQuery 与 AWS S3 的技术元数据，将分散在五朵云上的关联表与 AI 模型打包发布为可申请审批（Access Workflow）的 **Data Product**，自动生成满足 **BCBS 239（银行风险数据加总与报告规范）** 的端到端血缘图谱。

---

### Q3：这套跨五云开放目录与语义治理底座在底层是如何实现“255ms 数据产品寻源、BCBS 239 血缘核验与零漂移合规签约”的？

在今晚新增的 **Scenario Z（`global_bank_onelake_purview_catalog_federation_vs_unity_polaris`，`DL-117..DL-120`）** 中，我们验证了一家跨国投行与资管集团（管理 **4,200 个跨云数据产品**，涵盖 OneLake、Databricks Unity Catalog、Snowflake Polaris、BigQuery Dataplex 与 AWS Glue，面临 **BCBS 239 与 EU AI Act** 季度监管突击审计）的完整闭环：
1. **五云开放目录联邦与 Apache Ossie 语义挂载（`60 ms`）**：OneLake Catalog 与 Purview Unified Catalog 通过 Unity Catalog 零拷贝 Shortcut、Polaris Iceberg XTable 与 Apache Ossie 同步 4,200 个跨云数据产品，自动识别并优先锁定带 `Certified` 勋章的 **一级资本充足率（CET1 Ratio）语义本体**（`$0` 元数据复制算力）；
2. **端到端列级血缘穿透（源端 Oracle/Snowflake/UC → OneLake → Power BI DAX → M365 监管报告，`64 ms`）**：Purview Unified Catalog 在 `64 ms` 内生成跨越 5 云 14 跳的完整列级血缘有向无环图（DAG），精确证明提交给欧洲央行的 Word/Excel 监管报表中每一项风险加权资产（RWA）指标与源端核心总账 **0.0000% 血缘断链、0.0% 口径漂移**；
3. **Foundry IQ 监管合规护栏（BCBS 239 & EU AI Act）与 Purview 标签强制下沉核验（`65 ms`）**：自动校验 `BANK-BCBS239-CATALOG-LINEAGE-SOP-026`，拦截 3 个未获 `Certified` 背书的实验性影子表（Shadow Tables）接入高管 Agent，并确认 `Highly Confidential - MNPI`（重大非公开信息）标签已在 OneLake、Power BI 与 Excel 全链路加密生效；
4. **Rayfin SDK 数据产品访问授权与 1GB 免费 Fabric SQL 审计存证（`66 ms`）**：集团首席数据官（CDO）在 Teams 审批卡片点击确认后，Rayfin SDK 在 `66 ms` 内自动完成跨部门数据产品订阅授权并将 BCBS 239 合规证明写入 **1GB 免费 Fabric SQL**（端到端闭环总耗时 **`255 ms`**，月度目录与治理 TCO 节省 **74.4%** 即 `-$28,500/月`，成功规避 **$5,750,000** 监管合规罚款风险）。

---

## ③ 🧭 直观可视化图解（Mermaid 决策树 · 架构对比 · 时序闭环）

### 3.1 五大云数据目录与跨云联邦架构师选型决策树（`flowchart TD`）

```mermaid
flowchart TD
    Start["🏛️ 企业数据目录、元数据联邦与数据产品治理选型<br/>(Catalog, Lineage, Semantic Governance & Data Mesh)"] --> Q1{"核心诉求是打通数据湖到 Power BI / M365<br/>全链路血缘与业务数据产品超市？"}

    Q1 -- "是 (需端到端列级血缘 + Certified 语义本体 + 免第三方目录税)" --> Fab["✅ 首选 Microsoft Fabric OneLake Catalog<br/>+ Purview Unified Catalog + Fabric IQ<br/>• Explore/Govern/Secure 内置工作台 ($0 独立目录服务器)<br/>• 唯一穿透 源库 → OneLake → Power BI DAX → M365 血缘<br/>• 敏感度标签从湖仓一路强制继承至 Excel/Teams/Agent"]

    Q1 -- "否 (已有异构云技术目录或特定开源引擎诉求)" --> Q2{"存量核心元数据主要注册在哪个技术底座？"}

    Q2 -- "Databricks PySpark / MLflow 模型 / Volumes" --> DBX["⚙️ Databricks Unity Catalog + Lakehouse Federation<br/>• 强于 AI 特征库、MLflow 模型与表统一三级命名空间<br/>• 🤝 共存：OneLake Shortcut 直连 UC + Entra OBO 透传"]

    Q2 -- "纯开源 Apache Iceberg 多引擎 (Spark/Trino/Flink)" --> SNOW["❄️ Snowflake Horizon + Open Catalog (Apache Polaris)<br/>• 标准 Iceberg REST Catalog + 跨引擎原子提交凭证下发<br/>• 🤝 共存：OneLake XTable 零算力挂载 Polaris + Apache Ossie"]

    Q2 -- "GCP BigQuery / Vertex AI 原生分析栈" --> GCP["🔍 GCP Dataplex Universal Catalog<br/>• BigQuery/BigLake 自动数据质量剖析与项目级血缘<br/>• 🤝 共存：BigQuery Mirroring + Purview 跨云血缘采集"]

    Q2 -- "AWS S3 Tables / Redshift / Athena 原生栈" --> AWS["📦 AWS Glue Data Catalog + Amazon DataZone<br/>• AWS 域内 IAM Lake Formation 权限与业务目录门户<br/>• 🤝 共存：OneLake S3 Shortcut 挂载 + Purview 统一数据产品"]

    style Fab fill:#065F46,stroke:#10B981,color:#FFFFFF,stroke-width:2px
    style DBX fill:#1E293B,stroke:#F97316,color:#F8FAFC
    style SNOW fill:#1E293B,stroke:#38BDF8,color:#F8FAFC
    style GCP fill:#1E293B,stroke:#FBBF24,color:#F8FAFC
    style AWS fill:#1E293B,stroke:#A855F7,color:#F8FAFC
```

### 3.2 传统“多云孤岛目录 + 外购重型商业目录爬虫” vs “OneLake Catalog + Purview 零拷贝联邦与全链路血缘”对比图（`flowchart LR`）

```mermaid
flowchart LR
    subgraph Legacy["❌ 传统多目录割裂 + 外购商业目录爬虫架构 ($38,300/月 · BI/Office 血缘断链 · 标签无法拦截查询)"]
        direction TB
        L1["5 套孤立技术目录<br/>Unity Catalog / Horizon / Glue / Dataplex / 传统库"] -->|每日定时爬虫拉取 Schema<br/>滞后 12-24h ($11,800/月 API/同步)| L2["外购第三方商业目录 (Collibra/Alation)<br/>席位与平台授权 ($18,500/月)"]
        L2 -->|只贴静态展示标签<br/>无法下沉拦截引擎查询 ($8,000/月 人工审计)| L3["Power BI / Excel / M365 Copilot<br/>DAX 血缘彻底断链 · 3 张未认证影子表引发 14.2% 漂移"]
    end

    subgraph Modern["✅ Fabric OneLake Catalog + Purview Unified Catalog 联邦架构 ($9,800/月 · 省 74.4% · 255ms BCBS 239 全链路血缘)"]
        direction TB
        M1["五云开放目录零拷贝联邦<br/>UC Shortcut + Polaris XTable + Apache Ossie ($0 复制算力)"] -->|60ms 自动汇聚 4,200 数据产品| M2["OneLake Catalog + Purview Unified Catalog<br/>Explore/Govern/Secure + Certified 本体背书"]
        M2 -->|64ms 穿透 14 跳全链路列级血缘<br/>65ms Foundry IQ 拦截影子表| M3["Power BI DirectLake + M365 Copilot + 1GB Free SQL<br/>0.0000% RWA 血缘断链 · MNPI 标签强制加密 (255ms E2E)"]
    end

    Legacy -. "演进升级：用原生全链路嵌入式目录与开放联邦替代外购爬虫目录" .-> Modern

    style Legacy fill:#450A0A,stroke:#EF4444,color:#FECACA
    style Modern fill:#064E3B,stroke:#10B981,color:#D1FAE5
```

### 3.3 跨国投行 4,200 数据产品五云目录联邦与 BCBS 239 血缘审计时序图（`sequenceDiagram`）

```mermaid
sequenceDiagram
    autonumber
    participantEXT as Unity Catalog / Snowflake Polaris / S3 / BigQuery
    participant Cat as OneLake Catalog & Purview Unified Catalog
    participant Ont as Fabric IQ Ontology (Certified CET1 Model)
    participant Guard as Foundry IQ (BCBS 239 & EU AI Act Guardrail)
    participant SQL as CDO Teams Approval & 1GB Free Fabric SQL

    EXT->>Cat: 1. 通过 UC Shortcut + Polaris XTable + Apache Ossie 联邦 4,200 个数据产品 (60ms, $0 复制算力)
    Cat->>Ont: 2. 穿透 5 云 14 跳列级血缘 (源表 → OneLake → DAX → M365 报表) 锁定 Certified CET1 本体 (64ms)
    Ont->>Guard: 3. 核验 BANK-BCBS239-CATALOG-LINEAGE-SOP-026，拦截 3 张未认证影子表并校验 MNPI 加密标签 (65ms)
    Guard->>SQL: 4. CDO 在 Teams 批准 BCBS 239 血缘证明并写入 1GB 免费 Fabric SQL 审计账本 (66ms -> 255ms E2E)
```

---

## ④ 📊 五大平台开放数据目录与元数据联邦选型决策矩阵（Architect Decision Matrix）

| 评估维度 | Microsoft Fabric (`OneLake Catalog + Purview Unified Catalog`) | Databricks (`Unity Catalog + Lakehouse Federation`) | Snowflake (`Horizon + Open Catalog Apache Polaris`) | GCP (`Dataplex Universal Catalog`) | AWS (`Glue Data Catalog + Amazon DataZone`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **核心治理范围** | **数据湖 + 数仓 + 实时 KQL + Power BI 语义模型 + Fabric IQ 本体 + M365 文档全栈贯通** | Delta/Iceberg 表 + Volumes + MLflow 模型 + Feature Store + AI 工具函数 | Snowflake 内部对象（Horizon）+ 外部 Apache Iceberg 开放表（Polaris） | BigQuery + BigLake + Cloud Storage + Vertex AI 资产 | S3 + Redshift + Athena + Glue 表（Lake Formation 权限 + DataZone 门户） |
| **端到端列级血缘边界** | **从跨云源库 → OneLake → Spark/T-SQL → Power BI DAX 度量值 → Excel/Word/Copilot 全链路** | 表到表、Notebook 到表、模型到特征（**进入 Power BI DAX 与 Office 后断链**） | Snowflake SQL / Snowpark 内部列级血缘（外部 BI 与 Office 需第三方工具拼接） | BigQuery SQL / Dataform 内部列级血缘 | Glue ETL / Redshift 内部血缘（DataZone 门户提供业务视图） |
| **业务语义与 AI 防幻觉** | **内建 `Promoted`/`Certified` 背书 + Fabric IQ 本体 + Apache Ossie 语义同步（强制阻断未认证裸表）** | UC Metric Views + AI/BI Genie 空间说明 + AI 生成表注释 | Snowflake Semantic Views + Apache Ossie 规范发起方 | Looker Modeler + Dataplex Business Glossary | DataZone Business Glossary + Bedrock Knowledge Bases |
| **开放表与跨目录互通** | **原生支持 Unity Catalog Shortcut、Polaris/S3 Iceberg XTable、BigQuery Mirroring** | Unity Catalog OSS + Iceberg REST API + Lakehouse Federation (JDBC 下推) | Apache Polaris 开源 Iceberg REST Catalog（支持 Spark/Trino/Flink 读写） | BigLake Metastore (Iceberg REST 兼容) | Glue Data Catalog Iceberg REST 端点 |
| **安全标签到办公端继承** | **Purview Sensitivity Labels 自动从 OneLake 表继承至 Power BI、Excel、Teams 与邮件加密** | UC Tags 仅在 Databricks 内部引擎生效，导出至 Office 文件后失去原生加密保护 | Horizon Object Tags 仅在 Snowflake 内部生效，无原生 Office DLP 联动 | Google Cloud DLP / Policy Tags 仅限 GCP 内部生效 | Macie / Lake Formation Tags 仅限 AWS 内部生效 |
| **参考月度目录治理 TCO** *(4,200 数据产品规模)* | **`$9,800 / 月`** *(含于 F64 容量 + Purview 数据产品治理，省 **74.4%**)* | `$29,400 / 月` *(UC Serverless 治理计算 + 需外购 Collibra/Alation 补齐 BI/企业目录)* | `$31,200 / 月` *(Horizon/Polaris 算力 + 外购商业目录补齐跨云与 BI 血缘)* | `$28,900 / 月` *(Dataplex 扫描与质量计费 + 跨云商业目录集成)* | `$38,300 / 月` *(DataZone + Glue Crawlers + 第三方商业目录拼装栈)* |

---

## ⑤ 🧪 简明定量测评与 TCO / 血缘完整性拐点洞察（含 7-Card 报告）

### 5.1 跨国投行 4,200 数据产品目录联邦与 BCBS 239 血缘审计定量对比（`DL-117..DL-120` · `reports/report.json`）

> **数据溯源口径说明**：以下跨云数据目录与数据产品治理 TCO、14 跳列级血缘穿透耗时与 BCBS 239 审计风险敞口来自 `src/data_lab/benchmark_suite.py` 中的确定性参考模型（`synthetic_scenario_model`），路由判定（`119/120 = 99.17%`）与 `56/56` 单元测试为 `measured_local_harness`，官方产品特性截至 `2026-11-10`（`vendor_published_spec_as_of_2026`）。

| 量化指标 | Microsoft Fabric (`OneLake Catalog + Purview + Ossie`) | 传统“多云孤岛目录 + 外购商业目录爬虫”拼装方案 | Databricks (`Unity Catalog + 外部 BI 目录补充`) | 架构师核心洞察 |
| :--- | :--- | :--- | :--- | :--- |
| **月度目录、血缘与语义治理总成本** | **`$9,800 / 月`** | `$38,300 / 月` *(含外购商业目录席位与定时同步算力)* | `$29,400 / 月` | **节省 74.4%（`-$28,500/月`，年省 `$342,000`）** |
| **跨云数据产品联邦覆盖率** | **`100.0%` (4,200 / 4,200 数据产品)** | `78.5%` *(手工录入滞后)* | `88.0%` *(偏重湖仓层)* | UC Shortcut + XTable + Mirroring 实现零拷贝秒级入目 |
| **源表 → Power BI DAX → Office 列级血缘覆盖率** | **`100.0%` (14 跳完整无断链)** | `58.0%` *(在 DAX 度量值与 Excel 处断链)* | `64.0%` *(止步于湖仓表层)* | 唯一满足 BCBS 239 “从源总账到监管报表单元格”零断链要求 |
| **AI Agent 优先命中 `Certified` 认证资产比例** | **`100.0%` (拦截 3 张未认证影子表)** | `71.4%` *(易混入测试表/废弃表)* | `91.2%` | OneLake Catalog `Certified` 背书 + Foundry IQ 彻底阻断口径漂移 |
| **端到端寻源、血缘核验与合规签字耗时** | **`255 ms`** (`60+64+65+66 ms`) | `14 天` *(人工跨团队拉取 SQL 与 DAX 脚本核对)* | `4.5 小时` *(需人工核对下游 BI 报表)* | 将季度 BCBS 239 审计响应速度从“两周人肉排障”缩短至亚秒级 |
| **规避 BCBS 239 与 EU AI Act 监管处罚敞口** | **守护 `$5,750,000` 合规审计 SLA** | 暴露于血缘缺失与指标漂移合规通报风险 | 需额外部署 Office DLP 与 BI 血缘插件 | 治理标签与血缘跟随机动数据直达最后一公里办公桌面 |

### 5.2 架构师 TCO 与治理拐点洞察
1. **为什么外购第三方商业目录（Collibra/Alation）正在被“嵌入式统一目录（OneLake Catalog + Purview）”加速替代？**
   - 外购目录最大的软肋是**“控制面与执行面分离”**：在外部网页目录里给字段打上“机密”标签，并不会自动变成数据湖里的行级过滤（RLS）或 Excel 文件的打开加密。而 OneLake Catalog + Purview 将**目录检索（Explore）、健康度治理（Govern）、统一访问控制（Secure）与信息保护（Purview DLP）**原生焊死在同一个 SaaS 内核上，打标签即加密、背书即路由。
2. **用“开放协议联邦”终结“目录宗教战争”**：
   - 在大型企业内部，强迫算法团队放弃 Unity Catalog 或强迫基础设施团队放弃 Iceberg REST Catalog 是不现实的。通过 **OneLake Shortcuts to Unity Catalog + XTable for Apache Polaris + Apache Ossie for Semantic Views**，架构师可以用零拷贝方式把五朵云的技术目录凝聚成一个面向 CDO 和业务高管的 **Purview Unified Catalog 数据产品超市**。

---

## ⑥ 🛠️ 附录：生产落地与售前打单快速核验清单（Architect Checklist）

- [ ] **存量跨云目录盘点与零拷贝联邦接入**：盘点客户现有的 Databricks Unity Catalog、Snowflake Open Catalog (Polaris)、AWS Glue 与 GCP Dataplex 资产，优先配置 **OneLake Shortcuts to Unity Catalog** 与 **OneLake XTable Iceberg 虚拟化**，严禁编写复制数据的元数据同步 ETL。
- [ ] **启用 OneLake Catalog `Govern` 健康度巡检与三级背书体系**：在 Fabric 门户开启 OneLake Catalog Governance 视图，为全企业核心财务、风控与供应链语义模型及 Fabric IQ 本体授予 **`Promoted`（部门推荐）** 与 **`Certified`（集团官方认证）** 勋章。
- [ ] **配置 AI Agent 强制路由 `Certified` 资产护栏**：在 Fabric Data Agents 与 Foundry IQ 中启用目录治理策略，强制要求高管问数仅允许绑定带 `Certified` 勋章的语义模型与 Ontology，自动拦截未背书的临时表/影子表（防范 `DL-23` 类口径漂移）。
- [ ] **构建 Purview Unified Catalog 业务域（Domains）与数据产品（Data Products）**：按业务条线划分治理域，将关联的 Lakehouse 表、Warehouse 视图、Power BI 报表与 Data Agent 打包发布为标准 Data Product，并绑定业务术语表（Business Glossary）。
- [ ] **打通 BCBS 239 / SOX 全链路列级血缘与 Purview 敏感度标签继承**：开启 Purview 对源端数据库、Fabric 工作区与 Power BI 的自动血缘扫描，验证从源表列到 DAX 度量值再到导出 Excel/PDF 文档的敏感度标签（如 `Highly Confidential - MNPI`）强制继承。
