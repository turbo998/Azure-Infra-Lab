# 🔬 Data Lab — Microsoft Fabric × 四大云数智竞对（Databricks / Snowflake / GCP / AWS）深度研究与 AI Solution Architect 实战实验室

> **语言版本 / Language**: **中文 (当前)** | [English (`README.en.md`)](README.en.md)  
> **最新研究日期 / Latest Daily Run**: [`2026-11-04`](research/daily/2026-11-04.md) · [`2026-11-03`](research/daily/2026-11-03.md)（含 [`2026-11-02`](research/daily/2026-11-02.md) 与 [`2026-11-01`](research/daily/2026-11-01.md) 基线） · **评测基准得分**: `35 / 36 (97.22%)` · **单元测试**: `14 / 14 通过 (100%)`

[![Data Lab Executive Visual Summary](assets/svg/01-data-lab-executive-summary-2026-11-03.svg)](assets/svg/01-data-lab-executive-summary-2026-11-03.svg)

---

## 🎯 实验室定位与六大核心能力支柱

**Data Lab** 以资深 **AI Solution Architect（AI 解决方案架构师）** 视角构建，围绕 **Microsoft Fabric（Fabric IQ、Fabric IQ Planning、Project Osmos 自主工程智能体、开源 Rayfin SDK/CLI 全栈智能体应用、OneLake 与 IQ Sharing、Real-Time Intelligence 与跨区可观测性、Power BI 语义模型与 Agentic App 1GB 免费 SQL、Data/Operations Agents、Database Hub）** 与四大核心云数智竞对——**Databricks、Snowflake、Google Cloud (BigQuery / Looker / Vertex AI)、AWS (SageMaker Lakehouse / S3 Tables / Redshift / Bedrock)**——开展每日能力突破追踪、深度竞对拆解、架构设计、交互式 Demo 开发、可复现基准测评（7-Card 4:5 视觉报告）与行业场景打单 Playbook。

| 支柱编号 | 核心任务模块 | 关键交付物入口 | 核心量化结论 (`2026-11-03 / 11-04`) |
| :--- | :--- | :--- | :--- |
| **Pillar 0** | **每日最热门能力突破追踪** | [`2026-11-04.md`](research/daily/2026-11-04.md) · [`11-03.md`](research/daily/2026-11-03.md) · [`EN`](research/daily/2026-11-04.en.md) · [`11-02`](research/daily/2026-11-02.md) · [`11-01`](research/daily/2026-11-01.md) | 追踪开源 Rayfin SDK (TS 后端函数 + Secret Store + 默认私网)、跨 18 工作区单一 Eventhouse 可观测性、OneLake IQ Sharing RDF vs Databricks Lakeflow Real-Time GA、Snowflake Horizon Context、BigQuery ObjectRefs/GQL GA、AWS Bedrock GraphRAG |
| **Pillar 1** | **专项子任务：四大竞对深度攻防拆解** | [`comparisons/fabric-vs-4clouds-battlecards-2026.md`](comparisons/fabric-vs-4clouds-battlecards-2026.md) · [`EN`](comparisons/fabric-vs-4clouds-battlecards-2026.en.md) | 六维综合均分：**Fabric `93.3`** vs Databricks `86.8` vs GCP `85.5` vs Snowflake `85.0` vs AWS `82.8` + Rayfin/跨区可观测性/Osmos/OBO 攻防矩阵 |
| **Pillar 2** | **架构设计（Microsoft IQ × 五云共存 × Rayfin/Osmos/LTAP）** | [`06-rayfin-obs.svg`](assets/svg/06-rayfin-agentic-apps-eventhouse-observability.svg) · [`05-osmos-obo.svg`](assets/svg/05-osmos-autonomous-engineering-ossie-interop.svg) · [`04-ltap.svg`](assets/svg/04-translytical-ltap-agentic-architecture.svg) · [`02-iq.svg`](assets/svg/02-microsoft-iq-fabric-iq-architecture.svg) · [`03-coexist.svg`](assets/svg/03-five-cloud-coexistence-topology.svg) | Work IQ + Fabric IQ + Foundry IQ + Web IQ + Agent 365 闭环、四大跨云共存模式（A/B/C/D）、Rayfin 全栈应用与跨区 Eventhouse 可观测性架构 |
| **Pillar 3** | **交互式 H5 工作台与五大本体实时仿真台** | [`index.html` (中文)](index.html) · [`live-demo.en.html` (EN)](live-demo.en.html) | 集成五云攻防罗盘、动态 TCO 精算器、智算中心能源 (`780ms`)、JFK R25 跑道 (`640ms`)、跨云零售 (`710ms`)、多云金融反欺诈 (`660ms`) 与 18 工作区容量尖峰 Rayfin 自愈 (`590ms` 规避 `$28.4K`) |
| **Pillar 4** | **可复现 Benchmark 与 7-Card 4:5 视觉报告** | [`benchmark-cards.html` (中文)](benchmark-cards.html) · [`benchmark-cards.en.html` (EN)](benchmark-cards.en.html) · [`report.json`](reports/report.json) | 36 场景 `97.22%` (`35/36`) 通过率（`565.3ms` 均值）；500 用户月省 `46.1%–56.1%` TCO；DirectLake + KQL 高并发快 `4.54x–9.47x` |
| **Pillar 5** | **业务场景方案与 Win/Loss 打单 Playbook** | [`playbooks/scenario-win-loss-playbook.md`](playbooks/scenario-win-loss-playbook.md) · [`EN`](playbooks/scenario-win-loss-playbook.en.md) | 梳理五大标杆场景（智算中心能源编排、航空数字孪生、跨云零售爆单 Planning 回写、多云金融反欺诈与 Osmos 自愈、18 工作区容量尖峰与 Rayfin 自愈）必赢策略与避坑红线 |

---

## 🖼️ 核心架构图集（SVG 自包含矢量图）

### 1. 开源 Rayfin SDK 全栈智能体应用 × 跨工作区 Eventhouse 可观测性 × OneLake IQ Sharing 架构（`2026-11-04` 新增）
[![Rayfin SDK & Cross-Workspace Eventhouse Observability Architecture](assets/svg/06-rayfin-agentic-apps-eventhouse-observability.svg)](assets/svg/06-rayfin-agentic-apps-eventhouse-observability.svg)

### 2. Project Osmos 自主数据工程 × 跨云 OBO 智能体身份 × Apache Ossie 语义互操作架构（`2026-11-03`）
[![Project Osmos & Cross-Cloud OBO Architecture](assets/svg/05-osmos-autonomous-engineering-ossie-interop.svg)](assets/svg/05-osmos-autonomous-engineering-ossie-interop.svg)

### 3. LTAP 湖仓事务分析一体与智能体回写架构对比（`2026-11-02`）
[![LTAP & Translytical Architecture](assets/svg/04-translytical-ltap-agentic-architecture.svg)](assets/svg/04-translytical-ltap-agentic-architecture.svg)

### 4. Microsoft IQ × Fabric IQ 企业级语义本体与多智能体闭环架构
[![Microsoft IQ & Fabric IQ Architecture](assets/svg/02-microsoft-iq-fabric-iq-architecture.svg)](assets/svg/02-microsoft-iq-fabric-iq-architecture.svg)

### 5. OneLake 跨云零拷贝共存拓扑（Fabric × Databricks × Snowflake × GCP × AWS）
[![Five Cloud Coexistence Topology](assets/svg/03-five-cloud-coexistence-topology.svg)](assets/svg/03-five-cloud-coexistence-topology.svg)

---

## 📊 五大平台六维能力评分与 500 用户月度 TCO 对比（源自 `reports/report.json`）

| 评估维度 / 平台 | Microsoft Fabric | Databricks | GCP BigQuery | Snowflake | AWS Lakehouse | 胜出关键依据 |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **1. 业务语义与本体接地 (`semantic_ontology_grounding`)** | **96.0 ★** | 83.0 | 84.0 | 85.0 | 78.0 | 从 2000万+ Power BI 语义模型一键升级 Ontology + Graph 级联 + Apache Ossie |
| **2. 实时情报与亚秒级时序流 (`realtime_streaming_kql`)** | **95.0 ★** | 84.0 | 83.0 | 80.0 | 82.0 | Eventstream + Eventhouse KQL `142ms` 亚秒级时序异常检测 + Operations Agent |
| **3. 跨云零拷贝与开放互操作 (`cross_cloud_zero_etl`)** | **94.0 ★** | 85.0 | 87.0 | 86.0 | 81.0 | BigQuery/Snowflake/Oracle/SAP 镜像 GA + S3/GCS Shortcuts + OneLake IQ Sharing |
| **4. 大规模 ML 训练与深度工程 (`ml_and_data_engineering`)** | 82.0 | **97.0 ★** | 89.0 | 84.0 | 90.0 | Databricks 在 70B+ 分布式训练与底层 Spark/Photon 调优领先（推荐共存模式 B） |
| **5. BI 智能体应用与回写 (`bi_and_agentic_app_creation`)** | **98.0 ★** | 81.0 | 82.0 | 83.0 | 77.0 | DirectLake + Power BI Agentic App + 1GB 免费 Fabric SQL + 开源 Rayfin SDK |
| **6. 企业安全与 Agent 治理 (`enterprise_governance_security`)** | **95.0 ★** | 91.0 | 88.0 | 92.0 | 89.0 | Purview 敏感度标签贯通 Office/Teams + Agent 365 + Entra Agent ID |
| **六维综合均分 (Composite Mean)** | **93.3** | **86.8** | **85.5** | **85.0** | **82.8** | Fabric 在 5/6 个核心企业维度排名第一 |
| **500 用户月度总成本 (`100TB + 25K EPS + 5K 问数/日`)** | **$14,048/mo** | $26,562/mo | $26,813/mo | $31,990/mo | $26,063/mo | **Fabric 综合节省 `46.1%–56.1%`**（`$0` BI 读者许可 + `$0` M365 Copilot 额外 Token） |

---

## ⚡ 快速复现基准测试与生成 `report.json`

本实验室所有图表、7-Card 报告与 H5 看板的数据均由确定性 Python 评测套件生成，零外部 API 密钥依赖：

```powershell
# 1. 运行完整单元测试套件 (14/14 测试 100% 通过)
python -m unittest discover -s workshops/data-lab/tests -v

# 2. 重新生成密封评测输出 workshops/data-lab/reports/report.json
python workshops/data-lab/src/data_lab/benchmark_suite.py --output workshops/data-lab/reports/report.json
```

---

## 📂 目录结构说明

```text
workshops/data-lab/
├── README.md                                           # 中文主导航文档 (含一图流 SVG 预览)
├── README.en.md                                        # 英文主导航文档
├── index.html                                          # 中英双语交互式 H5 全景工作台 (攻防罗盘 + TCO 计算器 + 五大本体仿真台)
├── live-demo.html / live-demo.en.html                  # 双语快捷入口
├── benchmark-cards.html                                # 7-Card 4:5 视觉评测报告 (中文 · 严格 CSP 自包含)
├── benchmark-cards.en.html                             # 7-Card 4:5 Visual Benchmark Deck (English · Strict CSP)
├── assets/svg/
│   ├── 01-data-lab-executive-summary-2026-11-04.svg    # 2026-11-04 每日强制交付：五大平台竞对攻防与架构一图流总结卡
│   ├── 01-data-lab-executive-summary-2026-11-03.svg    # 2026-11-03 每日一图流总结卡 (同步更新 36 场景 & 5 仿真)
│   ├── 01-data-lab-executive-summary-2026-11-02.svg    # 2026-11-02 每日一图流总结卡
│   ├── 01-data-lab-executive-summary-2026-11-01.svg    # 2026-11-01 每日一图流总结卡
│   ├── 02-microsoft-iq-fabric-iq-architecture.svg      # Microsoft IQ × Fabric IQ 五层参考架构图
│   ├── 03-five-cloud-coexistence-topology.svg          # OneLake 跨云零拷贝共存拓扑图
│   ├── 04-translytical-ltap-agentic-architecture.svg   # LTAP 湖仓事务分析一体与智能体回写架构对比图
│   ├── 05-osmos-autonomous-engineering-ossie-interop.svg # Project Osmos × OBO 委托认证 × Apache Ossie 架构图
│   └── 06-rayfin-agentic-apps-eventhouse-observability.svg # Rayfin SDK × 跨区 Eventhouse 可观测性 × OneLake IQ Sharing 架构图 (新增)
├── research/daily/
│   ├── 2026-11-04.md / 2026-11-04.en.md                # 2026-11-04 (11-03 夜间窗口) 深度研究日报 (中英双语)
│   ├── 2026-11-03.md / 2026-11-03.en.md                # 2026-11-03 深度研究日报 (中英双语)
│   ├── 2026-11-02.md / 2026-11-02.en.md                # 2026-11-02 深度研究日报 (中英双语)
│   └── 2026-11-01.md / 2026-11-01.en.md                # 2026-11-01 深度研究日报 (中英双语)
├── comparisons/
│   ├── fabric-vs-4clouds-battlecards-2026.md           # 四大竞对深度拆解与售前 Battlecards (中文)
│   └── fabric-vs-4clouds-battlecards-2026.en.md        # 4-Cloud Competitive Battlecards (English)
├── playbooks/
│   ├── scenario-win-loss-playbook.md                   # 行业场景方案与 Win/Loss/Coexistence Playbook (中文)
│   └── scenario-win-loss-playbook.en.md                # Business Scenario & Win/Loss Playbook (English)
├── src/data_lab/
│   ├── __init__.py
│   └── benchmark_suite.py                              # 可复现五云评测、TCO 精算与 5 大 Ontology 仿真引擎
├── tests/
│   └── test_data_lab.py                                # 14 项自动化验证测试
└── reports/
    └── report.json                                     # 密封评测输出数据 (驱动所有视觉坐标)
```
