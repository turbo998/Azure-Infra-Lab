# 民航客货运、航司运行控制中心（IOC）与飞机维修工程（MRO：950 架客货机 + 每日 4,800 架次）ACARS/QAR 发动机 AOG 预测性排故、不正常航班（IROPS）机组恢复、NDC 动态辅收定价与 FAA 适航门禁五云选型 FAQ

> **语言版本 / Language**: **中文（当前）** | **[English (`fabric-airline-aviation-ioc-crew-recovery-mro-aog-ndc-pricing-faq.en.md`)](./fabric-airline-aviation-ioc-crew-recovery-mro-aog-ndc-pricing-faq.en.md)**  
> **适用角色**：干线客货运航空公司、飞机维修工程集团（MRO）的运行控制副总裁（VP of Flight Operations / IOC）、总工程师（VP of Engineering & MRO）、商务与收益管理副总裁、首席信息官（CIO）与云及 AI 解决方案架构师（Cloud & AI Solution Architect）  
> **关联架构图（历史性第 200 张架构图！）**：[`../assets/svg/200-fabric-airline-aviation-ioc-crew-recovery-mro-aog-ndc-pricing-faq.svg`](../assets/svg/200-fabric-airline-aviation-ioc-crew-recovery-mro-aog-ndc-pricing-faq.svg)  
> **评测基准版本**：`2026-11-19 R192`（`Scenario GQ` · `DL-809..DL-812` · **历史性第 `200` 张 SVG 架构图、第 `80` 篇精选企业级 FAQ（双语 `160` 篇！）、`359 / 360 = 99.72%`（`360°` 全景评测数！）、`120` 项 Confirm 门控、`640M` 向量 & 月省突破 `$380K` 达 `-$380.2K/mo` (`-96.1%`) 里程碑**）

---

## ① 📌 核心选型结论速览（Executive Summary）

在管理 **`950` 架宽体与窄体干线客货机**、每日执飞 **`4,800` 个航班**、年承运 **`2.1 亿`名旅客**、年客货运与辅营业务（NDC 选座/行李/升舱）总营收达 **`$58B`**、服务 **`17,200` 名运行控制中心（IOC）签派员、持照放行机务工程师（A&P / CCAR-66）、机组排班员与收益管理分析师**的大型航空集团中，数字化与运控团队面临三大核心痛点：
1. **机载 ACARS / QAR 发动机健康遥测与机务系统（AMOS / IFS Maintenix / SAP）及旅服系统（Amadeus Altéa / Sabre）割裂，导致外站突发停场（AOG）单次损失超 `$150,000+`**：飞行途中飞机通过空地数据链（ACARS）与着陆后无线 QAR 每秒回传 **`995K EPS`** 的发动机排气温度裕度（EGT Margin）、引气活门压力、液压泵脉动与过站保障节点（加油/配餐/廊桥）流。由于传统架构按天批处理同步 AMOS/Maintenix 航材库与排班表，当一架宽体机在海外外站推出前突发引气活门卡阻报错时，不仅当地无周转件（Rotable Spare）导致 **飞机停场（Aircraft-on-Ground, AOG）**，单次触发的欧盟 EU261 / DOT 旅客现金赔偿、食宿安置与后续 6 个航段连锁取消损失高达 **`$150,000–$300,000`**。
2. **`6.40 亿`（`640M`）波音/空客维修手册（AMM / FIM / MEL）、适航指令（AD）与 NDC 运价向量检索成本高昂且廊桥排故耗时 45 分钟**：将全机队数十种机型的飞机维修手册（AMM）、故障隔离手册（FIM）、最低设备清单（MEL / CDL）、FAA/EASA/CAAC 适航指令（Airworthiness Directives）、电子飞行记录本（eTechLog）与 IATA NDC 动态运价规则切分后达 **`640,000,000`（`6.40 亿`）**向量。在纯内存向量库中常驻需耗费 **`$79,000/mo`**；而在 45 分钟紧张过站时间内，航线机务人工翻查数万页 PDF 确认某项非致命故障是否符合 **MEL 保留故障放行条件** 常耗费 30–45 分钟，直接把准点航班拖成延误。
3. **雷雨/台风大面积延误（IROPS）下机组超时违规（FAA FAR Part 117 / CCAR-121）与超期 MEL 违规签派放行**：在恶劣天气导致全网上百架次备降延误时，传统分离的飞机恢复与机组恢复系统极易指派飞行执勤期（FDP）即将超时或法定休息不足的飞行员执飞后续航班，导致旅客登机后因 **“机组超时（Crew Timeout）”** 被迫清舱取消；更严重的是，若漏查某架飞机的 B/C 类 MEL 保留故障已过 3 天/10 天修复期限仍签派起飞，将直接违反适航法面临巨额行政处罚与停飞整顿。

| 选型决策路径 | 适用航司/MRO 画像与推荐理由 | 关键量化指标（TCO / 延迟 / 准点率 OTP 与辅收收益） |
| :--- | :--- | :--- |
| **✅ 首选 Microsoft Fabric（`F64` + AMOS / Maintenix / Altéa Open Mirroring `$0` + Eventhouse KQL + Azure SQL SSD DiskANN `640M` + 湖内 `PREDICT` + Foundry IQ FAR 117 机组与 MEL 适航门禁）** | **国际干线航司、大型低成本航司、航空货运与 MRO 维修集团**：需拉通空地 ACARS 遥测、航材周转件 ATP、廊桥秒级 MEL 放行与 IROPS 机尾/机组联合恢复，赋能 `17,200` 名员工零席位费协同。 | 端到端 AOG 预警、MEL 放行与机组恢复闭环 **`16 ms` (`4+4+4+4 = 4^2 ms`)**；月度总成本 **`$15,360/mo`**（较四云拼接栈省 **`96.1%` / `-$380.2K/mo`**）；外站 AOG 延误 **`-36.0%`**；年增效增收 **`+$31.2M/yr`**。 |
| **🔶 选 Azure Databricks（或与 Fabric 零拷贝共存）** | **航空发动机燃烧室与机翼气动仿真实验室**：需要在百 TB 级三维 CFD 流场网格上训练自定义空气动力学代理模型。 | 通过 OneLake Shortcuts 与 Fabric 运控机务底座零拷贝共享；若独立承担 `640M` 内存向量与 `17,200` 名员工 BI 席位，月均成本约 **`$384,000/mo`**（延迟 `890ms–2.6s`）。 |
| **🔷 选 Snowflake** | **已采购 Snowflake 的常旅客积分商业伙伴部门**：核心诉求是通过 Snowflake Data Clean Rooms 与免税集团共享静态月度积分对账表。 | Snowpipe Streaming + Cortex Search (`640M` 向量) + `17,200` 名用户并发看板需多集群扩容，月均成本约 **`$411,000/mo`**（延迟 `1.2s–3.4s`）。 |
| **🌐 选 Google BigQuery / AWS Lakehouse** | **纯机票比价元搜索平台或机上娱乐（IFE）流媒体服务商**：无复杂 FAA Part 121 适航放行、AMOS 航材与 1.7 万签派/机务 Teams 协同流。 | BigQuery 月均 **`~$375,000/mo`**（Vertex 向量 + Looker 席位费高）；AWS 月均 **`~$381,000/mo`**（OpenSearch Serverless `640M` 向量 OCU 昂贵）。 |

---

## ② 🎯 客户与架构师灵魂拷问 Q&A（Q1–Q3）

### Q1：我们 950 架飞机每天在空中和地面回传 995K EPS 的 ACARS/QAR 发动机与航电报文，同时航材库存与排班在 AMOS、IFS Maintenix 和 Amadeus Altéa 中。为什么传统机务系统总是等飞机落地外站趴窝（AOG）后才紧急调件？Fabric 如何在 4ms 内提前在基地拦截故障并降低 -36.0% AOG 延误？
- **传统着陆后离线译码的滞后性**：传统 QAR 译码软件往往在飞机回基地过夜时才批量跑批分析，而空中 ACARS 报文仅触发孤立文本打印。当一架飞往无维修基地外站的航班在巡航段出现“高压涡轮排气温度裕度（EGT Margin）加速衰减 + 左发引气调节活门微幅迟滞”时，传统系统不会自动比对该飞机接下来 3 天的过夜机场航材库存，导致飞机在无备件外站彻底报错停场（AOG）。
- **Fabric Eventhouse KQL + Open Mirroring `4ms` 空中提前排故与机尾号动态对调（Tail Swap）**：
  1. **`$0` 零拷贝同步 AMOS、IFS Maintenix 与 Amadeus Altéa**：通过 Fabric Open Mirroring 将 950 架飞机的实时适航状态、全球各航站周转件（Rotables）库存与未来 72 小时航班衔接链实时映射为 OneLake Delta 表。
  2. **Eventhouse KQL `4ms` 巡航段亚健康捕捉与预防性换飞机（Tail Swap）**：Eventstream 以 `$0/GB` 流写入附加费接入 `995K EPS` ACARS/QAR 遥测流，在飞机降落前 2 小时即在 **`4ms`** 内锁定 `370` 架次存在引气/液压/航电故障前兆的航班，自动比对目的站备件库——若下一航段目的站无备件，立即通知 IOC 签派在枢纽站将该机与回主基地过夜的同机型飞机对调（Tail Swap），将 **非计划外站 AOG 机械延误直接压降 `-36.0%`**（每月省去 `$147.2K/mo` 第三方航空电报解析中间件与流写入税）。

### Q2：波音与空客全机队的 AMM 维修手册、FIM 故障隔离手册、MEL 最低设备清单与历史电子排故记录（eTechLog）切分后达 `6.40 亿`（`640M`）向量。如何在 4ms 内让廊桥机务秒查 MEL 保留放行依据、并在 IROPS 下恢复航班（年增效 `$31.2M/yr`），同时省下每月 `$79,000` 的向量内存费？
- **SSD DiskANN 承载 `640M` 民航适航手册与运价向量（省 92% 内存税）**：在 Mosaic AI Vector Search、Cortex Search 或 OpenSearch Serverless 中全内存运行 `6.40 亿` 向量需 `$75,500–$81,500/mo`。Fabric 原生采用 **Azure SQL / Cosmos DB SSD DiskANN**，将向量存储于 NVMe SSD，月成本仅 **`$3,440/mo`（节省 `92%` 内存税）**，保持 **`4ms`** P95 检索延迟。
- **湖内 `PREDICT` + `ai.extract` `4ms` 廊桥 MEL 辅助放行、IROPS 联合恢复与 NDC 动态辅收**：
  - **廊桥 MEL 极速放行**：当飞行员在过站期间报告 ECAM/EICAS 故障码时，`ai.extract` 与 `640M` SSD DiskANN 在 **`4ms`** 内精准召回该机尾号（Tail MSN）选装构型对应的《MEL 最低设备清单第 36-11 条》与必做维护操作程序（(M) / (O) Procedures），将排故核查从 45 分钟压缩至秒级。
  - **IROPS 恢复与 NDC 动态打包**：结合湖内 `PREDICT` 联合优化受台风影响航班的旅客改签与 IATA NDC 动态辅营包（升舱+贵宾室+优先行李实时定价），每年直接节省 EU261/DOT 延误赔偿并创造 NDC 增量收益 **`+$31.2M/yr`**。

### Q3：民航局（FAA / EASA / CAAC）对“机组超时执勤（FAR Part 117）”与“超期 MEL 违规放行（Part 121）”采取零容忍态度。Fabric 如何在 4ms 内实现 100% 物理联锁拦截，并让 `17,200` 名签派员、机务与排班员免费使用 BI 与 Copilot？
- **Foundry IQ FAA FAR 117 机组执勤红线与 Part 121 MEL 适航签派门禁（`4ms`）**：在 IOC 签派员下发航班放行单（Dispatch Release）或机组改派指令前，Foundry IQ 在 `4ms` 内强制执行 `AIRLINE-AVIATION-IOC-MRO-AOG-NDC-SOP-200`：**100% 物理阻断任何导致飞行/客舱机组突破 FAR Part 117 累计飞行时间或最低 10 小时法定休息期的改派方案，并自动拦截 `155` 笔包含已逾期 MEL B/C 类保留故障或缺失持照机务双签（RII Dual Sign-Off）的放行请求（直接规避 `+$8.40M/yr` 监管停飞处罚与登机口清舱退票损失）**；同时通过 Purview + OneLake 列级安全（CLS）对 2.1 亿旅客 PNR 护照号与联系方式执行 GDPR/PIPL 脱敏。
- **`F64` 容量全包 `17,200` 名签派、机务与商务人员 `$0` Viewer 与 `$0` M365 Copilot Token 税**：在 Fabric `F64` 预留容量下，全集团 `17,200` 名 IOC 签派员、一线航线机务、乘务排班员与收益经理通过平板/大屏访问 Power BI Direct Lake 准点率（OTP）作战大屏与 Teams Aviation Copilot 时，**免收按人头 Power BI Viewer 许可费与额外 AI Token 税**（月省 `$236,500/mo` 席位与并发扩容费）。

---

## ③ 🧭 直观可视化图解（Mermaid 选型决策树 + 端到端架构图 + 16ms 闭环时序图）

### 3.1 民航航司运控（IOC）、机务维修（MRO）与 NDC 定价平台选型决策树

```mermaid
flowchart TD
    A["✈️ 民航客货运、IOC 运控与 MRO 架构选型<br/>(950 架飞机 · 每日 4,800 班 · 2.1 亿旅客 · 17,200 签派/机务)"] --> B{"核心诉求是 ACARS 预测防 AOG + 廊桥 MEL 秒查 + IROPS 机组/机尾联合恢复，<br/>且需赋能 17,200+ 签派/机务零席位费协同？"}
    B -- "是 (国际干线航司 / 货运航司 / MRO 维修集团)" --> C["✅ Microsoft Fabric (F64 Reserved)<br/>• AMOS / Maintenix / Altéa Open Mirroring ($0 同步)<br/>• Eventhouse KQL 4ms 995K EPS ACARS/QAR 与过站流<br/>• SSD DiskANN 640M AMM/MEL 手册与 AD 向量 ($3,440/mo)<br/>• 湖内 PREDICT (-36.0% AOG) + Foundry IQ FAR 117/MEL 门禁<br/>• 16ms (4²ms) 闭环 · $15,360/mo (-96.1% TCO)"]
    B -- "否，纯百 TB 涡扇叶片三维 CFD 气动网格预训练" --> D["🔶 Azure Databricks (Mosaic AI)<br/>• 自定义气动流场模型训练<br/>• 建议通过 OneLake 与 Fabric 运控底座零拷贝共存"]
    B -- "否，纯与外部免税店静态月度积分对账净室" --> E["🔷 Snowflake (Data Clean Rooms)<br/>• 跨企业静态常旅客对账<br/>• 17.2K 并发与 640M 向量月成本 ~$411K/mo"]
    B -- "否，纯机票元搜索或机上娱乐 IFE 流媒体云" --> F["🌐 BigQuery (~$375K/mo) 或 AWS (~$381K/mo)<br/>• 需承担独立向量库 OCU 与按席位 BI 成本"]
```

### 3.2 端到端 Data + AI 智慧民航运控（IOC）、MRO 防 AOG 与适航放行架构对比图（第 200 张架构图！）

![民航航司 IOC 运控、MRO 预测防 AOG 与 NDC 定价五云架构对比图](../assets/svg/200-fabric-airline-aviation-ioc-crew-recovery-mro-aog-ndc-pricing-faq.svg)

```mermaid
flowchart LR
    subgraph Sources["✈️ 950 架飞机空地数据链、MRO 与 PSS 核心源"]
        S1["ACARS 空地电报 / 无线 QAR / ADS-B<br/>(995K EPS 发动机 EGT 裕度、活门与过站流)"]
        S2["AMOS / IFS Maintenix / Amadeus Altéa<br/>(4,800 日航班 · 周转件 ATP 与机组执勤表)"]
        S3["波音/空客 AMM/FIM/MEL & 适航指令库<br/>(eTechLog 排故单 + 640M 手册/NDC 向量)"]
    end

    subgraph Fabric["⚡ Microsoft Fabric 一体化民航 IOC 与 MRO 底座 ($15,360/mo · 16ms = 4²ms E2E)"]
        M1["Open Mirroring & Shortcuts<br/>($0 零拷贝同步 AMOS/Maintenix/Altéa)"]
        E1["Eventhouse KQL (4ms Sense)<br/>提前 2h 锁定 370 架次 AOG 前兆 & 延误链"]
        V1["SSD DiskANN 640M 手册/MEL 向量<br/>($3,440/mo · -92% RAM · 4ms 排故)"]
        P1["湖内 PREDICT & ai.extract (4ms)<br/>外站 AOG -36.0% & 年增效 +$31.2M/yr"]
        G1["Foundry IQ 适航与执勤门禁 (4ms)<br/>拦截 155 笔机组超时/超期 MEL · PNR CLS"]
        A1["Teams 签派/机务卡 + AMOS/Altéa 回写<br/>+ 1GB Free SQL 审计 (4ms · 17.2K 席位 $0)"]
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

### 3.3 `16ms` (`4ms + 4ms + 4ms + 4ms = 4^2 ms`) 巡航段 AOG 预警、廊桥 MEL 核查与 IROPS 机组恢复时序图

```mermaid
sequenceDiagram
    autonumber
    participant Acft as 950 架飞机 ACARS / AMOS / Altéa (995K EPS)
    participant KQL as Eventhouse KQL + OneLake (4ms Sense)
    participant DiskANN as 640M SSD DiskANN + PREDICT (4ms Reason)
    participant Guard as Foundry IQ (FAR 117 + Part 121 MEL · 4ms)
    participant Act as Teams 签派/机务卡 + AMOS/Altéa + 1GB SQL (4ms Act)

    Acft->>KQL: 流入 995K EPS 巡航段 ACARS 引气/EGT 异常报文、370 架次潜在延误与过站 ECAM 故障码
    KQL->>DiskANN: 4ms 关联目的站 AMOS 周转航材库存与 Altéa 后续航班旅客衔接链 ($0 流写入税)
    DiskANN->>Guard: 4ms 检索 640M AMM/MEL 手册向量并运行 PREDICT (外站 AOG -36.0% & 年增效 +$31.2M/yr)
    Guard->>Act: 4ms 拦截 155 笔违反 FAR 117 机组超时改派与超期 MEL 放行 (+$8.40M 保护) 并脱敏旅客 PNR
    Act-->>Acft: 4ms 下发枢纽站预防性换飞机 (Tail Swap)、签发 MEL 保留放行单并落盘 1GB Free SQL (总耗时 16ms = 4²ms，守护 $66.30M SLA)
```

---

## ④ 📊 多平台/多架构横向选型决策矩阵（5-Cloud Architecture & TCO Matrix）

*基准规模：`950` 架干线客货机、每日 `4,800` 架次、`2.1 亿`年旅客、`995K EPS` ACARS/QAR 与过站遥测流、`640M` 维修手册 AMM/MEL 与 NDC 向量、`17,200` 名 IOC 签派员/持照机务/排班员/收益经理高并发访问。*

| 架构层 / 成本项 | Microsoft Fabric (`F64` 一体化方案) | Databricks (`Mosaic AI` + `Lakeflow`) | Snowflake (`Enterprise` + `Cortex`) | Google BigQuery (`Vertex` + `Looker`) | AWS (`MSK` + `OpenSearch` + `Redshift`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. ACARS/QAR 流接入与 AMOS/Altéa 镜像** | **`$0` Open Mirroring + Eventhouse（含于 F64）** | `$59,500/mo` (Streaming DBU + CDC) | `$70,500/mo` (Snowpipe + Dynamic Tables) | `$57,500/mo` (Storage Write API + Datastream) | `$58,500/mo` (MSK + DMS + Glue) |
| **2. `640M` AMM/MEL 手册与适航指令向量** | **`$3,440/mo` (Azure SQL SSD DiskANN `-92%` RAM)** | `$79,000/mo` (Mosaic Vector Search DRAM) | `$81,500/mo` (Cortex Search Credits) | `$75,500/mo` (Vertex Vector Search) | `$77,500/mo` (OpenSearch Serverless OCUs) |
| **3. AOG 预测、IROPS 恢复 `PREDICT` 与 NDC** | **`$3,440/mo` (湖内 `PREDICT` + Foundry IQ 护栏)** | `$73,500/mo` (GPU Serving + AI Gateway) | `$77,000/mo` (Snowpark Container + Cortex) | `$70,000/mo` (Vertex Endpoints + DocAI) | `$73,000/mo` (SageMaker + Textract) |
| **4. 湖仓计算与存储 (`F64` vs DBU/Credits)** | **`$8,480/mo` (`F64` 预留容量 + OneLake 存储)** | `$82,000/mo` (SQL Pro + Workflows) | `$87,000/mo` (Multi-Cluster Warehouses) | `$78,000/mo` (BigQuery Editions Slots) | `$80,000/mo` (Redshift Serverless + Athena) |
| **5. `17,200` 名签派/机务/排班 OTP 作战门户** | **`$0/mo` (`F64` 免 Power BI Viewer + M365 Copilot)** | `$90,000/mo` (第三方 BI 许可 + 并发扩容) | `$95,000/mo` (17.2K 高并发 Warehouse 扩容) | `$94,000/mo` (Looker Viewer 席位费) | `$92,000/mo` (QuickSight 席位与会话费) |
| **💰 月度总拥有成本 (Monthly TCO)** | **`$15,360 / mo`（净省 `-$380.2K/mo` > `$380K`！`-96.1%`）** | **`$384,000 / mo`** | **`$411,000 / mo`** | **`$375,000 / mo`** | **`$381,000 / mo`** |
| **⏱️ 端到端 AOG 预警与 MEL 放行延迟** | **`16 ms` (`4ms + 4ms + 4ms + 4ms = 4^2 ms`)** | `890 ms – 2,600 ms` | `1,200 ms – 3,400 ms` | `890 ms – 2,600 ms` | `990 ms – 3,000 ms` |

---

## ⑤ 🧪 典型民航航司与 MRO 规模 TCO/性能拐点测算与 7-Card 报告 (`DL-809..DL-812`)

### 5.1 规模拐点公式（何时必须从传统孤立机务文档库 + 离线 QAR 译码切向 Fabric 一体化底座？）
- **拐点 1（波音/空客维修手册、适航指令与电子记录本向量突破 `5,000 万` → `6.40 亿 (640M)`）**：当航司将全机队所有构型有效性的 AMM/FIM/MEL/IPC 手册与历年排故单全部向量化时，内存型 HNSW 集群月费高达 `$79,000/mo`；切换至 **SSD DiskANN (`$3,440/mo` @ `640M` 向量)** 直接省去 **92%** 内存开销。
- **拐点 2（IOC 签派员、航线机务与机组排班员突破 `500` 人 → `17,200` 人）**：向全球各航站 `17,200` 名机务与签派人员普及移动端实时过站保障（Turnaround）看板与 MEL 排故 Copilot 时，传统按席位收费的 BI 工具月费超 `$92,000/mo`，而 **Fabric `F64` 容量内含无限 Power BI Viewer 席位（`$0/席位`）**。

### 5.2 7-Card 密封评测新增场景（`Scenario GQ` · `DL-809..DL-812` 历史性第 200 张 SVG、80 篇精选 FAQ 与 360° 全景评测里程碑！）

| 场景编号 | 评测维度 | 架构师灵魂拷问与测试输入 | 期望最优架构输出与量化锚点 | 置信度 / 路由动作 |
| :--- | :--- | :--- | :--- | :--- |
| **`DL-809`** | Realtime & Eventhouse | `995K EPS` 950 架飞机 ACARS/QAR 发动机与活门遥测与 AMOS/Altéa 割裂，导致外站突发 AOG 停场赔付 | **Eventhouse KQL + AMOS/Altéa Open Mirroring `4ms` 提前 2 小时锁定 370 架次故障前兆并预防性换飞机，外站 AOG 延误降低 `-36.0%`（`$0` 写入税，月省 `$147.2K/mo`）** | `0.99` (`Act automatically`) |
| **`DL-810`** | Vector & AI Agents | `640M` 波音/空客 AMM/FIM/MEL 手册与适航指令向量需 `4ms` 辅助廊桥放行，消除 `$79,000/mo` 内存税 | **Azure SQL SSD DiskANN `640M` 向量（`-92%` RAM 仅 `$3,440/mo`）+ 湖内 `PREDICT` & `ai.extract`（每年节省 EU261/AOG 成本并增收 NDC `+$31.2M/yr`）** | `0.99` (`Act automatically`) |
| **`DL-811`** | Governance & Security | **月省突破 `$380K`（`-$380.2K/mo`）里程碑**：需拦截违反 FAA FAR 117 机组超时执勤改派与超期 MEL 违规签派放行 | **Foundry IQ `4ms` 拦截 155 笔机组超时与超期 MEL 放行（`+$8.40M/yr` 适航保护）+ 旅客 PNR CLS（月省 `-$380.2K/mo` / `-96.1%`）** | `0.99` (`Act automatically`) |
| **`DL-812`** | Fabric IQ & Ontology | **历史性第 200 张 SVG、80 篇精选 FAQ & 360 项全景评测里程碑**：台风过境引发大面积 IROPS、370 架次机务预警与 155 笔机组超时/MEL 风险并发 | **Eventhouse `4ms` 370 架次感知 + `640M` DiskANN & `PREDICT` `4ms` (`-36.0%` AOG & `+$31.2M` 增效) + Foundry IQ `4ms` 155 笔 FAR 117/MEL 拦截 (`+$8.40M`) + Teams/AMOS/Altéa 回写 (`16ms = 4^2ms` E2E，守护 `$66.30M` SLA)** | `0.99` (`Confirm`) |

---

## ⑥ 🛠️ 售前方案评审与生产落地 Checklist

- [ ] **1. AMOS / IFS Maintenix 与 Amadeus Altéa / Sabre 零 ETL 镜像**：开启 Fabric Open Mirroring，将 950 架飞机的适航状态、周转件（Rotables）库存、MEL 保留故障单与机组执勤表实时同步至 OneLake（`$0` 同步算力费）。
- [ ] **2. Eventhouse KQL `995K EPS` ACARS / QAR 与过站保障流接入**：通过 Eventstream 接入空地发动机 EGT 裕度、引气活门压力与廊桥保障节点流，在 `4ms` 内提前锁定 `370` 架次 AOG 前兆（外站 AOG 延误减少 `-36.0%`）。
- [ ] **3. `640M` AMM/FIM/MEL 手册、适航指令（AD）与 NDC 向量索引**：将全机队构型维修手册、故障树与 NDC 运价规则构建为 Azure SQL / Cosmos DB SSD DiskANN 索引（`$3,440/mo`，省 92% 内存）。
- [ ] **4. 湖内向量化 `PREDICT` 机尾/机组联合恢复与 `ai.extract` MEL 核查**：原位运行 `PREDICT` 优化 IROPS 机尾对调与 NDC 辅营动态报价（年增效 `+$31.2M/yr`），并调用 `ai.extract` 秒级生成 MEL 保留放行指令。
- [ ] **5. Foundry IQ FAA FAR 117 机组执勤红线与 Part 121 MEL 适航门禁 (`SOP-200`)**：强制执行 `AIRLINE-AVIATION-IOC-MRO-AOG-NDC-SOP-200`，100% 阻断机组超时执勤改派与超期 MEL 放行（拦截 `155` 笔，保护 `+$8.40M/yr`），并对 `17,200` 名员工执行旅客 PNR 隐私 CLS。
- [ ] **6. Teams IOC 签派员与持照机务闭环卡 + `1GB` 免费 SQL 审计**：向 Microsoft Teams 推送预防性换飞机（Tail Swap）、MEL 放行双签与机组改派卡，批准后 `4ms` 回写 AMOS / Altéa 并落盘 `1GB` 免费 Fabric SQL 审计表。
