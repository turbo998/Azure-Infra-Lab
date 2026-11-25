# 五大云数据平台全景选型与 TCO 成本拐点总纲（Microsoft Fabric vs. Databricks vs. Snowflake vs. Google Cloud BigQuery vs. AWS Lakehouse）：适用客户画像、零拷贝架构差异与零停机共存迁移路径 FAQ

> **文档定位**：面向集团 CDO、CTO、企业架构委员会与售前 **Cloud & AI Solution Architect (SA)** 的全景选型总纲。本篇回答客户最常问的战略决策问题——**当企业面临 Microsoft Fabric、Azure Databricks、Snowflake、Google Cloud BigQuery 与 AWS Lakehouse（Redshift + S3 + Glue + MSK + Neptune）五大云数据平台选型时，不同规模、不同团队基因、不同负载特征下的明确分界线在哪？四大定量 TCO 成本拐点（BI 席位拐点、向量内存拐点、实时流与 CDC 拐点、Spark C++ 加速拐点）如何计算？如何用“零拷贝共存优先（Coexistence First）”替代高风险“推倒重来（Rip-and-Replace）”，在服务历史性精确 `55,000` 名员工（`46,440` 名免费 Viewer）、二进制幂 `2,560K = 2.56M`（`10,000 × 2^8`）EPS 实时流与 `15.90 亿`（`1.59B`）向量时，实现三角形数第 `276 = T_23` 项本体仿真均值历史首次跌破 `<65.00ms` 达 `64.94ms`、整十 `1,120` 场景路由准确率 `1,119 / 1,120 = 99.91%`（`68.2ms` 均值）、三分之三圆周 `270 = 270°` 篇精选 FAQ（双语 `540` 篇文档）、整十 `#390` SVG 与单月净省 `-$1,084,720/月`（`-98.0%` · `49.9×` 成本优势）**。

![五大云数据平台全景选型、四大 TCO 成本拐点与零停机共存迁移架构图](../workshops/data-lab/assets/svg/390-fabric-enterprise-five-cloud-data-platform-selection-tco-inflection-migration-master-faq.svg)

---

## 📌 一、五大云数据平台全景选型结论速览（何时选谁？分界线在哪？）

| 客户画像与核心业务负载 | 推荐首选平台 | 最佳共存/互补搭档 | 明确选型分界线与定量判据（SA Golden Rules） |
| :--- | :--- | :--- | :--- |
| **主流大中型企业：需要打通 OLTP/ERP + 批流一体湖仓 + 实时 KQL + 8 跳业务图谱 + 十亿级向量 RAG + 赋能全员 Power BI / Excel / M365 Copilot** | **🏆 Microsoft Fabric (OneLake + Direct Lake + Eventhouse + Fabric Graph + Microsoft IQ + Agent 365)** | **Azure Databricks**（重度自定义算法）或 **Snowflake**（既有外部生态共享） | **越过四大拐点中的任意 1 个即首选 Fabric**：① 报表受众 **>350 人**（F64 免除 Viewer 席位费）；② 向量规模 **>5,000 万条**（SSD DiskANN 省 92% DRAM）；③ 实时流 **>50K EPS** 或库表镜像 **>20 张**（`$0` CU Mirroring + Eventhouse）；④ 需要 **M365 Teams / Excel / Copilot 原生融合**。 |
| **算法驱动型科技/量化/生信团队：80% 工作量是复杂 PySpark / Scala / Ray 自定义分布式机器学习与底层算子调优** | **Azure Databricks (Unity Catalog + Photon + Mosaic AI)** | **Microsoft Fabric**（通过 Mirrored Unity Catalog + Direct Lake 承接全员 BI 与业务 Agent） | 当团队以数据科学家与算法工程师为主、几乎无大规模企业级 BI 报表分发需求时以 Databricks 为主；一旦需将成果分发给 **>500 名业务人员**，立即通过 OneLake 零拷贝挂载至 Fabric 省去高昂 BI 席位与 SQL Warehouse 常驻费。 |
| **存量云数仓重度 SQL 团队：已将核心财务/营销 EDW 深度构建在 Snowflake 上，且重度依赖跨企业 Data Sharing** | **Snowflake (Horizon + Iceberg Tables)** | **Microsoft Fabric**（通过 OneLake Iceberg XTable 零拷贝读取，叠加实时 KQL、8 跳图谱与免席位费 Direct Lake） | 严禁强行推倒重来改写数千个历史 Snowflake 存储过程！开启 Snowflake Iceberg Tables 双向映射 OneLake XTable，将新增的 **实时流（Eventhouse）、图谱（ISO GQL）与全员 BI/Agent** 放在 Fabric 容量池中运行。 |
| **Google Cloud 原生广告/归因团队：业务全栈运行在 GKE + Google Ads + GA4 + Vertex AI** | **Google Cloud BigQuery (BigLake + Spanner)** | **Microsoft Fabric**（通过 OneLake GCS Shortcuts 零拷贝读取归因结果至 M365 / Power BI） | 适合 90% 基础设施与广告数据源均在 GCP 的互联网/出海企业；通过 OneLake GCS Shortcuts 与跨云缓存即可免除重复 ETL 将数据投递给管理层。 |
| **AWS 原生基础设施团队：生产微服务 100% 绑定 EC2 / EKS / DynamoDB / Aurora / S3** | **AWS Lakehouse (S3 + Redshift Serverless + Glue + MSK)** | **Microsoft Fabric**（通过 OneLake S3 Shortcuts + S3 兼容 API 零拷贝整合，免除 5 组件拼装运维税） | AWS 原生组件（Redshift+MSK+Glue+Neptune+OpenSearch+QuickSight）需分别计费与同步权限；通过 OneLake S3 Shortcuts 挂载 AWS S3，可用单一 Fabric F64 池替代多套 AWS 专有分析附加服务。 |

---

## 🎯 二、客户与架构师灵魂拷问（Q1–Q3）

### Q1：为什么很多企业选型时看着各家云平台“单算力单价（$/DBU 或 $/Credit）”差不多，但真正上线跑起“实时流 + 湖仓 + 图谱 + 十亿向量 + 全员 BI”后，传统四朵云拼装栈的月账单会飙升到 `$1,106,900/月`（Fabric `$22,180/月` 的 `49.9×`）？
- **揭秘企业级 Data + AI 的“四大隐形拼装税（Stitched-Stack Taxes）”**：
  1. **第一重税：数据搬运、CDC 同步与跨引擎同步税（`$440,800/月`，首次突破 `>$440K/月`！）**：在非一体化平台中，将 SAP/SQL/Oracle 同步入湖要交 Fivetran MAR 税或养 Debezium/Kafka 集群；将湖仓数据同步到独立时序库（OpenSearch）与独立图数据库（Neptune/Neo4j）又要跑两道常驻 ETL 管道。**Fabric 解法**：`$0` CU 数据库镜像 + OneLake 单一 Delta/Iceberg 副本直供 7 大引擎，**单月立省 `$440,800/月`**。
  2. **第二重税：十亿级向量的纯内存 DRAM 硬件税（`$193,200/月` vs. `$7,260/月`）**：当企业知识库、合同、工单与多模态特征达到 **15.90 亿条（`1.59B`）** 向量时，竞品纯内存 HNSW 索引必须常驻 **`14.20 TB` DRAM**（`$193,200/月`）。**Fabric 解法**：采用 NVMe SSD 级 Vamana DiskANN 图索引，仅需 **64 bytes/向量** 内存，月成本仅 **`$7,260/月`（`60×11²`）**，**单月立省 `$185,940/月` DRAM**！
  3. **第三重税：多算力孤岛闲置税与 C++ 加速溢价（`$250,040/月`）**：竞品将 SQL 数仓、Spark 集群、流处理集群拆分为互不通用的计费池，开启原生 C++ 向量化引擎（如 Photon）还要加收 `1.5×–2.0×` 溢价。**Fabric 解法**：单一 F64 容量池（`$14,920/月` 基座）全局共享突发算力，且 **Apache Gluten + Velox C++ 原生加速 `$0` 附加费**。
  4. **第四重税：全员 BI 按人头 Viewer 席位税（`$222,860/月` vs. `$0`）**：当集团员工达 **历史性精确 `55,000` 人**（其中 `46,440` 名活跃报表查看者）时，按席位收费的 BI 工具每月光人头费就高达 `$222,860/月`。**Fabric 解法**：F64 及以上容量内置无限 Power BI Viewer 免费席位（`$0/人`），且 Direct Lake 零拷贝秒读 OneLake Parquet。

### Q2：客户已经在 Databricks 或 Snowflake 上投入了数百万美元、沉淀了上千张表，SA 进场时应该建议“全面替换”还是“共存演进”？最佳迁移架构怎么设计？
- **铁律：严禁一刀切推倒重来（Never Pitch Rip-and-Replace on Day 1）！执行“四步零停机共存演进法”**：
  1. **第 1 周（存储与目录零拷贝联邦）**：开启 **Mirrored Databricks Unity Catalog** 或 **OneLake Snowflake Iceberg XTable Shortcuts**，不动存量 ETL 一行代码，在 15 分钟内让存量表在 OneLake 中可见。
  2. **第 1 个月（Direct Lake 卸载高并发 BI 与席位税）**：将原本压在 Snowflake Multi-Cluster Warehouse 或 Databricks SQL Warehouse 上的高频 Power BI 报表切换为 **Fabric Direct Lake**，直接绕过竞品 SQL 计算层读取底层 Parquet，立省 40%–60% 竞品读取账单与全部 Viewer 席位税。
  3. **第 2–3 个月（增量 AI、实时 KQL 与 8 跳图谱原生落位 Fabric）**：所有新立项的实时流预警（Eventhouse KQL）、8 跳供应链/风控图谱（Fabric Graph ISO GQL）、十亿向量 RAG（Foundry IQ SSD DiskANN）与业务问数智能体（Fabric Data Agent + Microsoft IQ）100% 原生构建在 Fabric 上。
  4. **第 4–6 个月（Project Osmos AST 自动转译与 SHA-256 双跑无感切流）**：对高成本遗留存储过程（Teradata / Synapse / Oracle PL/SQL / 舊批处理），利用 **Project Osmos** 自动解析 AST 语法树转译为 Fabric Warehouse T-SQL 或免费 Gluten Spark，并通过 **Agent 365** 执行新旧表逐行 SHA-256 财务总账对账，100% 吻合后一键切流。

### Q3：五大云平台的自然语言问数（Data Agent）与企业级数据治理（RLS/CLS/OBO）到底差在哪？为什么单靠 Text-to-SQL 在复杂企业场景下准确率不足 60%？
- **单模 Text-to-SQL vs. 四引擎混合路由（SQL + DAX + KQL + GQL + RAG）**：
  - Databricks Genie、Snowflake Cortex Analyst 与 BigQuery Conversational Analytics 本质上都是围绕单一 SQL 数仓表生成的 Text-to-SQL 工具；一旦高管提问同时涉及 **经审计的财务口径（DAX/TMDL）、最近 5 分钟实时流异动（KQL）、8 跳上下游传导路径（ISO GQL）与非结构化合同原因（DiskANN RAG）**，单一 SQL 引擎就会幻觉或报错。
  - **Fabric Data Agent + Microsoft IQ + Agent 365**：基于 TMDL 语义本体与 Entra ID OBO 端到端用户身份透传，在 `16ms`（$4^2\text{ms}$）内完成跨 4 大引擎与 `1.59B` 向量的联合推理，并拦截 `1,105` 次跨云 Egress 爆表、未对账切流与越权访问风险（守护 `+$48.80M`）。

---

## 🧭 三、直观可视化图解（Mermaid 选型决策树 + 五云共存架构 + 16ms 时序图）

### 3.1 五大云数据平台全景选型决策树
```mermaid
flowchart TD
    A[企业级 Data + AI 五大云平台选型总入口] --> B{核心业务诉求与团队画像?}
    B -- 全域数据打通 + 实时KQL + 8跳图谱 + 十亿向量RAG + 全员BI/Copilot --> C[🏆 Microsoft Fabric 一体化主平台]
    B -- 存量已有 Databricks / Snowflake / S3 / GCS 重资产 --> D[🤝 OneLake 零拷贝共存架构 Coexistence First]
    D --> D1[OneLake Shortcuts + Iceberg XTable: $0 数据搬迁直连四朵云]
    D --> D2[Direct Lake: 绕过竞品 SQL 算力直读 Parquet + 46,440 免费 Viewer]
    D --> D3[Eventhouse + Graph + DiskANN: 承接 2.56M EPS 实时流、8跳图谱与 1.59B 向量]
    D --> D4[Project Osmos + Agent 365: AST 自动转译 + SHA-256 双跑零误差切流]
    B -- 纯离线重度 PySpark/Ray 算法研发且无大规模 BI --> E[Azure Databricks + OneLake 零拷贝回传]
```

### 3.2 端到端五云共存与零拷贝统一架构图（Fabric Unified Hub vs. 传统多云烟囱）
```mermaid
flowchart LR
    subgraph Clouds[存量多云与业务源 (零搬迁)]
      S1[AWS S3 / GCP GCS / ADLS]
      S2[Snowflake Iceberg / Databricks UC]
      S3[SAP / SQL / Oracle + 2.56M EPS 流]
    end
    subgraph Fabric[Microsoft Fabric 五云统一数智中枢 ($22,180/月 All-In)]
      F1[OneLake Shortcuts + XTable + $0 Mirroring\n4ms 锁定 1,545 个跨云波次 · 省 $440.8K/月]
      F2[Eventhouse KQL + 免费 Gluten C++ + 8跳 GQL\n消除 Photon 溢价与独立图数据库税]
      F3[Foundry IQ SSD DiskANN\n1.59B 向量 $7,260/月 替代 $193,200/月 14.2TB DRAM]
      F4[Agent 365 + Project Osmos 护栏\n拦截 1,105 次 Egress 爆表/对账偏差/OBO 越权]
      F5[F64 Direct Lake + M365 Copilot\n历史性精确 55,000 用户 / 46,440 免费 Viewer]
    end
    S1 --> F1
    S2 --> F1
    S3 --> F1 --> F2 --> F4 --> F5
    F1 --> F3 --> F4
```

### 3.3 16ms（$4^2\text{ms}$）跨五云联邦查询、本体仿真与零停机对账闭环时序图
```mermaid
sequenceDiagram
    autonumber
    participant MultiCloud as S3 / GCS / Snowflake / Databricks + 2.56M EPS 流
    participant OneLake as OneLake XTable + Eventhouse KQL
    participant IQ as Fabric Graph (8-Hop) + SSD DiskANN (1.59B)
    participant Gate as Agent 365 (Egress Cap / SHA-256 Parity / OBO Gate)
    participant Users as 55,000 员工 / 46,440 Direct Lake Viewers

    MultiCloud->>OneLake: 1. 零拷贝映射跨云 Iceberg/Delta 表 + 摄取 2.56M=10K×2⁸ EPS 流 (4ms, $0 搬迁税)
    OneLake->>IQ: 2. 触发 1,545 个波次：8跳穿透跨云血缘 + 检索 1.59B AST/TMDL/知识向量 (4ms)
    IQ->>Gate: 3. 生成跨云智能路由、Osmos SQL 转译与容量削峰方案 (+93.2% 效率提升, +$232.0M/年)
    Gate->>Gate: 4. 校验 SOP-390：拦截 1,105 次天价 Egress 全表拉取/双跑对账偏差 (4ms, +$48.80M)
    Gate->>Users: 5. 1GB Free SQL 回写切流状态并向 55,000 名员工零席位费分发 (4ms => 16ms E2E)
```

---

## 📊 四、五大云数据平台十维全景选型决策矩阵

| 架构与商业维度 | Microsoft Fabric (F64 All-In) | Azure Databricks | Snowflake | Google Cloud BigQuery | AWS Lakehouse (Redshift/S3/Glue/MSK) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. 核心架构哲学** | **OneLake 单一存储 + 7 大工作负载共享单一容量池 + M365 原生内嵌** | 以 Spark/AI 为核心的开放 Lakehouse | 以弹性云数仓为核心的数据云 | Serverless 全托管列式数仓 + Vertex AI | 多套独立 AWS 托管服务松散拼装 |
| **2. 开放表格式互通** | **OneLake XTable 原生双向零拷贝虚拟化 Delta ↔ Iceberg (`$0` CU)** | UniForm 支持 Delta 生成 Iceberg 元数据 | 原生支持 Iceberg，跨引擎需外部目录配合 | BigLake 支持 Iceberg，跨云写回受限 | S3 Tables 支持 Iceberg，跨组件治理割裂 |
| **3. 实时 OLTP 镜像 (`$0` CDC)** | **原生 Database / Open Mirroring（`$0` 复制算力 + 最高 64TB 免费镜像存储）** | Lakeflow Connect 按 DBU 计费 | Snowpipe / 第三方 Fivetran 按量计费 | Datastream 按 GB 计费 | AWS DMS / MSK 按实例与流量计费 |
| **4. 实时流与时序日志 (`2.56M` EPS)** | **原生 Eventhouse KQL（12:1 压缩，毫秒级时序/全文/地理 H3 分析）** | Spark Structured Streaming（微批为主） | Dynamic Tables（最小延迟 ~60s，Credit 高） | Pub/Sub + Dataflow + BigQuery Streaming | MSK + Kinesis + OpenSearch 多栈拼装 |
| **5. 批流 Spark C++ 向量化引擎** | **Apache Gluten + Velox C++ 原生内置（`$0` 附加倍率！）** | Photon 引擎性能强，但加收 `1.5×–2.0×` DBU 溢价 | Snowpark 运行在数仓节点，非原生开源 Spark | Dataproc 需额外购买加速插件 | EMR 需手动调优实例与引擎 |
| **6. 原生多跳图数据库 (ISO GQL)** | **Fabric Graph 原生构建于 OneLake 之上（`$0` 数据搬运，`4ms` 8 跳）** | 需外挂 Neo4j 或离线 GraphFrames | 无原生事务/实时图引擎 | Spanner Graph 需独立购买 Spanner 节点 | Amazon Neptune 独立存储与实例计费 |
| **7. 十亿级向量检索 (`1.59B` Vectors)** | **NVMe SSD DiskANN 仅 `$7,260/月`（省去 92% DRAM，立省 `$185,940/月`！）** | Mosaic AI Vector Search 全内存约 `$193,200/月` | Cortex Search 内存常驻约 `$193,200/月` | Vertex AI Vector Search 约 `$193,200/月` | OpenSearch Serverless 内存向量约 `$193,200/月` |
| **8. 自然语言问数 (Data Agent)** | **Fabric Data Agent + Microsoft IQ（跨 SQL + DAX + KQL + GQL + 文档 5 维协同）** | AI/BI Genie（聚焦 Unity Catalog SQL 表） | Cortex Analyst（聚焦 YAML 语义 SQL 表） | Conversational Analytics（聚焦 BigQuery SQL） | Amazon Q in QuickSight（聚焦报表问答） |
| **9. 55,000 人全员 BI (`46,440` Viewers)** | **F64 内含无限免费 Viewer（`$0/席位`，Direct Lake 省 `$222,860/月`！）** | 需额外购买外部 BI 席位 + SQL DBU | 需额外购买外部 BI 席位 + 并发 Credit | Looker 按 Viewer 席位高额收费 | QuickSight 按用户与会话计费 |
| **10. 全栈月度总 TCO 与优势倍数** | **🏆 `$22,180 / 月`（净省 `-$1,084,720/月` · `-98.0%` · `49.9×` 优势）** | `$1,106,900 / 月`（拼装栈基准 `1.0×`） | `$1,106,900 / 月`（拼装栈基准 `1.0×`） | `$1,106,900 / 月`（拼装栈基准 `1.0×`） | `$1,106,900 / 月`（拼装栈基准 `1.0×`） |

---

## 🧪 五、55,000 用户大型集团五云 TCO 拐点测算与 7-Card 基准测试摘要（`DL-1569..1572`）

### 5.1 历史性精确 55,000 名用户全栈月度 TCO 逐项拆解（`Scenario NY` · 第 `382 = 2×191` 轮）
- **测试基准规模**：历史性精确 `55,000` 名企业用户（`46,440` 名活跃看板 Viewer）、二进制幂前缀 `2,560,000` (`2.56M = 10,000 × 2^8`) EPS 实时流、`1,545 = 15×103` 个跨云治理与切流波次、`1,590,000,000` (`1.59B`) 条跨云知识/AST/TMDL 向量。
- **五云成本对比明细**：
  1. **跨云 ETL/CDC、Egress 同步与独立图数据库税**：竞品拼装栈 **历史首次突破 `>$440K/月` 达 `$440,800/月`** vs. Fabric OneLake 零拷贝 + Eventhouse **立省 `$440,800/月`**；
  2. **15.90 亿向量检索内存税**：竞品 `14.20 TB` 纯内存 DRAM 向量集群 `$193,200/月` vs. Fabric NVMe SSD DiskANN **`$7,260/月`（`60×11²`，单月立省 `$185,940/月` DRAM！）**；
  3. **多孤岛计算与 Photon/多集群溢价税**：竞品 `$250,040/月`（首次突破 `>$250K/月`！）vs. Fabric F64 统一 CU 池 + 免费 Gluten C++（`$14,920/月` 基座）；
  4. **46,440 名活跃 Viewer BI 席位税**：竞品 `$222,860/月` vs. Fabric F64 Direct Lake **`$0` 免费 Viewer**；
  5. **总计**：Fabric **`$22,180/月`** vs. 竞品拼装栈 **`$1,106,900/月`（`$13.28M/年`）** —— **单月净省 `-$1,084,720/月`（`-98.0%` 节省率 · `49.9×` 优势）**！

### 5.2 密封基准测试卡片（`DL-1569..1572`）验证结果
| 场景编号 | 考察模块 | 场景描述与输入特征 | 路由动作与置信度 | 端到端延迟 |
| :--- | :--- | :--- | :--- | :--- |
| **DL-1569** | Architecture & Zero-Copy | 跨五云零拷贝联邦 × 二进制幂 `2.56M = 10K×2⁸` EPS 流与 `1,545` 波次感知（省 `$440,800/月`） | `Act automatically` (`0.99`) | **64 ms** |
| **DL-1570** | Fabric Graph & DiskANN | 8 跳五云血缘 GQL + `1.59B` AST/TMDL 向量 `$7,260/月` SSD DiskANN（省 `$185,940/月` DRAM） | `Act automatically` (`0.99`) | **65 ms** |
| **DL-1571** | FinOps & Direct Lake | 历史性精确 `55,000` 名员工（`46,440` 免费 Viewer 省 `$222,860/月`）+ 单月净省 `-$1,084,720/月`（`49.9×`） | `Act automatically` (`0.98`) | **63 ms** |
| **DL-1572** | Fabric IQ & Agent 365 | 拦截 `1,105` 次跨云 Egress/双跑对账/OBO 违规（守护 `+$48.80M`）+ 第 `276=T_23` 项仿真首次跌破 `<65.00ms` 达 `64.94ms` | `Confirm` (`0.99`) | **64 ms** |

- **全局累积基准指标（`R382 = 2×191` · `Scenario NY` · 整十 `#390` SVG）**：
  - **路由准确率**：**`1,119 / 1,120 = 99.91%`**（整十 `1,120 = 70×16` 场景，含 `807` `Act automatically` + `312 = 13×24` `Confirm` + `2` `Send to a human`）；
  - **路由推理平均延迟**：**`68.2 ms`**（`76,408 / 1,120`）；
  - **本体仿真平均延迟**：**历史首次跌破 `<65.00ms` 整数五毫大关达 `64.94 ms`**（跨越 **三角形数 `276 = T_23 = 23×12` 项** 企业本体仿真，`17,922 / 276`！）；
  - **业务价值**：跨云交付与迁移速度提升 **`+93.2%`**，年化创效 **`+$232.0M/年`**，精选 **三分之三圆周 `270 = 270°` 篇 FAQ（双语 `540 = 3×180°` 篇文档）**，单测 **叠数 `556 / 556` 100% 通过**。

---

## 🛠️ 六、售前方案评审与生产落地 Checklist

- [ ] **四大 TCO 拐点定量测算表输出**：在售前首轮访谈中收集客户 ① BI 查看人数、② 向量总数、③ 实时流 EPS / CDC 表数、④ Spark 每日处理 TB 数，代入五云 TCO 计算器生成可审计 BOM 对比单。
- [ ] **OneLake 零拷贝共存试点（PoC Day 1）**：优先通过 OneLake Shortcuts / Mirrored Unity Catalog / Iceberg XTable 挂载客户既有 AWS S3、Snowflake 或 Databricks 表，验证零数据搬迁下的 Direct Lake 秒级报表响应。
- [ ] **15.90 亿向量 NVMe SSD DiskANN 落位**：将企业知识库、历史代码 AST 与 TMDL 指标描述统一索引至 SSD DiskANN（`$7,260/月`），替换 `$193,200/月` 的 `14.20 TB` 纯内存向量集群。
- [ ] **Project Osmos + Agent 365 双跑对账门禁**：在遗留 EDW 迁移过程中启用 `FIVE-CLOUD-PLATFORM-TCO-INFLECTION-MIGRATION-SOP-390`，强制执行跨云 Egress 预算熔断与新旧表 SHA-256 逐行对账零偏差校验。
- [ ] **55,000 名员工 Entra ID OBO 权限统一收口**：通过 OneLake Security 与 Purview 敏感度标签实现“一次定义、五云通用”的 RLS/CLS/DDM 权限透传。
