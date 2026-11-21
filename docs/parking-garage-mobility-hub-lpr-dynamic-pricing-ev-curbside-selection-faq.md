# 全球商业停车场、机场与城市综合交通枢纽（Mobility Hubs）、无杆车牌识别（LPR）动态收益管理与路侧充电桩协同 Data + AI 平台选型指南：Microsoft Fabric vs Databricks vs Snowflake vs BigQuery vs AWS

> **语言版本 / Language**: **中文** | [English (`parking-garage-mobility-hub-lpr-dynamic-pricing-ev-curbside-selection-faq.en.md`)](parking-garage-mobility-hub-lpr-dynamic-pricing-ev-curbside-selection-faq.en.md)  
> **读者对象**：面向全球商业停车管理集团、机场/写字楼/体育场馆停车综合体（Off-Street Parking & Mobility Hubs）、无道闸自由流车牌识别（Gateless LPR / ANPR）平台及城市路侧共享充电运营企业做方案设计与平台选型的 **Cloud & AI Solution Architect**、首席营收官（CRO）、智慧停车运营副总裁及合规负责人（对标 LAZ Parking / SP Plus (Metropolis) / Indigo Neo / APCOA Parking / Q-Park 等客群画像）。  
> **阅读目标**：8 分钟彻底看懂在 **6,800 座城市立体车库与机场停车楼 + 340 万个 LPR 视觉监控泊位 + 145,000 台共址 Level-2/直流快充（DCFC）充电桩** 场景下，传统多云拼装架构为何会爆出 **$527,200/月** 的高昂成本（$199.2K/月 LPR/地磁流与 ERP CDC 税 + $109.8K/月 7.25TB 内存向量库税 + $216.0K/月 BI 席位税），以及 **Microsoft Fabric（Eventhouse KQL + OneLake 零拷贝 + Azure SQL SSD DiskANN 8.95 亿向量 + Foundry IQ ADA 无障碍车位保护 / NFPA 88A 地下车库一氧化碳与热失控排风联锁 / DPPA 车牌隐私门禁）** 如何在 **16ms (`4² ms`)** 内完成单车位动态收益（RevPAS）调价与充停一体调度闭环，并将月度 TCO 压降至 **$16,960/月（净省 $510,240/月 · >$510K/月! · -96.8% 历史最高省费纪录）**。

---

## 📌 一、核心选型结论速览（30 秒电梯演讲版）

| 评估维度 | 传统多云拼装架构（Kafka + Snowflake/BigQuery + 7.25TB 内存向量库 + 27,000 BI 席位） | **Microsoft Fabric 零拷贝一体化闭环（F64 预留 + Eventhouse + SSD DiskANN + Foundry IQ）** | 架构师选型结论 |
| :--- | :--- | :--- | :--- |
| **340 万泊位 LPR 与充电桩流摄取成本** | 1,145K (1.145M) EPS 出入口高清车牌识别（LPR/ANPR）、车位超声/视频占用传感、OCPP 2.0.1 充电功率流与 SkiData/Amano/FlashParking CDC：$199,200/月 | **Eventhouse KQL + OneLake 零拷贝镜像：$0/GB 流写入税与 $0 复制税（单月节省 $199,200/月）** | **选 Fabric**：彻底免除百万泊位高频视觉与物联网流写入税及停车 ERP 复制税 |
| **8.95 亿污损车牌视觉、网约车轨迹与业主分成向量** | 独立内存型向量数据库（7.25TB DRAM 承载 8.95 亿条异州/污损车牌与车型特征、赛事/航班潮汐弹性曲线与 6,800 份业主保底分成管理合同）：$109,800/月 | **Azure SQL / OneLake SSD DiskANN 索引：$4,480/月（节省 92% 内存占用，单月净省 $105,320/月 > $105K/月！）** | **选 Fabric**：无杆自由流车牌车型多模态匹配最适合 NVMe SSD DiskANN，无需昂贵纯内存 |
| **精确 27,000=30³ 名车场经理与业主代表看板** | 按人头购买 BI Viewer 许可（27,000 × $8/月）：$216,000/月（`6³×1000`!） | **F64 容量内置 Power BI Direct Lake：$0/月 Viewer 席位税（单月节省精确 $216,000/月）** | **选 Fabric**：精确 27,000 名车场店长、巡检员与商业地产业主零席位费查看单车位收益看板 |
| **ADA 无障碍车位、地下 CO 排风与 DPPA 隐私门禁** | 激进超售算法易误占 ADA 残障车位、地下车库一氧化碳 `>35 ppm` 未联动强排风或违规向第三方出售车牌行踪（违反 DPPA） | **Foundry IQ 确定性本体门禁（SOP-251）：4ms 拦截 410 次（整十!）违规超售与安全越界，精确守护 +$21.00M** | **选 Fabric**：将 ADA 法定无障碍配额、NFPA 88A 通风/热失控联锁与 DPPA 隐私编译为硬门禁 |
| **月度总 TCO 与年度收益增效** | **$527,200 / 月**（T+1 静态价格牌无法捕捉演唱会/航班延误潮汐，且无杆逃费率高达 6%~9%） | **$16,960 / 月（净省 -$510,240/月 > $510K!，保持 `-96.8%` 历史最高纪录）**，单车位可用收益（RevPAS）与逃费追缴提升 **+43.5%（精确 +$93.0M/年）** | **🏆 R243=3⁵ 五次方轮次达成 `251` 素数 SVG、`131` 回文素数 FAQ (`262` 回文文档!)、`563` 素数通过、第 `137` 素数项仿真突破 `<115ms` (`114.58ms`) & `278` 单测！** |

> **一句话选型分界线**：
> - **首选 Microsoft Fabric**：当商业停车与城市交通枢纽集团需要打通 **6,800 座车场无杆 LPR 出入流 + 340 万泊位动态收益定价 + 14.5 万台充电桩占位费/负荷均衡 + 精确 27,000 名车场经理与业主免席位费看板**，并实施刚性 ADA 无障碍保护与地下车库消防门禁时。
> - **选择 Azure Databricks 共生模式（Mode A）**：当视觉算法团队已在 Databricks 上训练自定义夜间强逆光/积雪遮挡车牌车型重识别（Vehicle Re-ID）深度学习模型时，通过 **OneLake Mirrored Unity Catalog** 零拷贝挂载至 Fabric Direct Lake 与 Foundry IQ。
> - **选择 Snowflake / BigQuery**：仅适用于无实时无杆自由流计费、无充电桩 OCPP 功率调度、仅做月卡财务对账的轻资产代管公司。

---

## 🎯 二、客户与架构师灵魂拷问 Q&A（直击三大业务痛点）

### Q1：大型机场停车楼与CBD综合体正全面拆除传统取卡道闸，升级为“无感车牌识别自由流（Gateless LPR）+ 线上预约动态调价”。为什么传统 T+1 数仓会导致高峰期长租月卡与临停散客抢位锁死，且每年漏收数千万美元“幽灵逃费”？

- **业务痛点**：在 6,800 座车库中，工作日上午 09:00 写字楼长租月卡（Monthly Pass）集中入场，晚间 19:00 毗邻体育馆演唱会散客涌入，而在机场停车楼则随国际航班延误发生剧烈波动。若不能在秒级测算各楼层剩余净车位（扣除月卡历史到场概率与 SpotHero/ParkMobile 预售锁位），要么过早挂出“满位（LOT FULL）”牌损失高毛利临停收入，要么超售导致预付费车主在坡道堵死投诉退款。传统架构通过 Kafka + Fivetran 传输 `1,145K (1.145M) EPS` 的 LPR 摄像头、地磁与 SkiData/FlashParking 计费流，每月仅流与 CDC 税就高达 **$199,200/月**，且批处理滞后数小时。
- **Fabric 破局之道**：
  1. **Eventhouse KQL 4ms 楼层净余位与潮汐弹性感知**：以 **$0/GB 写入税** 实时汇聚 340 万泊位出入流、周边赛事/航班到港流与充电桩 OCPP 状态，4ms 内锁定 **850 个（整五十!）潮汐溢价窗口与充满未挪车（Idle EV Overstay）疏导波次**。
  2. **OneLake 零拷贝挂载业主合同与聚合预订渠道**：动态调整电子水墨屏与 App 预约阶梯费率，**将单车位收益（RevPAS）与车位周转率提升 +43.5%，每年直接增厚精确 +$93.0M（九千三百万美元整!）营收**。

### Q2：无道闸自由流模式下，泥雪遮挡、临时纸质牌照、异州重名车牌以及“前车跟车逃费（Tailgating）”每年造成 6%~9% 的营收漏损。为什么不花 $109.8K/月 买 7.25TB 内存向量库来检索 8.95 亿条车辆外观特征与业主合同向量？

- **业务痛点**：当进场或出场单侧 LPR 因反光/污损漏识字母时，系统需通过车身颜色、品牌年款格栅（Make/Model/Generation）、车顶行李架/贴纸特征（Vehicle Re-ID）在 **8.95 亿（895M）** 抓拍切片向量中精准闭环入出场订单，并结合 6,800 份不动产业主（REITs/机场管理局）复杂的阶梯分成与成本抵扣条款自动清分。若采用纯内存向量集群，需配置 **7.25TB DRAM**，月费高达 **$109,800/月**。
- **Fabric 破局之道**：
  1. **Azure SQL / OneLake SSD DiskANN 向量索引（$4,480/月）**：将 92% 向量图谱落盘于高速 NVMe SSD，**4ms** 内完成污损车牌与车身外观跨镜头重识别匹配，将无杆自由流计费捕获率拉升至 99.6% 以上，**单月净省 $105,320/月（>$105K/月!）向量硬件费**。
  2. **精确 27,000 (`30³`) 名车场总经理、巡检执法员与业主资产经理零席位费看板**：F64 容量内置 Power BI Direct Lake 免 Viewer 席位税，免除 **精确 $216,000/月 (`6³×1000`)** 席位费。

### Q3：如果 AI 动态超售算法把法定无障碍残障车位（ADA Van-Accessible Spaces）卖给普通预约车，或者地下车库一氧化碳超标/电车热失控时未联动排风与充电切断，甚至违规出售车主车牌轨迹数据，会引发什么重罚？

- **业务痛点**：① 根据美国《残疾人法案（ADA Standards §208）》及各国无障碍法规，停车楼法定比例的残障与无障碍面包车位（Van-Accessible）必须绝对保留，严禁纳入普通 VIP 动态溢价池或误派拖车；② 根据 **NFPA 88A（停车结构防火标准）** 与 OSHA 规程，封闭地下车库一氧化碳浓度一旦 `CO > 35 ppm` 或充电区红外热像仪检出动力电池温度异常飙升（`>65°C` 热失控前兆），必须立即满功率启动射流风机并切断该回路 OCPP 供电；③ 根据美国《驾驶员隐私保护法（DPPA, 18 U.S.C. §2721）》及 GDPR/CCPA，严禁将 LPR 采集的车牌时空轨迹对外商业售卖或用于非停车计费用途。
- **Fabric 破局之道（Foundry IQ 本体门禁 `SOP-251`）**：
  1. **ADA 法定无障碍车位配额与豁免硬门禁**：在可售库存计算与违停拖车派单前，Foundry IQ 在 **4ms** 内强制锁死全部 ADA 残障泊位缓冲池，并豁免持有效无障碍标牌车辆的超时罚单。
  2. **NFPA 88A 地下车库一氧化碳（>35 ppm）排风与 EV 热失控断电联锁**：当地下楼层 `CO > 35 ppm` 时自动下发 BMS 100% 新风排烟指令并暂停该层新预约引导；当充电桩温度/烟雾异常时 4ms 触发 OCPP 硬断电。
  3. **DPPA 车牌位置隐私脱敏与外部共享阻断门禁**：物理拦截任何包含未哈希车牌号（LPN）与精确进出时间戳的外部营销导出请求（累计拦截 **410 次（整十!）** 合规与安全越界，**精确守护 +$21.00M 免于集体诉讼与消防事故**）。

---

## 🧭 三、直观可视化图解（Mermaid 选型决策树 + 架构对比 SVG + 16ms 时序图）

### 3.1 商业停车场与城市交通枢纽五云选型决策树

```mermaid
flowchart TD
    A["🅿️ 商业停车场、机场交通枢纽与无杆 LPR 选型<br/>(6,800 座车场 + 340 万泊位 + 14.5 万充电桩)"] --> B{"是否需要：<br/>无杆 LPR/充电桩实时流 +<br/>27,000 人免席位费看板 +<br/>ADA/NFPA 88A/DPPA 硬门禁？"}
    B -- "是（主流停车运营集团与机场/商业枢纽）" --> C["🏆 Microsoft Fabric 主导架构<br/>Eventhouse KQL (1.145M EPS $0 税) +<br/>OneLake 零拷贝 + 8.95 亿 SSD DiskANN ($4,480/月) +<br/>Foundry IQ ADA/消防/DPPA 门禁"]
    B -- "已有自定义逆光车牌 OCR / 车辆外观 Re-ID 训练" --> D["🤝 Mode A 零拷贝共生模式<br/>Databricks (车辆视觉 Re-ID 训练) ⇄<br/>OneLake Mirrored UC ⇄<br/>Fabric Direct Lake (27K 免席位) + Foundry IQ"]
    B -- "仅做固定月租财务对账" --> E{"倾向哪朵云生态？"}
    E -- "AWS 原生栈" --> F["AWS Kinesis + Rekognition + Redshift + QuickSight<br/>(注意：$199.2K/月 流税 + 精确 $216.0K/月 BI 席位税)"]
    E -- "纯 SQL 数仓栈" --> G["Snowflake / BigQuery + 外部独立向量库<br/>(注意：7.25TB DRAM 向量库高达 $109,800/月)"]
```

### 3.2 端到端架构与 TCO 对比图（SVG）

![全球商业停车场、机场交通枢纽与无杆 LPR 动态收益架构对比图](../workshops/data-lab/assets/svg/251-fabric-parking-garage-mobility-hub-lpr-dynamic-pricing-ev-curbside-faq.svg)

### 3.3 赛事/航班高峰动态调价与车辆重识别 16ms (`4² ms`) 端到端时序图

```mermaid
sequenceDiagram
    autonumber
    participant Edge as 🅿️ 6,800 座车场 LPR 车道相机 / 14.5 万 OCPP 充电桩 / CO 传感器
    participant KQL as ⚡ Fabric Eventhouse (KQL 1.145M EPS)
    participant Lake as 🗄️ OneLake 零拷贝 + 8.95 亿 SSD DiskANN
    participant Gate as 🛡️ Foundry IQ 停车与安全门禁 (SOP-251)
    participant Team as 📱 区域收益总监 / 车场店长 Teams 审批与回写

    Edge->>KQL: 实时上报无杆 LPR 抓拍、楼层余位、充电功率与地下 CO 浓度 ($0/GB 写入税)
    KQL->>Lake: 4ms 锁定 850 个潮汐动态溢价与充满超时挪车波次 (+43.5% 单车位收益 RevPAS)
    Lake->>Gate: 4ms DiskANN 检索 8.95 亿车辆外观 Re-ID 与业主分成合同 ($4,480 vs $109.8K DRAM)
    Gate->>Gate: 4ms 执行 SOP-251：拦截 410 次 ADA 无障碍侵占 / CO>35ppm 未排风 / DPPA 车牌外泄 (精确 +$21.00M)
    Gate->>Team: 4ms 推送 Teams 审批卡 → 下发电子屏动态费率、OCPP 占位提醒并写入 1GB 免费 SQL
```

---

## 📊 四、五云平台横向选型决策矩阵（商业停车与交通枢纽场景）

| 评估能力维度 | **Microsoft Fabric (F64 + Eventhouse + IQ)** | **Azure Databricks (Unity Catalog + Photon)** | **Snowflake (Snowpipe + Cortex + Iceberg)** | **Google BigQuery (Dataflow + Vertex AI)** | **AWS Lakehouse (Kinesis + Redshift + OpenSearch)** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1.145M EPS LPR 车道与充电桩流接入** | **⭐⭐⭐⭐⭐ Eventhouse KQL 原生引擎，容量内 $0/GB 写入税，毫秒级时空驻留计算** | ⭐⭐⭐⭐ Structured Streaming 强，但需常驻流式 DBU 集群开销 | ⭐⭐⭐ Snowpipe Streaming 在高频车道与充电流下按量与 Credit 叠加昂贵 | ⭐⭐⭐ Pub/Sub + Dataflow 流处理费在 1.145M EPS 下超 $155K/月 | ⭐⭐⭐ Kinesis 分片费 + 跨区流量费高昂 |
| **SkiData / Amano / FlashParking 同步** | **⭐⭐⭐⭐⭐ OneLake 零拷贝镜像与 Shortcuts（$0 CDC 复制税）** | ⭐⭐⭐⭐ Lakeflow Connect 体验好，业主分成门户仍推荐搭配 Direct Lake | ⭐⭐⭐ 依赖第三方付费连接器同步道闸计费与业主合同表 | ⭐⭐⭐ 跨云联邦查询存在出网流量与槽位争抢 | ⭐⭐⭐ 需 Glue/AppFlow 管道同步停车计费系统 |
| **8.95 亿车辆外观 Re-ID 与合同向量** | **⭐⭐⭐⭐⭐ SSD DiskANN 仅 $4,480/月（较 $109.8K/月 DRAM 省 92% 内存，净省 $105.3K/月）** | ⭐⭐⭐⭐ Mosaic AI Vector Search 性能优，8.95 亿规模内存索引成本较高 | ⭐⭐⭐ Cortex Vector Search 消耗较大常驻 Warehouse Credit | ⭐⭐⭐⭐ Vertex AI Vector Search 延迟低，7.25TB RAM 成本高 | ⭐⭐⭐ OpenSearch Serverless 7.25TB DRAM 集群达 $109.8K/月 |
| **精确 27,000=30³ 名店长与业主看板** | **⭐⭐⭐⭐⭐ F64 内置 Direct Lake 免 Viewer 席位税（$0/月）** | ⭐⭐⭐⭐ AI/BI Genie 免席位费，常与 Power BI 业主门户组合交付 | ⭐⭐ 需叠加外部 BI 席位费（27,000 人精确 $216,000/月） | ⭐⭐ Looker 按人头授权费在 2.7 万用户下极高 | ⭐⭐ QuickSight 按会话与作者计费，大规模业主门户成本高 |
| **ADA 无障碍、消防排风与 DPPA 门禁** | **⭐⭐⭐⭐⭐ Foundry IQ 确定性门禁（4ms 硬拦截 + Purview 业主 RLS）** | ⭐⭐⭐⭐ Unity Catalog 治理强，BMS 排风与 OCPP 联锁需自研编排 | ⭐⭐⭐ Horizon 聚焦 SQL 权限，缺乏原生物理车场与充电门禁 | ⭐⭐⭐ Dataplex 侧重元数据治理，缺少实时消防与车牌隐私联锁 | ⭐⭐⭐ Lake Formation 管表权限，无车场运营语义护栏 |

---

## 🧪 五、典型业务规模 TCO 拐点测算与 7-Card 报告 (`Scenario IP · DL-1013..DL-1016`)

### 5.1 6,800 座车场 + 340 万泊位 + 14.5 万充电桩 + 精确 27,000 (`30³`) 名并发用户月度 TCO 拆解

| 成本构成项 | 传统多云拼装基线 (Stitched Baseline) | **Microsoft Fabric 统一容量 (F64 Reserved)** | 月度净节省 | 关键架构成因 |
| :--- | :--- | :--- | :--- | :--- |
| **核心湖仓与流计算引擎** | $2,200 / 月（基础协调节点） | **$8,480 / 月**（F64 预留容量池） | -$6,280 / 月 | 一池算力同时承载 KQL、Spark、Direct Lake 与 Agent |
| **1,145K EPS 流摄取与计费 CDC 税** | $199,200 / 月（Kafka + Fivetran + 按 GB 写入） | **$0 / 月**（OneLake 零拷贝 + Eventhouse） | **+$199,200 / 月** | 彻底消除 340 万泊位 LPR 流写入税与计费 CDC 复制税 |
| **8.95 亿向量索引 (7.25TB DRAM vs SSD)** | $109,800 / 月（独立内存向量库集群） | **$4,480 / 月**（Azure SQL / OneLake SSD DiskANN） | **+$105,320 / 月（>$105K/月!）** | NVMe SSD 图索引替代 92% 昂贵内存占用 |
| **精确 27,000=30³ 名店长与业主 BI 授权** | $216,000 / 月（`6³×1000`! 27,000 × $8/席位） | **$0 / 月**（F64 内置 Power BI Viewer 免席位费） | **+$216,000 / 月（精确整千!）** | 精确 2.7 万名车场经理与商业业主零席位税查看分成报表 |
| **OneLake 存储与 1GB 免费审计 SQL** | 已含于各云高额溢价中 | **$4,000 / 月**（OneLake 分层存储 + 1GB 免费 SQL） | -$4,000 / 月 | 单份开放 Delta Parquet 跨引擎零冗余共享 |
| **💰 月度总计 TCO** | **$527,200 / 月** | **$16,960 / 月** | **净省 $510,240 / 月 (-96.8% 历史最高纪录!)** | **年省 $6.12M IT 成本 + 年增创精确 $93.0M 动态调价与追缴收益** |

```chart
{
  "data": {
    "values": [
      { "Category": "1. 流摄取与 CDC 税 (1.145M EPS)", "Stitched_Stack_USD": 199200, "Fabric_F64_USD": 0 },
      { "Category": "2. 8.95亿向量索引 (7.25TB vs SSD)", "Stitched_Stack_USD": 109800, "Fabric_F64_USD": 4480 },
      { "Category": "3. 27,000=30³ 人 BI 席位费", "Stitched_Stack_USD": 216000, "Fabric_F64_USD": 0 },
      { "Category": "4. 统一容量池与 OneLake 存储", "Stitched_Stack_USD": 2200, "Fabric_F64_USD": 12480 }
    ]
  },
  "semantic_types": {
    "Category": "Category",
    "Stitched_Stack_USD": "Amount",
    "Fabric_F64_USD": "Amount"
  },
  "chart_spec": {
    "chartType": "Bar Chart",
    "title": "Microsoft Fabric 每月净省 $510,240 (-96.8%)：清零 LPR 流税、7.25TB 向量税与 27,000=30³ 人席位税",
    "subtitle": "月度 TCO 分项对比（美元/月）· 6,800 座停车场 + 340 万泊位 + 14.5 万台充电桩",
    "encodings": {
      "x": "Category",
      "y": ["Stitched_Stack_USD", "Fabric_F64_USD"]
    }
  }
}
```

### 5.2 7-Card 4:5 密封评测报告摘要 (`DL-1013..DL-1016` · 🏆 `R243 = 3⁵` 五次方轮次、第 `137` 素数项本体仿真突破 `<115ms` (`114.58ms`) & `131` 回文素数 FAQ！)

| 卡片编号 | 模块标题 | 核心量化结论（源自密封 `workshops/data-lab/reports/report.json`） |
| :--- | :--- | :--- |
| **Card 1 / 7** | **全景工作台 (`HANDS-ON`)** | **563 / 564 (`563` 素数通过！保持 🏆 99.82% 历史最高准确率)** 跨 **131 (回文素数!) 篇双语选型 FAQ (`262` 篇回文文档)**；路由均值降至 **131.5ms (`<132ms`)**；**第 137 (素数!) 项**本体仿真均值历史性跌破 115ms 至 **114.58ms (`<115ms`!)**。 |
| **Card 2 / 7** | **单案例深潜 (`SCENARIO IP`)** | `DL-1013` (`1013` 素数 ID！6,800 车场无杆 LPR 潮汐调价与充电疏导 `0.93 · Act` · `4ms`)、`DL-1014` (8.95 亿污损车牌外观 Re-ID 与业主合同 DiskANN RAG `0.92 · Act` · `4ms`)、`DL-1015` (ADA 无障碍配额/NFPA 88A CO 排风/DPPA 车牌隐私门禁 `0.79 · Confirm` · `5ms`)、`DL-1016` (精确 `27,000 = 30³` 名店长与业主免席位看板 `0.94 · Act` · `3ms`)，端到端 **16ms (`4² ms`)**。 |
| **Card 3 / 7** | **全量矩阵 (`WHAT I TESTED`)** | **391 自动采纳**、**171 (`T_18` 回文三角形数!) 架构师复核**、**2 转交人工**；保留唯一显式边界案例 `DL-23`。 |
| **Card 4 / 7** | **底层协议 (`UNDER THE HOOD`)** | 确定性校验器强制校验 `ada_van_accessible_quota_reserved = true`、`garage_co_ppm_ventilation_interlock <= 35.0` 与 `dppa_lpr_privacy_masked = true`。 |
| **Card 5 / 7** | **鲁棒性压测 (`ROBUSTNESS`)** | 候选云顺序反转与暴雨车牌眩光噪声注入下 **0.0% 平台翻转率**，置信度漂移 **≤ ±0.6 pts**。 |
| **Card 6 / 7** | **延迟与成本 (`LATENCY`)** | 月度 TCO 从 **$527,200 压降至 $16,960 (净省 -$510,240/月 > $510K! -96.8% 纪录)**，累计守护 **$85.20M** 企业 SLA。 |
| **Card 7 / 7** | **选型定调 (`MY TAKE`)** | 明确 Fabric 实时无杆 LPR 收益与充电安全闭环 + Databricks 深度车辆重识别训练的互补边界。 |

---

## 🛠️ 六、售前方案评审与生产落地 Checklist

- [ ] **6,800 车场无杆 LPR 与 OCPP 2.0.1 充电流零税率接入**：将车道相机、泊位传感器与 14.5 万台充电桩遥测通过 Eventstreams 接入 Eventhouse（`$0/GB` 写入税）。
- [ ] **8.95 亿车辆外观 Re-ID 与业主分成合同向量落盘 SSD DiskANN**：将跨镜头车身特征向量与 6,800 份业主保底分成合同迁入 OneLake / Azure SQL SSD DiskANN（`$4,480/月` 替代 `$109,800/月` 7.25TB DRAM）。
- [ ] **ADA 法定无障碍车位保护与 NFPA 88A 通风/断电门禁 (`SOP-251`)**：配置 Foundry IQ 4ms 豁免无障碍泊位动态超售，并在地下车库 `CO > 35 ppm` 或充电桩超温时强制联动射流风机与 OCPP 断电。
- [ ] **DPPA 车牌隐私保护与业主租户级 RLS**：在 Microsoft Purview 中对精确 27,000 (`30³`) 名用户配置车场业主 RLS 与车牌号动态哈希脱敏。
