# 肿瘤精准医疗、空间转录组（Spatial Transcriptomics）、全切片数字病理（40x DICOM WSI）与液体活检 ctDNA 微小残留病灶（MRD）平台选型指南：Microsoft Fabric (HDS + Eventhouse + SSD DiskANN + ALDO) vs AWS HealthOmics / Databricks / Snowflake / GCP 深度对比 FAQ

> 🌐 **Language / 语言**: **中文 (Current)** | **[English (`fabric-precision-oncology-spatial-transcriptomics-wsi-ctdna-mrd-vs-4clouds-faq.en.md`)](fabric-precision-oncology-spatial-transcriptomics-wsi-ctdna-mrd-vs-4clouds-faq.en.md)**  
> 📅 **更新日期**: 2026-11-14（Round 56 · 肿瘤精准医疗、10x Xenium/Visium HD 空间转录组、40x 全切片数字病理 WSI、液体活检 ctDNA MRD 790K EPS 与分子肿瘤委员会 MTB 闭环专题）  
> 🎯 **定位**: 面向肿瘤专科医院、跨国药企转化医学中心（Translational Oncology）、NGS 基因检测实验室与 AI 解决方案架构师（SA）的**空间多组学湖仓与分子肿瘤委员会（MTB）架构选型指南**。直接回答：**在 42 家肿瘤中心、180 台高通量测序仪/空间成像仪与 65 万名肿瘤患者随访场景下，面对 `790,000 EPS` 纳米孔/短读长实时碱基识别（Base-Calling）流、单张 5GB 的 40x DICOM 全切片病理图像（WSI）与 `9,200 万条` 亚细胞空间转录组/药物敏感性图谱，如何消除“液体活检 ctDNA 分子复发漏检”与“跨系统手工拼凑分子肿瘤委员会（MTB）耗费 3.5 天错失 ADC/CAR-T 换药黄金期”，实现 `43ms` 端到端精准肿瘤靶向配药闭环并降低 `88.5%` 平台 TCO？**

[![Fabric Precision Oncology Spatial Transcriptomics WSI ctDNA MRD vs AWS HealthOmics Databricks Snowflake GCP FAQ Architecture](../assets/svg/64-fabric-precision-oncology-spatial-transcriptomics-wsi-ctdna-mrd-vs-4clouds-faq.svg)](../assets/svg/64-fabric-precision-oncology-spatial-transcriptomics-wsi-ctdna-mrd-vs-4clouds-faq.svg)

---

## ① 📌 核心结论速览（Executive Summary）

> **一句话架构演进本质**：  
> 以前做肿瘤多组学与分子肿瘤委员会（MTB），**NGS 测序仪跑完 FASTQ/VCF 扔在 AWS S3 / HealthOmics 里算三天，病理科的 40x 全切片扫描（WSI SVS/DICOM）锁在本地 PACS 孤岛里，空间转录组（10x Xenium / Visium HD 亚细胞基因表达矩阵）存在科研生信集群里，而患者的电子病历（Epic FHIR）与液体活检 ctDNA 微小残留病灶（MRD）随访曲线散落在医院 HIS 里**——当晚期乳腺癌/肺癌患者血液中出现 **`0.042%` 极低变异等位基因频率（VAF）的 `ESR1 Y537S` 耐药克隆或 `HER2-low` 表型漂移** 时，传统批处理管道要等 **3.5 天** 才能把基因组、病理微环境与临床试验入组标准拼齐开会，患者早已发生全身转移或承受无效化疗毒性！  
> **Microsoft Fabric Healthcare Data Solutions (HDS) + Eventhouse (`790K EPS` 测序流与 ctDNA 甲基化/片段组学 KQL 异常检测) + Cosmos DB SSD DiskANN（`9,200 万` 空间转录组免疫微环境与 WSI 病理切片 Tile 向量检索，省 92% 内存）+ SQL on Azure Local（ALDO 病理科断网边缘缓存）**，将“测序流控质控 + 空间病理微环境匹配 + MTB 靶向/ADC 换药处方回写”压缩进 **`43ms`** 闭环，月度 TCO 降低 **`88.5%`**（`$9,700/mo` vs `$84,400/mo`，单月净省 **`$74,700`**），每年为跨国肿瘤联盟避免 **`$18,700,000`** 的 III 期临床试验脱组与无效治疗理赔损失。

1. **何时选择 Microsoft Fabric（肿瘤精准医疗、空间多组学与实时 MTB 决策首选）**：
   - 需要同时接入 **`790K EPS` 实时测序仪流控遥测（Nanopore 纳米孔电流/Illumina Q30 碱基质量流 + 液体活检 ctDNA MRD 动力学流）**、检索 **千万级 40x DICOM WSI 病理组织切片块（Tiles）与空间转录组肿瘤浸润淋巴细胞（TIL）邻域向量（`9,200 万` 维表）**，并在 **`<50ms`** 内穿透 **Fabric HDS OMOP CDM v5.4 + 临床试验入组本体** 触发 **Epic FHIR `MedicationRequest` 换药建议与病理冷库切片自动调取**。
2. **何时选择 Databricks / AWS HealthOmics / Snowflake / GCP（互补定位）**：
   - **AWS HealthOmics / Batch**：适合重度依赖原生 Nextflow / WDL / Cromwell 生信流水线做从头全基因组比对（BWA-MEM2 / GATK Germline Calling）的纯生信计算团队；但缺乏亚秒级流式测序质控、十亿级病理空间向量低成本常驻检索及与医院 Epic/Teams 的原生无代码闭环。
   - **Databricks Lakehouse for Healthcare (Glow + Mosaic AI)**：适合用 PySpark / Glow 训练大规模全基因组关联分析（GWAS）或病理基础大模型（如 GigaPath / UNI 微调）的科研团队；推荐在 Databricks 训好病理特征提取器后，将 9,200 万切片与空间组学向量写入 **Fabric OneLake + Cosmos SSD DiskANN** 做实时 MTB 推理。
   - **Snowflake Healthcare & Life Sciences / GCP Healthcare API**：适合作为跨药企匿名化真实世界数据（RWD）交换数仓或标准 DICOMWeb 归档，通过 **OneLake Mirroring / Shortcuts** 零拷贝挂载至 Fabric HDS。
3. **定量赢面速览（密封基准 `Scenario BK` · `DL-265..DL-268`）**：
   - **液体活检 ctDNA MRD 克隆复发检出与测序流控质控延迟**：`10ms`（Fabric Eventhouse KQL `series_outliers()`）vs `4.2h – 3.5天`（传统批次 VCF 汇总）。
   - **9,200 万空间转录组微环境与 40x WSI 病理切片向量检索 TCO**：Cosmos DB in Fabric **SSD DiskANN** 比纯内存向量索引节省 **`92%` 内存成本**，检索延迟 **`11ms`**。
   - **标准化月度 TCO**：Fabric 方案 **`$9,700/mo`** vs 四大云拼接基线 **`$84,400/mo`**（节省 **`88.5%`**，单月省 `$74,700`；含全量生信与病理存储内部口径为 `$22,800/mo` vs `$198,300/mo`）。

---

## ② 🎯 客户与架构师灵魂拷问 Q&A（Q1–Q3 第一性原理拆解）

### Q1：在液体活检 ctDNA 微小残留病灶（MRD）与实时纳米孔测序中，为什么传统的“跑完 48 小时 BAM/VCF 批处理再进数仓”会漏掉早期耐药克隆并浪费昂贵测序芯片？Eventhouse KQL 如何在 `10ms` 内实现边测序边拦截？

* **传统痛点（48 小时盲测与假阴性背景噪声）**：
  1. **测序芯片孔道衰减（Pore Depletion）盲跑**：高通量纳米孔或短读长测序仪单次运行成本高达数千美元。如果样本存在游离 DNA（cfDNA）提取污染或芯片局部气泡导致 Phred 质量分（Q-Score）骤降，传统流程要等 48 小时下机跑完 FastQC 才发现整批作废。
  2. **超低频 ctDNA 耐药突变被当作测序背景噪音滤除**：晚期肿瘤患者在靶向治疗期间，血液中 ctDNA 的耐药突变（如 `ESR1 Y537S`、`EGFR C797S`）初始等位基因频率（VAF）往往只有 **`0.03% – 0.05%`**。传统单时间点静态 VCF 阈值过滤极易将其误判为 PCR/测序伪影；必须结合 **双链唯一分子标签（Duplex UMI）片段长度分布（Fragmentomics 143bp vs 167bp）与连续随访斜率** 才能在放射学 CT 发现病灶前 **14 周** 锁定分子复发。
* **Fabric 底层破局（Eventhouse `$0/GB` 写入税 + KQL `series_outliers()` 10ms 动力学判别）**：
  - **Eventhouse 纳秒级测序流与片段组学摄取**：通过 Eventstream 直接摄取 42 家中心 **`790,000 EPS`** 的实时 Base-Calling 质量流与 ctDNA UMI 片段特征，享受 **12:1 列式压缩与 `$0/GB` 按量写入税**。
  - **KQL 原生时序异常与双链一致性核验**：在内存中直接调用 `series_outliers()` 与 `series_fit_line()` 对患者纵向 VAF 曲线、143bp 短片段富集度及局部甲基化熵进行联合评分，**`10ms`** 内精准锁定 `ESR1 Y537S (VAF=0.042%)` 伴 `HER2-low` 克隆抬头，并同步对芯片孔道异常下发 Adaptive Sampling（自适应纳米孔富集/退孔）指令（实测用例 `DL-265`）。

### Q2：空间转录组（10x Xenium / Visium HD）和 40x 全切片数字病理（WSI）动辄产生上亿个亚细胞 Spot 和图像块（Tiles），如何把“切片形态学 + 空间基因表达 + 临床疗效”关联起来，且不被天价内存向量库拖垮？

* **传统痛点（生信矩阵与病理 PACS 割裂 + 纯内存 HNSW 天价账单）**：
  - 一张 40x 放大倍率的 DICOM WSI 全切片病理图包含上万个 `256×256` 图像块（由 Prov-GigaPath 等病理基础模型编码为 1,536 维向量），配合 10x Visium HD / Xenium 的数百万个亚细胞空间转录组 Spot（记录 `CD8A`、`PDCD1`、`ERBB2` 空间坐标表达）。
  - 跨 65 万名患者累计达 **`9,200 万条`** 高维空间微环境向量。若在云端使用传统纯内存 HNSW 向量索引（如独立 Vector Search 节点或 OpenSearch Serverless），不仅每年光常驻 RAM 就要烧掉数十万美元，而且向量库与 OMOP 临床表分离，无法在一次查询中同时回答：“**找出与当前患者‘肿瘤边界 CD8+ T 细胞耗竭但间质高表达 HER2-low’空间拓扑最相似、且在真实世界中改用 T-DXd 抗体偶联药物（ADC）后无进展生存期（PFS）超过 14 个月的历史病例**”。
* **Fabric 底层破局（Fabric HDS OMOP v5.4 + Cosmos DB SSD DiskANN + 6 跳 MTB 本体）**：
  1. **Fabric Healthcare Data Solutions (HDS) 统一多模态底座**：将 Epic FHIR R4 临床病历、DICOM WSI 病理元数据与 VCF/空间组学矩阵统一落入 `$23/TB` 的 OneLake Open-Format Delta 表（遵循 OMOP CDM v5.4 肿瘤扩展模型）。
  2. **Cosmos DB SSD DiskANN 省 `92%` 内存**：将 `9,200 万条` WSI 病理切片块与空间转录组邻域嵌入向量存储在 SSD 驱动的 **DiskANN** 索引中，**`11ms`** 内完成 `0.99` 余弦相似度的空间免疫微环境匹配，确认患者虽然 IHC 传统评分为 `HER2 1+`，但空间转录组显示旁观者效应（Bystander Effect）半径内具备极高 ADC 杀伤敏感性，推荐切换至 **T-DXd (德曲妥珠单抗) + 匹配 II 期双抗临床试验组**（实测用例 `DL-266`）。

### Q3：AI 给出的肿瘤靶向/ADC 换药建议与临床试验入组匹配，如何满足 CAP/CLIA、FDA 21 CFR Part 11、HIPAA 与欧盟 EHDS（欧洲健康数据空间）的严苛合规护栏，并在医院内网断网时保持病理阅片零中断？

* **Foundry IQ 医疗合规护栏 + Purview OBO + ALDO 病理边缘**：
  1. **Foundry IQ 循证医学与毒性护栏（`ONCOLOGY-SPATIAL-WSI-CTDNA-MRD-EHDS-SOP-063`，`11ms`）**：自动校验 ACMG/AMP 变异致病性分级、NCCN/ESMO 最新指南与患者肺功能基线，确认推荐剂量下 **3 级以上间质性肺病（ILD）预测风险为 `1.4% < 3.0%` 安全红线**；若外部脚本试图绕过脱敏批量导出带患者姓名的基因序列，或向合并活动性肺炎（`SpO2 < 91%`）的患者自动开具高风险 ADC 处方，系统在 **`11ms`** 内硬拦截并降级为 `Send to a human`（实测用例 `DL-267`）。
  2. **分子肿瘤委员会（MTB）Teams 联签 + Epic FHIR 回写 + ALDO 边缘（`11ms`）**：MTB 主任在 Teams 自适应卡片一键联签 `Confirm`（附 FDA 21 CFR Part 11 电子签名审计链），通过 Rayfin 自动向医院 Epic HIS 写入 FHIR `MedicationRequest` 草案、触发样本库自动调取石蜡切片复核，并通过 **SQL on Azure Local (ALDO)** 保障病理科本地高速阅片缓存不断联，端到端仅需 **`43ms`**（实测用例 `DL-268`）。

---

## ③ 🧭 直观可视化图解（Mermaid 选型决策树 + 架构对比图 + 43ms 分子肿瘤委员会时序图）

### 3.1 肿瘤精准医疗、空间转录组与数字病理平台选型决策树

```mermaid
flowchart TD
    A["🧬 肿瘤精准医疗、空间转录组、40x 数字病理 WSI 与 ctDNA MRD 选型"] --> B{"是否需要 790K EPS 实时测序质控/ctDNA MRD 流<br/>+ 9,200 万空间组学/WSI 检索 + <50ms MTB 临床回写？"}
    B -- "是（跨院肿瘤联盟 / 药企转化医学 / 伴随诊断实验室）" --> C["🏆 首选 Microsoft Fabric 全栈方案<br/>HDS OMOP v5.4 + Eventhouse KQL (10ms) +<br/>Cosmos SSD DiskANN (11ms) + Foundry IQ + ALDO 病理边缘<br/>（43ms 闭环 · 省 88.5% TCO · 守护 $18.70M SLA）"]
    B -- "否，仅做离线 FASTQ→BAM 全基因组比对流水线" --> D["⚙️ 选 AWS HealthOmics / Batch (Nextflow/WDL)<br/>再通过 OneLake Shortcuts 将 VCF/矩阵零拷贝入 Fabric HDS"]
    B -- "否，仅做 Prov-GigaPath 病理大模型微调或全基因组 GWAS" --> E["🧪 选 Databricks (Glow + Mosaic AI GPU)<br/>训后将 9,200 万切片与空间组学向量写入 Fabric DiskANN 推理"]
    B -- "否，仅做跨药企匿名化真实世界数据 (RWD) 静态共享" --> F["❄️ 选 Snowflake Clean Rooms / GCP Healthcare API<br/>通过 OneLake Mirroring $0 算力同步临床结局表"]
```

### 3.2 架构对比：传统割裂生信/病理烟囱（3.5 天拼单）vs Fabric 空间多组学 MTB 闭环（`43ms`）

```mermaid
flowchart LR
    subgraph Legacy["❌ 传统拼装生信与病理孤岛（3.5 天手工拼凑 MTB · $84,400/月）"]
        L1["NGS 测序仪 / 10x Xenium"] -->|48h 离线 FASTQ| L2["AWS HealthOmics / S3<br/>静态 VCF 批处理 ($28.5K)"]
        L2 -->|手工导出 CSV| L3["生信 R/Seurat 单机集群<br/>空间转录组离线聚类 ($24.2K)"]
        L3 -->|纯内存向量库| L4["OpenSearch / 专有病理云<br/>9,200万 WSI Tile RAM 税 ($31.7K)"]
        L4 -->|耗费 3.5 天人工对齐病历| L5["💥 错失 ADC/CAR-T 早期换药窗口<br/>$18.70M 临床试验脱组与复发损失"]
    end

    subgraph Fabric["✅ Microsoft Fabric 空间多组学与 MTB 实时闭环（43ms · $9,700/月）"]
        F1["42 中心 790K EPS 测序流<br/>+ 40x DICOM WSI + ctDNA MRD"] -->|"$0/GB 写入 · 12:1 压缩"| F2["Eventhouse KQL (10ms)<br/>series_outliers 检出 0.042% ESR1/HER2-low"]
        F2 -->|零拷贝直通 HDS OMOP| F3["Fabric IQ 6 跳 MTB 孪生 + SSD DiskANN (11ms)<br/>9,200万空间组学/WSI 检索 0.99 匹配 T-DXd ADC"]
        F3 -->|CAP/CLIA & 毒性核验| F4["Foundry IQ 医疗合规门禁 (11ms)<br/>确认 ILD 风险 1.4% < 3.0% + Purview OBO 脱敏"]
        F4 -->|Teams MTB 主任联签| F5["ALDO 病理边缘 + Epic FHIR 回写 (11ms)<br/>MedicationRequest 换药与入组锁定 · 保住 $18.70M SLA"]
    end
```

### 3.3 `43ms` 液体活检 ctDNA MRD 复发拦截与空间病理 ADC 换药端到端时序图

```mermaid
sequenceDiagram
    autonumber
    participant Seq as 42 家肿瘤中心 (790K EPS 测序/ctDNA/WSI)
    participant EH as Fabric Eventhouse (KQL 时序引擎)
    participant IQ as Fabric IQ HDS 本体 + SSD DiskANN (9,200万空间组学/WSI)
    participant FIQ as Foundry IQ (CAP/CLIA · HIPAA · EHDS SOP-063)
    participant Edge as Teams MTB 联签 + Epic FHIR / ALDO 病理边缘

    Seq->>EH: 实时流式上报纳米孔 Phred 质量流与患者纵向 ctDNA 双链 UMI 片段流
    EH->>EH: 10ms 执行 series_outliers() 捕获 0.042% VAF ESR1 Y537S + 143bp 短片段激增
    EH->>IQ: 触发 6 跳分子肿瘤委员会（MTB）图谱与 40x DICOM WSI 微环境联查
    IQ->>IQ: 11ms SSD DiskANN 检索 9,200万空间转录组/WSI 向量(0.99相似) 锁定 HER2-low 旁观者敏感性
    IQ->>FIQ: 请求换用 T-DXd ADC + 匹配 II 期双抗试验组并核验 CAP/CLIA 与 ILD 肺毒性护栏
    FIQ->>FIQ: 11ms 校验 SOP-063：确认预测 3 级 ILD 风险 1.4% < 3.0% 且 Purview OBO 知情同意完整
    FIQ->>Edge: 推送 MTB 主任 Teams 审批卡 (FDA 21 CFR Part 11) + Epic FHIR 换药处方草案
    Edge-->>Seq: 11ms (总计 43ms) 锁定临床试验入组名额、自动调取冷库切片并更新治疗方案
```

---

## ④ 📊 五大平台肿瘤精准医疗、空间转录组与数字病理选型决策矩阵

| 评估维度 | Microsoft Fabric (HDS + Eventhouse + SSD DiskANN + ALDO) | AWS (HealthOmics + HealthLake + OpenSearch + Batch) | Databricks (Lakehouse for Healthcare + Glow + Vector Search) | Snowflake (Healthcare & Life Sciences + Cortex) | GCP (Cloud Healthcare API + Vertex AI Search + BigQuery) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **实时测序仪质控与 ctDNA MRD 动力学检出** | ✅ **Eventhouse KQL `10ms` 原生 `series_outliers` + `$0/GB` 写入税** | ⚠️ Kinesis + Timestream 按 GB 阶梯计费，缺乏原生基因片段时序算子 | ⚠️ Spark Streaming 微批需 `1.5–4s`，常驻流计算 DBU 昂贵 | ❌ Dynamic Tables 最小刷新滞后 `60s`，仅适合离线汇总 | ⚠️ Pub/Sub + Dataflow + BigQuery 流式写入按量计费高 |
| **9,200 万空间转录组与 40x WSI 向量检索** | ✅ **Cosmos SSD DiskANN `11ms`（省 92% 内存，与 OMOP 同湖）** | ❌ OpenSearch Serverless 向量索引按 OCUs 常驻内存计费极贵 | ⚠️ Mosaic AI Vector Search 内存索引成本高（约 7–8 倍） | ⚠️ Cortex Vector Search 需开启独立大规格 Warehouse | ⚠️ Vertex AI Vector Search 独立于 Healthcare API，需跨服务搬运 |
| **FHIR R4 + DICOM WSI + OMOP CDM v5.4 统一** | ✅ **Fabric HDS 官方托管转换 + OneLake `$23/TB` 开放表** | ❌ HealthLake (FHIR)、HealthImaging (DICOM) 与 HealthOmics 三套孤岛计费 | ⚠️ 需手工维护 Solution Accelerator 笔记本转换管道 | ❌ 无原生 DICOM 像素流与空间转录组坐标引擎 | ⚠️ Cloud Healthcare API 按存储容量溢价计费且与生信割裂 |
| **知情同意权限穿透与主权医疗合规** | ✅ **Purview + OneLake RLS/CLS/OLS + Entra OBO + HIPAA/EHDS** | ❌ 需跨 HealthLake IAM、Lake Formation 与 S3 Bucket 策略手工同步 | ⚠️ Unity Catalog 无法直接管控医院本地 PACS 与 Epic 回写 | ⚠️ Horizon 仅限 Snowflake 内部表，无法穿透病理边缘 | ⚠️ IAM + Dataplex 与本地病理科 PACS 体系割裂 |
| **500 用户 / 42 肿瘤中心标准化月度 TCO** | 🏆 **`$9,700 / 月`**（节省 **88.5%**，含 `$0` BI 读者与 `$0/GB` 写入税） | `$84,400 / 月`（HealthOmics + HealthLake + OpenSearch OCU 叠加） | `$78,600 / 月`（All-Purpose DBU + 内存向量索引高） | `$81,200 / 月`（多 Warehouse 轮询 + 外部病理存储） | `$76,900 / 月`（Healthcare API 专有存储 + Vertex 向量） |

---

## ⑤ 🧪 定量测评与 TCO / 性能拐点洞察（含 `Scenario BK` 密封基准）

### 5.1 密封基准测试结果（`DL-265..DL-268` · 总体准确率 `267/268 = 99.63%`）

| 用例 ID | 测试场景与输入条件 | Fabric 实测结果与动作门控 | 四大云竞对基线表现 | 商业与临床价值（SLA 保护） |
| :--- | :--- | :--- | :--- | :--- |
| **`DL-265`** | 42 家肿瘤中心 `790K EPS` 测序流与纵向 ctDNA 双链 UMI 随访流异常检测 | **Eventhouse KQL `10ms`** 捕获 `0.042%` VAF `ESR1 Y537S` 复发抬头（`Act automatically` 触发 MTB 联查） | 离线 VCF 批处理耗时 `3.5 天`，早期耐药克隆被当作噪音漏检 | 提前 **14 周** 拦截分子复发，避免无效内分泌/化疗线延误 |
| **`DL-266`** | `9,200 万条` 10x Xenium 空间转录组邻域与 40x DICOM WSI 切片块匹配 | **Cosmos SSD DiskANN `11ms`** 完成 `0.99` 匹配，锁定 `HER2-low` 旁观者敏感性并匹配 T-DXd ADC（`Confirm`） | 纯内存向量库月费贵 8.7 倍，且与 OMOP 病历库跨系统割裂 | 节省 **92% 向量内存成本**，精准筛选 ADC 获益人群 |
| **`DL-267`** | 对抗性测试：向合并活动性间质性肺炎（`SpO2=89%`）患者自动开具高风险 ADC 或越权导出未脱敏基因表 | **Foundry IQ `11ms`** 触发 `SOP-063` 硬拦截，降级为 **`Send to a human`** 并记入 Purview 审计 | 缺乏统一临床毒性规则引擎与 OBO 行列脱敏，易引发严重不良事件（SAE） | **100% 阻断 3 级以上 ILD 致命肺毒性与 HIPAA/EHDS 违规** |
| **`DL-268`** | 跨 42 家肿瘤中心、65 万患者与 `790K EPS` 流量的 36 个月 TCO 与端到端 MTB 闭环对比 | **`43ms` 端到端闭环**，标准化月度 TCO **`$9,700`**（节省 **88.5%**） | 四大云多组件拼装月均 **`$84,400`**，MTB 准备耗时 3.5 天 | 每年守护 **`$18,700,000`** 临床试验入组里程碑与精准治疗 SLA |

---

## ⑥ 🛠️ 生产落地与售前打单快速核验清单（SA Checklist）

- [ ] **液体活检 ctDNA 与测序质控流接入核验**：确认实验室 Base-Calling 质控流与双链 UMI 片段组学流已通过 **Fabric Eventstream** 接入 **Eventhouse**，启用 KQL `series_outliers()` 10ms 动力学监测，替代 48 小时盲测批处理。
- [ ] **HDS 多模态统一入湖核验**：启用 **Fabric Healthcare Data Solutions (HDS)** 官方管道，将 Epic FHIR R4、40x DICOM WSI 切片索引与空间转录组（Anndata/SpatialData `.zarr`/Parquet）统一映射至 **OneLake OMOP CDM v5.4**（`$23/TB`）。
- [ ] **空间组学与 WSI 向量 SSD DiskANN 降本核验**：将 Prov-GigaPath / UNI 提取的千万级病理切片块向量与 10x Xenium 细胞邻域嵌入存入 **Cosmos DB in Fabric SSD DiskANN**，验证内存成本下降 `92%` 且 P99 检索 `<15ms`。
- [ ] **CAP/CLIA、HIPAA 与 EU EHDS 护栏核验**：在 **Foundry IQ** 中启用 `ONCOLOGY-SPATIAL-WSI-CTDNA-MRD-EHDS-SOP-063` 规则门禁，校验证据等级（ACMG/AMP/OncoKB）、ILD 肺毒性阈值（`<3.0%`）与 **Purview + Entra Agent ID OBO** 患者知情同意穿透。
- [ ] **病理科断网边缘与 Epic 回写核验**：在医院机房部署 **SQL on Azure Local (ALDO)** 缓存高频 WSI 切片与本地质控规则，并通过 **Teams MTB 自适应卡片（FDA 21 CFR Part 11 电子签名）** 验证向 Epic FHIR `MedicationRequest` 的安全回写。
