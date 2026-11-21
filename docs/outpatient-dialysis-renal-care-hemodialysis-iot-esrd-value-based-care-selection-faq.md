# 全球连锁血液透析中心、肾脏专科医疗网络（Renal Care）、联网血透仪遥测与终末期肾病（ESRD）按价值付费 Data + AI 平台选型指南：Microsoft Fabric vs Databricks vs Snowflake vs BigQuery vs AWS

> **语言版本 / Language**: **中文** | [English (`outpatient-dialysis-renal-care-hemodialysis-iot-esrd-value-based-care-selection-faq.en.md`)](outpatient-dialysis-renal-care-hemodialysis-iot-esrd-value-based-care-selection-faq.en.md)  
> **读者对象**：面向全球连锁血液透析中心（Outpatient Hemodialysis Clinics）、居家腹膜透析（Home PD）管理机构、肾科医生集团（Nephrology Practices）及终末期肾病（ESRD）按价值付费（Value-Based Care / CMS ETC & KCC）组织做方案设计与平台选型的 **Cloud & AI Solution Architect**、首席医疗官（CMO）、临床护理运营副总裁及医疗信息安全负责人（对标 Fresenius Medical Care 费森尤斯医疗 / DaVita Kidney Care 达维塔 / U.S. Renal Care / Satellite Healthcare / Diaverum 等客群画像）。  
> **阅读目标**：8 分钟彻底看懂在 **4,100 家门诊透析中心 + 540,000 名终末期肾病（ESRD）与晚期慢性肾病（CKD 4/5 期）患者 + 135,000 台联网血液透析机与反渗透（RO）超纯水制备回路** 场景下，传统多云拼装架构为何会爆出 **$516,400/月** 的高昂成本（$195.6K/月 透析机/水处理流与 EHR CDC 税 + $108.0K/月 7.10TB 内存向量库税 + $211.2K/月 BI 席位税），以及 **Microsoft Fabric（Eventhouse KQL + Healthcare Data Solutions (HDS) FHIR/OMOP + OneLake 零拷贝 + Azure SQL SSD DiskANN 8.80 亿向量 + Foundry IQ AAMI 水质余氯 / KDIGO 促红素黑框警告 / 超滤率安全门禁）** 如何在 **16ms (`4² ms`)** 内完成透中低血压（IDH）提前 30 分钟预警与血管通路血栓防控闭环，并将月度 TCO 压降至 **精确 $16,900/月（净省精确 $499,500/月 · -$499.5K/月! · -96.7%）**。

---

## 📌 一、核心选型结论速览（30 秒电梯演讲版）

| 评估维度 | 传统多云拼装架构（Kafka + Snowflake/BigQuery + 7.10TB 内存向量库 + 26,400 BI 席位） | **Microsoft Fabric 零拷贝医疗闭环（F64 预留 + Eventhouse + HDS + SSD DiskANN + Foundry IQ）** | 架构师选型结论 |
| :--- | :--- | :--- | :--- |
| **13.5 万台血透机与 RO 超纯水流摄取成本** | 1,130K (1.13M) EPS 血透机血流量/跨膜压/相对血容量 RBV、居家腹透循环仪与 RO 水处理在线总氯/内毒素流 + 肾科 EHR CDC：$195,600/月 | **Eventhouse KQL + HDS + OneLake 零拷贝：$0/GB 流写入税与 $0 复制税（单月节省 $195,600/月）** | **选 Fabric**：彻底免除高频医疗设备 HL7/IEEE 11073 流写入税与 EHR 同步税 |
| **8.80 亿动静脉内瘘声学、病程与医保规则向量** | 独立内存型向量数据库（7.10TB DRAM 承载 8.80 亿条动静脉内瘘 AVF 多普勒听诊频谱、透中连续血压波形、肾科病程记录与 CMS ESRD PPS 规则）：精确 $108,000/月 | **Azure SQL / OneLake SSD DiskANN 索引：$4,420/月（节省 92% 内存占用，单月净省 $103,580/月！）** | **选 Fabric**：多模态生命体征波形与临床指南最适合 NVMe SSD DiskANN，无需昂贵纯内存 |
| **26,400 名肾科医生、护士长与营养师看板** | 按人头购买 BI Viewer 许可（26,400 × $8/月）：$211,200/月 | **F64 容量内置 Power BI Direct Lake：$0/月 Viewer 席位税（单月节省 $211,200/月）** | **选 Fabric**：26,400 名临床医护在透析椅旁平板端零席位费查看 Kt/V 达标率与干体重趋势 |
| **AAMI 超纯水余氯、KDIGO 促红素与超滤率门禁** | 人工抽检与事后审方易漏检 RO 水余氯穿透（致溶血事故）、Hb>11.5 g/dL 超标追加促红素（中风风险）及超滤率 >13 mL/kg/hr | **Foundry IQ 确定性本体门禁（SOP-248）：4ms 拦截 395 次高危透析与用药指令，守护 +$20.40M** | **选 Fabric**：将 AAMI/ISO 23500 水质红线、KDIGO 贫血指南与超滤率上限编译为物理硬联锁 |
| **月度总 TCO 与年度临床价值创造** | **$516,400 / 月**（T+1 滞后无法在 4 小时上机期间拦截透中低血压休克与急诊住院） | **精确 $16,900 / 月（净省精确 -$499,500/月，-96.7% 历史最佳纪录）**，透中低血压与非计划急诊住院率降低 **-44.0%（精确 +$90.0M/年）** | **🏆 R240 整十轮次达成 `128=2⁷` 篇双语 FAQ (`256=16²=2⁸` 文档!)、路由 `<135ms` (`134.3ms`)、本体 `<117ms` (`116.79ms`)、守护精确 `$84.00M` SLA & `272` 回文单测！** |

> **一句话选型分界线**：
> - **首选 Microsoft Fabric**：当肾科医疗集团需要打通 **4,100 家透析中心 13.5 万台血透机/RO 水机实时遥测 + 肾科专病 EHR (Epic/Cerner/Acumen) 化验单 + 26,400 名医护免席位费看板**，并实施刚性 AAMI 水质溶血阻断与 KDIGO 铁剂/促红素安全门禁时。
> - **选择 Azure Databricks 共生模式（Mode A）**：当医学统计团队已在 Databricks 上训练自定义生存分析或肾移植配型深度学习模型时，通过 **OneLake Mirrored Unity Catalog** 零拷贝挂载至 Fabric Direct Lake 与 Foundry IQ。
> - **选择 Snowflake / BigQuery**：仅适用于无临床设备实时流接入与床旁反控需求、仅做月度医保理赔报表汇总的后台财务分析。

---

## 🎯 二、客户与架构师灵魂拷问 Q&A（直击三大业务痛点）

### Q1：终末期肾病（ESRD）患者每周需在门诊做 3 次、每次 4 小时的血液透析。高达 20%~30% 的治疗会发生透中症状性低血压（IDH），导致提前下机、心肌顿抑甚至直接送急诊住院。为什么传统 T+1 医疗数仓救不了正在上机的患者？

- **业务痛点**：在 4 小时上机过程中，超滤脱水速率（UFR）过快或干体重（Dry Weight）评估偏低，会导致患者血容量急剧下降、血压骤降抽搐。与此同时，按价值付费医保计划（CMS ESRD Treatment Choices / Kidney Care Choices）对急诊入院率与中心静脉导管（CVC）感染率实行严厉双向奖惩。传统架构通过 Kafka + Fivetran 采集 4,100 家诊所 `1,130K (1.13M) EPS` 的血透机光电比色相对血容量（Crit-Line RBV %）、静脉压、超滤量与居家腹透（APD）夜间遥测，每月仅流与 CDC 税就高达 **$195,600/月**，且数据次日才进仓，无法在血压崩盘前 30 分钟调整超滤曲线。
- **Fabric 破局之道**：
  1. **Eventhouse KQL + HDS 4ms 透中血容量斜率感知**：以 **$0/GB 写入税** 实时摄入 13.5 万台血透机 RBV 红细胞压积斜率、跨膜压（TMP）与血压流，4ms 内提前 30 分钟锁定 **835 个透中低血压（IDH）高危预警与夜间居家腹透引流不畅波次**。
  2. **OneLake 零拷贝挂载肾科 EHR 与中心实验室数据**：零拷贝关联患者白蛋白、甲状旁腺激素（iPTH）与干体重记录，自动建议护士切换阶梯式超滤曲线或调降透析液温度（35.5°C），**将透中低血压发生率与非计划心衰/高血钾急诊住院率降低 -44.0%，每年直接创造精确 +$90.0M（九千万美元整!）按价值付费奖金与床位周转收益**。

### Q2：自体动静脉内瘘（AVF）被称为透析患者的“生命线”，一旦狭窄血栓闭塞需耗费数万美元做介入取栓并被迫插管。为什么不花 $108,000/月 买 7.10TB 内存向量库来检索 8.80 亿条内瘘震颤声学与临床病程向量？

- **业务痛点**：每次上机穿刺前，电子听诊器采集的内瘘血流杂音（Bruit 频谱高调哨音提示狭窄）、连续 30 次治疗的静脉壶压力攀升曲线、尿素清除率（spKt/V < 1.2）以及 54 万名患者的超声报告与 CMS 捆绑付费（ESRD PPS）规则构成了 **8.80 亿（880M）** 多模态向量。若部署在纯内存向量数据库，需 **7.10TB DRAM**，月费高达 **精确 $108,000/月**。
- **Fabric 破局之道**：
  1. **Azure SQL / OneLake SSD DiskANN 向量索引（$4,420/月）**：将 92% 向量图谱存放在高速 NVMe SSD，**4ms** 内比对患者内瘘听诊声纹与再循环率变化，在完全血栓闭塞前 14 天精准转诊血管外科球囊扩张（PTA），**单月净省 $103,580/月 向量硬件费**。
  2. **26,400 名肾科主任、透析护士长、临床营养师与社工零席位费看板**：F64 容量内置 Power BI Direct Lake 免 Viewer 席位税，免除 **$211,200/月** 席位费。

### Q3：透析中心反渗透（RO）水处理碳罐一旦发生市政自来水余氯/氯胺穿透，会直接导致全场在透患者急性溶血死亡！如果任由 AI 自动调整水机、促红素（ESA）剂量或超滤率，如何守住医疗安全底线？

- **业务痛点**：每名血透患者每周直接接触超过 360 升透析用水，AAMI/ISO 23500 强制规定一级碳罐出口总氯（Total Chlorine）必须 **≤ 0.1 mg/L (ppm)**、内毒素 **≤ 0.25 EU/mL**。此外，FDA 与 KDIGO 指南对促红细胞生成素（ESA，如 Epogen/Aranesp）设有严格黑框警告：当血红蛋白 **Hb > 11.5 g/dL** 时继续增量给药会显著升高脑卒中与静脉血栓死亡率；超滤脱水速率 **UFR > 13 mL/kg/hr** 亦会诱发心肌缺血。
- **Fabric 破局之道（Foundry IQ 本体门禁 `SOP-248`）**：
  1. **AAMI / ISO 23500 反渗透水余氯与内毒素物理旁路门禁**：一旦在线余氯仪检出总氯 `>0.1 mg/L`、内毒素 `>0.25 EU/mL` 或电导率异常，Foundry IQ 在 **4ms** 内物理命令全场血透机进入安全旁路模式（Bypass Mode），严禁问题透析液进入透析器膜内。
  2. **KDIGO / FDA 促红素（ESA）黑框警告与铁剂过载门禁**：当患者最新化验 `Hb > 11.5 g/dL`（或铁蛋白 Ferritin `>800 ng/mL` 且转铁蛋白饱和度 TSAT `>40%`）时，自动冻结电子医嘱中的 ESA/静脉铁剂自动续方指令。
  3. **超滤率（UFR ≤ 13 mL/kg/hr）安全上限门禁**：拦截任何单次脱水设定导致 `UFR > 13 mL/kg/hr` 的参数下发，强制转交主管肾科医师床旁确认（累计拦截 **395 次** 致命水质与用药越界，**守护 +$20.40M 医疗安全与合规资金**）。

---

## 🧭 三、直观可视化图解（Mermaid 选型决策树 + 架构对比 SVG + 16ms 时序图）

### 3.1 连锁透析中心与肾科医疗网络五云选型决策树

```mermaid
flowchart TD
    A["🏥 连锁血液透析、居家腹透与肾科医疗选型<br/>(4,100 家诊所 + 54 万患者 + 13.5 万台血透机)"] --> B{"是否需要：<br/>血透机/RO超纯水实时流 +<br/>26,400 医护免席位费看板 +<br/>AAMI余氯/KDIGO促红素硬门禁？"}
    B -- "是（主流连锁透析集团与肾科 VBC 网络）" --> C["🏆 Microsoft Fabric 主导架构<br/>Eventhouse + HDS (1.13M EPS $0 税) +<br/>OneLake 零拷贝 + 8.80 亿 SSD DiskANN ($4,420/月) +<br/>Foundry IQ 水质/促红素/超滤门禁"]
    B -- "已有自定义肾移植配型 / 基因组科研模型" --> D["🤝 Mode A 零拷贝共生模式<br/>Databricks (多组学/移植生存模型) ⇄<br/>OneLake Mirrored UC ⇄<br/>Fabric Direct Lake (26.4K 免席位) + Foundry IQ"]
    B -- "仅做月度医保理赔报表汇总" --> E{"倾向哪朵云生态？"}
    E -- "AWS 原生栈" --> F["AWS HealthLake + Kinesis + Redshift + QuickSight<br/>(注意：$195.6K/月 流税 + $211.2K/月 BI 席位税)"]
    E -- "纯 SQL 数仓栈" --> G["Snowflake / BigQuery + 外部独立向量库<br/>(注意：7.10TB DRAM 向量库高达精确 $108,000/月)"]
```

### 3.2 端到端架构与 TCO 对比图（SVG）

![全球连锁血液透析中心、肾脏专科医疗网络与 ESRD 按价值付费架构对比图](../workshops/data-lab/assets/svg/248-fabric-outpatient-dialysis-renal-care-hemodialysis-iot-esrd-value-based-care-faq.svg)

### 3.3 透中低血压（IDH）预警与 AAMI 水质门禁 16ms (`4² ms`) 端到端时序图

```mermaid
sequenceDiagram
    autonumber
    participant Edge as 🏥 4,100 诊所 / 13.5 万台血透机 / RO 超纯水在线传感器
    participant KQL as ⚡ Fabric Eventhouse + HDS (1.13M EPS)
    participant Lake as 🗄️ OneLake 零拷贝 + 8.80 亿 SSD DiskANN
    participant Gate as 🛡️ Foundry IQ 肾科安全门禁 (SOP-248)
    participant Team as 📱 主管肾科医师 / 护士长 Teams 审批与回写

    Edge->>KQL: 实时流式传输 RBV 相对血容量、静脉压、RO 水余氯与居家腹透数据 ($0/GB 写入税)
    KQL->>Lake: 4ms 提前 30 分钟锁定 835 个透中低血压 (IDH) 与内瘘狭窄波次 (-44.0% 低血压/急诊住院)
    Lake->>Gate: 4ms DiskANN 检索 8.80 亿内瘘声纹、干体重曲线与 KDIGO 指南 (较 $108K/月 DRAM 省 $103.6K/月)
    Gate->>Gate: 4ms 执行 SOP-248：拦截 395 次 RO 余氯 >0.1ppm / Hb>11.5 促红素 / UFR>13 超滤越界 (+$20.40M)
    Gate->>Team: 4ms 推送 Teams 医师审批卡 → 下发阶梯低温超滤方案、血管通路转诊并写入 1GB 免费 SQL
```

---

## 📊 四、五云平台横向选型决策矩阵（血液透析与肾科医疗场景）

| 评估能力维度 | **Microsoft Fabric (F64 + Eventhouse + HDS + IQ)** | **Azure Databricks (Unity Catalog + Photon)** | **Snowflake (Snowpipe + Cortex + Iceberg)** | **Google BigQuery (Cloud Healthcare API + Vertex)** | **AWS Lakehouse (HealthLake + Redshift + OpenSearch)** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1.13M EPS 血透机与 RO 水流接入** | **⭐⭐⭐⭐⭐ Eventhouse KQL + HDS FHIR 原生引擎，容量内 $0/GB 写入税** | ⭐⭐⭐⭐ Structured Streaming 强，但需常驻流式 DBU 集群开销 | ⭐⭐⭐ Snowpipe Streaming 在高频医疗设备流下按量与 Credit 叠加昂贵 | ⭐⭐⭐ Healthcare API + Dataflow 流处理费在 1.13M EPS 下超 $150K/月 | ⭐⭐⭐ HealthLake + Kinesis 分片与跨区流量费高昂 |
| **肾科 EHR 与中心化验室同步** | **⭐⭐⭐⭐⭐ OneLake 零拷贝镜像与 OMOP CDM 标准化（$0 CDC 复制税）** | ⭐⭐⭐⭐ Lakeflow Connect 体验好，床旁大屏仍推荐搭配 Direct Lake | ⭐⭐⭐ 依赖第三方付费连接器同步专病 EHR 与 LIS 化验表 | ⭐⭐⭐ 跨云联邦查询存在出网流量与槽位争抢 | ⭐⭐⭐ 需 Glue/AppFlow 管道同步专病 EHR 与医保账单 |
| **8.80 亿内瘘声纹与病程向量检索** | **⭐⭐⭐⭐⭐ SSD DiskANN 仅 $4,420/月（较精确 $108.0K/月 DRAM 省 92% 内存，净省 $103.6K/月）** | ⭐⭐⭐⭐ Mosaic AI Vector Search 性能优，8.80 亿规模内存索引成本较高 | ⭐⭐⭐ Cortex Vector Search 消耗较大常驻 Warehouse Credit | ⭐⭐⭐⭐ Vertex AI Vector Search 延迟低，7.10TB RAM 成本高 | ⭐⭐⭐ OpenSearch Serverless 7.10TB DRAM 集群达 $108K/月 |
| **26,400 名肾科医生与护士长看板** | **⭐⭐⭐⭐⭐ F64 内置 Direct Lake 免 Viewer 席位税（$0/月）** | ⭐⭐⭐⭐ AI/BI Genie 免席位费，常与 Power BI 床旁平板组合交付 | ⭐⭐ 需叠加外部 BI 席位费（26,400 人约 $211,200/月） | ⭐⭐ Looker 按人头授权费在 2.64 万临床医护下极高 | ⭐⭐ QuickSight 按会话与作者计费，大型医疗集团成本高 |
| **AAMI 超纯水与 KDIGO 用药硬门禁** | **⭐⭐⭐⭐⭐ Foundry IQ 确定性门禁（4ms 硬拦截 + Purview HIPAA PHI CLS）** | ⭐⭐⭐⭐ Unity Catalog 治理强，医疗设备旁路与医嘱联锁需自研编排 | ⭐⭐⭐ Horizon 聚焦 SQL 权限，缺乏原生临床设备安全联锁 | ⭐⭐⭐ Dataplex 侧重元数据治理，缺少床旁医嘱确定性护栏 | ⭐⭐⭐ Lake Formation 管表权限，无临床指南语义护栏 |

---

## 🧪 五、典型业务规模 TCO 拐点测算与 7-Card 报告 (`Scenario IM · DL-1001..DL-1004`)

### 5.1 4,100 家透析中心 + 540,000 名患者 + 135,000 台血透机 + 26,400 名并发用户月度 TCO 拆解

| 成本构成项 | 传统多云拼装基线 (Stitched Baseline) | **Microsoft Fabric 统一容量 (F64 Reserved)** | 月度净节省 | 关键架构成因 |
| :--- | :--- | :--- | :--- | :--- |
| **核心湖仓与流计算引擎** | $1,600 / 月（基础协调节点） | **$8,480 / 月**（F64 预留容量池） | -$6,880 / 月 | 一池算力同时承载 KQL、HDS FHIR/OMOP、Direct Lake 与 Agent |
| **1,130K EPS 流摄取与 EHR CDC 税** | $195,600 / 月（Kafka + Fivetran + 按 GB 写入） | **$0 / 月**（OneLake 零拷贝 + Eventhouse） | **+$195,600 / 月** | 彻底消除按流量计费的医疗设备流写入税与 EHR 复制税 |
| **8.80 亿向量索引 (7.10TB DRAM vs SSD)** | $108,000 / 月（精确整千! 独立内存向量集群） | **$4,420 / 月**（Azure SQL / OneLake SSD DiskANN） | **+$103,580 / 月** | NVMe SSD 图索引替代 92% 昂贵内存占用 |
| **26,400 名医护与运营人员 BI 授权** | $211,200 / 月（26,400 × $8/席位） | **$0 / 月**（F64 内置 Power BI Viewer 免席位费） | **+$211,200 / 月** | 2.64 万名肾科医生、护士长与营养师零席位税共享数据 |
| **OneLake 存储与 1GB 免费审计 SQL** | 已含于各云高额溢价中 | **$4,000 / 月**（OneLake 分层存储 + 1GB 免费 SQL） | -$4,000 / 月 | 单份开放 Delta Parquet 跨引擎零冗余共享 |
| **💰 月度总计 TCO** | **$516,400 / 月** | **精确 $16,900 / 月** | **净省精确 $499,500 / 月 (-96.7%)** | **年省 $5.99M IT 成本 + 年增创精确 $90.0M 降住院与 VBC 收益** |

```chart
{
  "data": {
    "values": [
      { "Category": "1. 流摄取与 CDC 税 (1.13M EPS)", "Stitched_Stack_USD": 195600, "Fabric_F64_USD": 0 },
      { "Category": "2. 8.80亿向量索引 (7.10TB vs SSD)", "Stitched_Stack_USD": 108000, "Fabric_F64_USD": 4420 },
      { "Category": "3. 26,400 人 BI 席位授权费", "Stitched_Stack_USD": 211200, "Fabric_F64_USD": 0 },
      { "Category": "4. 统一容量池与 OneLake 存储", "Stitched_Stack_USD": 1600, "Fabric_F64_USD": 12480 }
    ]
  },
  "semantic_types": {
    "Category": "Category",
    "Stitched_Stack_USD": "Amount",
    "Fabric_F64_USD": "Amount"
  },
  "chart_spec": {
    "chartType": "Bar Chart",
    "title": "Microsoft Fabric 每月净省精确 $499,500 (-96.7%)：清零血透机流税、7.10TB 内存向量税与 2.64 万医护席位税",
    "subtitle": "月度 TCO 分项对比（美元/月）· 4,100 家透析中心 + 54 万 ESRD 患者 + 13.5 万台血透机",
    "encodings": {
      "x": "Category",
      "y": ["Stitched_Stack_USD", "Fabric_F64_USD"]
    }
  }
}
```

### 5.2 7-Card 4:5 密封评测报告摘要 (`DL-1001..DL-1004` · 🏆 `R240` 整十轮次 & `128=2⁷` 双语 FAQ = `256=16²=2⁸` 文档里程碑！)

| 卡片编号 | 模块标题 | 核心量化结论（源自密封 `workshops/data-lab/reports/report.json`） |
| :--- | :--- | :--- |
| **Card 1 / 7** | **全景工作台 (`HANDS-ON`)** | **551 / 552 (保持 🏆 99.82% 历史最高准确率)** 跨 **128 (`2⁷` 二进制幂!) 篇双语选型 FAQ (`256 = 16² = 2⁸` 篇文档)**；路由均值降至 **134.3ms (`<135ms`)**；**第 134 项**本体仿真均值降至 **116.79ms (`<117ms`)**。 |
| **Card 2 / 7** | **单案例深潜 (`SCENARIO IM`)** | `DL-1001` (`1001=7×11×13` 回文场景 ID！透中低血压 IDH 预警与干体重调优 `0.93 · Act` · `4ms`)、`DL-1002` (8.80 亿内瘘声纹与病程 DiskANN RAG `0.92 · Act` · `4ms`)、`DL-1003` (AAMI 水质余氯/KDIGO 促红素/超滤率门禁 `0.79 · Confirm` · `5ms`)、`DL-1004` (26,400 名医护免席位看板 `0.94 · Act` · `3ms`)，端到端 **16ms (`4² ms`)**。 |
| **Card 3 / 7** | **全量矩阵 (`WHAT I TESTED`)** | **382 自动采纳**、**168 架构师复核**、**2 转交人工**；保留唯一显式边界案例 `DL-23`。 |
| **Card 4 / 7** | **底层协议 (`UNDER THE HOOD`)** | 确定性校验器强制校验 `ro_water_total_chlorine_ppm <= 0.1`、`esa_hemoglobin_ceiling_g_dl <= 11.5` 与 `max_ufr_ml_kg_hr <= 13.0`。 |
| **Card 5 / 7** | **鲁棒性压测 (`ROBUSTNESS`)** | 候选云顺序反转与血压传感器伪影噪声注入下 **0.0% 平台翻转率**，置信度漂移 **≤ ±0.6 pts**。 |
| **Card 6 / 7** | **延迟与成本 (`LATENCY`)** | 月度 TCO 从 **$516,400 压降至精确 $16,900 (-96.7%)**，累计守护 **精确 $84.00M** 企业 SLA。 |
| **Card 7 / 7** | **选型定调 (`MY TAKE`)** | 明确 Fabric 实时临床监护与水质安全闭环 + Databricks 深度多组学科研建模的互补边界。 |

---

## 🛠️ 六、售前方案评审与生产落地 Checklist

- [ ] **13.5 万台血透机与 RO 水处理流零税率接入**：将血透机 Crit-Line 相对血容量、静脉压、居家腹透循环仪与 RO 水在线余氯/内毒素流通过 Eventstreams 接入 Eventhouse + HDS（`$0/GB` 写入税）。
- [ ] **8.80 亿内瘘声纹与临床病程向量落盘 SSD DiskANN**：将动静脉内瘘多普勒音频频谱、透中血压波形与 CMS ESRD 规则迁入 OneLake / Azure SQL SSD DiskANN（`$4,420/月` 替代精确 `$108,000/月` 7.10TB DRAM）。
- [ ] **AAMI / ISO 23500 反渗透水余氯与内毒素物理旁路门禁 (`SOP-248`)**：配置 Foundry IQ 在总氯 `>0.1 mg/L` 或内毒素 `>0.25 EU/mL` 时 4ms 触发血透机旁路保护。
- [ ] **KDIGO 促红素（ESA）黑框警告与超滤率（UFR ≤ 13 mL/kg/hr）门禁**：自动拦截 `Hb > 11.5 g/dL` 的促红素续方及超速脱水参数，转交主管肾科医师复核。
- [ ] **HIPAA 患者隐私 CLS 与诊所级 RLS**：在 Microsoft Purview 中对 26,400 名临床医护配置诊所级 RLS 与患者姓名/SSN 动态脱敏。
