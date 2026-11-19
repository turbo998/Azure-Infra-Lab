# Azure Infra Lab — 企业级 AI 与数据基础设施架构师实战仓库 (`turbo998/Azure-Infra-Lab`)

> 🌐 **语言切换 / Language**: **🇨🇳 中文主页 (`README.md`)** | **[🇬🇧 English (`README.en.md`)](README.en.md)**  
> ⚡ **核心快捷入口 / Quick Access**: **[💎 Diamond 企业级实战演示中心](workshops/data-lab/demos/diamond-hub.html)** · **[📺 TCL × Fabric 6幕渠道指挥舱](workshops/data-lab/demos/tcl-fabric/index.html)** · **[🛒 Zava × Databricks & Fabric 共生沙盘](workshops/data-lab/demos/databricks-fabric/index.html)** · **[⚔️ Databricks vs Fabric 10维战卡](workshops/data-lab/demos/databricks-fabric/battlecard.html)** · **[🔬 Data Lab 五云选型工作台](workshops/data-lab/index.html)** · **[🤖 Azure Agent Infra (`AKSClaw × E2B`)](workshops/azure-agent-infra/index.html)** · **[🎬 FabCon 2026 视频简报](workshops/fabcon-sqlcon-2026/index.html)**

面向 **AI Solution Architect (SA)**、售前技术专家与云基础设施工程团队的公开实战架构库。仓库聚焦高价值企业云原生与 Data+AI 落地场景，提供**可直接演示的脱敏高管沙盘**、**多云架构选型指南**、**容量/TCO 计算器**与**密封可复现评测报告**。

---

## 💎 快捷直达：Diamond 企业级数据与 AI 实战演示套件（Diamond Enterprise Demo Suite）

专为客户高管汇报、架构工作坊与售前验证打造的 **100% 租户脱敏交互式演示环境**（支持中英双语切换、离线/在线即开即演）：

| 旗舰演示样板 | 核心技术栈 | 解决的真实业务痛点与量化收益 | 交互沙盘与配套讲稿 |
| :--- | :--- | :--- | :--- |
| **📺 Demo 01 · TCL 海外多级渠道智能 (Global Channel IQ)** | **Microsoft Fabric 端到端闭环**<br>OneLake Shortcuts · Eventhouse KQL · Fabric IQ Ontology · Data & Operations Agents · Direct Lake | 破除 3.23 周平均库存假象：48h 法→德跨国调拨护航 **`$629.7K`** 黑五营收；声霸捆绑方案规避价保赔付净省 **`$582.1K`** 毛利；实时拦截越南渠道季度末压货返利套利 **`$162.5K`** | [🚀 启动 6 幕指挥舱](workshops/data-lab/demos/tcl-fabric/index.html) · [📖 双屏逐字稿剧本](workshops/data-lab/demos/tcl-fabric/playbook.html) · [EN](workshops/data-lab/demos/tcl-fabric/index.en.html) |
| **🛒 Demo 02 · Zava 全渠道生鲜零售 (Better Together)** | **Azure Databricks × Microsoft Fabric**<br>Lakeflow · Unity Catalog CLS & Metric Views · AI/BI Genie · Mirrored UC · Power BI Direct Lake | Lakeflow 自动拦截脏数据 + `mask_cn_phone()` 动态脱敏；Genie 5 轮追问定位华东毛利暴跌 **`-3.1pp`** 根因（昆山冷库 **`17.3h`** 出库瓶颈）并调度嘉兴仓 **`1,460 箱`**补货；零拷贝同步 Power BI | [🚀 启动 4 幕沙盘](workshops/data-lab/demos/databricks-fabric/index.html) · [⚔️ 10维选型战卡](workshops/data-lab/demos/databricks-fabric/battlecard.html) · [EN](workshops/data-lab/demos/databricks-fabric/index.en.html) |

👉 **[进入 Diamond 企业级演示总中心 (`workshops/data-lab/demos/diamond-hub.html`)](workshops/data-lab/demos/diamond-hub.html)**

---

## 📚 四大核心技术专题总览（Workshops & Playbooks）

| 专题模块 | 架构师核心覆盖范围 | 交互式工作台与视觉报告 | 验证与代码基线 |
| :--- | :--- | :--- | :--- |
| **1. [Data Lab — 企业级五云数据与 AI 选型实验室](workshops/data-lab/README.md)** · [EN](workshops/data-lab/README.en.md) | 对标 **Microsoft Fabric × Azure Databricks / Snowflake / GCP BigQuery / AWS**；收录 🏆 **100 篇（`10²` 世纪里程碑 · 双语整 200 篇！）企业架构选型 FAQ**（Microsoft IQ 四维智能层、零拷贝、实时流、CDC 镜像、向量检索、OBO 治理、安全运营 SOC/SIEM、零售/美妆护肤日化/商超生鲜/体育场馆与主题乐园票务/金融/主权基金养老金/制造/智能家居白电暖通/新能源风光储/动力电池 Gigafactory/智慧水务/铁路城轨/国际货代与报关行/医疗/连锁口腔视光 DSO/连锁宠医与宠物零售/SAP/B2B 分销/高教 EdTech/EPC 基建/专业服务律所/商业地产 REITs/医疗器械 MedTech/酒旅邮轮/商业产险/车队租赁/大宗农粮/民航 IOC/支付收单 PayFac/油气 LNG/精细化工/海运港口/晶圆封测/矿业有色融合）及 **Diamond 双旗舰沙盘** | [交互选型与 TCO 工作台](workshops/data-lab/index.html) · [7-Card 评测卡组](workshops/data-lab/benchmark-cards.html) · [Diamond 演示中心](workshops/data-lab/demos/diamond-hub.html) | `439 / 440 (99.77% · 🏆 100th=10² FAQ · 220th SVG)` 路由评估 (精确 `167.5ms / 143.42ms` 均值) · `216 / 216 (6³!)` 单测全绿 ([`tests/`](workshops/data-lab/tests)) |
| **2. [Azure AI Agent Infra 全栈架构手册 (`AKSClaw × E2B`)](workshops/azure-agent-infra/README.md)** · [EN](workshops/azure-agent-infra/README.en.md) | 6 层生产级智能体基础设施（`Build · Run · Ground · Govern`）；实测 `Standard_D96as_v7` 上 **Firecracker MicroVM `80ms` 冷启动 / `108ms` UFFD 恢复**，261 节点承载 **10 万并发沙箱**；含 **34 套 Bicep 蓝图**与 **34 项容量测算器** | [全景工作台](workshops/azure-agent-infra/index.html) · [双轨实时仿真](workshops/azure-agent-infra/demo.html) · [10万沙箱计算器](workshops/azure-agent-infra/selector.html) · [7-Card 报告](workshops/azure-agent-infra/cards.html) | `30 / 30` 单测全绿 ([`simulator/`](workshops/azure-agent-infra/simulator)) · [`blueprints/`](workshops/azure-agent-infra/blueprints) |
| **3. [FabCon & SQLCon Barcelona 2026 创新简报](workshops/fabcon-sqlcon-2026/README.md)** · [EN](workshops/fabcon-sqlcon-2026/README.en.md) | 系统拆解微软企业数据底座六大战略支柱：Fabric IQ、Power BI 智能体建站、OneLake IQ 语义共享、Osmos 自主数据工程与 Azure SQL Hyperscale DiskANN 向量索引（含 18 项 GA/Preview 矩阵） | [双语视频交互展厅 (`index.html`)](workshops/fabcon-sqlcon-2026/index.html) · [English Hub](workshops/fabcon-sqlcon-2026/index.html?lang=en) | 5 支官方实机演示视频与多码率字幕归档 |
| **4. [Azure VM 现代化评估与 FinOps 伙伴工作坊](workshops/azure-vm-modernization/README.md)** | 面向 Sales / Presales / Service 的同页三语（简/繁/英）7 模块课程、6 个合成评估案例与纯浏览器本地 CSV/XLSX TCO 及约束分析器 | [自动演示 (`demo.html`)](workshops/azure-vm-modernization/demo.html) · [课程 (`workshop.html`)](workshops/azure-vm-modernization/workshop.html) · [计算器 (`calculator.html`)](workshops/azure-vm-modernization/calculator.html) | 纯静态离线可用 · 客户价格护栏校验 |

---

## 🖼️ 核心参考架构图速览（Core Reference Diagrams）

![Azure AI Agent Infra 六层全栈参考架构图](workshops/azure-agent-infra/assets/svg/01-six-layer-architecture.svg)

![100K 并发沙箱生产拓扑与五步落地工作流](workshops/azure-agent-infra/assets/svg/08-100k-sandbox-topology.svg)

---

## ✅ 本地一键验证（Repository Verification）

```bash
# 1. 验证 Data Lab 基准评测与 216 (6³) 项单元测试
python -m unittest discover -s workshops/data-lab/tests -p "test_*.py"

# 2. 验证 Azure Agent Infra 容量测算器与 30 项单元测试
python -m unittest discover -s workshops/azure-agent-infra/simulator -p "test_*.py"
python workshops/azure-agent-infra/simulator/agent_infra_sizer.py --check
```
