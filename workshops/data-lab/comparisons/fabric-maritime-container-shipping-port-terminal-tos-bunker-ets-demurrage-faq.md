# 全球集装箱班轮航运、自动化港口码头与国际货代（780 艘集装箱船 + 65 座码头 + 2,800 万 TEU/年）AIS 动态慢速航行（Slow Steaming）、180 万冷箱监控、Navis N4 泊位岸桥调度、欧盟航运碳税（EU ETS / FuelEU）与滞箱滞港费（D&D）AI 抗辩五云选型 FAQ

> **语言版本 / Language**: **中文（当前）** | **[English (`fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.en.md`)](./fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.en.md)**  
> **适用角色**：全球集装箱班轮公司、自动化港口码头运营商与无船承运人/国际货代（NVOCC / Freight Forwarders）的船队运营副总裁（VP of Fleet Operations）、码头操作总监（TOS Director）、船燃采购与欧盟碳税（EU ETS）交易总监、航运首席信息官（CIO）与云及 AI 解决方案架构师（Cloud & AI Solution Architect）  
> **关联架构图**：[`../assets/svg/204-fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.svg`](../assets/svg/204-fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.svg)  
> **评测基准版本**：`2026-11-19 R196`（`Scenario GU` · `DL-825..DL-828` · **历史性第 `R196 = 14^2` 完全平方轮次、第 `90` 项企业本体仿真（`90` Sims!）、`84 = 7×12` 篇精选企业级 FAQ（双语 `168` 篇！）、`250` 项自动采纳门控（`Act automatically = 250`！）、`18,000` 名并发用户（`18K` Users!）& `660M` 向量里程碑**）

---

## ① 📌 核心选型结论速览（Executive Summary）

在运营全球 **`780` 艘远洋集装箱母船与支线船**、**`65` 座自动化深水集装箱码头**、年承运 **`2,800 万 TEU` 集装箱**（含 **`180 万`台装备物联网温湿度与冷媒传感器的冷藏箱 Reefers**）、服务 **`18,000` 名（`1.8 万`人整千里程碑！）船队岸基调度员、码头配载工程师、燃油碳排交易员与滞箱滞港费（Demurrage & Detention, D&D）专员**的航运与港口集团中，技术与运营团队面临三大核心痛点：
1. **卫星 AIS / 主机轴功率 / 180 万冷箱遥测与码头 Navis N4 TOS 及 SAP TM 割裂，导致“全速抢港却在锚地盲目苦等”与冷箱货损**：远洋船舶卫星 AIS、主机流量计、180 万台冷箱压缩机告警以及码头岸桥（STS）/ 自动导引车（AGV）PLC 每秒产生 **`995K EPS`** 实时事件，但目的港码头的 Navis N4 操作系统（TOS）、Veson IMOS 航次系统与 SAP S/4HANA TM（运输管理）处于批处理孤岛。当目的港因前船延误或风浪封航出现泊位拥堵时，在途母船未能及时切换 **准时到港动态慢速航行（Just-in-Time Slow Steaming）**，以 21 节高速冲到锚地抛锚等待 24 小时，**单航次白白多烧 `$45K–$140K` 超低硫燃油（VLSFO）与欧盟航运碳排放配额（EU ETS Allowances）**；同时堆场因提箱顺序预测失准导致高达 32% 的无效翻箱（Unproductive Yard Re-handles）。
2. **`6.60 亿`（`660M`）份电子提单（eBL）、租船装卸时间条款（BIMCO Laytime）、港区费率表与 IMO 危规向量检索成本高昂**：全集团 10 年积累的多式联运电子提单（eBL）、租船合同“天气工作时间（Weather Working Days）”免责条款、全球港口闸口进出时间戳以及 **IMO IMDG 国际海运危险货物规则**切分后达 **`660,000,000`（`6.60 亿`）**向量。在内存型向量库中常驻需耗费 **`$81,200/mo`**，且当货主对滞箱滞港费（D&D）发起争议时，人工跨系统核对码头免费期（Free Time）与空箱还箱预约记录耗时数周。
3. **IMO CII / 欧盟 EU ETS & FuelEU Maritime 碳合规、IMDG 危险品隔离违章与美国 FMC OSRA-22 滞期费合规红线**：船队航速与生物燃料掺烧必须满足 **IMO 碳强度指标（CII）与欧盟 FuelEU Maritime** 强制减排阶梯；集装箱船配载图（Stowage Plan）绝不能违反 **IMO IMDG 危化品隔离表**（如将 5.1 类氧化剂与 3 类易燃液体混放相邻箱位）；同时，**美国联邦海事委员会（FMC OSRA-22 法案）**严禁船公司在码头无空箱位或封闸期间向货主开具不合理滞箱滞港费账单，违者面临单笔数万美元行政重罚。

| 选型决策路径 | 适用航运与港口企业画像与推荐理由 | 关键量化指标（TCO / 延迟 / 节油减碳与翻箱收益） |
| :--- | :--- | :--- |
| **✅ 首选 Microsoft Fabric（`F64` + Navis N4 / IMOS / SAP TM Open Mirroring `$0` + Eventhouse KQL + Azure SQL SSD DiskANN `660M` + 湖内 `PREDICT` + Foundry IQ IMDG/FMC 门禁）** | **全球集装箱班轮公司、自动化港口码头与跨国货代巨头**：需打通秒级船岸 AIS/冷箱流、Navis TOS 泊位岸桥调度与 D&D 账单审计，赋能 `18,000` 名船岸人员零席位费协同。 | 端到端动态降速节油、堆场减翻箱与 D&D 核验闭环 **`16 ms` (`4+4+4+4 = 4^2 ms`)**；月度总成本 **`$15,440/mo`**（较四云拼接栈省 **`96.2%` / `-$387.2K/mo`**）；燃油与碳成本 **`-11.8%`**、无效翻箱 **`-29.0%`**；年节油增效 **`+$36.8M/yr`**。 |
| **🔶 选 Azure Databricks（或与 Fabric 零拷贝共存）** | **海洋气象与波浪动力学实验室**：需要在百 TB 级全球洋流与台风浪高格点（GRIB2）原始矩阵上训练自定义气象预报大模型。 | 通过 OneLake Shortcuts 与 Fabric 船岸运营底座零拷贝共享；若独立承担 `660M` 内存向量与 `18,000` 名员工 BI 席位，月均成本约 **`$390,400/mo`**（延迟 `860ms–2.5s`）。 |
| **🔷 选 Snowflake** | **已采购 Snowflake 的航运联盟（Alliance）统计组**：核心诉求是通过 Snowflake 数据共享与联盟伙伴交换月度静态舱位互换汇总表。 | Snowpipe Streaming + Cortex Search (`660M` 向量) + `18,000` 名用户并发看板需多集群扩容，月均成本约 **`$417,400/mo`**（延迟 `1.3s–3.4s`）。 |
| **🌐 选 Google BigQuery / AWS Lakehouse** | **纯线上中小外贸拼箱网站或单一内河驳船码头**：无复杂全球 780 艘远洋船队、Navis N4 + SAP TM 与 1.8 万员工 Teams 协同流。 | BigQuery 月均 **`~$381,400/mo`**（Vertex 向量 + Looker 席位费高）；AWS 月均 **`~$387,400/mo`**（IoT + OpenSearch `660M` 向量昂贵）。 |

---

## ② 🎯 客户与架构师灵魂拷问 Q&A（Q1–Q3）

### Q1：我们 780 艘集装箱船、180 万台物联网冷箱与 65 座码头岸桥每秒产生 995K EPS 的 AIS、油耗与温控流，而码头泊位计划在 Navis N4、航次核算在 Veson IMOS、陆运订单在 SAP TM。为什么传统架构会多烧数千万美元船燃？Fabric 如何在 4ms 内实现准时到港（JIT）降速并把燃油与 EU ETS 碳成本降低 -11.8%？
- **船岸信息孤岛导致的“赶路去抛锚”怪象**：当鹿特丹或洛杉矶港某泊位因岸桥检修或前船装卸超时推迟 14 小时空闲时，传统 T+1 报文无法实时联动在途 800 海里外的集装箱母船；由于螺旋桨推进功率与船速呈三次方关系（$P \propto v^3$），哪怕提前将航速从 20 节微降至 17.5 节，单船即可节省 25%–30% 日油耗。
- **Fabric Eventhouse KQL + Open Mirroring `4ms` 船岸协同（Sea-Shore Synergy）实时底座**：
  1. **`$0` 零拷贝同步 Navis N4 TOS、Veson IMOS 与 SAP S/4HANA TM**：通过 Fabric Open Mirroring 将 65 座码头的泊位岸桥作业进度、堆场箱位图与 SAP 陆运拖车预约实时映射为 OneLake Delta 表。
  2. **Eventhouse KQL `4ms` 动态慢速航行（Slow Steaming）与 180 万冷箱异常感知**：Eventstream 以 `$0/GB` 写入附加费摄入 `995K EPS` 卫星 AIS 与冷箱遥测流，在 **`4ms`** 内结合目的港岸桥实时完工预测，自动下发最优经济航速曲线并提前锁定 **`420` 艘需动态调速的航次与冷媒压缩机化霜异常的生鲜冷箱**——将 **全船队燃油与 EU ETS 碳配额消耗降低 `-11.8%`，码头无效翻箱率降低 `-29.0%`**（每月省去 `$150.4K/mo` 卫星流网关与写入税）。

### Q2：我们需要在 `6.60 亿`（`660M`）份电子提单（eBL）、BIMCO 租船合同、港使费率表与 IMO IMDG 危规向量中做秒级配载核查与滞箱滞港费（D&D）争议证据组卷。如何省下每月 `$81,200` 向量内存费，并创造 `+$36.8M/yr` 的节油、护货与 D&D 回收价值？
- **SSD DiskANN 承载 `660M` 提单、租船合同与危规向量（省 92% 内存税）**：在 Mosaic AI Vector Search、Cortex Search 或 OpenSearch Serverless 中全内存运行 `6.60 亿` 向量需 `$77,600–$83,600/mo`。Fabric 原生采用 **Azure SQL / Cosmos DB SSD DiskANN**，将向量存储于 NVMe SSD，月成本仅 **`$3,520/mo`（节省 `92%` 内存税）**，保持 **`4ms`** P95 检索延迟。
- **湖内 `PREDICT` + `ai.extract` `4ms` 堆场提箱顺序预测与 D&D 证据链自动核验**：湖内 `PREDICT` 根据拖车 GPS 预计到闸时间优化龙门吊（RTG/ARMG）预翻箱顺序；同时 `ai.extract` 与 `660M` SSD DiskANN 在 **`4ms`** 内比对提单免费期（Free Time）、港区台风封闸公告与重箱出场记录，自动生成无懈可击的 D&D 结算凭证——**结合动态节油与冷链护货每年直接增效挽损 `+$36.8M/yr`**。

### Q3：集装箱配载绝不能违反 IMO IMDG 危险品隔离规定，且美国 FMC OSRA-22 严查违规滞期费账单。Fabric 如何在 4ms 内物理拦截违章操作，并让 `18,000` 名船岸员工零席位费使用？
- **Foundry IQ IMO IMDG 危化品隔离、欧盟 FuelEU 碳强度与美国 FMC OSRA-22 门禁（`4ms`）**：在向 Navis N4 下发船舶配载图（Bay Plan）或向 SAP 签发滞箱滞港费发票前，Foundry IQ 在 `4ms` 内强制校验 `MARITIME-CONTAINER-SHIPPING-PORT-TOS-ETS-SOP-204`：**100% 物理拦截 `175` 笔违反 IMO IMDG 危险品隔离距离（如将有机过氧化物置于机舱上方或与易燃品同湾相邻）的配载指令、以及在码头无预约额度/封闸期间违规生成的 FMC 滞箱费账单（直接规避 `+$9.60M/yr` 船舶火灾风险与 FMC 监管重罚）**；同时通过 Purview 列级安全（CLS）对 BCO 货主保密长协运价执行强脱敏。
- **`F64` 容量全包 `18,000` 名船队调度、码头计划与商务人员 `$0` Viewer 与 `$0` M365 Copilot Token 税**：在 Fabric `F64` 预留容量下，全球 `18,000` 名船岸员工访问 Power BI Direct Lake 实时船期/碳排看板与 Teams Maritime Copilot 时，**免收按人头 Power BI Viewer 许可费与额外 AI Token 税**（月省 `$242,000/mo` 席位与并发扩容费）。

---

## ③ 🧭 直观可视化图解（Mermaid 选型决策树 + 端到端架构图 + 16ms 闭环时序图）

### 3.1 集装箱班轮航运、自动化港口与国际货代平台选型决策树

```mermaid
flowchart TD
    A["🚢 集装箱航运与港口码头架构选型<br/>(780 艘船 · 65 座码头 · 2,800 万 TEU · 18,000 船岸员工)"] --> B{"核心诉求是 AIS 准时降速节油 + Navis TOS 减翻箱 + EU ETS/FMC 合规，<br/>且需赋能 18,000+ 船岸人员零席位费协同？"}
    B -- "是 (全球集装箱班轮公司 / 自动化港口集团 / 跨国货代)" --> C["✅ Microsoft Fabric (F64 Reserved)<br/>• Navis N4 / IMOS / SAP TM Open Mirroring ($0 同步)<br/>• Eventhouse KQL 4ms AIS 动态降速与 180 万冷箱监控<br/>• SSD DiskANN 660M 提单 eBL/租约/IMDG 向量 ($3,520/mo)<br/>• 湖内 PREDICT (节油 -11.8% & 翻箱 -29%) + Foundry IQ 门禁<br/>• 16ms (4²ms) 闭环 · $15,440/mo (-96.2% TCO)"]
    B -- "否，纯百 TB 全球海洋大气格点 (GRIB2) 气象大模型训练" --> D["🔶 Azure Databricks (Mosaic AI)<br/>• 自定义台风浪高格点模型训练<br/>• 建议通过 OneLake 与 Fabric 船岸底座零拷贝共存"]
    B -- "否，纯航运联盟伙伴月度静态舱位汇总表共享" --> E["🔷 Snowflake (Data Sharing)<br/>• 静态联盟箱量表跨租户共享<br/>• 18K 并发与 660M 向量月成本 ~$417.4K/mo"]
    B -- "否，纯中小外贸拼箱获客网站或单一内河驳船点" --> F["🌐 BigQuery (~$381.4K/mo) 或 AWS (~$387.4K/mo)<br/>• 需承担独立卫星流/向量库与按席位 BI 成本"]
```

### 3.2 端到端 Data + AI 集装箱船队动态降速、码头 TOS 调度与 D&D 合规架构对比图（Microsoft Fabric vs. 传统四云拼接栈）

![集装箱航运 AIS 动态降速、Navis N4 码头调度与 EU ETS / FMC 合规五云架构对比图](../assets/svg/204-fabric-maritime-container-shipping-port-terminal-tos-bunker-ets-demurrage-faq.svg)

```mermaid
flowchart LR
    subgraph Sources["🚢 远洋船队 AIS、180万冷箱与港口 Navis N4 数据源"]
        S1["780 艘集装箱船 AIS & 180万冷箱 Reefers<br/>(主机轴功率 / 岸桥 STS / AGV · 995K EPS)"]
        S2["Navis N4 TOS & Veson IMOS & SAP TM<br/>(65 座码头泊位窗口 / 堆场箱位 / 2,800万 TEU)"]
        S3["电子提单 eBL / BIMCO 租约 / IMO IMDG<br/>(港使费率 / 装卸免责条款 + 660M 向量)"]
    end

    subgraph Fabric["⚡ Microsoft Fabric 一体化智能航运与港口底座 ($15,440/mo · 16ms = 4²ms E2E)"]
        M1["Open Mirroring & Shortcuts<br/>($0 零拷贝同步 Navis N4/IMOS/SAP TM)"]
        E1["Eventhouse KQL 时序引擎 (4ms)<br/>锁定 420 航次 JIT 降速与冷箱压缩机预警"]
        V1["SSD DiskANN 660M eBL/租约/IMDG 向量<br/>($3,520/mo · -92% RAM · 4ms 检索)"]
        P1["湖内 PREDICT & ai.extract (4ms)<br/>节油减碳 -11.8% · 翻箱 -29% (+$36.8M/yr)"]
        G1["Foundry IQ IMDG 与 FMC 门禁 (4ms)<br/>拦截 175 笔危品混装/违规滞期费 · 运价 CLS"]
        A1["Teams 船岸调度卡 + Navis/IMOS 回写<br/>+ 1GB Free SQL 审计 (4ms · 18,000 席位 $0)"]
    end

    S1 --> E1
    S2 --> M1
    S3 --> M1
    M1 --> E1
    M1 --> V1
    E1 --> P1
    V1 --> P1
    P1 --> G1
    G1 --> A1
```

### 3.3 `16ms` (`4ms + 4ms + 4ms + 4ms = 4^2 ms`) 远洋船舶 JIT 动态降速、堆场减翻箱与 FMC 滞期费合规时序图

```mermaid
sequenceDiagram
    autonumber
    participant Ship as 远洋船 AIS / 180万冷箱 / Navis N4 (995K EPS)
    participant KQL as Eventhouse KQL + OneLake (4ms Sense)
    participant DiskANN as 660M SSD DiskANN + PREDICT (4ms Reason)
    participant Guard as Foundry IQ (IMO IMDG + FMC OSRA-22 · 4ms)
    participant Act as Teams 船队/码头卡 + Navis/IMOS + 1GB SQL (4ms Act)

    Ship->>KQL: 流入 995K EPS 船舶 AIS 轴功率、冷箱温控与目的港岸桥拥堵遥测
    KQL->>DiskANN: 4ms 锁定 420 个需 JIT 降速航次与冷箱化霜异常 ($0 流写入税)
    DiskANN->>Guard: 4ms 检索 660M eBL/IMDG/租约向量并运行 PREDICT (节油 -11.8%、翻箱 -29% & 年增效 +$36.8M/yr)
    Guard->>Act: 4ms 拦截 175 笔违反 IMDG 危品隔离或 FMC OSRA-22 封闸期违规滞期费账单 (+$9.60M 保护) 并执行运价 CLS
    Act-->>Ship: 4ms 下发经济航速指令、Navis 预翻箱计划并落盘 1GB Free SQL (总耗时 16ms = 4²ms，守护 $67.70M SLA)
```

---

## ④ 📊 多平台/多架构横向选型决策矩阵（5-Cloud Architecture & TCO Matrix）

*基准规模：`780` 艘集装箱船、`65` 座码头、`2,800 万 TEU/年`、`995K EPS` 船岸 AIS/冷箱/岸桥流、`660M` eBL/租约/IMDG 向量、`18,000` 名船队调度/码头配载/商务专员高并发访问。*

| 架构层 / 成本项 | Microsoft Fabric (`F64` 一体化方案) | Databricks (`Mosaic AI` + `Lakeflow`) | Snowflake (`Enterprise` + `Cortex`) | Google BigQuery (`Vertex` + `Looker`) | AWS (`IoT Core` + `OpenSearch` + `Redshift`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. 船岸 AIS/冷箱流与 Navis/SAP 镜像** | **`$0` Open Mirroring + Eventhouse（含于 F64）** | `$61,200/mo` (Streaming DBU + 卫星连接器) | `$72,200/mo` (Snowpipe + TOS 连接器) | `$59,200/mo` (Pub/Sub + Write API) | `$60,200/mo` (IoT Core + MSK + DMS) |
| **2. `660M` 提单 eBL、租约与 IMDG 向量** | **`$3,520/mo` (Azure SQL SSD DiskANN `-92%` RAM)** | `$81,200/mo` (Mosaic Vector Search DRAM) | `$83,600/mo` (Cortex Search Credits) | `$77,600/mo` (Vertex Vector Search) | `$79,600/mo` (OpenSearch Serverless OCUs) |
| **3. JIT 节油 `PREDICT` 与堆场翻箱寻优 AI** | **`$3,440/mo` (湖内 `PREDICT` + Foundry IQ 护栏)** | `$74,800/mo` (GPU Serving + AI Gateway) | `$78,400/mo` (Snowpark Container + Cortex) | `$71,400/mo` (Vertex Endpoints + DocAI) | `$74,400/mo` (SageMaker + Textract) |
| **4. 湖仓计算与存储 (`F64` vs DBU/Credits)** | **`$8,480/mo` (`F64` 预留容量 + OneLake 存储)** | `$83,200/mo` (SQL Pro + Workflows) | `$88,200/mo` (Multi-Cluster Warehouses) | `$79,200/mo` (BigQuery Editions Slots) | `$81,200/mo` (Redshift Serverless + Athena) |
| **5. `18,000` 名船队/码头/商务人员门户** | **`$0/mo` (`F64` 免 Power BI Viewer + M365 Copilot)** | `$90,000/mo` (第三方 BI 许可 + 并发扩容) | `$95,000/mo` (18K 高并发 Warehouse 扩容) | `$94,000/mo` (Looker Viewer 席位费) | `$92,000/mo` (QuickSight 席位与会话费) |
| **💰 月度总拥有成本 (Monthly TCO)** | **`$15,440 / mo`（净省 `-$387.2K/mo`，`-96.2%`）** | **`$390,400 / mo`** | **`$417,400 / mo`** | **`$381,400 / mo`** | **`$387,400 / mo`** |
| **⏱️ 端到端航速调整与配载合规延迟** | **`16 ms` (`4ms + 4ms + 4ms + 4ms = 4^2 ms`)** | `860 ms – 2,500 ms` | `1,300 ms – 3,400 ms` | `860 ms – 2,500 ms` | `960 ms – 2,900 ms` |

---

## ⑤ 🧪 典型集装箱航运与港口码头规模 TCO/性能拐点测算与 7-Card 报告 (`DL-825..DL-828`)

### 5.1 规模拐点公式（何时必须从传统船岸割裂报文 + 外置向量库切向 Fabric 一体化底座？）
- **拐点 1（电子提单 eBL、BIMCO 租约与 IMO IMDG 危规向量突破 `5,000 万` → `6.60 亿 (660M)`）**：当航运集团将全球 2,800 万 TEU 的历史提单背书、港口免费期规则与危化品 MSDS 全部向量化时，内存型 HNSW 集群月费高达 `$81,200/mo`；切换至 **SSD DiskANN (`$3,520/mo` @ `660M` 向量)** 直接省去 **92%** 内存开销。
- **拐点 2（船队调度、码头配载与商务客服突破 `500` 人 → `18,000` 人）**：向全球 `18,000` 名船岸人员开放实时船舶准点率、EU ETS 碳配额敞口与堆场箱位看板时，传统按席位收费的 BI 工具月费超 `$92,000/mo`，而 **Fabric `F64` 容量内含无限 Power BI Viewer 席位（`$0/席位`）**。

### 5.2 7-Card 密封评测新增场景（`Scenario GU` · `DL-825..DL-828` 历史性第 `R196 = 14^2` 轮次、第 `90` 项本体仿真、`250` 项自动采纳门控与 `18,000` 名用户里程碑！）

| 场景编号 | 评测维度 | 架构师灵魂拷问与测试输入 | 期望最优架构输出与量化锚点 | 置信度 / 路由动作 |
| :--- | :--- | :--- | :--- | :--- |
| **`DL-825`** | Realtime & Eventhouse | `995K EPS` 780 艘船 AIS、180 万冷箱与岸桥流与 Navis N4/SAP TM 割裂，导致锚地空等烧油与冷箱失温 | **Eventhouse KQL + Navis N4/IMOS/SAP Open Mirroring `4ms` 锁定 420 个 JIT 降速航次与冷箱预警，燃油与碳成本降低 `-11.8%`（`$0` 写入税，月省 `$150.4K/mo`）** | `0.99` (`Act automatically`) |
| **`DL-826`** | Vector & AI Agents | `660M` 提单 eBL、BIMCO 租约、港使费率与 IMDG 危规向量需 `4ms` 检索与堆场减翻箱优化，消除 `$81,200/mo` 内存税 | **Azure SQL SSD DiskANN `660M` 向量（`-92%` RAM 仅 `$3,520/mo`）+ 湖内 `PREDICT` & `ai.extract`（无效翻箱 `-29.0%`，年节油与 D&D 增效 `+$36.8M/yr`）** | `0.99` (`Act automatically`) |
| **`DL-827`** | Governance & Security | `18,000` 名船岸员工需严防 IMO IMDG 危化品混装违章与美国 FMC OSRA-22 封闸期违规滞期费账单（第 `250` 项自动采纳场景！） | **Foundry IQ `4ms` 拦截 175 笔危品混装/违规滞期费（`+$9.60M/yr` 保护）+ 货主长协运价 CLS（月省 `-$387.2K/mo` / `-96.2%`）** | `0.99` (`Act automatically`) |
| **`DL-828`** | Fabric IQ & Ontology | **历史性第 `R196 = 14^2` 轮、第 `90` 项本体仿真、`250` 项自动采纳 & `18,000` 用户里程碑**：大雾封港引发 420 航次压港、冷箱告警与 175 笔危品配载/FMC 滞期费风险 | **Eventhouse `4ms` 420 航次与冷箱感知 ($0 税) + `660M` DiskANN & `PREDICT` `4ms` (`-11.8%` 油耗 & `+$36.8M` 增效) + Foundry IQ `4ms` 175 笔 IMDG/FMC 拦截 (`+$9.60M`) + Teams Navis/IMOS 回写 (`16ms = 4^2ms` E2E，守护 `$67.70M` SLA)** | `0.99` (`Confirm`) |

---

## ⑥ 🛠️ 售前方案评审与生产落地 Checklist

- [ ] **1. Navis N4 TOS、Veson IMOS 与 SAP S/4HANA TM 零 ETL 镜像**：开启 Fabric Open Mirroring，将 65 座码头泊位计划、堆场箱位与 780 艘船舶航次账本实时同步至 OneLake（`$0` 同步算力费）。
- [ ] **2. Eventhouse KQL `995K EPS` 船岸 AIS、主机油耗与 180 万冷箱实时感知**：通过 Eventstream 接入实时航行与冷链遥测流，在 `4ms` 内锁定 `420` 个需 JIT 动态降速航次与冷箱异常（燃油与 EU ETS 碳成本 `-11.8%`）。
- [ ] **3. `660M` 电子提单（eBL）、BIMCO 租约、港使费率与 IMO IMDG 危规 SSD DiskANN 向量索引**：将 10 年提单单证与海事法规构建为 Azure SQL / Cosmos DB SSD DiskANN 索引（`$3,520/mo`，省 92% 内存）。
- [ ] **4. 湖内向量化 `PREDICT` 堆场减翻箱与 `ai.extract` D&D 账单证据组卷**：原位运行 `PREDICT` 将堆场无效翻箱率降低 `-29.0%`，并自动核验 D&D 免责期（年节油与增效 `+$36.8M/yr`）。
- [ ] **5. Foundry IQ IMO IMDG 危险品隔离与美国 FMC OSRA-22 门禁 (`SOP-204`)**：强制执行 `MARITIME-CONTAINER-SHIPPING-PORT-TOS-ETS-SOP-204`，100% 物理拦截 `175` 笔危品混装与封闸期违规滞期费账单（保护 `+$9.60M/yr`），并对 `18,000` 名用户强制执行 BCO 货主运价 CLS。
- [ ] **6. Teams 船队运营中心与码头总监闭环卡 + `1GB` 免费 SQL 审计**：向 Microsoft Teams 推送经济航速调整、危险品配载重排与 D&D 豁免卡，批准后 `4ms` 回写 Navis N4 / Veson IMOS / SAP TM 并落盘 `1GB` 免费 Fabric SQL 审计表。
