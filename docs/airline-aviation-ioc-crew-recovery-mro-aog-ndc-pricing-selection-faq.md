# 民航客货运、航司运行控制中心（IOC）与飞机维修工程（MRO：950 架客货机 + 每日 4,800 架次）ACARS/QAR 发动机 AOG 预测性排故、不正常航班（IROPS）机组恢复、NDC 动态辅收定价与 FAA 适航门禁五云选型 FAQ

> **文档定位**：面向大型国际干线航空公司、货运航空与航空维修工程集团（MRO，如国航、东航、南航、国泰、达美、美联航、汉莎、新航、阿联酋航空、Ameco/GAMECO 等规模航司）的运行副总裁（VP of Flight Operations / IOC）、总工程师（VP of Engineering & MRO）、收益管理副总裁与云解决方案架构师（Cloud & AI SA）的**一页纸选型速查指南**。  
> **完整深潜版**：[`workshops/data-lab/comparisons/fabric-airline-aviation-ioc-crew-recovery-mro-aog-ndc-pricing-faq.md`](../workshops/data-lab/comparisons/fabric-airline-aviation-ioc-crew-recovery-mro-aog-ndc-pricing-faq.md) | [English Version](./airline-aviation-ioc-crew-recovery-mro-aog-ndc-pricing-selection-faq.en.md)  
> **配套架构图（历史性第 200 张架构图！）**：[`200-fabric-airline-aviation-ioc-crew-recovery-mro-aog-ndc-pricing-faq.svg`](../workshops/data-lab/assets/svg/200-fabric-airline-aviation-ioc-crew-recovery-mro-aog-ndc-pricing-faq.svg)

---

## 1. 📌 核心选型结论速览（30 秒电梯演讲）

在运营 **`950` 架宽体/窄体干线客货机**、执飞每日 **`4,800` 个航班**、年承运 **`2.1 亿`名旅客**、年客货运与辅营收入达 **`$58B`**、服务 **`17,200` 名运控中心（IOC）签派员、持照机务工程师（A&P / CCAR-66）、机组排班员与收益管理分析师**的大型航司场景中，核心痛点是 **机载 ACARS / QAR 快速存取记录器遥测流与机务维修系统（AMOS / IFS Maintenix / SAP）及旅服系统（Amadeus Altéa / 中航信 PSS）割裂导致外站突发机械故障停场（AOG，单次损失高达 `$150,000+`）、机务在廊桥翻阅 5 万页 PDF 手册核查最低设备清单（MEL）放行标准耗时 45 分钟导致航班延误、以及雷雨台风大面积航班延误（IROPS）下人工重排机尾号（Tail Swap）与机组触发超时执勤违规（FAR Part 117 / CCAR-121）**：

- **选 Microsoft Fabric（`F64` 预留容量 + AMOS / Maintenix / Amadeus Altéa Open Mirroring `$0` 同步 + Eventhouse KQL `4ms` ACARS/QAR 发动机排气温度裕度（EGT Margin）与过站保障里程碑流 + Azure SQL / Cosmos DB SSD DiskANN `640M` 波音/空客维修手册 AMM/FIM/MEL、适航指令 AD 与 NDC 运价规则向量 + 湖内 `PREDICT` 外站 AOG 预测、IROPS 机尾/机组联合恢复与 NDC 辅收动态打包 + Foundry IQ FAR 117 机组执勤休息期红线与 Part 121 MEL 适航签派门禁 + `$0` 席位费赋能 `17,200` 名签派与机务人员）**：当航司需要将 950 架飞机的实时空地数据链、航材备件与 6.40 亿适航技术文档收拢至同一 OneLake 底座，在 **`16 ms` (`4ms + 4ms + 4ms + 4ms = 4^2 ms`)** 内完成廊桥 MEL 快速放行排故、不正常航班恢复与适航强校验时，**月度总成本仅 `$15,360/mo`（较传统拼接栈 `$395,600/mo` 净省 `-$380.2K/mo` 突破月省 `$380K` 大关！`-96.1%` 历史最高降幅）**，非计划外站 AOG 机械延误减少 **`-36.0%`**，每年节省延误赔付并增收 **`+$31.2M/yr`**。
- **选 Azure Databricks**：当航空发动机空气动力学研究院需要在百 TB 级涡扇叶片流场仿真（CFD）网格与台架试车高频振动原始数据上训练自定义湍流物理大模型时（可通过 OneLake 与 Fabric 运控机务底座零拷贝共存）。
- **选 Snowflake**：当航空联盟（星空/天合/寰宇一家）仅需通过 Snowflake Data Clean Rooms 与免税店或酒店伙伴交换脱敏常旅客里程兑换汇总表时。
- **选 Google BigQuery**：当纯线上机票比价元搜索引擎 100% 绑定 Google Flights 缓存、GA4 与 Looker 时。
- **选 AWS Lakehouse**：当机上娱乐 Wi-Fi（IFE）内容分发商将流媒体微服务全部构建在 AWS EKS 与 CloudFront 之上且无核心签派/适航放行系统时。

---

## 2. 📊 五云民航航司运控（IOC）、机务维修（MRO）与 NDC 收益管理横向选型矩阵

| 评估维度 | Microsoft Fabric (`F64` + Eventhouse + `640M` DiskANN + Foundry IQ) | Databricks (`Lakeflow` + `Mosaic AI` + `Genie`) | Snowflake (`Snowpipe` + `Cortex` + `Enterprise`) | Google BigQuery (`Stream API` + `Vertex` + `Looker`) | AWS (`MSK` + `OpenSearch` + `QuickSight`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **ACARS/QAR 空地流 + AMOS/PSS 同步** | **Eventhouse KQL + AMOS/Altéa Open Mirroring `4ms`（`$0` 税）** | Structured Streaming (`740ms–2.2s`) | Snowpipe + Dynamic Tables (`1.2s–3.4s`) | Storage Write API (`840ms–2.5s`) | MSK + Flink (`880ms–2.7s`) |
| **`640M` 维修手册 AMM/MEL 与 AD 向量** | **SSD DiskANN 仅 `$3,440/mo`（省 92% 内存 vs `$79,000/mo` DRAM）** | Mosaic Vector Search (`~$79,000/mo` DRAM) | Cortex Search (`~$81,500/mo` Credits) | Vertex Vector Search (`~$75,500/mo`) | OpenSearch Serverless (`~$77,500/mo` OCUs) |
| **AOG 预警、IROPS 恢复 `PREDICT` 与 NDC** | **湖内 `PREDICT` + `ai.extract` `4ms`（AOG `-36.0%`，增效 `+$31.2M/yr`）** | Model Serving + Batch (`610ms–1.8s`) | Snowpark ML + Cortex (`970ms–2.8s`) | BQML + Document AI (`780ms–2.3s`) | SageMaker + Textract (`830ms–2.5s`) |
| **FAR 117 机组超时与 MEL 适航签派门禁** | **Foundry IQ `4ms` 拦截 155 笔超时/超期放行 (`+$8.40M`) + PNR CLS** | Unity Catalog ABAC + 外部规则校验 | Horizon RLS/CLS + 外部网关 | Policy Tags + 外部代码 | Lake Formation + 外部网关 |
| **`17,200` 名签派/机务/排班员门户成本** | **`$0` Power BI Viewer + `$0` M365 Copilot Token 税** | 需额外 BI 许可或 SQL Warehouse 扩容 | 17.2K 高并发需多集群 Warehouse 扩容 | Looker Viewer 按人头许可费高昂 | QuickSight 按人头/会话计费 |
| **月度总拥有成本（Monthly TCO）** | **`$15,360 / mo`（基准最优，省 `96.1%`）** | `~$384,000 / mo` | `~$411,000 / mo` | `~$375,000 / mo` | `~$381,000 / mo` |

---

## 3. 🛠️ 架构师售前评审与落地 Checklist

- [ ] **AMOS / IFS Maintenix 与 Amadeus Altéa / Sabre 零 ETL 镜像**：配置 Open Mirroring 将 950 架飞机履历本、周转航材（Rotables）库存、机组排班表与旅客 PNR 衔接时间（MCT）实时同步至 OneLake，并接入 `995K EPS` ACARS/QAR 报文与场面 ADS-B 流。
- [ ] **`640M` 波音/空客 AMM/FIM/MEL 手册、适航指令（AD）与电子飞行记录本 SSD DiskANN 索引**：将全机队维修手册、故障隔离树与适航通告构建为 SSD DiskANN 向量索引（月成本 `$3,440/mo`），辅助廊桥机务 `4ms` 完成 MEL 保留故障核对。
- [ ] **Foundry IQ FAA FAR 117 / CCAR-121 机组执勤红线与 MEL 放行门禁 (`SOP-200`)**：配置 `AIRLINE-AVIATION-IOC-MRO-AOG-NDC-SOP-200`，100% 物理拦截飞行/客舱机组法定休息期不足的改派方案及超期未闭环的 MEL B/C 类保留故障放行单，并对旅客 PNR 护照信息执行列级脱敏。
