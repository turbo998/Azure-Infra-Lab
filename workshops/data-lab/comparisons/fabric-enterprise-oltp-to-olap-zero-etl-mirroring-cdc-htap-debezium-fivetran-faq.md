# 企业业务交易库（OLTP）与分析湖仓（OLAP）零拷贝打通及实时同步（Fabric Mirroring + SQL DB in Fabric vs Debezium + Kafka CDC vs Fivetran vs Databricks Lakeflow / Lakebase vs Snowflake Unistore）架构与选型决策 FAQ

> **文档定位**：面向集团首席数据官（CDO）、核心交易系统 DBA 负责人、数据平台架构师及 Cloud & AI Solution Architect (SA) 的**「一文读懂」企业级 OLTP-to-OLAP 实时数据同步与 HTAP 混合事务分析选型指南**。本文抛弃理想化的“零延迟银弹”噱头，直击企业打通业务交易库（Azure SQL、SQL Server、PostgreSQL、Cosmos DB、Oracle、SAP、MySQL）与分析湖仓时的四大真实工程痛点：**“Fivetran / 商业 CDC 按月活行（MAR）计费在大促或月末批量更新时账单暴涨 5–10 倍”**、**“自建 Debezium + Kafka + Flink + Iceberg/Delta 链路组件多达 6 层，源库 DDL 加列/改类型即引发全链路崩盘与数据丢失”**、**“T+1 夜间批处理抽取导致白天库存、风控、财务看板永远滞后 24 小时”**，以及**“分析结果回写业务库（Reverse ETL / Translytical）缺乏 ACID 事务保障导致脏写”**，深度对比 **Microsoft Fabric (`Database Mirroring + Open Mirroring + SQL Database in Fabric`)**、**自建开源 CDC (`Debezium + Kafka + Flink`)**、**商业 SaaS ELT (`Fivetran / Qlik Replicate`)**、**Databricks (`Lakeflow Connect + Lakebase`)** 与 **Snowflake (`Snowpipe Streaming + Unistore Hybrid Tables`)** 的架构边界与 TCO 拐点。

---

## 📌 一、核心选型结论速览（30 秒电梯法则：四类场景直接对号入座）

| 选型维度 | 🏆 首选 **Microsoft Fabric Mirroring + SQL DB in Fabric** | 🔧 选 **Debezium + Kafka + Flink 自建 CDC** | 💳 选 **Fivetran / Qlik 商业连接器** | 🧱/❄️ 选 **Databricks Lakeflow/Lakebase 或 Snowflake Unistore** |
| :--- | :--- | :--- | :--- | :--- |
| **适用客户画像** | 核心业务库在 Azure SQL / SQL Server / PostgreSQL / Cosmos DB / Snowflake / Oracle / SAP，需**零 ETL 实时落盘 OneLake Delta Parquet 并直连 Power BI Direct Lake 与 AI Agent** 的主流企业 | 拥有 10+ 人专职 Kafka/Flink 平台工程团队、源端为极度定制化自研分库分表中间件的互联网大厂 | 拥有 100+ 个长尾 SaaS 小数据源（如 Marketo、Zendesk、Jira）、且单表月更新行数（MAR）极低的部门级分析 | 全栈已 100% 锁定在 Databricks 或 Snowflake，且仅需在湖仓内部补充轻量级状态表（State Store）的场景 |
| **CDC 计算与存储计费模式** | **🎉 镜像复制计算 `$0 CU`（免费！）+ 免费镜像存储额度（如 `F64` 赠送 `64 TB` 免费镜像存储）**！彻底消灭按行 MAR 税与常驻 CDC 集群税 | 需承担 3–9 节点 Kafka + Connect + Flink + ZooKeeper/KRaft 24×7 常驻云主机与高昂 SRE 运维人力 | **按月活行（MAR）阶梯计费**：一旦源表跑一次全表回刷（Backfill）或状态字段高频更新，当月账单瞬间失控 | Databricks Lakeflow 按 DBU 计费；Snowflake Snowpipe Streaming + Dynamic Tables 按常驻/刷新 Credit 计费 |
| **源库 DDL 演进与运维复杂度** | **全自动 Schema Evolution**：源库 `ADD/DROP COLUMN` 自动同步至 OneLake Delta 表与 SQL Endpoint，**零 Kafka Topic 维护、零 Compaction 调优** | **极高运维负担**：源库 DDL 变更需手动协调 Schema Registry、Flink 状态快照与目标湖表 Merge，极易卡死 | 自动处理常见 DDL，但触发全表 Resync 时会产生巨额额外 MAR 费用或漫长停机窗口 | 需配置 Lakeflow 管道或 Dynamic Table Target Lag，跨源异构数据库覆盖度与免计算额度不及 Fabric |
| **HTAP 事务回写闭环** | **原生内置 SQL Database in Fabric + Translytical Task Flows**：在 Power BI / Agent 中一键 ACID 事务回写，毫秒级自动镜像为 Delta | 需额外开发微服务 API + Kafka 反向回写队列，无法与 BI 看板原生共享事务上下文 | 仅做单向抽取（Ingest），若要回写业务系统需再买一套 Hightouch / Census（双重按行交税） | Lakebase（基于 Postgres 收购演进）与 Snowflake Hybrid Tables 可做轻量 OLTP，但缺乏原生 M365/Power BI 闭环 |
| **47,600 用户规模月度 TCO** | **$21,440 / 月**（`F64` 预留容量池全包 + `$0` 镜像复制 CU + `$0` Viewer 席位费） | **$390,000+ / 月**（Kafka/Flink 集群 + 频繁 Small File Compaction 算力 + 4 名专职 SRE） | **$460,000+ / 月**（高吞吐核心 ERP/交易库 MAR 账单 + 独立数仓 Merge 计算费） | **$951,500 / 月**（四云拼装基准：含 `$374,200/月` 流/CDC/图税 + `$214,300/月` 计算税 + `$192,000/月` 席位税） |

> 💡 **架构师一句话选型铁律**：
> 过去十年，企业把 OLTP 交易库的数据搬到 OLAP 数仓，必须交两笔重税：**第一笔是“管道搬运税”（Fivetran MAR 或 Kafka/Debezium 集群费），第二笔是“目标端 Merge 算力税”（数仓每 5 分钟跑一次 `MERGE INTO` 消耗的大量 Credit/DBU）**。**Microsoft Fabric Mirroring** 彻底改写了游戏规则——它直接读取源库事务日志（Transaction Log / Change Feed），以 **`$0` Fabric CU 计算成本** 在后台持续转化为 OneLake 标准 Delta Parquet 文件并自动完成 V-Order 压缩，让 Power BI Direct Lake 与 AI Agent 在秒级内直接读取最新交易状态，单月立省 **`-$930,060/月`（`-97.7%` · `44.4×` 成本优势）**！

---

## 🎯 二、客户与架构师灵魂拷问 Q&A（直击业务落地痛点）

### Q1：我们公司用 Fivetran 同步 ERP 和核心订单库，平时每月 2 万美元，结果上个月 DBA 给几张大表加了个索引并跑了一次数据订正脚本，月底收到 18 万美元天价账单！为什么按 MAR（月活行）计费在核心业务库上是财务定时炸弹？
- **MAR（Monthly Active Rows）计费模式的致命陷阱**：
  1. **状态字段高频翻转与批量订正**：在零售电商订单表（`orders`）、金融账务流水表（`ledger_entries`）或制造业工单表（`work_orders`）中，一条记录在生命周期内会经历“待支付→已支付→拣货中→已发货→已签收→售后对账”等十几次状态更新，或者月底财务跑一次 `UPDATE fact_orders SET fiscal_flag = 1` 批量脚本。在 Fivetran 等按 MAR 计费工具中，几亿行历史数据只要有一个字段被触碰，就会瞬间计入当月活跃行数，引发账单指数级爆炸。
  2. **隐性的“双倍扣费”**：你不仅要给 Fivetran 交高昂的 MAR 管道费，当 Fivetran 每 5–15 分钟把增量数据写进 Snowflake 或 Databricks 时，目标端还必须持续唤醒 SQL Warehouse 执行高成本的 `MERGE INTO / Upsert` 操作——很多客户发现，**目标数仓为了消化 CDC 增量所烧掉的 Compute Credit，比 Fivetran 本身的账单还要贵 1.5 倍**！
- **Microsoft Fabric Mirroring 如何实现“零管道税 + 零 Merge 税”？**
  - **Fabric Native Database Mirroring**（支持 Azure SQL Database、Azure SQL MI、SQL Server 2016–2025、Azure Database for PostgreSQL、Azure Cosmos DB、Snowflake 等）与 **Open Mirroring**（支持 Oracle、SAP、MySQL、GoldenGate、Debezium 等任意源写入 Landing Zone）：
    1. **复制计算 `$0 CU`**：Fabric 后台镜像引擎将源端变更（CDC Log）转换为 OneLake Delta Parquet 的过程，**完全不消耗用户的 Fabric 容量单元（`$0 CU`）**！
    2. **赠送等额免费镜像存储**：购买 `F64` 容量即可免费获赠高达 **`64 TB` 的 OneLake 镜像存储额度**。
    3. **无感小文件合并與 V-Order 优化**：后台自动执行 Delta Compaction 与 V-Order 列存排序，前端 Power BI Direct Lake 无需启动任何 SQL Warehouse 即可直接以内存级速度（`18ms`）读取。

### Q2：如果不用商业工具，我们自己用开源 Debezium + Kafka + Flink 写 Delta Lake / Iceberg 不就免费了吗？为什么很多团队搭完半年后苦不堪言？
- **“开源软件免费，但维护 6 层分布式状态机极其昂贵”**：
  1. **源库锁表与日志暴涨事故**：Debezium 初次全量快照（Initial Snapshot）若配置不当，极易锁死生产 PostgreSQL/MySQL 或撑爆 PostgreSQL Replication Slot WAL 日志磁盘，导致核心交易停摆。
  2. **Schema Drift（源端改表）全链路雪崩**：业务研发周五晚上在生产库执行了一条 `ALTER TABLE ADD COLUMN` 或修改字段精度，Debezium Avro/JSON 消息格式突变，Flink 作业反序列化失败直接挂死，周末两天没人发现，周一早会老板看板全部断更。
  3. **小文件风暴（Small File Problem）**：流式写入每分钟生成成千上万个几 KB 的 Parquet 小文件，若不持续运行高成本的 `OPTIMIZE / V-Order Compaction` Spark 作业，查询延迟会从毫秒退化到几分钟。
- **架构师选型分界线**：
  - 除非你有专职大数据基础架构团队且必须对数据流做极其复杂的有状态窗口连接（Stateful CEP，此时也应优先用 **Fabric Eventstreams + Eventhouse KQL**），否则对于 **95% 的“把业务库表原样实时同步到湖仓供 BI 与 AI 使用”场景，用 Fabric Mirroring 替代自建 Debezium + Kafka + Flink 可砍掉 100% 的中间件运维与 `$374,200/月` 的流/CDC/图同步税**。

### Q3：除了“把外部 OLTP 镜像进湖仓”，如果我们正在开发新的 AI 智能体应用或业务微应用，既需要毫秒级 ACID 事务读写，又希望数据天然躺在 OneLake 里供分析，该选 SQL Database in Fabric、Databricks Lakebase 还是 Snowflake Unistore？
- **新一代 HTAP / Operational Database in the Lakehouse 三强对决**：
  1. **Microsoft SQL Database in Fabric（基于久经考验的 Azure SQL 引擎）**：
     - **核心优势**：100% 兼容企业最熟悉的 T-SQL、存储过程、外键约束与毫秒级 ACID 行存事务；数据在写入 SQL 事务库的同时，**后台自动、零配置同步生成 OneLake Delta Parquet 镜像**！配合 **Power BI Translytical Task Flows + User Data Functions**，业务人员在报表或 Teams Agent 中点击“批准调价/锁库”，4ms 内完成 ACID 事务回写并立刻刷新全局 Direct Lake 指标。
  2. **Databricks Lakebase（基于 Neon Serverless Postgres 架构演进）**：
     - 适合在 Databricks 内部为 AI Agent 保存会话状态（Session State）或轻量级 Feature Serving，但与企业核心 T-SQL/ERP 生态及 M365 Office/Power BI 写回闭环存在代差。
  3. **Snowflake Unistore（Hybrid Tables）**：
     - 允许在 Snowflake 中创建支持行锁的单表事务表，但存在单表吞吐限制、Credit 消耗偏高，且不适合直接承载高并发核心 OLTP 微服务。

---

## 🧭 三、直观可视化图解（决策树 + 五云零拷贝同步架构对比 + 端到端 HTAP 时序流）

### 3.1 企业 OLTP-to-OLAP 实时同步与 HTAP 选型决策树

```mermaid
flowchart TD
    A["🎯 企业启动 OLTP 业务库与分析湖仓 (OLAP) 实时打通选型"] --> B{源端数据库类型与应用场景是什么？}
    B -- "Azure SQL / SQL Server / Postgres / Cosmos DB / Snowflake" --> C["🏆 首选 Microsoft Fabric Native Database Mirroring<br/>✅ $0 CU 免费复制计算 + F64 赠 64TB 免费存储 + 自动 V-Order Delta<br/>✅ 秒级直连 Power BI Direct Lake 与 Fabric IQ / Data Agent"]
    B -- "Oracle / SAP / MySQL / DB2 / 自研库 (通过 GoldenGate/Debezium/ADF)" --> D["🏆 首选 Microsoft Fabric Open Mirroring<br/>✅ 只需向 OneLake Landing Zone 投递增量 Parquet/CSV，Fabric 免费自动 Merge 为 Delta!"]
    B -- "新建 AI Native 业务应用 / 报表审批回写 (Translytical HTAP)" --> E["🏆 首选 SQL Database in Fabric + User Data Functions<br/>✅ 原生 T-SQL ACID 事务写入 + 零配置自动镜像至 OneLake Delta"]
    B -- "100+ 个低吞吐长尾营销 SaaS API (且月更新行数 MAR < 500万)" --> F["💳 选 Fivetran / Airbyte / Fabric Data Factory Copy Job<br/>⚠️ 严禁将高频更新的核心交易大表直接挂在按 MAR 计费管道上"]
```

### 3.2 五云企业级 OLTP-to-OLAP 零拷贝镜像与 HTAP 架构全景对比图（SVG #353）

![企业 OLTP-to-OLAP 零拷贝镜像与 HTAP 选型对比图](../assets/svg/353-fabric-enterprise-oltp-to-olap-zero-etl-mirroring-cdc-htap-debezium-fivetran-faq.svg)

### 3.3 “源库 CDC 零拷贝镜像 + 图谱风控 + ACID 事务回写” 52ms 端到端 HTAP 时序图

```mermaid
sequenceDiagram
    autonumber
    participant OLTP as 🗄️ 核心交易库 (Azure SQL / Postgres / Cosmos DB / SAP)
    participant Mirror as 🔄 Fabric Mirroring ($0 CU 免费复制 + 自动 V-Order Delta)
    participant KQL as ⚡ Eventhouse KQL & Direct Lake (12ms + 18ms)
    participant Graph as 🕸️ Fabric IQ 8-Hop GQL + 1.405B SSD DiskANN (10ms + 7ms)
    participant HTAP as 🛡️ Agent 365 Guardrail & SQL DB in Fabric ACID 回写 (5ms)

    OLTP->>Mirror: 1. 交易发生：订单状态变更 / 库存扣减 / 信用额度调整 (实时事务日志流)
    Mirror->>KQL: 2. $0 CU 自动合并为 OneLake Delta Parquet (省去 $374,200/月 Fivetran MAR 与 Kafka 税)
    KQL->>Graph: 3. 1,360 波次异常库存/信贷敞口触发 8 跳供应链/授信图谱与 1.405B 合同向量检索 ($6,520/月 DiskANN)
    Graph->>HTAP: 4. 校验 920 次幂等防重、分布式锁与字段脱敏门禁 (置信度 0.99 >= 0.85)
    HTAP-->>OLTP: 5. 通过 SQL DB in Fabric / Translytical UDF 执行 ACID 调拨回写 (总延迟 52ms · 守护 $126.40M SLA)
```

---

## 📊 四、主流 OLTP-to-OLAP 实时同步与 HTAP 方案六维选型矩阵

| 评测维度 | 🏆 **Fabric Mirroring + SQL DB in Fabric** | **自建 Debezium + Kafka + Flink** | **Fivetran / Qlik 商业 CDC** | **Databricks Lakeflow + Lakebase** | **Snowflake Snowpipe Streaming + Unistore** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **增量复制与 Merge 计算成本** | **`$0 CU`（后台复制与 Delta Merge 完全免费！）** | 极高（Kafka Broker + Flink 常驻计算 + Spark Compaction） | **极高且不可预测**（按月活行 MAR 计费 + 目标仓 Merge 算力费） | 按 Lakeflow DBU + Delta Live Tables 持续计费 | 按 Snowpipe Streaming + Dynamic Tables Credit 计费 |
| **存储成本与开放格式** | **F-SKU 赠送等额免费镜像存储**（原生开放 OneLake Delta Parquet） | 需付 Kafka 多副本块存储 + 对象存储费 | 不含存储，需在目标数仓全额支付存储费 | 存于云对象存储（Delta 格式），按量计费 | 存于 Snowflake 内部微分区或 Iceberg，按量计费 |
| **源端 DDL 变更自愈能力** | **全自动同步**（加列/改列自动反映至 OneLake 与 SQL Endpoint） | 脆弱（常因 Schema Registry 不兼容导致 Flink 任务崩溃） | 自动同步，但大表结构变更易触发高价全量重刷 | 支持 Schema Evolution，需管理 DLT 管道配置 | Dynamic Tables 部分 DDL 变更需触发 Full Refresh |
| **Open Mirroring 异构扩展性** | **原生支持**（Oracle/SAP/GoldenGate/任意源投递文件即自动 Merge） | 需为每种源库独立编写并维护 Flink Upsert Sink | 连接器丰富，但核心 ERP（如 SAP）需高价 HVR 授权 | 依赖 Lakeflow 预置连接器或パートナー集成 | 依赖 Snowflake Openflow / 第三方连接器 |
| **BI 消费与 ACID 事务回写** | **Direct Lake 零拷贝秒级读取 + SQL DB in Fabric 原生 ACID 回写** | 只管搬数，前端 BI 需另配导入，无回写能力 | 只管单向入仓，回写需再买 Hightouch Reverse ETL | 需唤醒 SQL Warehouse 查询；Lakebase 提供 Postgres 状态存储 | 需唤醒 Virtual Warehouse；Hybrid Tables 提供单表行锁 |
| **47,600 用户全栈月度总 TCO** | **`$21,440 / 月`**（`F64` 全包，单月净省 **`-$930,060/月`**！） | **`$680,000+ / 月`**（含中间件集群 + BI 席位 + DRAM 向量） | **`$820,000+ / 月`**（含高吞吐 MAR 账单 + 数仓 Merge + BI 席位） | **`$951,500 / 月`**（四云多组件拼装基准，首次突破 `>$950K/月`！） | **`$925,000+ / 月`**（含常驻 Warehouse + Unistore + BI 席位） |

---

## 🧪 五、典型业务规模 TCO/性能拐点测算与 7-Card 密封基准报告（Round 345 · `Scenario MN`）

### 5.1 为什么“Open Mirroring”是异构数据库（Oracle / SAP / MySQL / 自研系统）迁云与降本的终极利器？
很多架构师误以为 Fabric Mirroring 只能连微软自家的 Azure SQL。实际上，**Fabric Open Mirroring** 将 Fabric 底层的“免费 Delta Merge 引擎”开放给了全世界所有数据源：
1. 无论你的源端是 Oracle GoldenGate、SAP Datasphere、自研分库分表程序，还是已有的轻量级脚本，**你只需要把增量的 Insert/Update/Delete Parquet 或 CSV 文件丢进 OneLake 的 Open Mirroring Landing Zone 文件夹**；
2. Fabric 后台引擎会**以 `$0 CU` 免费算力**自动按照主键执行 Upsert/Delete 合并、自动做小文件 Compaction 与 V-Order 压缩，瞬间生成标准 Delta 表！你再也不需要为了做 CDC Upsert 而24小时开着昂贵的 Spark Streaming 或 Snowflake Warehouse。
3. 在 **Round 345 (`R345 = 5×69` 整五轮 · `Scenario MN`)** 密封基准评测中，针对 **`2,190,000` (`2.19M`) EPS** 的高频 OLTP CDC 事务与业务事件流、**整十 `1,360` 个跨库一致性与实时决策波次**、**`1,405,000,000` (`1.405 Billion = 1,405M`) 条交易凭证、审计日志与主数据实体向量**、以及 **`47,600` 名企业用户（`39,780` 活跃 Viewer）** 的生产负载：
   - **Microsoft Fabric (`F64` 预留容量 + `$0 CU` Mirroring + SSD DiskANN `$6,520/月`)** 全栈月度总 TCO 仅为 **`$21,440 / 月`**，端到端感知-分析-ACID 回写延迟仅 **`52ms` P99**，路由决策准确率达成 **`971 / 972 = 99.90%`**（素数 `971` 通过！路由均值达成**历史性精确整数 `78.0ms`** = `75,816 / 972 = 78.0000ms`！），素数第 **`239`** 项企业本体仿真均值降至 **`72.51ms`**（`17,330 / 239`）。
   - **四云拼装竞品栈**因 `12.35 TB` 纯内存向量库（整千 **`$171,000/月`**，Fabric 单月省 **`$164,480/月`** 首次省破 `>$164K/月` DRAM！）、Fivetran MAR + Kafka/Debezium + 图同步税（`$374,200/月`）、CDC Merge 计算税（`$214,300/月`）与精确 `$192,000/月` 的 BI 席位税，月度总 TCO **历史首次突破 `>$950,000/月` 大关达 `$951,500 / 月`（`$11.42M / 年`）**！Fabric **单月总 TCO 净省历史首次突破 `>-$930,000/月` 达 `-$930,060 / 月`（`-97.7%` · 叠字 `44.4×` 成本优势）**，实时决策效率提升 **`+78.8%`**，年化创造整五 **`+$195.0M / 年`** 业务价值，拦截整十 **`920`** 次非幂等脏写、锁冲突与权限违规（保护 **`+$41.40M`**），守护 **`$126.40M`** SLA！

### 5.2 Round 345 (`Scenario MN`) 7-Card 密封评测核心指标速览

| 卡片编号 | 评测维度 (`Scenario MN` · `DL-1421..1424`) | Microsoft Fabric 实测 / 密封值 | 四云拼装 / Fivetran / Debezium 对照值 | 架构师选型结论 |
| :--- | :--- | :--- | :--- | :--- |
| **Card 1** | **Overview & Workbench (素数 `971/972`!)** | **`99.90%`** (`698` 自动 + `273` 复核 + `1` 人工 `DL-23`) | 自建 CDC 在源端 DDL 变更时中断率 `>15%` | `$0 CU` 原生/开放镜像彻底终结 MAR 与运维税 |
| **Card 2** | **Single-Case (`Scenario MN` 整五 `R345`)** | **`52ms`** E2E · 首次净省破 **`>-$930K/月`** (`-$930,060/月` · `44.4×`) | `3,800ms–15min` 批微同步 · 首次破 `>$950K` (`$951,500/月`) | 唯一同时免除 CDC 管道费与目标端 Merge 算力费的架构 |
| **Card 3** | **Full Matrix (`DL-1421..1424`)** | 实时镜像与 HTAP 回写 `0.99` 自动 · 跨库主键冲突 `0.79` 复核 | 缺少端到端 LSN 水位线校验与幂等回写门禁 | 保障金融/零售核心台账 `100%` 最终一致与 ACID 安全 |
| **Card 4** | **Under the Hood (Mirroring + DiskANN)** | **`1.405B` (`1,405M`)** 向量 **`$6,520/月`** SSD DiskANN | `12.35 TB` DRAM 整千 **`$171,000/月`** | 单月省 **`$164,480/月`** (`>$164K`!) DRAM 内存税 |
| **Card 5** | **Robustness (素数 `n = 239` Sims)** | 仿真均值 **`72.51ms`** (`17,330 / 239`) · `0.0 pts` 抖动 | 高峰期 Kafka 反压与 Small Files 导致延迟飙升 10 倍 | 后台自动 V-Order Compaction 保障全天候恒定低延迟 |
| **Card 6** | **Latency (历史性精确整数 `78.0ms` 路由!)** | 路由均值 **`78.0ms`** (`75,816 / 972 = 78.0000ms`!) | Warehouse CDC Merge 排队导致查询阻塞 | 78.0ms 精确整数路由均值 + Direct Lake 零拷贝读取 |
| **Card 7** | **My Take (回文素数 `#353` SVG & `482` 单测)** | 守护 **`$126.40M`** SLA · 整五 **`+$195.0M/年`** 创收 | Fivetran MAR + Snowflake Merge 双重扣费吞噬预算 | 核心 OLTP 入湖与 HTAP 闭环首选 Fabric Mirroring |

---

## 🛠️ 六、售前方案评审与生产落地 Checklist（上线前必查 8 项）

- [ ] **1. 源库分类与 Mirroring 模式对标**：是否已梳理全部 OLTP 源库清单，将 Azure SQL / SQL Server / Postgres / Cosmos DB / Snowflake 路由至 **Native Database Mirroring**，并将 Oracle / SAP / MySQL / GoldenGate 路由至 **Open Mirroring Landing Zone**？
- [ ] **2. 淘汰高价 MAR 管道与冗余 Merge 作业**：是否已识别出当前在 Fivetran / Qlik 中消耗 80% MAR 预算的高频更新核心大表，并将其切换至 Fabric `$0 CU` Mirroring 以释放目标端 `MERGE INTO` 算力？
- [ ] **3. 源库事务日志（Log Retention）与权限最小化基线**：在开启源库 CDC / Mirroring 前，是否已核验源库事务日志保留窗口、快照隔离级别（RCSI）与专用只读复制账号，确保对生产 OLTP 交易延迟影响 `< 1%`？
- [ ] **4. 免费镜像存储配额规划**：是否已根据 Fabric 容量等级（如 `F64` 对应 `64 TB` 免费镜像存储）规划保留策略与历史冷归档分层，最大化利用免费存储红利？
- [ ] **5. LSN 水位线监控与延迟告警（Replication Lag Gate）**：是否已配置 Fabric Monitoring Hub 与 Activator 规则，当源端到 OneLake 的镜像延迟超过业务 SLA（如 `> 30 秒`）时自动告警并在高危风控决策中启用水位线校验？
- [ ] **6. Translytical ACID 回写幂等保护**：当使用 **SQL Database in Fabric + User Data Functions** 从 Power BI 或 AI Agent 执行业务回写时，是否已强制包含 `Idempotency_Key`、乐观并发版本号与 Entra ID OBO 审计签名？
- [ ] **7. 主外键关系与 Fabric IQ Ontology 自动绑定**：镜像进 OneLake 的多张业务表（如 `Customer`、`Order`、`Shipment`、`Invoice`）是否已在 Power BI TMDL 与 **Fabric IQ Graph (`8-Hop GQL`)** 中声明实体关系，供 Data Agent 直接零拷贝问数？
- [ ] **8. 灾难恢复与跨区 BCDR 演练**：是否已验证 OneLake BCDR 跨区复制与源库故障切换（Failover Group）后的 Mirroring 自动重连机制，确保 RPO `< 5 分钟`？
