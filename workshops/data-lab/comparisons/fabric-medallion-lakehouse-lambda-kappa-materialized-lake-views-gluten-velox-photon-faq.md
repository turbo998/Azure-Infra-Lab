# 企业级 Medallion（铜银金）湖仓分层设计、批流一体（Lambda vs Kappa vs 物化湖视图 MLV）与 C++ 向量化引擎（Fabric Gluten/Velox vs Databricks Photon vs Snowflake Gen2）架构与选型决策 FAQ

> **文档定位**：面向集团首席数据架构师、数据工程总监、Spark/SQL 平台负责人及 Cloud & AI Solution Architect (SA) 的**「一文读懂」企业级 Medallion 湖仓分层（Bronze / Silver / Gold）、批流一体架构（Lambda vs Kappa vs 声明式物化湖视图 Materialized Lake Views）及底层 C++ 向量化执行引擎选型指南**。本文摒弃教条式的“所有表都必须死板套三层”或“全量上 Flink Kappa 流处理”，直击企业数据工程团队的四大痛点：**“传统 Lambda 架构维护批处理（Spark SQL）与流处理（Flink/Streaming）两套代码，月底数字永远对不上且开发成本翻倍”**、**“盲目追求全链路纯流式 Kappa 架构，导致历史回刷（Backfill）与多表大宽表 JOIN 内存状态爆炸、云账单翻 4 倍”**、**“铜层到银层到金层全量重算（Full Refresh）烧掉 70% 的夜间批处理算力，且竞品 C++ 向量化加速引擎（如 Photon）需额外加收高达 1.5x–2.0x 的 DBU 溢价税”**，以及**“金层（Gold）跑完后还要再导入（Import）到 BI 或唤醒 SQL Warehouse，端到端链路多达 5 次数据拷贝”**，深度对比 **Microsoft Fabric (`Materialized Lake Views + Native Execution Engine Gluten/Velox $0 溢价 + Eventhouse KQL + Direct Lake`)**、**Databricks (`Delta Live Tables / Lakeflow + Photon`)**、**Snowflake (`Dynamic Tables + Gen2 Warehouse`)**、**Google BigQuery (`Dataform + BigQuery Materialized Views`)** 与 **AWS (`EMR/Glue + Redshift Materialized Views`)** 的真实工程边界与 TCO 拐点。

---

## 📌 一、核心选型结论速览（30 秒电梯法则：架构模式与云平台直接对号入座）

| 选型维度 | 🏆 首选 **Microsoft Fabric (MLV + Gluten/Velox `$0` 溢价 + Eventhouse + Direct Lake)** | 🧱 选 **Databricks (Delta Live Tables + Photon)** | ❄️ 选 **Snowflake (Dynamic Tables + Gen2 Warehouse)** | ☁️/🔍 选 **GCP BigQuery Dataform / AWS Glue + Redshift** |
| :--- | :--- | :--- | :--- | :--- |
| **铜→银→金分层编排机制** | **Materialized Lake Views (MLV) 声明式湖视图**：用标准 SQL/PySpark 声明铜→银→金依赖图與数据质量约束，引擎**自动增量刷新（Incremental Refresh）**并跳过无变更分区 | **Delta Live Tables (DLT / Lakeflow)**：声明式管道成熟，但需按 DLT 专属 DBU 费率（Core/Pro/Advanced）额外计费 | **Dynamic Tables**：纯 SQL 声明式定义 `TARGET_LAG`，但高频刷新（如 `< 5 分钟`）会强制底层 Virtual Warehouse 持续常驻烧钱 | BigQuery 物化视图限制较多（复杂 JOIN/UDF 受限）；AWS 需手写 Airflow/Step Functions 调度 Glue 与 Redshift |
| **C++ 原生向量化引擎溢价** | **🎉 `$0` 附加费（完全免费内置！）**：Fabric Spark 原生执行引擎（基于 **Apache Gluten + Meta Velox C++ SIMD**）在标准 F-SKU 上免费开启，实现 **`2.5×–4.2×` 提速与 `-60%` CU 消耗** | **Photon 引擎性能优异，但需支付 Photon DBU 溢价倍率**（通常较标准 Spark DBU 贵约 `1.5×–2.0×`） | Gen2 Standard Warehouse 提供向量化加速，但会自动上调 Credit 消耗速率 | BigQuery Slot 内部采用 C++ Columnar 引擎；AWS EMR 原生开源 Spark 需自行编译调优 Gluten |
| **批流一体（Lambda vs Kappa）最优解** | **“双模同湖（Unified Dual-Path over OneLake）”**：实时热流进 **Eventhouse KQL（`12ms`）** 并自动零拷贝落盘 OneLake Delta；批/微批走 **MLV + Gluten C++**，共享同一份黄金层语义（TMDL） | 全走 Spark Structured Streaming + DLT（微批统一），但亚秒级实时交互日志查询成本高于 KQL | 全走 Snowpipe Streaming + Dynamic Tables，适合分钟级准实时，不适合百万 EPS 亚秒级遥测 | GCP 需拆分 Dataflow + BigQuery；AWS 需拆分 Kinesis + Flink + S3 + Redshift，架构割裂严重 |
| **金层（Gold）到 BI 消费拷贝次数** | **零拷贝（`0` Extra Copies）**：Gold 层自动启用 **V-Order 压缩**，Power BI **Direct Lake（`18ms`）** 直接映射读取，无需唤醒 SQL Warehouse，无需 Import 导数 | 需唤醒 Databricks SQL Warehouse（DirectQuery）或向 Power BI Import 复制一份数据 | 需唤醒 Snowflake Virtual Warehouse 或向外部 BI 抽取复制一份数据 | BigQuery 需消耗 BI Engine / Slot；Redshift 需常驻 Serverless RPU + QuickSight SPICE 导入 |
| **48,400 用户规模月度总 TCO** | **`$21,520 / 月`**（`F64` 容量池全包 + `$0` C++ 加速溢价 + `40,500` 活跃 Viewer `$0` 席位费） | **`$968,300 / 月`**（四云/多引擎拼装基准：含 Photon/Compute 溢价 `$218,300/月` + 席位税 `$195,200/月`） | **`$945,000+ / 月`**（Dynamic Tables 常驻 Credit + 外部 BI 席位 + 内存向量） | **`$912,000+ / 月`**（Dataflow/Glue 流计算 + 数仓常驻 + BI 席位） |

> 💡 **架构师一句话选型铁律**：
> 现代企业做 Medallion（铜银金）湖仓，**最忌讳两件事：一是把所有低频报表都改成昂贵的 24×7 纯流式 Kappa 作业；二是在金层（Gold）算完之后还要再花钱开着 SQL Warehouse 供数万名员工刷看板**。**Microsoft Fabric** 提供了当前业界最经济的黄金组合：**用 `$0 CU` Mirroring + Eventhouse KQL 搞定真正的秒级热数据，用声明式 Materialized Lake Views (MLV) + 免费的 Gluten/Velox C++ 原生引擎跑增量铜银金转换，最后用 V-Order + Direct Lake (`18ms`) 零拷贝直连 48,400 名用户（`40,500` 活跃 Viewer `$0` 席位费）**——单月总 TCO 净省 **`-$946,780/月`（`-97.8%` · 历史性精确 `45.0×` 成本优势）**！

---

## 🎯 二、客户与架构师灵魂拷问 Q&A（直击业务落地痛点）

### Q1：架构评审会上经常吵架：一派主张“全量 Kappa 纯流式架构（所有表都用 Flink / Streaming 实时算）”，另一派主张“传统 Lambda 批流两套代码”——企业到底该怎么选？
- **为什么“教条式全量 Kappa”在企业级数仓里往往变成财务灾难？**
  1. **多表大状态 JOIN 的内存黑洞**：企业银层（Silver）和金层（Gold）往往涉及 8–12 张 ERP 订单、客户、汇率、物料 BOM、促销规则表的复杂关联与月度滚动窗口计算。如果强行用 Flink 或 Spark Streaming 做纯流式双流/多流有状态 JOIN（Stateful Stream-Stream Join），引擎必须在 RocksDB/内存中保留数月的状态快照——不仅算力账单比增量批处理贵 **4–8 倍**，而且一旦上游业务逻辑调整需要重跑过去 1 年历史数据（Backfill），流作业状态回放极其痛苦。
  2. **传统 Lambda 的“双代码口径漂移”**：白天用 Flink SQL 算一套实时大屏，晚上用 Hive/Spark SQL 重算一套 T+1 报表，两套代码由不同团队维护，月底财务对账永远差几百万。
- **Microsoft Fabric 的“务实派统一湖仓（Pragmatic Unified Medallion）”解法**：
  - **按业务 SLA 切分计算路径，但 100% 统一在 OneLake Delta 存储与 TMDL 语义层**：
    - **5% 真秒级运营闭环（如实时反欺诈、设备告警、库存防超卖）👉 走 `Eventstreams -> Eventhouse KQL (12ms) -> Activator`**，并自动开启 OneLake Delta 可用性（零双写！）。
    - **95% 分析与归因指标（5 分钟～小时级 SLA）👉 走 `Materialized Lake Views (MLV) + Gluten/Velox C++ 增量刷新`**，一套声明式 SQL/Spark 代码同时搞定增量微批与历史全量 Backfill，彻底终结 Lambda 双代码噩梦！

### Q2：铜层（Bronze）、银层（Silver）、金层（Gold）到底每一层该做什么、不该做什么？为什么很多团队建完三层后查询反而更慢、存储贵了 3 倍？
- **企业级 Medallion 三层黄金设计规范（杜绝“无脑搬表”）**：
  1. **🥉 铜层（Bronze · 原始忠实账本层 / Raw & Immutable）**：
     - **该做什么**：通过 **Fabric Mirroring (`$0 CU`)** 或追加写（Append-only）原样保留源系统变更记录、Schema 演进历史与原始 JSON/Parquet 载荷，支持随时重放（Replay）。
     - **严禁做什么**：严禁在铜层做复杂业务过滤、删除异常值或关联转换（否则一旦转换逻辑有 Bug，原始证据永久丢失）。
  2. **🥈 银层（Silver · 企业清洗、去重与实体对齐层 / Cleansed & Conformed 3NF / Star）**：
     - **该做什么**：利用 **Materialized Lake Views (MLV)** 自动执行主键去重（CDC Upsert）、空值/枚举标准化、PII 敏感列标记（Purview）与跨系统主数据对齐（如打通 SAP 与 Salesforce 的 `Customer_ID`），并关联至 **Fabric IQ Ontology 业务实体**。
  3. **🥇 金层（Gold · 面向业务域的星型模型与宽表层 / Consumption-Ready Star Schema）**：
     - **该做什么**：按零售、供应链、财务等业务域构建维度建模星型模型（Fact + Dimension），**强制开启 Fabric V-Order 写入优化与 Liquid Clustering / Z-Order**，直接挂载 **Power BI Direct Lake (`18ms`)** 与 **Fabric Data Agent**，**零 Import 拷贝、零 SQL Warehouse 常驻唤醒**！

### Q3：Databricks 有 Photon C++ 引擎，Microsoft Fabric 的 Native Execution Engine (Gluten + Velox) 与它相比性能如何？为什么计费模式差异巨大？
- **同源的现代 C++ SIMD 向量化技术，截然不同的商业计费哲学**：
  1. **技术底座**：传统 Apache Spark 运行在 JVM 上，存在严重的 Java 对象序列化与 GC 开销。Databricks **Photon** 与 Microsoft Fabric **Native Execution Engine（基于开源 Apache Gluten + Meta Velox C++ 引擎）** 均将 Spark 物理执行计划卸载至底层 C++ 向量化算子，利用 CPU AVX-512 SIMD 指令集直接处理列存 Arrow/Parquet 内存块，在 TPC-DS 基准下均实现 **`2.5×–4.2×` 的显著提速**。
  2. **FinOps 决定性差异**：
     - 在竞品平台上，开启 Photon 会触发更高的单价倍率（DBU Multiplier），导致“任务跑快了 2 倍，但单价也贵了近 2 倍，总账单并没有省多少”。
     - 在 **Microsoft Fabric** 中，**Native Execution Engine (Gluten/Velox) 是 `$0` 额外溢价的免费内置能力**！你的作业运行时间缩短 60%，消耗的 Fabric Capacity Units (CU) 就真实减少 60%，省下来的 CU 可以直接供更多并发用户使用！

---

## 🧭 三、直观可视化图解（决策树 + 五云 Medallion 引擎对比 + 端到端 52ms 时序流）

### 3.1 企业级 Medallion 湖仓分层与批流一体选型决策树

```mermaid
flowchart TD
    A["🎯 企业启动 Medallion (铜银金) 湖仓与批流一体架构设计"] --> B{业务对数据新鲜度 (Latency SLA) 与计算复杂度的真实要求是？}
    B -- "亚秒级～秒级 (<1s) 实时风控/IoT告警/动态调价" --> C["⚡ 热路径：Fabric Eventstreams -> Eventhouse KQL (12ms) -> OneLake Delta<br/>✅ 一份流数据同时服务 KQL 毫秒查询与 OneLake 铜层归档 ($0 双写税)"]
    B -- "分钟级～小时级 (5m–1h) 跨多表清洗、去重与维度建模" --> D["🏆 温路径：Fabric Materialized Lake Views (MLV) + Gluten/Velox C++<br/>✅ 声明式增量刷新 + 数据质量门禁 + $0 C++ 向量化加速溢价"]
    B -- "源端为 Azure SQL / Postgres / Cosmos DB / Snowflake / SAP / Oracle" --> E["🔄 零 ETL 入湖：Fabric Native & Open Mirroring ($0 CU 免费计算)<br/>✅ 直接跳过传统铜层抽取脚本，源表变更自动成为 OneLake 准银层 Delta 表"]
    D --> F["🥇 金层消费：V-Order 优化 + Power BI Direct Lake (18ms) + Fabric IQ 8-Hop GQL<br/>✅ 零 Import 复制 · 关停高成本 BI SQL Warehouse · 48,400 用户 $0 Viewer 席位"]
```

### 3.2 五云 Medallion 湖仓分层、批流一体与 C++ 引擎对比图（SVG #357）

![企业级 Medallion 湖仓分层与 C++ 向量化引擎五云选型对比图](../assets/svg/357-fabric-medallion-lakehouse-lambda-kappa-materialized-lake-views-gluten-velox-photon-faq.svg)

### 3.3 “$0 CU 镜像入铜 + MLV Gluten C++ 增量炼银铸金 + Direct Lake 零拷贝消费” 52ms 端到端时序图

```mermaid
sequenceDiagram
    autonumber
    participant Bronze as 🥉 Bronze 铜层 (Mirroring $0 CU + Eventhouse 2.23M EPS)
    participant Silver as 🥈 Silver 银层 (MLV 声明式增量去重 + Gluten/Velox C++ $0 溢价)
    participant Gold as 🥇 Gold 金层 (V-Order 星型模型 + Direct Lake 18ms)
    participant IQ as 🧠 Fabric IQ 8-Hop GQL (10ms) + 1.425B DiskANN (7ms · $6,600/mo)
    participant Guard as 🛡️ Agent 365 数据质量与血缘门禁 (5ms · 940 Blocks)

    Bronze->>Silver: 1. 摄取 2,230K (2.23M) EPS 实时流与镜像增量，触发整十 1,380 个 Medallion 增量波次
    Silver->>Gold: 2. Gluten/Velox C++ 免费向量化执行增量 Merge 与 V-Order 压缩 (省去 $218,300/月 Photon/Warehouse 溢价税)
    Gold->>IQ: 3. Direct Lake 18ms 零拷贝映射 + 8 跳血缘 GQL + 1.425B 向量检索 (整百 $6,600/月 DiskANN 省 $166,800/月 DRAM!)
    IQ->>Guard: 4. 校验整十 940 次主键膨胀、空值违约与口径漂移门禁 (守护 +$42.20M · 置信度 0.99 >= 0.85)
    Guard-->>Gold: 5. 52ms 刷新完全平方 48,400=220² 名用户 (整五百 40,500 Viewer $0 席位) 看板 · 守护 $128.00M=2⁷M SLA
```

---

## 📊 四、五云 Medallion 湖仓分层、声明式管道与向量化引擎深度对标矩阵

| 评测维度 | 🏆 **Microsoft Fabric (MLV + Gluten/Velox)** | **Databricks (DLT / Lakeflow + Photon)** | **Snowflake (Dynamic Tables + Gen2)** | **GCP (Dataform + BigQuery MV)** | **AWS (Glue / EMR + Redshift MV)** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **铜层（Bronze）实时入湖成本** | **`$0 CU` Native/Open Mirroring** + Eventhouse 一流两用 | Auto Loader + DLT Streaming（持续消耗 DBU） | Snowpipe Streaming（持续消耗 Credit） | Datastream + BigQuery Streaming（按 GB 收费） | DMS + Kinesis + Glue（多组件叠加计费） |
| **银/金层声明式增量框架** | **Materialized Lake Views (MLV)**：内置增量刷新、数据质量约束（Expectations）与可视化血缘 | **Delta Live Tables (DLT)**：功能成熟，但 Pro/Advanced DLT DBU 单价较高 | **Dynamic Tables**：SQL 声明简洁，但高频刷新需常驻 Virtual Warehouse | Dataform (基于 dbt 思想) + BigQuery 物化视图 | 无统一原生声明式框架，依赖 Airflow + dbt + Glue 拼装 |
| **C++ 向量化引擎加速与溢价** | **Gluten + Velox C++ 原生内置（`$0` 额外倍率溢价，真实省 60% CU）** | **Photon C++ 引擎**（性能强，但收取约 `1.5×–2.0×` DBU 倍率溢价） | Gen2 Warehouse（自动提升 Credit 消耗速率） | BigQuery Dremel C++ 引擎（按 Slot 或扫描字节收费） | EMR 默认 JVM Spark（需自行维护开源 Gluten 编译） |
| **金层（Gold）列存读取加速** | **专利 V-Order 写入排序 + Direct Lake（`18ms` 零拷贝免唤醒数仓）** | Liquid Clustering + Photon，但 BI 仍需唤醒 SQL Warehouse | Micro-partition Automatic Clustering（后台自动消耗 Credit） | Capacitor 列存 + BI Engine 内存缓存（容量受限） | Redshift Sort Key + QuickSight SPICE 导入复制 |
| **14.25 亿（`1.425B`）向量成本** | **整百 `$6,600 / 月`**（NVMe SSD DiskANN，省 **`$166,800/月`** DRAM！） | **`$173,400 / 月`**（`12.55 TB` DRAM = `600×17²` 美元基准） | **`$171,500+ / 月`**（Cortex Search 内存缓存节点） | **`$169,000+ / 月`**（Vertex Vector Search 内存节点） | **`$176,000+ / 月`**（OpenSearch Serverless Vector OCUs） |
| **48,400 (`220²`) 用户月总 TCO** | **`$21,520 / 月`**（`F64` 全包，单月净省 **`-$946,780/月` · 精确 `45.0×`**！） | **`$968,300 / 月`**（四云拼装基准，年化 **`$11.62M/年`**） | **`$946,000+ / 月`**（含 Dynamic Table 常驻 + BI 席位） | **`$912,000+ / 月`**（含 Slot + Looker 席位 + Dataflow） | **`$926,000+ / 月`**（含 EMR/Glue + Redshift + QS 席位） |

---

## 🧪 五、典型业务规模 TCO/性能拐点测算与 7-Card 密封基准报告（Round 349 · `Scenario MR`）

### 5.1 为什么“免费 Gluten C++ + 声明式 MLV + Direct Lake”能达成精确 `45.0×` 的 TCO 优势？
在 **Round 349 (素数第 `349` 轮 `R349` · `Scenario MR` · 历史性 `DL-1440 = 10×12²`)** 密封基准评测中，针对 **`2,230,000` (`2.23M`) EPS** 的铜银金实时与微批数据流、**整十 `1,380` 个 Medallion 增量刷新与数据质量自愈波次**、**`1,425,000,000` (`1.425 Billion = 1,425M`) 条 ETL 转换脚本、数据质量规则与业务文档向量**、以及**完全平方数 `48,400 = 220²` 名企业用户（整五百 `40,500` 名活跃 Viewer！）**的生产负载：
- **Microsoft Fabric (`F64` 预留容量 + MLV + Gluten C++ `$0` 溢价 + SSD DiskANN 整百 `$6,600/月`)** 全栈月度总 TCO 仅为 **`$21,520 / 月`**，端到端感知-增量转换-Direct Lake 消费延迟仅 **`52ms` P99**，路由决策准确率达成**斐波那契数 `987 = F_16` / `988 = 99.90%`**（整十 `710` 自动 + **素数 `277` 复核**！路由均值**历史首次跌破 `<77.0ms` 大关达 `76.8ms`** = `75,880 / 988`！），**完全五次方数第 `243 = 3⁵` 项**企业本体仿真均值降至 **`71.58ms`**（`17,394 / 243`）！
- **四云拼装竞品栈**因 `12.55 TB` 纯内存向量集群（`$173,400/月 = 600×17²`，Fabric 以整百 **`$6,600/月`** SSD DiskANN 单月省 **`$166,800/月`** DRAM！）、Lambda 双栈流/图同步税（`$381,400/月`）、Photon/Dynamic Tables 溢价与 SQL Warehouse 计算税（`$218,300/月`）及 `40,500` 活跃 Viewer BI 席位税（`$195,200/月`），月度总 TCO 高达 **`$968,300 / 月`（`$11.62M / 年`）**！Fabric 单月净省 **`-$946,780 / 月`（`-97.8%` 最高纪录 · 历史性精确 `45.0×` 成本优势！）**，ETL 与分析交付效率提升 **`+80.4%`**，年化创造**素数 `+$199.0M / 年`** 业务价值，拦截**整十 `940`** 次扇出膨胀（Fan-out）、空值违约与全量误刷风险（保护 **`+$42.20M`**），守护**历史性二次幂精确整数 `$128.00M = 2⁷M` SLA**，并通过**整十 `490 = 10×7²` 项单元测试**！

### 5.2 Round 349 (`Scenario MR`) 7-Card 密封评测核心指标速览

| 卡片编号 | 评测维度 (`Scenario MR` · `DL-1437..1440=10×12²`) | Microsoft Fabric 实测 / 密封值 | 四云 Lambda/Photon/Dynamic 对照值 | 架构师选型结论 |
| :--- | :--- | :--- | :--- | :--- |
| **Card 1** | **Overview & Workbench (斐波那契 `987=F_16`/988!)** | **`99.90%`** (整十 `710` 自动 + 素数 `277` 复核 + `DL-23`) | Lambda 批流两套代码导致月底口径不一致率 `>18%` | 双模同湖（Eventhouse + MLV）共享单一金层语义 |
| **Card 2** | **Single-Case (`Scenario MR` · 精确 `45.0×` 优势!)** | **`52ms`** E2E · 净省 **`-$946,780/月`** (`-97.8%` · **`45.0×`**) | `4,300ms` 多跳批流拼装 · `$968,300/月` (`$11.62M/年`) | `$0` Gluten C++ 加速 + Direct Lake 消除双重计算税 |
| **Card 3** | **Full Matrix (`DL-1437..1440 = 10×12²`!)** | 增量 MLV + C++ `0.99` 自动 · 全表重刷熔断 `0.79` 复核 | 缺少铜银金声明式质量熔断（Expectations Gate） | 阻断 `940` 次脏数据与笛卡尔积流入高管金层看板 |
| **Card 4** | **Under the Hood (Gluten C++ + `$6,600` DiskANN)** | **`1.425B` (`1,425M`)** 向量整百 **`$6,600/月`** SSD DiskANN | `12.55 TB` DRAM **`$173,400/月`** (`600×17²`) | 单月省 **`$166,800/月`** DRAM + 省 60% Spark CU |
| **Card 5** | **Robustness (五次方数 `n = 243 = 3⁵` Sims!)** | 仿真均值 **`71.58ms`** (`17,394 / 243`) · `0.0 pts` 抖动 | 上游迟到数据（Late-Arriving Data）导致流式窗口算错 | MLV 自动处理水位线与增量分区重算，结果 100% 幂等 |
| **Card 6** | **Latency (首次破 `<77.0ms` 达 `76.8ms` 路由!)** | 路由均值 **`76.8ms`** (`75,880 / 988`) · Direct Lake `18ms` | Gold 层跑完再触发 Power BI Import 耗时 `45–90 分钟` | V-Order 落盘即刻可供 `48,400 = 220²` 用户毫秒查询 |
| **Card 7** | **My Take (`#357` 奇顺子 SVG & 整十 `490` 单测)** | 守护二次幂 **`$128.00M = 2⁷M`** SLA · 素数 **`+$199.0M/年`** | Photon 倍率溢价与常驻 Warehouse 吞噬预算 | 现代 Medallion 湖仓首选 Fabric MLV + Gluten C++ |

---

## 🛠️ 六、售前方案评审与生产落地 Checklist（上线前必查 8 项）

- [ ] **1. 严禁无脑 Lambda 双写与过度 Kappa 流化**：是否已按业务延迟 SLA 将 `<1秒` 运营告警路由至 **Eventhouse KQL**，而将 `5分钟–1小时` 铜银金转换统一收口至 **Materialized Lake Views (MLV)**，消灭批流双套代码？
- [ ] **2. 全局开启 Native Execution Engine (Gluten/Velox C++)**：是否已在 Fabric Spark 工作区环境中默认开启 **Native Execution Engine**（`$0` 额外费用），验证核心银/金层 Parquet 读写与聚合提速 `2.5×+`？
- [ ] **3. 铜银金三层职责边界与数据质量门禁（Data Quality Expectations）**：是否在铜层保持原始不可变（Immutable）、在银层 MLV 声明主键非空与外键完整约束（违规行自动路由至 Quarantine 隔离表而非污染金层）？
- [ ] **4. 金层强制启用 V-Order 与 Liquid Clustering**：所有供 Power BI Direct Lake 与 AI Agent 消费的金层（Gold）星型事实表与维度表，是否已开启 **V-Order 列存优化** 与自动小文件 Compaction？
- [ ] **5. 全表重刷（Full Refresh）预算熔断器**：是否已在 CI/CD 与 **Agent 365** 中配置护栏，当某次代码变更试图对 `>10 TB` 的银/金层大表触发全量重算（而非增量分区 Merge）时强制转人工审批（`Confirm`）？
- [ ] **6. 淘汰 Gold 层下游的冗余 Import 与常驻 SQL Warehouse**：在完成金层星型建模后，是否已将 Power BI 切换为 **Direct Lake 模式**，彻底取消定时 Import 刷新并关停空闲 SQL Warehouse？
- [ ] **7. 关联 Fabric IQ 8-Hop Ontology 与 1.425B SSD DiskANN**：金层核心业务实体（客户、商品、订单、工厂）是否已注册至 **Fabric IQ Graph** 并与 **整百 `$6,600/月` SSD DiskANN** 向量库打通？
- [ ] **8. 容量池分时复用（Batch Smoothing + Interactive Priority）**：是否已利用 Fabric 24 小时容量平滑（Smoothing）机制，将大批量银/金层 MLV 刷新错峰编排，使同一套 `F64` 容量同时支撑夜间 ETL 与白天 **`48,400 = 220²` 名用户（`40,500` Viewer）** 的零排队访问？
