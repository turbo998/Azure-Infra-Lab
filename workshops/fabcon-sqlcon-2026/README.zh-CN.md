# FabCon & SQLCon Barcelona 2026：Microsoft Fabric 与 SQL 创新发布深度简报（中文版）

> 🌐 **版本切换 / Navigation**: **[📘 双语总入口 (`README.md`)](README.md)** | **[🇬🇧 English Edition (`README.en.md`)](README.en.md)** | **[🎬 在线交互式视频简报 H5 (`index.html`)](https://turbo998.github.io/Azure-Infra-Lab/workshops/fabcon-sqlcon-2026/index.html)** | **[🏠 返回 Azure Infra Lab 主页](../../README.zh-CN.md)**

- **原文标题**：*FabCon and SQLCon 2026: Explore Microsoft Fabric and SQL innovations*
- **原文作者**：Arun Ulag（微软 Azure Data 执行副总裁 / EVP, Azure Data）
- **发布日期**：2026 年 9 月 29 日（2026 年 10 月 9 日更新）
- **峰会地点**：西班牙巴塞罗那（FabCon & SQLCon Europe 2026，近 5,000 名数据专业人士参会）
- **官方原文链接**：<https://azure.microsoft.com/en-us/blog/fabcon-and-sqlcon-2026-in-barcelona-building-the-data-foundation-for-microsoft-copilot-and-agents/>

---

## 一、 高管摘要与核心规模指标 (Executive Summary)

随着企业加速部署 Microsoft Copilot 与智能体（Agents），AI 落地的核心瓶颈已从“模型能力”转向**“数据底座与业务上下文治理”**：若智能体无法安全访问完整数据资产并理解业务术语、指标口径、实体关系与安全边界，其输出就无法支撑生产级决策。

在巴塞罗那 FabCon & SQLCon 2026 峰会上，微软围绕 **“为 Microsoft Copilot 与智能体构建可信企业数据底座”** 发布了横跨 **Fabric IQ、Power BI 智能体应用构建、Rayfin (Fabric Apps)、OneLake 开放数据网络、自主数据工程智能体 (Osmos)、全链路可观测性与按需计费、Database Hub 以及 Azure SQL Hyperscale / 主权云** 的全栈创新：

| 关键生态指标 | 披露数据 | 核心演进亮点 |
| --- | --- | --- |
| **Microsoft Fabric 企业客户数** | **40,000+ 家全球企业** | 包括 Levi Strauss & Co.、H&M Group、Thomson Reuters 等行业领军企业 |
| **Power BI 全球客户覆盖** | **425,000+ 家客户** | 引入 Agentic App Creation（自然语言构建支持数据回写与状态保持的业务应用）及每应用最高 1GB 免费 Fabric SQL |
| **SQL Server 企业渗透率** | **>90% 财富 500 强** | Azure SQL Hyperscale 升级至 192 vCore (GA)、Serverless 自动暂停（预览）、DiskANN 向量索引全面 GA |
| **实机演示视频** | **5 支官方高清 MP4** | 覆盖 Fabric IQ in M365、Power BI Agentic Apps、Rayfin SDK、OneLake IQ Sharing 与 Fabric 全链路可观测性 |

---

## 二、 5 支微软官方实机演示视频与多码率直链 (Official Demo Videos)

> 💡 **在线内嵌播放**：打开 **[交互式双语 H5 简报 (`index.html`)](https://turbo998.github.io/Azure-Infra-Lab/workshops/fabcon-sqlcon-2026/index.html)** 即可直接在页面内观看全部 5 支高清实机演示视频。以下为微软官方 CDN 各清晰度 MP4、字幕与音频文稿直链：

| 序号 | 演示视频名称 | 发布状态 | 实机演示核心内容 | 官方 CDN 视频与字幕直链 |
| --- | --- | --- | --- | --- |
| **Demo 01** | **Powering Microsoft Copilot with Fabric IQ**<br>(`1117414-fabriciqinm365`) | **GA**<br>(Chat & Cowork) | 演示 Microsoft Copilot（Home / Chat / Cowork）如何直接调取 Fabric IQ 与 Power BI 语义模型中的受治理业务指标、本体（Ontology）和企业上下文，**零额外 AI Token 成本**生成可信决策建议。 | • [▶ 1080p HQ (MP4)](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-fabriciqinm365-0x1080-6439k)<br>• [720p HD](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-fabriciqinm365-0x720-3266k) · [540p SD](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-fabriciqinm365-0x540-2160k) · [360p LO](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-fabriciqinm365-0x360-958k)<br>• [CC 字幕 (TTML)](https://www.microsoft.com/content/dam/microsoft/bade/videos/products-and-services/en-us/azure/1117414-fabriciqinm365/1117414-fabriciqinm365_cc_en-us.ttml) · [封面图](https://cdn-dynmedia-1.microsoft.com/is/image/microsoftcorp/1117414-fabriciqinm365_tbmnl_en-us?wid=1280) |
| **Demo 02** | **The Next Evolution of Power BI: Agentic App Creation**<br>(`1117414-futureofpowerbi`) | **Preview**<br>(Power BI Desktop) | 演示在 Power BI Desktop 中从可信语义模型出发，用自然语言生成具备数据录入、**数据回写 (Write-back)**、状态保持、身份认证与最多 **1GB 免费 Fabric SQL 数据库**的完整业务应用（向 Pro / PPU / Fabric 容量用户免费开放）。 | • [▶ 1080p HQ (MP4)](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-futureofpowerbi-0x1080-6439k)<br>• [720p HD](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-futureofpowerbi-0x720-3266k) · [540p SD](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-futureofpowerbi-0x540-2160k) · [360p LO](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-futureofpowerbi-0x360-958k)<br>• [📄 英文文稿 (Transcript)](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-futureofpowerbi_transcript_en-us) · [🔊 音频 (Audio)](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-futureofpowerbi_audio_en-us) · [CC 字幕 (TTML)](https://www.microsoft.com/content/dam/microsoft/bade/videos/products-and-services/en-us/azure/1117414-futureofpowerbi/1117414-futureofpowerbi_cc_en-us.ttml) |
| **Demo 03** | **Prompt to Production with Fabric Apps & Rayfin SDK**<br>(`1117414-agenticappdevdemo`) | **Available**<br>(Rayfin SDK & CLI) | 演示开发者与编程智能体利用开源 **Rayfin SDK 与 CLI** 构建应用并一键部署到 Fabric，直连 Warehouse/SQL/Lakehouse/语义模型，展示新增的 **TypeScript 后端函数、Secret Store、PostgreSQL 支持与默认私有访问**。 | • [▶ 1080p HQ (MP4)](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-agenticappdevdemo-0x1080-6439k)<br>• [720p HD](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-agenticappdevdemo-0x720-3266k) · [540p SD](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-agenticappdevdemo-0x540-2160k) · [360p LO](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-agenticappdevdemo-0x360-958k)<br>• [📄 英文文稿 (Transcript)](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-agenticappdevdemo_transcript_en-us) · [🔊 音频 (Audio)](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-agenticappdevdemo_audio_en-us) · [CC 字幕 (TTML)](https://www.microsoft.com/content/dam/microsoft/bade/videos/products-and-services/en-us/azure/1117414-agenticappdevdemo/1117414-agenticappdevdemo_cc_en-us.ttml) |
| **Demo 04** | **OneLake IQ Sharing: Governed Data & Context Sharing**<br>(`1117414-iqsharing`) | **Preview**<br>(OneLake Network) | 演示通过 **OneLake IQ Sharing** 跨团队、客户与合作伙伴生态安全共享受治理表、文件、**Markdown 智能体指令与 RDF 本体**（EY、S&P Global、TomTom、Financial Fabric、xMentium 已率先集成）。 | • [▶ 1080p HQ (MP4)](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-iqsharing-0x1080-6439k)<br>• [720p HD](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-iqsharing-0x720-3266k) · [540p SD](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-iqsharing-0x540-2160k) · [360p LO](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-iqsharing-0x360-958k)<br>• [📄 英文文稿 (Transcript)](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-iqsharing_transcript_en-us) · [🔊 音频 (Audio)](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-iqsharing_audio_en-us) · [CC 字幕 (TTML)](https://www.microsoft.com/content/dam/microsoft/bade/videos/products-and-services/en-us/azure/1117414-iqsharing/1117414-iqsharing_cc_en-us.ttml) |
| **Demo 05** | **End-to-End Observability & Operations Agents in Fabric**<br>(`1117414-eumerged`) | **Preview**<br>(Platform Operations) | 演示 **Workspace Monitoring**（跨工作区遥测汇聚至单一 Eventhouse）、**Monitor Hub**（容量余量视图 + Activator 作业告警）以及 **Operations Agent**（AI 辅助根因调查与预授权修复动作）。 | • [▶ 1080p HQ (MP4)](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-eumerged-0x1080-6439k)<br>• [720p HD](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-eumerged-0x720-3266k) · [540p SD](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-eumerged-0x540-2160k) · [360p LO](https://cdn-dynmedia-1.microsoft.com/is/content/microsoftcorp/1117414-eumerged-0x360-958k)<br>• [CC 字幕 (TTML)](https://www.microsoft.com/content/dam/microsoft/bade/videos/products-and-services/en-us/azure/1117414-eumerged/1117414-eumerged_cc_en-us.ttml) · [封面图](https://cdn-dynmedia-1.microsoft.com/is/image/microsoftcorp/1117414-eumerged_tbmnl_en-us?wid=1280) |

---

## 三、 六大核心发布板块深度拆解 (6 Strategic Innovation Pillars)

### 支柱一：Fabric IQ 深度赋能全新 Microsoft Copilot（Frontier 转型核心）
- **共享智能层 (Fabric IQ)**：将 OneLake 统一数据、Power BI 可信语义指标、Ontology（业务本体）与 Real-Time Intelligence（实时情报）融合成人机共用的业务语义层。
- **Microsoft Copilot Chat & Cowork 正式版 (GA)**：M365 Copilot 用户现可在日常工作流（Copilot Home、Chat、Cowork）中直接调取 Fabric 业务洞察，且**无需额外消耗 AI Token 成本**；全新的 **Copilot Code** 集成也即将通过 Frontier 计划推出。
- **零改造成果复用**：企业多年来在 Power BI 语义模型与报表中沉淀的指标定义、实体关系与行级安全策略（RLS），直接成为 Copilot 与智能体的可信决策依据。

### 支柱二：Power BI 的下一代演进——智能体应用构建 (Agentic App Creation) 与 Rayfin 全栈投产
- **从“看数”走向“行动” (Agentic App Creation in Power BI, Preview)**：在 Power BI Desktop 中，用户基于可信语义模型通过自然语言即可生成完整的交互式业务应用——支持**用户输入、数据回写 (Data Write-back)、跨会话共享状态与业务工作流**，彻底消除导出 Excel 或跨工具手工搬运数据的断层。
- **普惠授权与内置 SQL 数据库**：该能力不仅面向 Fabric 容量客户，也**向所有 Power BI Pro 和 PPU（Premium Per User）用户免费开放**，且每个应用自带最高 **1GB 的 Fabric SQL 数据库**（含内置身份认证、权限治理与共享机制）。
- **开源 Rayfin SDK 与 CLI 持续增强 (Fabric Apps)**：自 2026 年 6 月推出 Fabric Apps 与开源 Rayfin SDK/CLI 以来，已有数千名开发者使用。本次更新支持：
  - 应用与智能体直连 **Fabric Data Warehouse、SQL Database、Lakehouse 与 Power BI 语义模型**；
  - 新增 **TypeScript 后端函数**、**Secret Store（密钥保管库）**、**PostgreSQL 支持**、**默认私有访问 (Private-by-default access)** 以及内置应用性能指标。

### 支柱三：OneLake 开放数据网络——IQ Sharing 与多云生态互联
- **OneLake IQ Sharing（预览）**：随着 Agent 承担更多业务工作，光共享原始表已远远不够，还必须共享业务语义。IQ Sharing 支持跨团队、客户和合作伙伴边界安全共享**受治理表、文件、Markdown 智能体指令与 RDF 本体**（路线图即将原生支持 Fabric IQ 本体与 Power BI 语义模型）。
- **首批合作伙伴生态**：**EY（安永）、S&P Global（标普全球）、TomTom、Financial Fabric 与 xMentium** 已率先接入 IQ Sharing，其受治理数据产品与语义上下文可在 OneLake 目录中直接发现并供智能体调用。
- **跨云零拷贝互联与工具链集成**：
  - **Salesforce Data 360 双向零拷贝集成（预览）**：无需移动或复制数据，即可将 Salesforce Data 360 纳入 OneLake 并供 Fabric Data Agents 使用；
  - **Google BigQuery 镜像（正式版 GA）** 与 **Dynamics 365 Business Central** 深度集成；
  - 深化与 **Atlan、dbt、ClickHouse** 的开放生态协作。

### 支柱四：自主数据工程智能体 (Osmos) 与实时情报 Copilot
- **Fabric Data Engineering Agent（预览）**：基于微软 2026 年 1 月收购的 **Osmos**（智能体数据工程领军企业）技术构建，可在受控工作区权限下**自主规划并执行数据平台迁移、Lakehouse 现代化、性能调优与复杂 ETL 流水线**。
- **跨开发工具无缝接力**：支持在 Fabric 门户以及 **GitHub Copilot、VS Code、Codex 与 Claude Code** 中启动、监控和引导同一数据工程任务。
- **Real-Time Intelligence Copilot（预览）**：支持用自然语言创建实时看板（Real-Time Dashboards）、管理 Eventhouse 表/策略/日常运维、获取表与 Schema 成本性能调优建议，并结合 Operations Agent 实现 AI 故障根因诊断。

### 支柱五：Agentic 本体构建、Apache Ossie 开放标准、全栈可观测性与按需计费
- **Agentic Ontology 构建与 Apache Ossie**：
  - 支持从现有 Power BI 语义模型、OneLake 数据及非结构化文档自动构建业务本体（预览），支持用自然语言定义业务规则并直接复用 Power BI 度量值；
  - 微软联合 **Snowflake** 等行业伙伴共同推进 **Apache Ossie (Incubating)** 项目，打造跨分析引擎、BI 工具与 AI 系统的开放互操作语义元数据标准。
- **Fabric Agents 升级（预览）**：
  - **Data Agents** 深度融合 Fabric IQ 本体，提供更高准确率与可解释性，并推出读取数据字典与业务术语表的 AI 辅助构建模式；
  - **Operations Agents** 新增**预授权修复动作 (Pre-approved actions)** 与 **AI 根因分析 (RCA)**。
- **全链路可观测性 (End-to-End Observability, Preview)**：
  - **Workspace Monitoring** 将多个工作区的日志与指标汇聚至单一 Eventhouse，并支持自定义导出端点；
  - **Monitor Hub** 新增容量余量（Capacity Headroom）视图与集成 Activator 的作业告警。
- **按需消费计费 (On-Demand Billing) 与零预置起步 (Fabric Zero-Provisioned)**：
  - 继 Spark 自动扩缩容计费（Autoscale Billing for Spark）成功后，微软将**按需消费计费模式扩展至更多 Fabric 工作负载**，并推出 **Fabric Zero-Provisioned**，让新老客户无需前期容量承诺即可按实际用量起步和弹性扩展。

### 支柱六：Database Hub、Azure SQL Hyperscale 向量突破与主权云全面 GA
- **Database Hub in Fabric（预览）与 Database Agents**：
  - 在 Fabric 中提供统一控制平面，集中监控、评估风险并治理 **SQL Server、Azure SQL、Azure Database for PostgreSQL、Azure Cosmos DB 与 SQL Database in Fabric**；
  - 即将推出面向 **SQL 与 PostgreSQL 的 Database Agents（预览）**，可在 Fabric Database Hub 与 VS Code 中持续分析数据库信号、定位瓶颈并给出调优方案。
- **Azure SQL Database Hyperscale 重磅升级**：
  - **Serverless 自动暂停（预览）**：闲置时自动暂停计算，大幅降低开发测试与间歇性负载成本；
  - **弹性池密度翻倍（预览）**：每个 Hyperscale 弹性池支持最多 **50 个数据库**；
  - **192 vCore 超大计算规格（正式版 GA）**：满足关键任务级高并发与吞吐需求；
  - **DiskANN 向量索引（正式版 GA）**：在 **Azure SQL Database Hyperscale、Azure SQL Managed Instance 与 SQL Database in Fabric** 引擎内原生提供高性能 DiskANN 向量检索，无需将数据搬出核心事务库即可构建低延迟 RAG 与语义搜索。
- **主权云与断网边缘全面 GA (Sovereign & Disconnected Estates)**：
  - **SQL Server on Azure Local（正式版 GA）** 与 **Azure Local Disconnected Operations / ALDO（正式版 GA）**：支持完全断网（Air-gapped）与严苛合规环境下的本地云一致管理；
  - **Microsoft Fabric 扩展至 Microsoft 365 GCC High**：正式为美国政府与主权合规客户提供统一分析与 AI 数据平台。

---

## 四、 18 项发布特性状态全景速查表 (Complete Availability Matrix)

| # | 产品域 / 模块 | 发布特性名称 | 当前状态 | 核心技术亮点与商业价值 |
| --- | --- | --- | --- | --- |
| 01 | **Fabric IQ + Copilot** | Fabric IQ in Microsoft Copilot (Chat & Cowork) | **GA** | 将 OneLake、Power BI 语义模型与本体注入 M365 Copilot，零额外 AI Token 成本；Code 集成即将通过 Frontier 推出 |
| 02 | **Power BI Desktop** | Agentic App Creation in Power BI | **Preview** | 自然语言生成支持数据回写与共享状态的业务应用；向 Pro / PPU / Fabric 容量用户免费提供最高 1GB Fabric SQL |
| 03 | **Fabric Apps (Rayfin)** | Rayfin SDK & CLI Enhancements | **Available** | 直连 Warehouse/SQL/Lakehouse/语义模型；新增 TypeScript 后端函数、Secret Store、PostgreSQL 支持、默认私有访问与内置指标 |
| 04 | **Microsoft OneLake** | OneLake IQ Sharing | **Preview** | 跨组织安全共享受治理表、文件、Markdown 智能体指令与 RDF 本体（EY、S&P Global、TomTom 等首批集成） |
| 05 | **Microsoft OneLake** | Bidirectional Salesforce Data 360 Integration | **Preview** | 零拷贝双向集成 Salesforce Data 360 至 OneLake，直接供分析与 Fabric Data Agents 调用 |
| 06 | **Microsoft OneLake** | Google BigQuery Mirroring & D365 Business Central | **GA** | Google BigQuery 零拷贝镜像正式 GA；深化 D365 Business Central 及 Atlan、dbt、ClickHouse 生态集成 |
| 07 | **Data Engineering** | Fabric Data Engineering Agent (Osmos) | **Preview** | 基于 Osmos 收购技术，自主规划执行平台迁移、Lakehouse 现代化与 ETL，支持跨 GitHub Copilot / VS Code / Codex / Claude Code 协同 |
| 08 | **Real-Time Intelligence** | Copilot for Real-Time Dashboards & Eventhouse | **Preview** | 自然语言构建实时看板、管理 Eventhouse 表与策略、提供 Schema 优化建议与 AI 故障排查 |
| 09 | **Fabric IQ** | Agentic Ontology Creation & Apache Ossie | **Preview** | 从语义模型与文档自动构建本体、自然语言定义规则、复用 Power BI 度量值；联合 Snowflake 推进 Apache Ossie 开放语义标准 |
| 10 | **Fabric Agents** | Data Agents + Ontology & Operations Agents RCA | **Preview** | Data Agents 深度融合本体并支持读取术语表/数据字典；Operations Agents 新增预授权动作与根因分析 (RCA) |
| 11 | **Fabric Platform** | End-to-End Observability in Fabric | **Preview** | 跨工作区遥测汇聚单一 Eventhouse、自定义导出端点；Monitor Hub 新增容量余量视图与 Activator 作业告警 |
| 12 | **Fabric Platform** | On-Demand Billing & Fabric Zero-Provisioned | **Preview** | 将按需消费计费扩展至更多 Fabric 负载，支持无前期容量承诺的零预置（Zero-Provisioned）起步 |
| 13 | **Database Estate** | Database Hub in Fabric | **Preview** | 单一控制平面集中监控、评估风险并治理 SQL Server、Azure SQL、PostgreSQL、Cosmos DB 与 Fabric SQL |
| 14 | **Database Estate** | Database Agents for SQL & PostgreSQL on Azure | **Coming Soon (Preview)** | 可在 Database Hub 与 VS Code 中调用的数据库专家智能体，持续分析数据库信号、定位瓶颈并提供优化建议 |
| 15 | **Azure SQL Hyperscale** | Serverless Auto-Pause & 50-DB Elastic Pools | **Preview** | 闲置自动暂停计算以节省开发测试成本；弹性池密度提升至每池最多 50 个数据库 |
| 16 | **Azure SQL Hyperscale** | 192 vCore Compute Tier | **GA** | Azure SQL Database Hyperscale 192 vCore 超大计算规格正式可用，支撑关键任务高并发负载 |
| 17 | **Azure SQL & Fabric SQL** | DiskANN Vector Indexes | **GA** | 在 Azure SQL Hyperscale、SQL MI 与 Fabric SQL 引擎内原生提供高性能 DiskANN 向量索引，原位构建 RAG 与语义检索 |
| 18 | **Sovereign & Edge** | SQL Server on Azure Local, ALDO & Fabric GCC High | **GA** | SQL Server on Azure Local 与断网操作 (ALDO) 正式 GA；Microsoft Fabric 扩展支持美国主权云 M365 GCC High |

---

## 五、 官方配套深度博客索引 (Companion Deep-Dive Blogs)

1. **Fabric Analytics (Bogdan Crivat)**：[Bringing governed analytics into the flow of work: Fabric Analytics at FabCon Europe 2026](https://aka.ms/Analytics-EU26)
2. **Power BI & Apache Ossie (Mohammad Ali)**：[Power BI’s next chapter: The evolution of business intelligence](https://aka.ms/PowerBI-EU26)
3. **Fabric Apps & Rayfin (Sachin Patney)**：[From prompt to production: What’s new in Fabric Apps](https://aka.ms/Rayfin-FabConEU26-blog)
4. **Microsoft OneLake (Dipti Borkar)**：[FabCon and SQLCon Barcelona 2026: What’s new in Microsoft OneLake and its ecosystem](https://aka.ms/OneLake-EU26)
5. **Real-Time Intelligence & Fabric IQ (Yitzhak Kesselman)**：[Trusted AI starts with Microsoft Fabric, Real-Time Intelligence, and IQ](https://aka.ms/FabricIQ-EU26)
6. **Fabric Platform & Observability (Kim Manis)**：[Build, deploy, and govern Microsoft Fabric at scale](https://aka.ms/Fabric-Platform-Barcelona-2026)
7. **SQLCon & Azure Databases (Shireesh Thota)**：[SQLCon Barcelona 2026: Advancing SQL with greater control, scale, and intelligence](https://aka.ms/SQLConEU26-databases-blog)
8. **月度特性汇总 (2026 年 9 月)**：[Fabric September 2026 Feature Summary](https://aka.ms/Fabric-September-26) · [Power BI September 2026 Feature Summary](https://aka.ms/PowerBI-September-26)
