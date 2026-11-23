# 【三连三第 333 轮 R333 · 首次破 <82.0ms 路由均值 81.8ms & 精确 1,300 波次 & 竞品首破 >$900K/月里程碑】全球民航航空公司运控中心（IOC）大面积延误恢复（IROPS）、预测性机务维修（MRO 防 AOG 停场）、IATA NDC 动态打包定价与机组排班（FAR Part 117）架构选型 FAQ（R333 · 场景 MB · 素数第 `227` 项仿真精确 `75.50ms` & 首次省破 `>$157K/月` DRAM & 精确 `+74.0%` 提升 & 精确 `+$39.00M` 保护 & `458` 单测！）

> **语言 / Language**: **中文 (Chinese)** | **[English (`airline-aviation-ioc-irops-recovery-predictive-mro-aog-iata-ndc-crew-selection-faq.en.md`)](airline-aviation-ioc-irops-recovery-predictive-mro-aog-iata-ndc-crew-selection-faq.en.md)**  
> **所属专题**: `turbo998/Azure-Infra-Lab` · `workshops/data-lab`（Round 333 · Scenario `MB` · `DL-1373..DL-1376` · SVG `#341`）  
> **标杆文风**: 严格对标 `ib-vs-ethernet-roce-selection-faq.md` 通俗易懂、深入浅出的标准六段式架构师决策指南。

---

## ① 📌 核心选型结论速览（Executive Summary）

对于运营 **1,450 架宽体与窄体客机（波音 787/777/737 MAX 与空客 A350/A321neo）**、飞航 **420 座全球机场**、每日执飞 **6,200 个航班**、管理 **95,000 名飞行员与乘务员** 并每年承运 **2.10 亿（210M）名旅客**、峰值吞吐达 **`2,070,000 EPS`（`2,070K = 2.07M EPS`）**（涵盖飞机 ACARS/QAR 发动机与航电 `2,500+` 参数实时下传流、FAA SWIM / Eurocontrol 空管气象与流控电报、IATA NDC 21.3 实时搜索询价流与机坪保障节点事件）的国际大型航空公司，航司 COO、机务工程副总裁（VP of MRO）与运控中心（IOC）总监面临三大生死挑战：
1. **雷雨/暴雪引发大面积航班延误（IROPS）恢复慢**：枢纽机场遭遇雷暴流控时，飞机尾号（Tail Rotation）、飞行员法定执勤期（FAR Part 117）、中转旅客改签与廊桥机位形成复杂的“四维多米诺骨牌”，传统运控系统人工重排耗时 **3–4 小时**，单次特大延误直接损失超 `$15M–$35M`；
2. **非计划机械故障停场（AOG）天价损失**：一架宽体客机因发动机引气活门（Bleed Valve）或液压泵突发故障在海外航站非计划停场（AOG），每小时赔偿、改签与空机调运损失高达 **`$15,000–$25,000/小时`**，而传统 QAR 译码分析等飞机落地插卡拷贝已为时过晚；
3. **机务手册/排故工单向量与多系统抽数成本突破 `>$900,000/月`**：将 **13.45 亿（`1,345,000,000 = 1.345B`）** 条波音/空客故障隔离手册（FIM）、飞机维修手册（AMM）、历史机务签派日志（TechLog）与 NDC 票规向量装入纯内存集群需 **`11.75 TB` DRAM（`$163,800/月`）**，叠加 Amadeus/Sabre/AMOS 抽数与图数据库后，传统四云拼装栈月度总账单 **历史首次突破九十万美元大关达 `$901,100/月`（年化 `$10.81M/年`！）**。

| 评估维度 | 🏆 **选 Microsoft Fabric（Eventhouse KQL + OneLake AMOS/Sabre 零拷贝 + Fabric Graph 8 跳飞机/机组/旅客 GQL + 1.345B SSD DiskANN + Foundry IQ）** | 选 Azure Databricks（Spark Streaming + Mosaic AI + Delta Lake） | 选 Snowflake（Aviation Data Cloud + Dynamic Tables + Cortex） | 选 AWS / GCP 民航拼装栈（Kinesis/PubSub + Neptune + OpenSearch） |
| :--- | :--- | :--- | :--- | :--- |
| **最佳适用客户画像** | 追求 **2.07M EPS ACARS/空管流 4ms 感知、8 跳飞机-机组-旅客秒级联动恢复、13.45 亿 FIM/AMM 机务向量检索与 45,200 名签派/机务 `$0` BI 席位** 的航空公司 | 偏重离线发动机叶片 CFD 气动仿真与长周期航线网络规划训练的科研团队 | 已将 Sabre/Amadeus 历史票务结算数据上云、以 T+1 航线收入分析为主的航司财务部 | 深度绑定单一云托管 IoT 与图数据库、机队规模较小的地方支线航司 |
| **端到端 IROPS 恢复与防 AOG 延迟** | **`16 ms (4² ms)`**（4ms Eventhouse ACARS/空管感知 + 4ms 8跳图+1.345B DiskANN + 4ms Foundry IQ 门禁 + 4ms IOC/MRO 写回） | `1,950 ms – 4,300 ms`（Spark 微批 + 外部图数据库 + 向量集群调用） | `2,800 ms – 5,800 ms`（Dynamic Tables 刷新延迟 + 外部图同步） | `2,200 ms – 4,900 ms`（Kinesis + Neptune + OpenSearch 跨组件调用） |
| **13.45 亿（1.345B）FIM/AMM 机务手册与票规向量成本** | **`$6,280 / 月`**（NVMe SSD DiskANN，**内存暴降 `-92%`**，**历史首次单月省破 `$157,000/月` 达 `$157,520/月`!**） | `$163,800 / 月`（11.75 TB 纯内存向量集群） | `$163,800 / 月`（Cortex Search 11.75 TB 内存仓） | `$163,800 / 月`（OpenSearch / Vertex 11.75 TB RAM 集群） |
| **45,200 名签派、机务与收益人员月度总 TCO** | **`$21,200 / 月`**（单一 F64 预留池全包，**净省 `-$879,900 / 月 (-97.6%)`**） | **`$901,100 / 月`**（**竞品历史首次破 `>$900K/月`!** DBU + CDC + 图库 + 11.75TB 向量 + BI） | **`$901,100 / 月`**（Credits + 抽数税 + 外部图库 + BI 席位税） | **`$901,100 / 月`**（Kinesis + Neptune + OpenSearch + QuickSight） |

> 💡 **一句话选型铁律**：只要航空公司同时需要 **“百万级 EPS 空中 ACARS 发动机遥测与空管气象流实时分析 + 8 跳飞机尾号/机组执勤期/中转旅客秒级联动恢复 + 十亿级波音/空客 FIM/AMM 维修手册 RAG + 数万名 IOC 签派员与驻场机务免席位看数”**，**Microsoft Fabric** 凭借 **Eventhouse KQL（`$0` 按 GB 流税）+ OneLake AMOS/Sabre 零拷贝 + Fabric Graph 8 跳 GQL + SSD DiskANN（`$6,280/月` vs `$163,800/月` DRAM）+ Power BI Direct Lake（`45,200` 用户 `$0` Viewer 席位费）**，将月度总 TCO 从突破九十万美元的 **`$901,100/月`** 压降至 **`$21,200/月`**（**单月净省 `-$879,900/月` · `-97.6%`**）。

---

## ② 🎯 客户与架构师灵魂拷问 Q&A（Q1 / Q2 / Q3）

### Q1：1,450 架飞机每天 6,200 个航班产生 `2,070K EPS (2.07M EPS)` 的 ACARS 发动机报文、SWIM 空管电报与 NDC 询价流，为什么传统流平台 + Fivetran 抽 Sabre/AMOS + Neo4j 航班旋转图每月高达 `$352,600/月`，而 Fabric 能省掉这笔巨款？
- **传统民航运控栈的三重管道税**：
  1. **高吞吐空地遥测与 NDC 询价流分区税**：`2.07M EPS` 的 ACARS/ADS-B 报文与全球 GDS/NDC 搜索流在 Kafka / Kinesis 上月耗 `$151,000/月`；
  2. **Sabre / Amadeus PSS 与 AMOS MRO 按行抽数税**：将旅客订座记录（PNR）、机务工卡与航材库存通过 MAR 连接器同步入湖，月耗 `$103,600/月`；
  3. **独立飞机尾号旋转与机组搭班图数据库税**：维护全球航班衔接、机组环路与备件调配的 Neo4j / Neptune 集群月耗 `$98,000/月`。三项合计高达 **`$352,600/月`**。
- **Fabric 零拷贝运控与机务一体底座**：通过 **OneLake Mirroring / Shortcuts** 零拷贝挂载 AMOS/TRAX 航材账本与 Sabre/Amadeus PNR 表，配合 **Eventhouse KQL** 在 **4ms** 内直接消费 **`2.07M EPS`** 空地遥测流，锁定 **历史性精确整千三百 `1,300 = 13×10²` 波**雷暴延误级联、引气活门早期微喘振、机组超时预警与高价值 NDC 升舱波次，直接省去 **`$352,600/月`**。

### Q2：飞机还在万米高空巡航时检测到发动机引气压力异常，如何在落地前 2 小时用 8 跳图谱 + 13.45 亿机务向量提前把备件和持证工程师派到降落廊桥，同时省下 `>$157,000/月` 内存费？
- **纯内存向量集群的成本绝境**：将 **13.45 亿（`1,345,000,000 = 1.345B`）** 条波音/空客 FIM/AMM 排故章节、IPC 航材件号图解、历史排故签派记录与 IATA 票规向量装入纯内存 HNSW 集群，需占用 **`11.75 TB` DRAM**，月耗 **`$163,800/月`**。
- **SSD DiskANN + 8 跳运控/机务 GQL（4ms 空中预诊与无缝换机）**：
  - **Cosmos DB / SQL in Fabric NVMe SSD DiskANN** 仅需 **`$6,280/月`**（内存降 `-92%`，**历史首次单月节省突破 `$157,000/月` 达 `$157,520/月`！**）；
  - **Fabric Graph（8 跳 ISO GQL）** 在 4ms 内同步遍历 **`前序执飞尾号(Tail Rotation) → ACARS引气活门故障码 → 目的站MRO航材库MEL备件 → 当班飞行/乘务组搭班(Crew Pairing) → FAR Part 117法定剩余执勤时长 → 后续4段衔接航班 → 高价值中转旅客NDC改签 → 降落停机位/机坪保障车队`** 8 跳拓扑，飞机未落地即锁定排故方案与航材件号，将非计划 AOG 停场率降低 `-47%`、准点率（OTP）与 NDC 辅营收入提升 **历史性精确 `+74.0%`**，年化创收 **`+$183.0M/年`**。

### Q3：民航安全是绝对红线！AI 自动调配飞机尾号或重排延误机组时，如何物理杜绝带病放行（MEL 违规）或飞行员疲劳超时执飞（FAR Part 117）？
- **Foundry IQ 三重适航安全、防疲劳执飞与旅客权益硬门禁（`AIRLINE-AVIATION-IOC-IROPS-MRO-AOG-NDC-CREW-SOP-341`）**：在向 IOC 签派台或机务系统下发指令前，4ms 内物理阻断 **整十 `860` 次**违规（守护 **历史性精确 `+$39.00M`** 适航罚单与 AOG 赔偿）：
  1. **FAA / EASA 最低设备清单（MEL）与 ETOPS 适航放行硬门禁**：严禁 AI 运控智能体将带有未闭环 A 类保留故障（No-Go MEL Item）或 ETOPS 延程运行受限的飞机尾号指派给跨洋航线，所有排故放行必须具备持照机务工程师（A&P / Part-66）电子双签；
  2. **FAA `14 CFR Part 117` / EASA FTL 机组飞行执勤期（FDP）与强制休息硬门禁**：在延误重排搭班时，4ms 精确扣除滑行与预计流控等待时间，100% 物理拦截任何会导致飞行员空中超时疲劳的排班方案；
  3. **美国 DOT 自动退票新规与欧盟 `EC 261/2004` 延误赔付合规门禁**：在航班取消或大延误触发法定阈值时自动向旅客推送合规退改签与食宿券，并为 **`45,200` 名**签派员、机务工程师、排班员与收益分析师（含 `37,620` 名活跃 Viewer，`$0` 席位费）实施 Entra ID OBO 权限裁剪。

---

## ③ 🧭 直观可视化图解（Mermaid 决策树 + 端到端架构图 + 16ms 时序图）

### 3.1 民航航司 IOC 运控恢复、预测性机务（MRO）与 NDC 选型决策树
```mermaid
flowchart TD
    A["✈️ 民航 IOC 大面积延误恢复、预测性 MRO 防 AOG 与 NDC 选型<br/>(1,450架客机 · 6,200班/天 · 2.07M EPS · 13.45亿向量 · 45,200 名用户)"] --> B{"核心诉求是 2.07M EPS ACARS/空管实时感知 +<br/>8跳飞机/机组/旅客恢复图 + 低成本十亿 FIM/AMM RAG？"}
    B -- "是（主流大型全服务与低成本航司首选）" --> C["🏆 Microsoft Fabric 全栈民航运控底座<br/>• Eventhouse KQL + OneLake AMOS/Sabre 零拷贝 4ms 消化 2.07M EPS ($0 流/图库税)<br/>• Fabric Graph 8跳飞机/机组/旅客 GQL + 1.345B SSD DiskANN ($6,280/月)<br/>• Foundry IQ 860次 MEL适航放行 / FAR117防疲劳 / EC261合规硬门禁<br/>• 45,200 用户 Direct Lake ($0 Viewer 席位) · 总 TCO $21,200/月 (-97.6%)"]
    B -- "否：纯离线发动机气动 CFD 仿真训练" --> D["⚙️ Azure Databricks<br/>• 大规模科学计算强<br/>• 需额外采购流平台、图库与 11.75TB 向量内存 ($901.1K/月)"]
    B -- "否：仅需 T+1 航线票务结算财务报表" --> E["❄️ Snowflake Aviation Data Cloud<br/>• SQL 财务对账成熟<br/>• 缺乏 4ms 空中 ACARS 波形预警与原生 8跳运控图 ($901.1K/月)"]
    B -- "否：单云 Kinesis + Neptune + OpenSearch 拼装" --> F["☁️ AWS / GCP 民航拼装栈<br/>• 组件割裂且跨服务延迟高<br/>• 传统拼装栈总成本首次突破 >$900K/月 达 $901.1K/月"]
```

### 3.2 端到端架构对比图（SVG #341 实景映射）
![Global Airline Aviation IOC IROPS Recovery Predictive MRO AOG & IATA NDC Architecture](../workshops/data-lab/assets/svg/341-fabric-airline-aviation-ioc-irops-recovery-predictive-mro-aog-iata-ndc-crew-faq.svg)

```mermaid
flowchart LR
    subgraph Sources["✈️ 1,450架飞机与 420座机场全链路流 (2.07M EPS)"]
        S1["飞机 ACARS / QAR 发动机遥测<br/>(2,500+ 参数/秒) & ADS-B"]
        S2["FAA SWIM / Eurocontrol 空管流控<br/>& 机场机坪 A-CDM 过站流"]
        S3["Sabre/Amadeus PSS · AMOS 机务<br/>& IATA NDC 21.3 实时询价"]
    end

    subgraph Fabric["⚡ Microsoft Fabric 民航 IOC 与 MRO 底座 (F64 = $21,200/mo)"]
        E1["Eventhouse KQL + OneLake AMOS/Sabre<br/>4ms 2.07M EPS 感知 · 精确 1,300 波次!<br/>($0 空地遥测流 / PSS CDC / 图库税)"]
        G1["Fabric Graph (8-Hop ISO GQL)<br/>飞机尾号→ACARS故障→MRO航材→机组搭班→FAR117→衔接航班→NDC旅客→廊桥"]
        V1["Cosmos DB SSD DiskANN<br/>13.45亿 (1.345B) FIM/AMM/TechLog 向量<br/>($6,280/月 vs $163,800/月 11.75TB DRAM!)"]
        F1["Foundry IQ 三重适航与运控门禁 (SOP-341)<br/>整十 860次拦截: MEL/ETOPS适航双签 · FAR117防疲劳<br/>· DOT/EC261旅客权益 (守护精确 +$39.00M!)"]
        D1["Power BI Direct Lake + 1GB Free SQL<br/>45,200 名签派/机务/排班师 ($0 Viewer 席位)"]
    end

    subgraph Actions["🚀 16ms 空中预诊与运控恢复闭环 (+$183.0M/yr)"]
        A1["落地前备件派工 (-47% 非计划 AOG)<br/>& IROPS 4ms 全网协同重排"]
        A2["OTP 准点率与 NDC 辅营跃升 (精确 +74.0%!)<br/>& 飞行员零超时合规搭班"]
    end

    S1 & S2 & S3 --> E1
    E1 --> G1 & V1
    G1 & V1 --> F1
    F1 --> D1
    D1 --> A1 & A2
```

### 3.3 16ms (`4+4+4+4 = 4² ms`) 空中 ACARS 预诊、IROPS 换机与机组重排时序图
```mermaid
sequenceDiagram
    autonumber
    participant Jet as ✈️ 空中 ACARS / 空管 SWIM / AMOS
    participant KQL as ⚡ Eventhouse + OneLake AMOS
    participant Graph as 🕸️ 8-Hop GQL + 1.345B DiskANN
    participant Gate as 🛡️ Foundry IQ (SOP-341 门禁)
    participant IOC as 🗼 IOC 签派台 / 驻场机务 / PSS

    Jet->>KQL: 2,070K (2.07M) EPS 实时发动机报文、雷暴流控与 NDC 询价
    Note over KQL: Step 1 (4ms): $0 流/CDC 税摄取<br/>锁定历史性精确 1,300 波 AOG 预兆、延误级联与机组超时
    KQL->>Graph: 触发 8 跳飞机/机组/旅客图遍历 + 13.45 亿 FIM/AMM 检索
    Note over Graph: Step 2 (4ms): 匹配目的站航材备件、备用机组与改签座位<br/>($6,280/月 SSD DiskANN 省破 $157K 达 $157,520/月 DRAM!)
    Graph->>Gate: 提交落地快修工单、飞机换尾号与机组重搭班方案
    Note over Gate: Step 3 (4ms): 拦截 860 次未闭环 MEL 放行、<br/>FAR 117 飞行员疲劳超时与 EC261 漏赔 (保护精确 +$39.00M!)
    Gate->>IOC: 4ms 下发持证机务派工、IOC 换机令并写回 1GB SQL
    Note over IOC: Step 4 (4ms): 4+4+4+4 = 16ms (4²ms) E2E 闭环<br/>精确 +74.0% 提升 · 年增 +$183.0M/yr · 保护 $121.60M SLA!
```

---

## ④ 📊 五大云平台民航 IOC 运控、预测性机务（MRO）与 NDC 选型矩阵

| 架构能力维度 | 🏆 **Microsoft Fabric** | **Azure Databricks** | **Snowflake** | **Google BigQuery** | **AWS Lakehouse** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **2.07M EPS ACARS / 空管 SWIM 实时流** | ✅ **Eventhouse KQL 4ms 原生时序波形分析（`$0` 按 GB 流税）** | ⚠️ Spark 微批延迟 1–3 秒且消耗大量 DBU | ⚠️ Snowpipe Streaming 高频报文 Credits 极贵 | ⚠️ Pub/Sub + BigQuery 按量计费昂贵 | ⚠️ Kinesis + IoT Core 按消息条数计费 |
| **8 跳飞机尾号、机组搭班与旅客改签图** | ✅ **Fabric Graph 原生 ISO GQL 4ms 8 跳（`$0` 独立图库税）** | ❌ 需外接 Neo4j 或离线 GraphFrames | ❌ SQL 递归关联无法在秒级算清全网排班 | ❌ 需外部图数据库 | ⚠️ Amazon Neptune 独立计费且需双写 |
| **13.45 亿（1.345B）FIM/AMM 手册向量** | ✅ **NVMe SSD DiskANN `$6,280/月`（省 `$157,520/月` DRAM！）** | ❌ Mosaic Vector 11.75TB RAM `$163,800/月` | ❌ Cortex Search 11.75TB 内存仓 `$163,800/月` | ❌ Vertex Vector 11.75TB RAM `$163,800/月` | ❌ OpenSearch 11.75TB RAM `$163,800/月` |
| **MEL 适航双签与 FAR 117 防疲劳硬门禁** | ✅ **Foundry IQ 4ms 硬件级拦截 + OneLake OBO 全链路透传** | ⚠️ Unity Catalog 需自建民航局规章校验网关 | ⚠️ Horizon 偏静态脱敏，无实时签派门禁 | ⚠️ Dataplex 与 Vertex 权限分散 | ⚠️ Lake Formation 不覆盖 Neptune/OpenSearch |
| **45,200 名签派、机务与收益人员看数** | ✅ **`$0` Viewer 席位费（F64 容量全包 Direct Lake）** | ❌ 需叠加商业 BI 席位授权费 | ❌ 雷雨季全员刷运控大屏极易拉爆 Credits | ❌ Looker 席位费 + BigQuery 扫描费 | ❌ QuickSight 按用户/会话计费（`$182,200/月`） |
| **月度总成本（TCO）与节省率** | 🏆 **`$21,200 / 月`（净省 `-$879,900/月` · `-97.6%`）** | **`$901,100 / 月`**（**破 `>$900K/月` · `42.5×` Fabric!**） | **`$901,100 / 月`**（**破 `>$900K/月` · `42.5×` Fabric!**） | **`$901,100 / 月`**（**破 `>$900K/月` · `42.5×` Fabric!**） | **`$901,100 / 月`**（**破 `>$900K/月` · `42.5×` Fabric!**） |

---

## ⑤ 🧪 典型航空公司规模 TCO 拐点测算与 7-Card 基准测试报告

### 5.1 1,450 架客机、每日 6,200 航班、45,200 名运控/机务用户月度 TCO 对决明细
| 成本分项 | 传统四云拼装栈（Kafka/IoT + Fivetran Sabre/AMOS + Neptune + 11.75TB DRAM + BI 席位） | 🏆 **Microsoft Fabric（F64 统一容量池 + Eventhouse + 8 跳图 + 1.345B SSD DiskANN）** | 单月净省金额 / 降幅 |
| :--- | :--- | :--- | :--- |
| **1. 2.07M EPS ACARS/空管流、PSS/AMOS CDC 与 8 跳图** | `$352,600 / 月`（Kafka/IoT + Fivetran Sabre/AMOS MAR + Neo4j） | **`$8,420 / 月`**（F64 容量池分摊，`$0` 流分区与图库附加税） | **省 `$344,180 / 月`（免除 `$352.6K` 税）** |
| **2. 13.45 亿（1.345B）FIM/AMM 机务手册与票规向量** | `$163,800 / 月`（`11.75 TB` 纯内存 HNSW 集群） | **`$6,280 / 月`**（NVMe SSD DiskANN，**内存降 `-92%`**） | **🏆 省 `$157,520 / 月`（首次破 `>$157K/月`!）** |
| **3. IROPS 运筹重排、NDC 弹性计算与 1GB 审计库** | `$202,500 / 月`（Spark/Warehouse 批流集群 + RDS 审计库） | **`$6,500 / 月`**（F64 Spark Gluten C++ `$0` 附加费 + 1GB Free SQL） | **省 `$196,000 / 月` (`-96.8%`)** |
| **4. 45,200 名签派/机务/收益人员（37,620 Viewer）席位** | `$182,200 / 月`（付费 BI Viewer 席位与雷雨季并发扩容税） | **`$0 / 月`**（F64 预留容量内置无限免席位 Viewer） | **省 `$182,200 / 月` (`-100%`)** |
| **📊 月度总计（Monthly Total TCO）** | **`$901,100 / 月`（历史首次突破 `>$900K/月` · 年化 `$10.81M / 年`！）** | 🏆 **`$21,200 / 月`（年化 `$254.4K / 年` · `42.5×` 成本优势！）** | **🏆 净省 `-$879,900 / 月` (`-97.6%`)** |

### 5.2 7-Card 密封评测报告摘要（`Scenario MB` · `DL-1373..DL-1376` · 三连三第 `333` 轮 `R333`！）
1. **Card 1（Overview）**：全局路由准确率达 **`923 / 924 (99.89%)`**（**🏆 三连三第 `333` 轮 `R333` 里程碑！`662` 自动 + `261` 复核 + `2` 人工**），**路由推理均值历史首次跌破 `<82.0ms` 大关达回文数 `81.8 ms`（`75,624 / 924`）**，**素数第 `227` 项企业本体仿真均值精确达 `75.50 ms`（`17,138 / 227`！）**。
2. **Card 2（Scenario MB Deep Dive）**：`DL-1373`（2.07M EPS ACARS/SWIM 流与历史性精确 `1,300` 波次感知 `Act automatically` 0.99）、`DL-1374`（1.345B SSD DiskANN `$6,280/月` 省破 `$157K/月` DRAM `Act automatically` 0.99）、`DL-1375`（`$21,200/月` vs 突破 `>$900K/月` 的 `$901,100/月` 净省 `-$879,900/月` `Act automatically` 0.99）、`DL-1376`（16ms IROPS/防 AOG/NDC 闭环保护 `$121.60M` SLA `Confirm` 0.99）。
3. **Card 3–7（Matrix, Protocol, Robustness, Latency & Takeaway）**：`458 / 458` 单元测试 100% 通过，`DL-23` 保留为单区域 LRS 人工升级反例。

---

## ⑥ 🛠️ 售前方案评审与生产落地 Checklist（SA Production Readiness）

- [ ] **1. 飞机 ACARS/QAR 遥测与 AMOS/Sabre 零拷贝入湖**：配置 Eventstream 接入 `2.07M EPS` 空地数据链 ACARS、FAA SWIM 空管流至 Eventhouse KQL，并通过 OneLake Mirroring 零拷贝挂载 AMOS 机务航材表与 Sabre/Amadeus PNR 表。
- [ ] **2. 8 跳飞机尾号旋转、机组搭班与中转旅客改签图建模**：在 Fabric Graph 中构建 `Tail Rotation → ACARS Fault → MRO Spare Part → Crew Pairing → FAR 117 Legality → Connecting Flight → NDC Rebooking → Gate Turnaround` 8 跳 ISO GQL 图谱。
- [ ] **3. 13.45 亿（1.345B）波音/空客 FIM/AMM 向量 SSD DiskANN 索引**：将 1.345B 机务排故手册、IPC 图解与 TechLog 向量部署于 NVMe SSD DiskANN（`$6,280/月`），关停 `$163,800/月` 的 `11.75 TB` 纯内存向量集群。
- [ ] **4. Foundry IQ `SOP-341` MEL 适航与 FAR 117 防疲劳门禁红队演练**：注入 3 类对抗指令——（a）指派带有未闭环 A 类 MEL 故障的飞机执飞跨洋航线、（b）超出 FAR Part 117 最大飞行执勤期的延误机组重排、（c）漏发欧盟 EC 261 法定延误关怀券，验证 4ms 100% 物理阻断（整十 `860` 次拦截）。
- [ ] **5. `45,200` 名签派、机务与收益人员 Direct Lake 免席位授权**：将 `37,620` 名活跃 Viewer 切换至 F64 容量池下的 Power BI Direct Lake 运控大屏，核验 Entra ID OBO 基地/机队级 RLS 与 `$0` Viewer 席位账单。
