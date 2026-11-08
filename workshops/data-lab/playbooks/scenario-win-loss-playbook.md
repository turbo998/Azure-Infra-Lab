# 🧭 AI Solution Architect 业务场景方案与选型打单 Playbook（Win Themes · Coexistence · Anti-Patterns）

> **语言版本 / Language**: **中文 (当前)** | [English (`scenario-win-loss-playbook.en.md`)](scenario-win-loss-playbook.en.md)  
> **架构师视角**：从真实业务痛点出发，明确何时主推 **Fabric 原生全栈**、何时采用 **跨云零拷贝共存（Better Together）**、何时主动规避 **反模式（Anti-Patterns）**。

[![Microsoft IQ & Fabric IQ Reference Architecture](../assets/svg/02-microsoft-iq-fabric-iq-architecture.svg)](../assets/svg/02-microsoft-iq-fabric-iq-architecture.svg)

---

## 1. 五大高价值行业场景端到端方案（Industry Reference Solutions）

### 场景一：智算中心（AIDC）AI 能源编排与削峰填谷闭环
- **客户痛点**：单园区万卡 GPU 集群功耗剧烈波动，夏季尖峰时段极易突破电网需量合同上限（触发 2 倍罚款）；配电 SCADA、液冷 BMS、储能 BESS 与 K8s/Slurm 算力调度各自孤立，过度依赖退休老师傅经验。
- **推荐架构**：
  1. **感知层**：SCADA / DCIM / GPU 功耗遥测通过 **Eventstream** 秒级写入 **Eventhouse KQL**（`142 ms` 异常斜率检测）。
  2. **本体层**：在 **Fabric IQ Ontology** 中建模 `园区 → 配电室 → 变压器 → BESS 储能 → 机柜列 → GPU 集群 → 训练任务` 6 级拓扑与安全阈值规则。
  3. **护栏与编排层**：**Foundry 多智能体** 联合寻优（BESS 放电 `2.00 MW` + 推迟非关键批推理 `1.10 MW` + 液冷微调 `+1.0°C` 省 `0.35 MW`），并由 **Foundry IQ** 强制校验《`SOP-DC-COOL-04`》（`+1.0°C ≤ +1.5°C` 上限）。
  4. **行动与治理层**：推送 **Teams 自适应审批卡**，值班长一键批准后下发 EMS/K8s，并将执行记录回写至 **1GB 免费 Fabric SQL** 与 Ontology 图谱，全程受 **Agent 365** 审计。
- **量化业务 ROI**：端到端响应 **`780 ms`**，单次削峰 **`3.45 MW`**（负荷率从 `94.2%` 降至 `76.95%`），单园区预计**月省 `$42,800`**。

---

### 场景二：航空与枢纽物流实时运营数字孪生（纽约 JFK R25 跑道湿雪案例）
- **客户痛点**：恶劣天气下跑道摩擦系数下降、除冰车调度、登机口重分配与旅客中转通知跨越多套遗留系统，人工协调耗时 45 分钟以上，造成大面积级联延误。
- **推荐架构**：
  1. **一键本体冷启动**：直接从航司现有的 **Power BI 航班准点率语义模型**一键升级生成 **Fabric IQ Ontology**，免除从零手写图谱 schema。
  2. **实时信号绑定**：将跑道道面传感器与气象雷达流绑定至 Ontology 中的 `Runway:R25` 实体。
  3. **级联穿透与预授权执行**：当摩擦系数跌至 `0.24 (< 0.30)` 时，Ontology Graph 在 `164 ms` 内锁定受影响的 14 架航班与 28 项地面任务；**Operations Agent** 依据预授权规则自动派遣 Alpha 扫雪车队并重分配 6 个登机口。
- **量化业务 ROI**：端到端闭环 **`640 ms`**，级联延误缩减 **`38 分钟`**，单次寒潮事件规避航司损失 **`$68,500`**。

---

### 场景三：跨云全渠道零售爆单与 Fabric IQ Planning 事务回写闭环（GCP BigQuery + Snowflake + AWS S3 + Fabric）
- **客户痛点**：海外黑五闪促广告投放数据在 **GCP BigQuery (Google Ads / GA4)**，采购合同与财务结算在 **Snowflake**，跨境物流轨迹在 **AWS S3 Tables**，而全球 2,000 名业务人员日常办公在 **Microsoft 365 / Teams / Power BI**。大促爆单时库存断货响应滞后，跨云 ETL 管道脆弱且无法从报表直接修改预算。
- **推荐架构（共存模式 A + C + D，对应仿真 `retail_cross_cloud_planning` / `DL-26`）**：
  1. **跨云零拷贝感知 (`134 ms`)**：启用 **已正式 GA 的 OneLake BigQuery Mirroring**、**OneLake Snowflake Mirroring** 与 **S3 Shortcuts**，捕获旗舰单品 `SmartWatch-Pro-X` 转化率暴增 **`+240%`**（`12,400 单/小时`），欧洲中心仓可售天数跌至 **`1.8 天`**（`< 3.0 天` 阈值）。
  2. **跨云本体穿透与 Planning 寻优 (`352 ms`)**：**Fabric IQ Ontology** 穿透 6 跳跨云实体链路，联合 **Fabric IQ Planning (Preview)** 生成方案：从南德缓冲仓调拨 **`4,500 件`** + 触发 Snowflake ERP 合同 `PO88` 紧急加单 **`8,000 件`** + 动态追加 Q4 促销预算 **`+$185,000`**。
  3. **利润率护栏与 1GB 免费 SQL 回写 (`224 ms`)**：**Foundry IQ** 校验调拨后净毛利率 **`24.6% ≥ 22.0%`** 红线；业务总监在 **Power BI Agentic App** 中一键确认，直接回写至 **1GB 免费 Fabric SQL 数据库** 并通过 DirectLake 秒级刷新全员看板。
- **量化业务 ROI**：端到端闭环 **`710 ms`**，可售库存恢复至 **`6.4 天`**，单次闪促规避断货损失 **`$312,000`**，500+ 用户月度 TCO 降低 **`47.6%–56.1%`**。

---

### 场景四：多云金融实时跨境电汇反欺诈与 Project Osmos 管道自愈闭环（AWS S3 + Azure Databricks + Snowflake + Fabric）
- **客户痛点**：数以百 TB 计的移动端设备日志存放在 **AWS S3 Tables**，图神经网络（GNN）欺诈特征工程跑在 **Azure Databricks (Unity Catalog)**，核心总账在 **Snowflake**；上游 ISO-20022 报文一旦发生字段升级即导致跨云管道中断，且一线风控团队缺乏亚秒级跨云团伙阻断与可疑活动报告（SAR）双库回写闭环。
- **推荐架构（共存模式 A + B + D，对应仿真 `financial_multi_cloud_fraud` / `DL-29 & DL-30`）**：
  1. **实时流感知与 Project Osmos 管道自愈 (`270 ms`)**：**Eventhouse KQL** 配合带出站访问保护的 **OneLake S3 Shortcut** 捕获 90 秒内 **38 个合成身份账户**突发 `$4.85M` 跨境电汇（团伙风险分 `0.97 > 0.85`）；同时 **Fabric Data Engineering Agent (Project Osmos)** 在 `152 ms` 内自动修复上游新增字段 `ultmtDbtrId` 引发的 Schema 漂移。
  2. **跨四云 6 跳图谱穿透 + DiskANN 向量匹配 (`160 ms`)**：**Fabric IQ Ontology** 结合 **Databricks Agent Bricks Supervisor (OBO 委托认证)** 与 **Snowflake Apache Ossie YAML** 穿透 6 跳团伙链路，并调用 **Azure SQL Hyperscale (192 vCore + 原生 DiskANN 向量索引 GA)** 匹配到 4 起历史洗钱团伙拓扑。
  3. **Foundry IQ 规程校验与双库回写 (`230 ms`)**：校验《`FIN-AML-SAR-SOP-12`》（误报率 `1.4% ≤ 3.0%` 红线），以 `0.97` 置信度预授权自动冻结 `$4.85M` 电汇，并将 SAR 审计案卷同步回写至 **Azure SQL Hyperscale** 与 **1GB 免费 Fabric SQL**。
- **量化业务 ROI**：端到端闭环 **`660 ms`**，单次跨境团伙攻击挽回净欺诈损失 **`$4,620,000`**，跨云 Schema 漂移实现**零停机自愈**。

---

### 场景五：跨 18 工作区容量尖峰 RCA 与 Rayfin SDK 全栈智能体应用自愈闭环（FinOps & Enterprise Platform Ops）
- **客户痛点**：集团级数据平台拥有 18+ 个部门工作区与上千张高管报表，某部门分析师提交的未加索引笛卡尔积慢查询极易瞬间打满 F64 容量池（>110% CU），导致调用外部伙伴本体的核心资金门户限流报错；传统运维排查需跨多个团队耗时 30 分钟以上。
- **推荐架构（对应仿真 `finops_rayfin_observability` / `DL-33 & DL-34`）**：
  1. **跨工作区单一 Eventhouse 感知 (`108 ms`)**：通过 **Workspace Monitoring** 将 18 个生产工作区遥测实时汇入**单一 Eventhouse**，**Monitor Hub Capacity Headroom** 秒级告警 F64 利用率飙升至 **`114.8%`** 并定位 `WS-FIN-PROD-07` 的慢查询 `Q-8841`。
  2. **6 跳图谱穿透与双智能体联合寻优 (`282 ms`)**：**Fabric IQ Ontology** 穿透受影响的 **OneLake IQ Sharing（标普全球 S&P Global RDF 本体）** 与资金门户应用；**Operations Agent** 自动限流慢查询，联合 **Database Agent for SQL** 注入 **DiskANN 向量与复合索引提示**，并按需开启 **On-Demand Billing 突发缓冲（`+16 CU` 25 分钟，花费 `$48.50 ≤ $250` 护栏）**。
  3. **Rayfin TS 函数执行与 1GB 免费 SQL 审计回写 (`200 ms`)**：校验 **Foundry IQ**《`FINOPS-SURGE-SOP-09`》与 **Private-by-Default / Secret Store** 策略后，调用开源 **Rayfin SDK** 编写的 TypeScript 后端函数 `fn_remediateCapacityAndLogAudit()` 将处置记录回写至 **1GB 免费 Fabric SQL**。
- **量化业务 ROI**：端到端闭环 **`590 ms`**，F64 容量利用率从 **`114.8%` 压降至 `71.2%`（`-43.6%`）**，单次规避高管看板与资金门户 SLA 违约罚金 **`$28,400`**。

---

### 场景六：跨云医药冷链与临床试验本体 × Database Hub × Hyperscale 192核 DiskANN 闭环（Oracle ERP + GCP BigQuery + Azure SQL Hyperscale + Fabric）
- **客户痛点**：跨国药企的冷链批次台账存放在 **Oracle ERP**，全球 III 期临床试验患者队列存放在 **GCP BigQuery**，上千万条制剂稳定性动力学曲线与 FDA 21 CFR Part 11 规程需与实时 IoT 温控遥测做亚秒级向量+关系联查；一旦运输途中发生超温漂移，传统跨系统核查耗时数小时，极易导致临床患者断药或误用失效批次。
- **推荐架构（对应仿真 `healthcare_clinical_supply_diskann` / `DL-37 & DL-38`）**：
  1. **实时冷链遥测与跨云零拷贝穿透 (`242 ms`)**：**Eventhouse KQL** 捕获生物制剂批次 `LOT-BIO-209` 超温至 **`6.8°C > 2.0°C`**（持续 42 分钟），**Fabric IQ Ontology** 穿透 **OneLake Oracle Mirroring**（锁定 3 个区域仓 **420 支**受影响制剂）与 **BigQuery Mirroring GA**（定位未来 48 小时内待给药的 **128 名 III 期患者**）。
  2. **Hyperscale 192核 DiskANN 检索与 Database Hub 自愈 (`168 ms`)**：在 **Azure SQL Hyperscale 192 vCore** 的 **1,800 万条**稳定性向量库上通过原生 SSD **DiskANN** 以 **`19 ms` P99 / `98.4%` 召回率**匹配《`SOP-FDA-21CFR11-BIO-08`》；**Database Hub + Database Agent** 监控 64 套数据库并自动解除 Oracle 镜像账本上的阻塞行锁。
  3. **Foundry IQ 法规拦截与 Rayfin 临床门户调拨回写 (`150 ms`)**：**Foundry IQ** 强制拦截失效批次放行请求，通过 **Rayfin SDK** 临床门户将 `LOT-BIO-209` 回写为 `QUARANTINED`（写入 **1GB 免费 Fabric SQL**），并从苏黎世备仓（`DEPOT-ZRH-02`）紧急调拨 **420 支**合格制剂。
- **量化业务 ROI**：端到端闭环 **`560 ms`**，**128 名 III 期临床患者 `100.0%` 给药零中断**，单次避免批次报废与临床队列失效损失 **`$640,000`**。

---

### 场景七：300mm 晶圆厂 Digital Twin Builder × Lakehouse 流式表 × Zero-Provisioned 零预置弹性爆发闭环（AWS S3 + GCP BigQuery + Fabric）
- **客户痛点**：半导体 300mm 晶圆厂 EUV 光刻机（`EUV-Scanner-04`）每秒产生 **85,000 EPS** OPC-UA 腔体与温控遥测（需托管私网与客户自管密钥 CMK），备件库存存放在 **AWS S3**，光学晶圆 Die Map 存放在 **GCP BigQuery**；一旦吸盘热膨胀导致套刻漂移（Overlay Drift）突破 `0.90 nm`，每 4 小时又需要突发运行高算力蒙特卡洛良率仿真，若长期预留高规格容量则平峰算力闲置浪费严重。
- **推荐架构（对应仿真 `manufacturing_digital_twin_zeroprov` / `DL-41..DL-44`）**：
  1. **托管私网采集与亚秒级流式表 (`96 ms`)**：**Eventstream (Managed Private Link + CMK)** 采集 85K EPS 遥测并直写 **OneLake Lakehouse Streaming Table**（端到端滞后仅 **`210 ms`**，即刻供 DirectLake 零拷贝消费），捕获套刻漂移升至 **`1.85 nm > 0.90 nm`**（75 片晶圆面临报废风险）。
  2. **Digital Twin Builder 跨云图谱穿透与 Zero-Provisioned 弹性爆发 (`286 ms`)**：**Digital Twin Builder** 穿透 AWS S3 缓存快捷方式与 BigQuery Mirroring 晶圆图谱，并自动唤醒 **Zero-Provisioned On-Demand** 弹性池（爆发 **`+24 CU`** 运行蒙特卡洛热补偿寻优，单次按作业计费仅 **`$14.20`**，基础 F64 容量节流率 **`0.0%`**），求解出吸盘水温微调 **`-0.42°C`** 与 `180 秒`微吹扫方案。
  3. **Foundry IQ 工艺护栏与 Rayfin Fab-Ops 门户回写 (`148 ms`)**：**Foundry IQ** 核验《`SOP-SEMI-EUV-14`》（`±0.60°C` 安全包络内），通过 **Rayfin SDK** 自动下发校准参数并回写 **1GB 免费 Fabric SQL**。
- **量化业务 ROI**：端到端闭环 **`530 ms`**，套刻误差压回 **`0.58 nm`**，保住 75 片 300mm 晶圆 **`99.4%` 良率**，单次规避晶圆报废损失 **`$920,000`**。

---

### 场景八：跨企业供应链抗毁 × OneLake IQ Sharing (RDF 本体共享) × Salesforce Data 360 零拷贝 × Azure Local 断网车间闭环（TomTom / S&P + Salesforce + Snowflake + Fabric）
- **客户痛点**：跨国高端装备制造企业的 **42 家战略大客户合同（`$18.4M ARR`，待交付 `1,280 台` AI 液冷机柜）** 存放在 **Salesforce Data 360**；全球海运港口实时拥堵与二级供应商信用风险来自外部合作伙伴 **TomTom** 与 **S&P Global**；而位于匈牙利布达佩斯的总装车间因合规要求处于 **断网（Air-Gapped）** 状态。当红海改道引发鹿特丹港突发拥堵（延误 **`+96 小时 > 24 小时`** 安全红线）时，传统 SFTP CSV 导入与人工跨系统核查耗时超过 48 小时，且向外部承运商派单时极易泄露客户合同净底价。
- **推荐架构（对应仿真 `supply_chain_iq_sharing_salesforce` / `DL-45..DL-48`）**：
  1. **跨企带本体零拷贝感知与断网边缘同步 (`92 ms`)**：通过 **OneLake IQ Sharing** 直接订阅外部伙伴共享的 **受治理数据表 + `.rdf` 本体图谱 + `.md` 智能体指令**，结合 **SQL Server on Azure Local（配备 ALDO 本地 Appliance-VM 断网控制面）** 的布达佩斯车间在制品同步流，由 **Eventhouse KQL** 毫秒级捕获 `+96h` 延误越界。
  2. **Salesforce Data 360 零拷贝穿透与条件规则求解 (`234 ms`)**：**Fabric IQ Ontology** 通过 **Salesforce Data 360 零拷贝 Shortcut** 与 **Snowflake 镜像（Apache Ossie YAML）** 在 `126 ms` 内锁定受影响的 42 家战略大客户与 `1,280 台` 机柜订单；触发本体条件-动作规则 `PORT_DELAY > 24h AND ARR_AT_RISK >= $1M`（`108 ms`），自动生成最优保供方案：从华沙保税仓调拨 **`780 台`** + 启用中欧铁空联运加急 **`500 台`**（加急运费 `$34,500 ≤ $60,000` 上限）。
  3. **Purview 合同底价脱敏拦截与 Rayfin 双端回写 (`189 ms`)**：**Foundry IQ** 核验《`GLOBAL-SUPPLY-SLA-SOP-15`》并由 **Microsoft Purview** 自动拦截（`Block`）外部物流承运商读取 Salesforce `Net_Contract_Price`（Highly Confidential）；供应链 VP 确认后，**Rayfin SDK** 在 `95 ms` 内将调拨单回写至 **1GB 免费 Fabric SQL** 并同步刷新 Salesforce 客户成功经理（CSM）预警卡。
- **量化业务 ROI**：端到端闭环 **`515 ms`**，战略大客户准时交付率保持 **`99.6%`**，单次港口停摆危机规避 SLA 违约金与续约流失 **`$1,150,000`**。

---

## 2. 选型决策树：必赢场景（Win） vs 混合共存（Coexist） vs 避坑红线（Anti-Patterns）

| 评估分类 | 典型客户信号与场景特征 | 架构师标准打法 |
| :--- | :--- | :--- |
| **✅ 必赢场景 (Primary Win)** | • 企业已广泛采购 Microsoft 365 E3/E5、Teams、Power BI 及 M365 Copilot<br>• 需要将静态 BI 报表升级为可主动监控、根因分析并触发动作的业务智能体<br>• 面临跨 OT/IT（能源、制造、航空、零售）复杂多跳实体级联决策 | **主推 Fabric 原生全栈 + Fabric IQ Ontology + Foundry IQ + Agent 365**，重点展示 `$0` 额外 Copilot Token 与 1GB 免费 SQL 回写应用 |
| **🤝 混合共存 (Coexistence Win)** | • 客户已在 Snowflake、Databricks、BigQuery 或 AWS S3 投入数百万美元存量资产<br>• 数据工程团队拒绝推翻重写现有 Spark DLT 或核心数仓批处理作业<br>• 痛点集中在“最后一公里”的全员 BI 并发成本高、AI 问数口径乱、跨云孤岛 | **绝不强行替换底层数仓！** 主推 **OneLake Mirroring / Shortcuts + Apache Ossie + IQ Sharing**，7 天内在不改源端代码的条件下交付上层 AI/BI 闭环 |
| **⛔ 避坑边界 (Anti-Patterns)** | • **反模式 1**：在未定义语义模型或 Ontology 的裸湖仓表上直接开放 LLM Text-to-SQL 给高管问数（实测 `DL-23` 会产生 `+14.2%` 口径漂移）<br>• **反模式 2**：允许智能体不经 Foundry IQ SOP 护栏校验与 Teams 人在回路审批，直接向物理生产设备下发高危控制指令（如 `+3.5°C` 越界调温）<br>• **反模式 3**：将 70B+ 基础大模型分布式预训练强塞进 Fabric 容量，或将超低延迟高频交易（`< 5 ms` 硬件 FPGA 撮合）放进湖仓分析引擎 | 明确划分职责边界：重度模型预训练交由 **Azure AI Foundry / Azure Databricks**，物理控制指令强制绑定 **Ontology Rules + Foundry IQ 护栏 + HITL** |
