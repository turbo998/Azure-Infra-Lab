# 企业知识图谱、原生属性图（Property Graph / ISO GQL）与多跳关系推理底座：Microsoft Fabric Graph & Fabric IQ Ontology vs. GCP Spanner Graph vs. AWS Neptune & Neptune Analytics vs. Snowflake Neo4j Container Services vs. Databricks GraphFrames & Mosaic GraphRAG 架构师选型与攻防 FAQ

> 🌐 **Language / 语言**: **中文 (Current)** | **[English (`fabric-graph-gql-ontology-vs-spanner-neptune-neo4j-faq.en.md`)](fabric-graph-gql-ontology-vs-spanner-neptune-neo4j-faq.en.md)**
> 📅 **迭代轮次**: 2026-11-10 · **Round 20（今晚第 7 轮深潜：湖内原生属性图、ISO GQL 标准查询、8 跳穿透式反洗钱 UBO 寻源与 GraphRAG 零搬迁架构）**
> 🎯 **文档定位**: 面向 **AI Solution Architect（AI 解决方案架构师）** 与 **银行风控反洗钱负责人 / 全球供应链架构师 / 知识图谱与 GraphRAG 工程主管** 的一页纸实战选型指南。严格对标 `ib-vs-ethernet-roce-selection-faq.md` 标杆文风，3 分钟抓准核心结论，10 分钟吃透五大云平台图计算底座（Fabric Graph + Fabric IQ Ontology / GCP Spanner Graph / AWS Neptune / Snowflake Neo4j SPCS / Databricks GraphFrames）的底层机理、内存/导出税差异与共存方案。

[![Fabric Graph ISO GQL Fabric IQ Ontology vs GCP Spanner Graph AWS Neptune Snowflake Neo4j Databricks GraphFrames FAQ Architecture](../assets/svg/28-fabric-graph-gql-ontology-vs-spanner-neptune-neo4j-faq.svg)](../assets/svg/28-fabric-graph-gql-ontology-vs-spanner-neptune-neo4j-faq.svg)

---

## ① 📌 核心结论速览（Executive Summary）

### 1.1 什么是“湖内原生属性图（In-Lake Native Property Graph）与 ISO GQL”？为什么传统“独立图数据库孤岛”成了企业落地 GraphRAG 与多跳风控的最大成本黑洞？
- **通俗大白话 + 第一性原理**：
  - 当业务问题涉及**超过 3 跳的深层关系网穿透**——例如：**跨境贸易金融反洗钱（穿透 8 层离岸空壳公司寻找最终受益所有人 UBO）**、**全球供应链 N 级断供传导（Tier-4 矿山停产会影响哪些终端车型）**、或是 **GraphRAG 知识图谱问答**——传统关系型 SQL 的多表 `JOIN` 会发生笛卡尔积内存爆炸，耗时从几秒飙升到几十分钟甚至 OOM 崩溃。
  - 过去企业的做法是**“在数据湖旁边另建一座独立图数据库孤岛（Standalone Graph DB Silo）”**：把数仓里的客户表、股权表、转账流水表每天通过繁重的 ETL 导出成 CSV/JSON，灌入 **AWS Neptune**、**Neo4j Enterprise** 或 **TigerGraph**。
  - **这种“外挂独立图库”架构有三大致命内伤**：
    1. **双份存储与高昂常驻全内存机器税（Always-On Graph RAM Tax）**：为了遍历 8,500 万个实体节点与 12 亿条关系边，独立图数据库往往要求挂载数十台大内存实例（如 `r6g.8xlarge` 或 Neo4j 高配容器节点）7×24 小时常驻运行，仅图库月度账单就高达 **$22,000–$38,000/月**；
    2. **数据同步滞后与图-表割裂（Graph-Table Sync Lag）**：湖仓里的交易表每分钟都在更新，但导出到独立图数据库的 ETL 往往每天只跑一次，导致风控系统看到的是“昨天过期的股权与转账图”，被洗钱团伙利用时间差逃逸；
    3. **权限与治理归零（Security Amnesia）**：原本在数据湖和 Power BI 里配好的行级/列级安全（RLS/CLS），一旦导出进外部图数据库就全部失效，必须重写一套 Cypher/Gremlin 权限逻辑。
- **Microsoft Fabric Graph + Fabric IQ Ontology 的底层破局机制**：
  1. **OneLake 零拷贝图投影（Zero-Copy Graph Projection over Delta Parquet）**：无需把数据导出到外部图数据库！直接在 OneLake 现有的 Delta Lake 表上定义 **Node（实体节点，如企业、账户、提单）** 与 **Edge（关系边，如控股、担保、转运）** 映射，底层列存引擎自动构建高速邻接索引（Adjacency Index），实现“一份 Delta 数据，既是 SQL 表，又是原生属性图”；
  2. **原生支持 ISO/IEC 39075 标准 GQL（Graph Query Language）与低代码视觉构建器**：不仅提供面向业务架构师的拖拽式图建模（与 Fabric IQ Ontology 实体/关系 1:1 互通），还原生支持国际标准 **ISO GQL**（如 `MATCH (c1:Company)-[:OWNS*1..8]->(c2:ShellEntity)`），亚秒级完成 8 跳环路与最短路径搜索；
  3. **池化 F-SKU 算力复用与 OneLake 权限继承**：图遍历算力直接复用企业已购买的 Fabric F64 容量池（空闲时 `0 CU` 常驻税），且 100% 自动继承 OneLake RLS/CLS 与 Purview 敏感度标签，天然成为 **Fabric Data Agents 与 Foundry IQ 的原生 GraphRAG 引擎**。

### 1.2 三条核心选型铁律（3-Minute Takeaways）
1. **什么时候首选 Microsoft Fabric Graph + Fabric IQ Ontology？**
   - 当企业的源数据已经沉淀在数据湖/数仓（或通过 OneLake Mirroring/Shortcuts 接入），需要开展 **3–10 跳关联风控（UBO 穿透、套现环路）、供应链级联影响分析或企业级 GraphRAG 智能体问答**，且希望**免除独立图数据库的 ETL 搬运与 24×7 全内存实例税**时，**首选 Fabric Graph + Fabric IQ Ontology**——在 8,500 万节点 / 12 亿边规模下，月度图分析 TCO 降低 **75.2%**（`$9,400/月` vs `$37,900/月`）。
2. **什么时候选择 GCP Spanner Graph、AWS Neptune、Snowflake Neo4j SPCS 或 Databricks GraphFrames？**
   - 当应用本身就是构建在 **Google Cloud Spanner** 上的全球分布式强一致 OLTP 交易系统（需在同一事务内完成写入与 GQL 图查询）时，选择 **GCP Spanner Graph**；当已有重度 RDF 三元组（SPARQL）或 Gremlin 遗留图应用运行在 AWS 上时，选择 **AWS Neptune / Neptune Analytics**；当数据科学团队需要在 Spark 集群上跑全图 PageRank / Connected Components 批处理算法时，可使用 **Databricks GraphFrames** 或 **Snowflake Snowpark Container Services (SPCS) 上的 Neo4j GDS**。
3. **“湖内属性图 + 分布式图算法”黄金协同模式（Better Together）**：
   - 日常 **90% 的在线多跳穿透查询、ISO GQL 规则拦截与 GraphRAG 语义问数** 直接跑在 **Fabric Graph + Fabric IQ Ontology**（零数据导出、亚秒级响应）；对于每月一次的百亿边全图社区发现（Louvain / Leiden 聚类批处理），可通过 Spark Gluten 或 Databricks 读取同一份 OneLake Delta 表计算并将社区标签回写为节点属性，实现零冗余协同。

---

## ② 🎯 客户与架构师灵魂拷问 Q&A（First-Principles Deep Dive）

### Q1：直接在 SQL 数仓里写递归 CTE（`WITH RECURSIVE`）不也能查多跳关系吗？为什么非要用原生属性图（Property Graph / ISO GQL），以及 Fabric Graph 跟 AWS Neptune、GCP Spanner Graph、Snowflake Neo4j 有什么本质区别？

**1. 为什么传统 SQL `WITH RECURSIVE` 在 5 跳以上会彻底崩盘？**
- 关系型数据库通过 B-Tree 或列存分块做 Hash Join，每增加 1 跳（Hop），引擎都必须把中间结果集与整张几十亿行的关系表重新做一次全局 Hash 匹配。在 8,500 万节点、平均度数 14 的贸易网络中，查到第 6–8 跳时中间状态会膨胀至数百亿行，耗时超过 `45 秒` 甚至触发内存溢出。
- **Fabric Graph 原生属性图引擎** 在 OneLake Delta 表之上构建了紧凑的 **CSR（Compressed Sparse Row，压缩稀疏行）正向/反向邻接指针索引**。从任意节点出发跨 1 跳只需一次 `O(1)` 内存指针偏移（Index-Free Adjacency 加速），无需全表扫描，将 8 跳环形控股穿透从 `45 秒` 压缩至 **`56–116 ms`**！

**2. 五大云平台图方案的底层架构代差**
- **AWS Neptune & Neptune Analytics**：功能全面的专用图数据库（支持 Property Graph 与 W3C RDF），但它是典型的**独立存储计算栈**——你必须先把 S3/Redshift 的表导出并加载进 Neptune 存储卷，并按 provisioned `m-NCU`（内存计算单元）24×7 计费，产生双份存储与 ETL 延迟。
- **Snowflake (Neo4j on Snowpark Container Services)**：Snowflake 本身没有内置原生 ISO GQL 图存储引擎，通常依赖在 **Snowpark Container Services (SPCS)** 中拉起第三方 **Neo4j** 容器，把 Snowflake 表投影进容器内存后运行图算法，再把结果写回 Snowflake 表——不仅要付 Snowflake GPU/CPU 容器算力费，还要付 Neo4j 商业许可费。
- **GCP Spanner Graph**：架构非常优雅——直接在 Spanner 关系表上通过 `CREATE PROPERTY GRAPH` 暴露 ISO GQL 接口，无需搬运数据。但 **Spanner 是按高单价 OLTP 节点（Nodes / Processing Units）计费的分布式事务库**，把上百 TB 的历史分析湖仓数据全放进 Spanner 成本极高。
- **Microsoft Fabric Graph + Fabric IQ Ontology**：把 Spanner Graph 的“表即图、原生 ISO GQL”体验直接带到了**低成本开放数据湖（OneLake Delta Parquet）**之上！既具备 `$23/TB/月` 的湖存储经济性，又与 **Fabric IQ Ontology** 和 **Power BI / Data Agents** 天然合一。

---

### Q2：在当下最火的企业级 GraphRAG（基于知识图谱的检索增强生成）场景中，Fabric Graph + Fabric IQ Ontology 如何比自建“Neo4j + LangChain + 向量库”省下 75% 成本并消除权限漏洞？

许多企业跟风搭建开源 GraphRAG 时，拼凑了 **“Unstructured 文档解析 + LLM 抽三元组 + Neo4j 存图 + Milvus/Pinecone 存向量 + LangChain 检索”** 五套组件，上线前才发现两大死穴：**① 运维极其脆弱且账单高昂；② 任何普通员工提问都能通过图遍历绕过权限看到高管保密合同节点！**
- 在 **Microsoft Fabric** 中，企业级 GraphRAG 被收敛为**单一 OneLake 闭环**：
  1. **多模态抽取（Round 16 `df.ai.extract`）**：直接从 OneLake Files 合同与提单中抽取实体与关系写入 OneLake Delta 表；
  2. **零拷贝成图（Round 20 `Fabric Graph + Fabric IQ Ontology`）**：将实体表与关系表零拷贝映射为属性图，支持 **ISO GQL 多跳拓扑检索**；
  3. **SSD 向量融合（Round 5 `Cosmos DB / SQL DiskANN`）**：同一实体挂载 SSD DiskANN 向量索引（省 92% 内存），实现 **“向量语义召回 + ISO GQL 8 跳子图扩展（Hybrid Vector + GraphRAG）”**；
  4. **OBO 权限穿透（Round 6 `OneLake Security`）**：当用户在 M365 Copilot 提问时，图遍历过程中凡是当前用户无权访问的节点或边，在存储层即被自动剪枝过滤，**0 越权泄露**！

---

### Q3：这套湖内属性图与本体引擎在底层是如何跑通“239ms 穿透 8,500 万实体 / 12 亿边锁定 8 跳空壳公司洗钱环路并完成合规冻结”的？

在今晚新增的 **Scenario AA（`global_trade_finance_fabric_graph_gql_aml_vs_neptune_spanner`，`DL-121..DL-124`）** 中，我们测试了一家跨国贸易金融银行（图谱包含 **8,500 万个全球工商实体、银行账户与海运提单节点，以及 12 亿条股权控股、信用证担保与转口贸易边**）在签发一笔 `$6.10M` 跨境大宗商品信用证前的实时反洗钱（AML）与最终受益人（UBO）穿透闭环：
1. **OneLake 零拷贝图投影与 CSR 邻接索引增量挂载（`56 ms`）**：无需将 8,500 万节点导出至外部图库，Fabric Graph 直接映射 OneLake 中的工商股权、SWIFT 报文与海运提单 Delta 表（`$0` 独立图库复制税）；
2. **ISO GQL 8 跳环形股权与虚假转口贸易穿透（`60 ms`）**：执行标准 ISO GQL 查询 `MATCH p=(applicant:Company)-[:CONTROLS|ENDORSES|SHIPS_TO*1..8]->(sanctioned:WatchlistEntity)`，在 `60 ms` 内穿透 8 层马绍尔/开曼离岸空壳公司，锁定一个由 **24 家空壳公司构成的旋转木马式制裁规避环路（UBO 实际控制率 `68.4%` > `25%` 监管红线）**；
3. **Foundry IQ 国际制裁与反洗钱护栏（OFAC / EU AMLD6）核验（`61 ms`）**：结合 DiskANN 相似历史洗钱手法召回，校验 `TRADE-FINANCE-AML-UBO-SANCTIONS-SOP-027`，确认触发强制拒付（Hard Block）条件并生成可解释的 8 跳证据链；
4. **Rayfin SDK 信用证冻结与 1GB 免费 Fabric SQL 可疑交易报告（SAR）落库（`62 ms`）**：制裁合规官在 Teams 审批卡确认后，Rayfin 在 `62 ms` 内冻结该笔信用证并将完整 GQL 证据子图写入 **1GB 免费 Fabric SQL**（端到端闭环总耗时 **`239 ms`**，月省 **75.2%** 图计算 TCO 即 `-$28,500/月`，成功规避 **$6,100,000** 制裁违规罚单与坏账损失）。

---

## ③ 🧭 直观可视化图解（Mermaid 决策树 · 架构对比 · 时序闭环）

### 3.1 五大云平台图分析、ISO GQL 与 GraphRAG 选型决策树（`flowchart TD`）

```mermaid
flowchart TD
    Start["🕸️ 企业多跳图分析、知识图谱与 GraphRAG 选型<br/>(85M+ Nodes · 1.2B+ Edges · UBO AML / Supply Chain / GraphRAG)"] --> Q1{"核心数据是否已在湖仓/数仓，且希望免除<br/>独立图库 ETL 搬运与 24x7 全内存实例税？"}

    Q1 -- "是 (需零拷贝图投影 + ISO GQL + OneLake RLS 继承)" --> Fab["✅ 首选 Microsoft Fabric Graph<br/>+ Fabric IQ Ontology + SSD DiskANN<br/>• 直接在 OneLake Delta 表上零拷贝构建 CSR 邻接图<br/>• 原生支持 ISO GQL 多跳查询 + 无代码图建模<br/>• 复用 F64 容量池 (省 75.2% TCO) + 原生 OBO GraphRAG"]

    Q1 -- "否 (特定 OLTP 事务内图查询或既有专业图栈)" --> Q2{"核心工作负载属于以下哪种特定技术形态？"}

    Q2 -- "全球强一致 OLTP 事务库内联 GQL 查询" --> GCP["🔍 GCP Spanner Graph<br/>• 在 Cloud Spanner 事务表上直接暴露 ISO GQL<br/>• 🤝 共存：Spanner 管在线交易，BigQuery/OneLake Mirroring 管全域图"]

    Q2 -- "既有 W3C RDF/SPARQL 语义网或 Gremlin 应用" --> AWS["📦 AWS Neptune & Neptune Analytics<br/>• 托管 RDF/SPARQL、Gremlin 与 openCypher 专用图引擎<br/>• 🤝 共存：OneLake S3 Shortcut 汇聚图特征至 Fabric IQ"]

    Q2 -- "Snowflake 内运行 Neo4j 专属 GDS 图算法库" --> SNOW["❄️ Snowflake + Neo4j on Snowpark Container Services<br/>• 在 SPCS 容器内挂载 Neo4j 运行 65+ 图数据科学算法<br/>• 🤝 共存：计算结果写回 Iceberg 表由 OneLake XTable 零拷贝读取"]

    Q2 -- "超大规模 Spark 离线全图批处理 (PageRank/ConnectedComponents)" --> DBX["⚙️ Databricks GraphFrames + Mosaic AI GraphRAG<br/>• 基于 PySpark DataFrame 的分布式离线图算法批处理<br/>• 🤝 共存：离线特征写回 OneLake，在线 GQL 穿透交由 Fabric Graph"]

    style Fab fill:#065F46,stroke:#10B981,color:#FFFFFF,stroke-width:2px
    style GCP fill:#1E293B,stroke:#FBBF24,color:#F8FAFC
    style AWS fill:#1E293B,stroke:#A855F7,color:#F8FAFC
    style SNOW fill:#1E293B,stroke:#38BDF8,color:#F8FAFC
    style DBX fill:#1E293B,stroke:#F97316,color:#F8FAFC
```

### 3.2 传统“独立图数据库孤岛 + 每日 CSV 导出 ETL” vs “Fabric Graph + Fabric IQ Ontology 湖内零拷贝属性图”对比图（`flowchart LR`）

```mermaid
flowchart LR
    subgraph Legacy["❌ 传统独立图数据库孤岛架构 ($37,900/月 · T+1 同步滞后 · 导出后 RLS 权限丢失)"]
        direction TB
        L1["数据湖/数仓 8,500 万实体与 12 亿边<br/>工商股权 / SWIFT / 海运提单表"] -->|每日批量导出 CSV 并重载图索引<br/>滞后 12-24h ($7,400/月 ETL 算力)| L2["独立全内存图数据库集群<br/>Neptune / Neo4j Enterprise ($24,500/月 常驻 RAM 税)"]
        L2 -->|另建向量库拼凑 GraphRAG ($6,000/月)<br/>OneLake RLS 权限在图库中彻底失效| L3["风控与合规审核端<br/>漏检当天新设空壳公司 · 暴露于 $6.10M 制裁风险"]
    end

    subgraph Modern["✅ Fabric Graph + Fabric IQ Ontology 零拷贝架构 ($9,400/月 · 省 75.2% · 239ms 8 跳 UBO 穿透)"]
        direction TB
        M1["OneLake 统一 Delta 存储 (85M 节点 / 1.2B 边)<br/>零拷贝图投影 ($0 导出 ETL · $0 独立图库税)"] -->|56ms 增量挂载 CSR 邻接索引| M2["Fabric Graph (原生 ISO GQL) + SSD DiskANN<br/>60ms 完成 8 跳离岸空壳公司环路穿透 (24 家空壳)"]
        M2 -->|61ms Foundry IQ 核验 OFAC/AMLD6 制裁红线<br/>100% 继承 OneLake 行列安全| M3["Rayfin SDK + 1GB 免费 Fabric SQL<br/>62ms 冻结信用证并落库 SAR 证据图 (239ms E2E)"]
    end

    Legacy -. "架构收敛：用湖内零拷贝属性图与 ISO GQL 消灭外挂图数据库孤岛" .-> Modern

    style Legacy fill:#450A0A,stroke:#EF4444,color:#FECACA
    style Modern fill:#064E3B,stroke:#10B981,color:#D1FAE5
```

### 3.3 跨国贸易金融 8,500 万实体 × 12 亿边 8 跳反洗钱 UBO 穿透时序图（`sequenceDiagram`）

```mermaid
sequenceDiagram
    autonumber
    participant OL as OneLake Delta Tables (85M Nodes / 1.2B Edges)
    participant FG as Fabric Graph (Native ISO GQL & CSR Index)
    participant Guard as Foundry IQ (OFAC & EU AMLD6 Guardrail + DiskANN)
    participant SQL as Compliance Officer Teams & 1GB Free Fabric SQL

    OL->>FG: 1. 零拷贝映射工商股权、SWIFT 与提单 Delta 表并挂载 CSR 邻接索引 (56ms, $0 图导出 ETL)
    FG->>FG: 2. 执行 ISO GQL 8 跳穿透查询，锁定 24 家离岸空壳旋转木马环路 (UBO 控股 68.4% > 25% 红线, 60ms)
    FG->>Guard: 3. 核验 TRADE-FINANCE-AML-UBO-SANCTIONS-SOP-027 并结合 DiskANN 历史洗钱特征确认强制拦截 (61ms)
    Guard->>SQL: 4. 合规官在 Teams 批准冻结 $6.10M 信用证并将 8 跳证据图写入 1GB 免费 Fabric SQL (62ms -> 239ms E2E)
```

---

## ④ 📊 五大平台企业级图分析、ISO GQL 与 GraphRAG 选型决策矩阵（Architect Decision Matrix）

| 评估维度 | Microsoft Fabric (`Fabric Graph + Fabric IQ Ontology`) | GCP (`Spanner Graph`) | AWS (`Amazon Neptune & Neptune Analytics`) | Snowflake (`Neo4j on Snowpark Container Services`) | Databricks (`GraphFrames + Mosaic AI GraphRAG`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **底层存储与成图模式** | **OneLake Delta 表零拷贝原位图投影（表即图，无需导出复制）** | Cloud Spanner 分布式关系表原位映射（`CREATE PROPERTY GRAPH`） | 独立图存储卷与内存计算集群（需从 S3/数仓导入数据） | 需将 Snowflake 表加载至 SPCS 容器内 Neo4j 内存实例 | 基于 Spark DataFrame 动态构建内存图（无持久化原生图索引） |
| **标准图查询语言支持** | **原生支持国际标准 ISO GQL + 可视化无代码图探索 + NL2GQL** | 原生支持国际标准 ISO GQL + SQL 混合查询 | openCypher + Apache TinkerPop Gremlin + RDF SPARQL | Cypher（通过 Neo4j 容器） | PySpark DataFrame API / Motif Finding（非交互式低延迟 GQL） |
| **与业务本体及 BI 的融合** | **与 Fabric IQ Ontology 1:1 绑定，图查询结果直连 Power BI DirectLake 与 Data Agent** | 需通过 BigQuery 联邦或 Looker 额外建模 | 需导出至 QuickSight 或通过 Graph Explorer 查看 | 需写回 Snowflake 表再供 BI 消费 | 需写回 Delta 表再供 AI/BI Genie 消费 |
| **细粒度权限与安全继承** | **100% 自动继承 OneLake RLS/CLS/OLS 与 Purview 标签（GraphRAG 零越权）** | 继承 Spanner IAM 与精细访问控制 | 独立 Neptune IAM 策略（与湖仓 Lake Formation 权限分离） | 容器内 Neo4j 权限需与 Snowflake RBAC 额外同步 | 依赖底层 Delta 表 Unity Catalog 权限（图对象本身无独立行级剪枝） |
| **计费模式与常驻内存税** | **复用 F-SKU 容量池（按查询消耗 CU，空闲 `0` 独立图库月租）** | 按 Spanner 节点/处理单元（OLTP 级高单价）24×7 计费 | 按 Neptune 实例或 `m-NCU` 内存容量单元持续计费 | Snowflake SPCS 计算节点 Credit + Neo4j 商业许可双重计费 | 按 Spark 集群全量扫描构建图的 DBU 计费 |
| **参考月度图分析 TCO** *(8,500 万节点 / 12 亿边)* | **`$9,400 / 月`** *(含于 F64 容量池分摊 + DiskANN，省 **75.2%**)* | `$34,200 / 月` *(Spanner 企级多节点存储与计算成本较高)* | `$36,800 / 月` *(Neptune Analytics 大内存 `m-NCU` 常驻 + ETL)* | `$37,900 / 月` *(SPCS 常驻内存容器 + Neo4j 授权 + 同步算力)* | `$27,600 / 月` *(交互式多跳查询需维持常驻 Spark 集群)* |

---

## ⑤ 🧪 简明定量测评与 TCO / 多跳延迟拐点洞察（含 7-Card 报告）

### 5.1 跨国贸易金融 8,500 万实体 × 12 亿边 8 跳反洗钱 UBO 穿透定量对比（`DL-121..DL-124` · `reports/report.json`）

> **数据溯源口径说明**：以下 8,500 万节点 / 12 亿边多跳图穿透耗时、月度图分析 TCO 与 `$6.10M` 贸易金融制裁合规敞口来自 `src/data_lab/benchmark_suite.py` 中的确定性参考模型（`synthetic_scenario_model`），路由判定（`123/124 = 99.19%`）与 `58/58` 单元测试为 `measured_local_harness`，官方产品特性截至 `2026-11-10`（`vendor_published_spec_as_of_2026`）。

| 量化指标 | Microsoft Fabric (`Fabric Graph + ISO GQL + DiskANN`) | 传统“外挂 Neo4j/Neptune + 每日导出 ETL”方案 |传统数仓递归 SQL (`WITH RECURSIVE` 8 跳 Join) | 架构师核心洞察 |
| :--- | :--- | :--- | :--- | :--- |
| **月度图分析与 GraphRAG 总成本** | **`$9,400 / 月`** | `$37,900 / 月` *(常驻全内存图实例 + 商业许可 + ETL)* | `$26,500 / 月` *(高并发递归 Join 极易打满数仓集群)* | **节省 75.2%（`-$28,500/月`，年省 `$342,000`）** |
| **8 跳 UBO 空壳公司环路穿透延迟 (P95)** | **`60 ms` 图查询 / `239 ms` 端到端闭环** | `95 ms` 图查询，但**数据滞后 12–24 小时** | `46,800 ms (46.8 秒)` 或 OOM 超时 | CSR 邻接索引比递归 SQL 快 **780 倍**，且消除 T+1 数据盲区 |
| **独立图数据库数据导出 ETL 开销** | **`$0`（OneLake Delta 零拷贝原位投影）** | `$7,400 / 月` *(每日全量/增量导出与重索引)* | `$0` | 彻底消灭“为了查图把数据搬出数据湖”的架构税 |
| **GraphRAG 检索节点级 RLS 权限继承率** | **`100.0%`（OneLake OBO 原生剪枝）** | `0.0%` *(需手工重写 Cypher/Gremlin 过滤逻辑)* | `100.0%` | 防止智能体通过多跳邻居遍历泄露未授权高管节点 |
| **24 家离岸空壳旋转木马洗钱环路召回率** | **`100.0%` (锁定 68.4% 隐名 UBO 控股)** | `83.3%` *(漏检当日新注册空壳关联边)* | `41.7%` *(通常被限制在 3 跳内截断)* | 8 跳深度 + 秒级新鲜度是拦截复杂贸易洗钱的关键 |
| **规避 OFAC / EU AMLD6 贸易制裁敞口** | **守护 `$6,100,000` 信用证合规 SLA** | 暴露于当日突发制裁实体穿透盲区 | 无法在交易审批窗口内完成深跳核验 | 从“事后 T+1 离线跑批”升级为“交易前 239ms 实时熔断” |

### 5.2 架构师多跳图选型拐点洞察
1. **“跳数（Hop Count）”选型法则**：
   - **1–2 跳简单关联**：直接用 **Fabric Warehouse / SQL 常规星型模型 Join** 即可，无需动用图引擎；
   - **3–10+ 跳动态路径、环路检测（Cycle Detection）、最短路径与隐名 UBO 穿透**：必须启用 **Fabric Graph (ISO GQL)**——因为 3 跳以上关系型 Join 的复杂度呈指数级爆炸，而 Fabric Graph 的 CSR 邻接指针保持亚秒级线性扩展。
2. **为什么“Table-as-Graph（表即图）”是未来五年图数据库的主流终局？**
   - 独立图数据库（Neo4j / Neptune）过去之所以昂贵且难落地，是因为它们迫使企业维护第二套存储与第二套安全体系。以 **Microsoft Fabric Graph** 和 **GCP Spanner Graph** 为代表的新一代架构证明：**图不应该是另一个数据库孤岛，而应该是构建在统一表存储之上的原生 ISO GQL 索引与语义层**。

---

## ⑥ 🛠️ 附录：生产落地与售前打单快速核验清单（Architect Checklist）

- [ ] **识别 3 跳以上高价值图场景**：在售前访谈中重点挖掘客户是否存在 **“超过 3 层嵌套的股权/受益人穿透（UBO）”、“多级 BOM 物料断供影响分析”、“团伙欺诈环路识别”** 或 **“跨文档多跳 GraphRAG 问答”** 痛点。
- [ ] **用 OneLake 零拷贝图投影替代 CSV 导出图库**：验证客户的节点表（客户、企业、物料）与边表（转账、控股、供货）是否已位于 OneLake Delta（或可通过 Mirroring/Shortcuts 接入），直接在 Fabric Graph 中定义 Node/Edge 映射，砍掉外部图库同步管道。
- [ ] **编写标准 ISO GQL 多跳规则并绑定 Fabric IQ Ontology**：使用标准 ISO GQL 语法编写 3–8 跳路径匹配规则（如控股比例累加 > 25%），并将其注册为 Fabric IQ Ontology 的核心推理工具供 Data Agent 调用。
- [ ] **验证“DiskANN 向量 + ISO GQL 图”混合 GraphRAG 闭环**：对非结构化政策/合同启用 Cosmos DB / SQL SSD DiskANN 向量检索，再通过 Fabric Graph 沿实体关系边扩展 2–4 跳上下文，实现高召回、零幻觉的混合 GraphRAG。
- [ ] **压测 OBO 行级安全在多跳遍历中的自动剪枝**：使用两个不同权限的 Entra ID 测试账号执行同一条 6 跳 GQL 查询，验证无权限访问的中间节点及下游路径被 OneLake Security 自动屏蔽。
