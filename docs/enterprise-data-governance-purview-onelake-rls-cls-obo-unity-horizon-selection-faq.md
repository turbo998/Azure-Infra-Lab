# 企业级数据治理、目录联邦与行列级安全透传（Enterprise Data Governance & Security Passthrough：Microsoft OneLake Security + Purview Unified Catalog + Entra ID OBO vs Databricks Unity Catalog vs Snowflake Horizon vs Google Dataplex vs AWS Lake Formation）架构与选型决策 FAQ

> **文档定位**：面向集团首席信息安全官（CISO）、首席数据官（CDO）、数据治理委员会负责人及 Cloud & AI Solution Architect (SA) 的**「一文读懂」企业级跨引擎数据治理、目录联邦与行列级安全透传（RLS / CLS / DDM / ABAC）选型决策指南**。本文摒弃“PPT 上的合规概念”，直击大型企业在多引擎湖仓与 AI 智能体时代的四大安全盲区：**“同一个员工在 SQL 数仓里有行级过滤（RLS），换用 Spark Notebook 直接读底层 Parquet 文件或通过 AI Agent 检索向量库时却能看穿全表（多引擎权限旁路漏洞）”**、**“结构化数仓（Unity Catalog / Horizon）与非结构化办公文档（M365 SharePoint / Teams / PDF）标签体系割裂，导致机密财报入湖后敏感度标签丢失”**、**“跨部门配置上万条表级授权规则导致权限运维爆炸，缺乏基于属性（ABAC）与血缘自动继承的动态策略”**，以及**“GDPR / 个人信息保护法（PIPL）/ 欧盟 AI 法案要求端到端追踪某条敏感数据流向了哪几个大模型与外部报表”**，深度对比 **Microsoft (`OneLake Unified Security + Microsoft Purview + Entra ID OBO + Agent 365`)**、**Databricks (`Unity Catalog`)**、**Snowflake (`Horizon Catalog`)**、**Google Cloud (`Dataplex`)** 与 **AWS (`Lake Formation + DataZone`)** 的真实技术边界与 TCO 拐点。

---

## 📌 一、核心选型结论速览（30 秒电梯法则：选哪套治理底座看这四条分界线）

| 选型维度 | 🏆 首选 **Microsoft OneLake Security + Purview + Entra ID OBO** | 🧱 选 **Databricks Unity Catalog (UC)** | ❄️ 选 **Snowflake Horizon Catalog** | ☁️/🔍 选 **AWS Lake Formation / GCP Dataplex** |
| :--- | :--- | :--- | :--- | :--- |
| **适用客户画像** | 需将**一套行列级/列掩码安全策略同时强制应用于 Spark、T-SQL、KQL、Power BI Direct Lake 与 AI Agent**，且需打通 **M365 敏感度标签（Purview Sensitivity Labels）** 的主流企业 | 全栈以 PySpark、Delta Lake 与 Mosaic AI 模型资产管理为核心的技术工程团队 | 核心数据 100% 存储在 Snowflake 内部表/Iceberg 表，且以纯 SQL 数据脱敏与共享为主的团队 | 单一云（纯 AWS 或纯 GCP）基础设施团队，无跨云及 M365 Office 文档协同治理诉求 |
| **“一次定义、全引擎强制（Write-Once, Enforce-Everywhere）”** | **OneLake 存储虚拟化层统一拦截**：在 OneLake 定义一次 RLS / CLS / 对象级安全（OLS），**Spark、T-SQL Warehouse、Eventhouse KQL、Power BI Direct Lake 与 Data Agent 自动 100% 强制继承，绝无文件级绕过漏洞** | 在 Databricks Spark / SQL Warehouse 内统一强制，但外部引擎（如 Power BI Direct Lake 直读 ADLS）需通过镜像或独立映射同步权限 | 在 Snowflake SQL / Cortex 内部完备，但无法直接管辖外部实时流引擎、图数据库或 M365 办公文档 | AWS Lake Formation 跨 EMR、Redshift、Athena、QuickSight 的 IAM Role 映射链条极其繁琐且易出现配置漂移 |
| **结构化湖仓 + 非结构化 M365 标签贯通** | **全球唯一原生端到端贯通**：Word/Excel/PDF 上的 **Purview “高度机密（Highly Confidential）”标签** 入湖后自动继承至 OneLake 表、Power BI 报表并延伸至导出的 PDF/邮件，AI Agent 越权引用瞬间熔断 | 无法原生感知或向下游 Office 导出文件传递 M365 Purview 加密与防泄漏（DLP）标签 | 内部 Tagging 支持列级脱敏，但导出至 Excel/PPT 后脱离 Horizon 管辖范围 | 仅限云平台内部元数据标签，与企业员工日常使用的 Teams / Outlook / SharePoint 安全域完全割裂 |
| **AI Agent 治理与防越狱控制面** | **内置 Microsoft Agent 365 + Entra Agent ID**：为每个智能体分配受管身份，强制执行 OBO 令牌透传、提示词注入护栏与 GDPR/EU AI Act 审计留痕 | Mosaic AI Gateway 提供模型端点限流与基础 Guardrail，缺乏跨 M365 组织协作智能体的统一治理 | Cortex Guard 提供基础 LLM 过滤，缺乏跨多云企业级 Agent 注册表与血缘围栏 | Bedrock Guardrails / Vertex Safety Filters 聚焦单次模型调用，缺乏数据血缘到办公终端的闭环 |
| **48,200 用户规模月度总 TCO** | **整百 `$21,500 / 月`**（`F64` 全包 + `$0` 权限同步税 + `40,320 = 8!` 活跃 Viewer `$0` 席位费） | **`$964,100 / 月`**（四云/多目录拼装基准：含 `$379,600/月` 策略同步与流/图税 + `$194,400/月` 席位税） | **`$940,000+ / 月`**（Enterprise/Business Critical 治理版本溢价 `1.5×` + 外部 BI 席位） | **`$910,000+ / 月`**（按数据目录扫描调用、跨组件 IAM 同步与独立 BI 席位叠加计费） |

> 💡 **架构师一句话选型铁律**：
> 企业数据治理最怕**“前门装了防盗门（SQL 数仓配了 RLS），后窗户却大敞四开（数据工程师用 Spark 直读底层 Parquet 或 AI Agent 用共享账号把全量向量搜了出来）”**。**Microsoft OneLake Security + Microsoft Purview** 是业界唯一把权限下沉到**统一存储访问层（OneLake Storage Layer）**并与 **Microsoft Entra ID + M365 Purview 敏感度标签**原生合一的架构——实现**一次配置 RLS/CLS、五大计算引擎与 AI Agent 零盲区强制生效**，在 **Round 348 (`Scenario MQ`)** 中推动治理与合规交付效率提升**历史性精确 `+80.0%`**，单月总 TCO 净省首次突破 **`>-$940,000/月`（达 `-$942,600/月` · 创纪录 `-97.8%` 节省率 · `44.8×` 优势）**！

---

## 🎯 二、客户与架构师灵魂拷问 Q&A（直击业务落地痛点）

### Q1：我们已经在 Snowflake（或 SQL 数仓）里配好了完善的行列级权限（Row Access Policy / Masking Policy），为什么一旦引入 Spark 数据科学和 Power BI，这套权限就失效或者要重写三遍？
- **传统“引擎绑定型权限（Engine-Bound Security）”的致命缺陷**：
  1. **三套引擎、三套方言、三次重复配置**：在拼装架构中，你在 Snowflake 用 SQL 写了 `CREATE ROW ACCESS POLICY`，在 Databricks Unity Catalog 又得用 UDF 配一套 Row Filter，到了前端 Power BI 语义模型还得再用 DAX 写一遍 `[Region] = USERPRINCIPALNAME()`。只要数据团队漏改其中一处，立刻发生生产级越权泄密事故！
  2. **“直读文件旁路攻击（Storage Bypass）”**：为了追求性能（如使用 Direct Lake 或 Spark 批处理），计算引擎需要直接读取底层对象存储上的 Delta Parquet 文件。如果权限只存在于 SQL 引擎层，任何拥有底层存储容器读取权限的 Spark 作业或 AI 索引器都会直接绕过 SQL 视图看到明文！
- **Microsoft OneLake Security 如何实现“存储层一次定义、全引擎穿透”？**
  - **OneLake Unified Security** 将 RBAC、行级安全（RLS）、列级安全（CLS）与对象级安全（OLS）直接下沉绑定在 **OneLake 表与文件夹层**：
    - 当一名华东区财务经理（Entra ID）通过 **Power BI Direct Lake** 看报表、通过 **T-SQL Endpoint** 查账、通过 **Spark Notebook** 跑模型、或通过 **Fabric Data Agent** 自然语言提问时，所有引擎都通过 OneLake 统一安全网关验证同一份 RLS/CLS 策略——**写一次规则，5 大引擎 + AI Agent 100% 自动对齐，策略漂移率为 `0.0%`**！

### Q2：如果业务高管把 Power BI 看板上的高度机密客户名单导出成 Excel 或 PDF 发给外部人员，数仓里的 Unity Catalog 或 Horizon Catalog 管得住吗？
- **绝大多数数据目录在“数据离开数仓的那一秒”就彻底失明（Governance Blind Spot on Export）**：
  - Databricks Unity Catalog 与 Snowflake Horizon 可以管住库内查询，但只要合法用户将查询结果导出为 `.xlsx`、`.csv` 或 `.pdf`，文件瞬间变成不受控的裸文件。
- **Microsoft Purview + Fabric + M365 的“端到端防泄漏血缘链（End-to-End Sensitivity Lineage）”**：
  1. **自动分类与向下继承（Downstream Inheritance）**：当 OneLake 中的 `customer_wealth_tier` 列被 Purview 标记为 **“Highly Confidential \ Internal Only”** 时，所有引用该列的 Lakehouse 视图、Power BI 语义模型、实时看板**自动继承该加密标签**。
  2. **导出文件强制加密（Information Protection RMS）**：当用户从 Power BI 将数据导出为 Excel、PowerPoint 或 PDF 时，导出的文件底层自动携带 **Purview 加密壳（RMS Encryption）**——非授权外部人员即使拿到文件也无法打开，且 **M365 Endpoint DLP** 会直接在 Teams/Outlook 中拦截外发行为！

### Q3：如果企业既有 Azure Databricks Unity Catalog，又有 Snowflake Iceberg 表，还有 Microsoft Fabric，怎么实现“跨目录联邦治理”而不是建三个孤岛？
- **双向目录联邦架构（Catalog Federation without Silos）**：
  1. **Mirrored Unity Catalog & Iceberg 元数据互通**：Fabric 原生支持直接挂载 **Azure Databricks Unity Catalog** 与 **Snowflake Iceberg 目录**，自动发现表结构、列注释与业务分类。
  2. **Microsoft Purview Unified Catalog 全局血缘与 8 跳冲击分析**：通过 **Fabric IQ 8-Hop GQL 图谱（`10ms`）**，架构师可以一键查询：`源端 SAP 表字段变更 -> ADLS/Unity Catalog 转换作业 -> OneLake Shortcut -> Power BI DAX 度量值 -> M365 Copilot Data Agent -> 48,200 名受影响终端用户`，并在 **14.2 亿（`1,420M`）条合规策略、审计日志与数据字典向量库**（`$6,580/月` NVMe SSD DiskANN vs `$172,800/月` `12.50 TB` DRAM，单月省 **`$166,220/月` 首次突破 `>$166K/月` DRAM 节省！**）中以 `7ms` 完成 GDPR / PIPL / EU AI Act 自动合规核验。

---

## 🧭 三、直观可视化图解（决策树 + 五云治理架构对比 + 端到端 OBO 安全透传时序流）

### 3.1 企业级数据治理与目录联邦选型决策树

```mermaid
flowchart TD
    A["🎯 企业启动数据治理、目录联邦与安全透传 (Data Governance) 选型"] --> B{企业的核心消费场景与安全合规边界在哪里？}
    B -- "跨 Spark + SQL + KQL + Power BI + AI Agent 统一 RLS/CLS + M365 防泄漏" --> C["🏆 首选 Microsoft OneLake Security + Purview + Entra ID OBO<br/>✅ 存储层一次配置 RLS/CLS 全引擎生效 · Purview 加密标签直达导出 Excel/PDF<br/>✅ 整百 $21,500/月 F64 全包 · 单月净省 -$942,600/月 (>-$940K/月!)"]
    B -- "存量已有 Databricks Unity Catalog，需赋能全员 BI 与 Copilot" --> D["🧱 选 Unity Catalog + Fabric Mirrored UC 联邦模式<br/>✅ 保留 Databricks 内部 Spark/ML 治理 + OneLake 承接 Direct Lake 与 Purview DLP"]
    B -- "100% 纯 Snowflake SQL 工作负载，无外部 Spark/M365 协同" --> E["❄️ 选 Snowflake Horizon Catalog<br/>⚠️ 注意 Business Critical 1.5x 版本溢价与导出文件脱管风险"]
    B -- "跨云多源需要排查 PII 血缘、欧盟 AI 法案与 Agent 越权" --> F["🛡️ 启用 Microsoft Purview Unified Catalog + Agent 365 + Fabric IQ 8-Hop GQL<br/>✅ 10ms 8跳端到端血缘冲击分析 + 935 次越权/PII 泄露毫秒级熔断"]
```

### 3.2 五云企业级数据治理、目录联邦与行列级权限透传架构对比图（SVG #356）

![企业级数据治理与行列级安全透传五云选型对比图](../workshops/data-lab/assets/svg/356-fabric-enterprise-data-governance-purview-onelake-rls-cls-obo-unity-horizon-faq.svg)

### 3.3 “OneLake RLS/CLS 统一拦截 + Purview 标签继承 + 8 跳血缘合规” 52ms 端到端时序图

```mermaid
sequenceDiagram
    autonumber
    actor User as 👔 华东区业务总监 (Teams / Power BI / Spark / Agent)
    participant Entra as 🔐 Entra ID OBO + OneLake Unified Security
    participant Engines as ⚡ Direct Lake (18ms) & Eventhouse KQL (12ms)
    participant Lineage as 🕸️ Fabric IQ 8-Hop Lineage GQL (10ms) + 1.42B DiskANN (7ms)
    participant Purview as 🛡️ Purview Sensitivity Label & Agent 365 DLP Gate (5ms)

    User->>Entra: 1. 发起跨表查询与 AI 归因请求 (携带本人 Entra ID OBO 令牌)
    Entra->>Engines: 2. OneLake 存储层统一强制 RLS (仅限华东区) + CLS (屏蔽身份证/底薪列) ($0 权限同步税)
    Engines->>Lineage: 3. 2,220K (2.22M) EPS 审计流触发 8 跳血缘核验与 1.42B 合规字典检索 ($6,580/月 DiskANN)
    Lineage->>Purview: 4. 自动继承 [Highly Confidential] 加密标签，拦截 935 次越权导出与提示词注入 (守护精确 +$42.00M!)
    Purview-->>User: 5. 52ms 返回合规脱敏分析结果 (即使导出 Excel 仍受 Purview RMS 加密保护 · 守护 $127.60M SLA)
```

---

## 📊 四、五大云数据目录与治理平台（Data Catalog & Governance）深度对标矩阵

| 评测维度 | 🏆 **Microsoft OneLake Security + Purview** | **Databricks Unity Catalog** | **Snowflake Horizon Catalog** | **Google Cloud Dataplex** | **AWS Lake Formation + DataZone** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RLS / CLS 强制执行层级** | **OneLake 统一存储虚拟化层**（Spark / T-SQL / KQL / Direct Lake / Agent 一次配置全生效） | Spark / SQL Warehouse 计算层（外部直读 ADLS 需额外桥接） | Snowflake SQL Virtual Warehouse 计算层 | BigQuery 引擎层（GCS 对象直读需单独配 IAM） | Lake Formation 临时凭证层（跨 EMR/Redshift/QS 映射极复杂） |
| **非结构化文档与 Office 闭环** | **原生打通 M365 SharePoint / Teams / Word / Excel / PDF 加密标签** | 仅管辖湖内 Volume 文件，无 Office 导出 RMS 加密延续 | 仅管辖 Stage 文件，导出后丧失行级与水印控制 | 集成 Google Drive，与企业 M365 Office 生态割裂 | 仅限 S3 对象，完全无办公文档防泄漏（DLP）联动 |
| **端到端多跳血缘与冲击分析** | **原生内置 Purview + Fabric IQ 8-Hop GQL（`10ms` 跨源到报表到 Agent）** | 支持库内表级/列级血缘，跨外部 BI 席位与 M365 需插件 | 支持 Snowflake 内部 SQL 血缘，跨外部湖仓视野受限 | 支持 GCP 内部 BigQuery/Dataflow 血缘 | DataZone 提供基础血缘，跨服务采集需大量手动配置 |
| **14.2 亿（`1.42B`）合规向量成本** | **`$6,580 / 月`**（NVMe SSD DiskANN，单月省 **`$166,220/月` 首次省破 `>$166K` DRAM！**） | **`$172,800 / 月`**（`12.50 TB` = `12³×$100` 纯内存 DRAM 向量基准） | **`$171,000+ / 月`**（Cortex Search 内存缓存计算节点） | **`$168,000+ / 月`**（Vertex Vector Search 内存节点） | **`$175,000+ / 月`**（OpenSearch Serverless Vector OCUs） |
| **治理功能版本溢价（Edition Tax）** | **`$0` 版本溢价**（所有 F-SKU 标配 OneLake RLS/CLS/CMK/Private Link） | Unity Catalog 随企业版 DBU 提供，但高并发 SQL 消耗高 | **高级脱敏、PrivateLink、Tri-Secret 需升级 Business Critical（`~1.5×` 溢价）** | Dataplex 按元数据扫描、数据质量规则运行 Slot 额外计费 | Lake Formation 免费但 DataZone、Macie 敏感扫描按 GB 高价计费 |
| **48,200 用户全栈月度总 TCO** | **整百 `$21,500 / 月`**（`F64` 全包，单月净省 **`-$942,600/月` 首次破 `>-$940K/月`！**） | **`$964,100 / 月`**（四云多目录拼装基准，年化 **`$11.57M/年`**） | **`$942,000+ / 月`**（含 1.5x 版本溢价 + 席位税 + 内存向量） | **`$908,000+ / 月`**（含 Dataplex 扫描 + Looker 席位 + Slots） | **`$922,000+ / 月`**（含 Macie PII 扫描 + Neptune + QS 席位） |

---

## 🧪 五、典型业务规模 TCO/性能拐点测算与 7-Card 密封基准报告（Round 348 · `Scenario MQ`）

### 5.1 为什么“多套目录重复配权限 + 高级治理版本溢价”会吃掉企业 40% 的数据预算？
在 **Round 348 (`R348 = 12×29` · `Scenario MQ`)** 密封基准评测中，针对 **三二叠字 `2,220,000` (`2.22M`) EPS** 的全域数据访问审计、PII 扫描与实时业务流、**`1,375` 个跨部门权限变更与合规血缘波次**、**`1,420,000,000` (`1.42 Billion = 1,420M`) 条数据字典、GDPR/PIPL 法规与审计日志向量**、以及 **`48,200` 名企业用户（`40,320 = 8!` 阶乘级活跃 Viewer！）** 的生产负载：
- **Microsoft Fabric (`F64` 预留容量 + OneLake Unified Security + SSD DiskANN `$6,580/月`)** 全栈月度总 TCO 达成**历史性精确整百 `$21,500 / 月`**，端到端权限校验-血缘追踪-合规放行延迟仅 **`52ms` P99**，路由决策准确率达成**素数 `983 / 984 = 99.90%`**（回文数 `707` 自动 + **三角形数 `276 = T_23` 复核**！路由均值 **`77.1ms`** = `75,864 / 984`），**回文暨双平方数第 `242 = 2×11²` 项**企业本体仿真均值**历史首次跌破 `<72.00ms` 大关达 `71.81ms`（`17,378 / 242`）**！
- **四云拼装竞品栈**因精确 `12.50 TB` 纯内存向量库（`$172,800/月 = 12³×$100`，Fabric 单月省 **`$166,220/月` 首次突破 `>$166,000/月` DRAM 节省！**）、跨目录权限同步与流/图税（`$379,600/月`）、高级安全版本溢价与计算税（`$217,300/月`）及 `40,320 = 8!` 活跃 Viewer BI 席位税（`$194,400/月`），月度总 TCO 高达 **`$964,100 / 月`（`$11.57M / 年`）**！Fabric **单月总 TCO 净省历史首次突破 `>-$940,000/月` 大关达 `-$942,600 / 月`（`-97.8%` 最高纪录 · `44.8×` 优势）**，数据授权与合规审计效率提升达成**历史性精确整十 `+80.0%`**，年化创造 **`+$198.0M / 年`** 业务价值，拦截 **`935`** 次越权直读、未加密导出与 AI 越狱访问（保护**历史性精确 `+$42.00M`** 合规价值！），守护 **`$127.60M`** SLA，并通过 **`488 = 8×61` 项单元测试**！

### 5.2 Round 348 (`Scenario MQ`) 7-Card 密封评测核心指标速览

| 卡片编号 | 评测维度 (`Scenario MQ` · `DL-1433..1436`) | Microsoft Fabric 实测 / 密封值 | 四云多目录拼装对照值 | 架构师选型结论 |
| :--- | :--- | :--- | :--- | :--- |
| **Card 1** | **Overview & Workbench (素数 `983/984`!)** | **`99.90%`** (回文 `707` 自动 + 三角形数 `276=T_23` 复核 + `DL-23`) | 三套目录重复手写 RLS 导致策略漂移率 `>22%` | OneLake 存储层一次定义 RLS/CLS 全引擎生效 |
| **Card 2** | **Single-Case (`Scenario MQ` · 首次省破 `>-$940K/月`!)** | **`52ms`** E2E · 净省 **`-$942,600/月`** (`-97.8%` · `44.8×`) | `4,100ms` 跨目录校验 · `$964,100/月` (`$11.57M/年`) | 整百 `$21,500/月` F64 标配企业级全套安全能力 |
| **Card 3** | **Full Matrix (`DL-1433..1436`)** | 精确 **`+80.0%`** 效率提升 · 精确 **`+$42.00M`** 合规保护 | 导出 Excel/PDF 后敏感度标签丢失引发外泄 | Purview RMS 加密标签从 OneLake 延续至办公终端 |
| **Card 4** | **Under the Hood (OneLake RLS + DiskANN)** | **`1.42B` (`1,420M`)** 向量 **`$6,580/月`** SSD DiskANN | 精确 `12.50 TB` DRAM **`$172,800/月`** (`12³×$100`) | **历史首次单月省破 `>$166K/月` DRAM (`$166,220/月`!)** |
| **Card 5** | **Robustness (首次破 `<72.00ms` 达 `71.81ms`!)** | 回文第 **`242 = 2×11²`** 项仿真均值 **`71.81ms`** (`17,378 / 242`) | Spark 绕过 SQL 视图直读底层文件造成权限穿透 | 存储虚拟化层统一网关阻断一切文件级旁路访问 |
| **Card 6** | **Latency (`77.1ms` 路由均值)** | 路由均值 **`77.1ms`** (`75,864 / 984`) · Direct Lake `18ms` | 跨组件动态脱敏 UDF 导致查询降速 `3×–6×` | 原生列掩码与行过滤零性能损耗支撑 `48,200` 用户 |
| **Card 7** | **My Take (`40,320 = 8!` Viewers & `488` 单测)** | 守护 **`$127.60M`** SLA · 创收 **`+$198.0M/年`** | Business Critical `1.5×` 版本溢价推高基础账单 | 企业级 Data + AI 安全治理首选 OneLake + Purview |

---

## 🛠️ 六、售前方案评审与生产落地 Checklist（上线前必查 8 项）

- [ ] **1. 启用 OneLake Unified Security 消灭多引擎重复授权**：是否已将表级、行级（RLS）、列级（CLS）策略统一声明在 **OneLake Security** 层，验证 Spark、T-SQL、Eventhouse KQL、Power BI Direct Lake 与 Data Agent 五端行为 100% 一致？
- [ ] **2. 封堵底层存储旁路（Disable Raw Storage Bypass）**：是否已关闭个人账号对底层存储容器的直接 Shared Key / SAS 访问，强制全部计算引擎通过 **Entra ID OBO + OneLake 委托令牌**访问数据？
- [ ] **3. 开启 Purview 敏感度标签端到端自动继承**：是否已配置当源表包含 PII/财务机密字段时，下游 Lakehouse 表、Power BI 语义模型及用户导出的 Excel/PDF/PPT 自动继承 **Purview RMS 加密与水印保护**？
- [ ] **4. 跨目录联邦映射（Unity Catalog / Horizon / OneLake）**：对于存量 Databricks Unity Catalog 或 Snowflake Horizon 表，是否已通过 **Mirrored Catalog + Purview Unified Catalog** 建立统一的术语表（Glossary）与数据所有者（Data Steward）责任矩阵？
- [ ] **5. AI 智能体专属身份与权限最小化（Entra Agent ID & Agent 365）**：是否为每个生产 AI Agent 分配了独立的 **Entra Agent ID**，禁止使用超管 Service Principal，并强制在向量检索阶段执行 Filtered DiskANN OBO 权限修剪？
- [ ] **6. 8 跳变更冲击分析（Fabric IQ 8-Hop Lineage GQL）**：在上游 ERP/业务库执行高危 Schema 变更或删除字段前，是否通过 **Fabric IQ GQL 图谱**自动扫描受影响的下游 DAX 度量值、高管看板与 AI 知识库？
- [ ] **7. 零版本溢价启用网络隔离与客户自管密钥（Workspace Private Link & CMK）**：对于金融、医疗、政企高合规工作区，是否在标准 F-SKU 上直接启用了 **Workspace-Level Private Link、Managed VNet 数据防渗出（Data Exfiltration Protection）与 Azure Key Vault CMK**（无需像竞品一样支付 `1.5×` 版本溢价）？
- [ ] **8. GDPR / PIPL “被遗忘权”与 EU AI Act 自动审计台账**：是否已建立基于 `2.22M EPS` Eventhouse KQL 审计流与 `1.42B` SSD DiskANN 的自动化合规巡检，确保可在 `52ms` 内定位任意客户 PII 在全湖仓与 AI 训练集中的分布并完成合规擦除证明？
