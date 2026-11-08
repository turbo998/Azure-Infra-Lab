# Microsoft Fabric OneLake 统一细粒度安全 (RLS/CLS/OLS) + Purview + Entra Agent ID (OBO) vs. Databricks Unity Catalog (ABAC / Mosaic AI Gateway) vs. Snowflake Horizon (Cortex Guard) vs. AWS Lake Formation vs. GCP Dataplex 多云 AI 治理、智能体权限穿透与主权合规架构选型 FAQ

> **文档定位**：面向 AI 解决方案架构师（AI Solution Architect）与客户 CTO / CISO / 数据治理负责人的**实战选型与第一性原理指南**（对标 `ib-vs-ethernet-roce-selection-faq.md` 六段式标杆结构）。  
> **阅读收益**：3 分钟抓准五大云数智平台在“多引擎统一细粒度权限 + AI 智能体身份穿透 + 跨境主权合规”上的核心边界，10 分钟掌握从“四套权限各自为战 + 超级账号越权泄密”走向“OneLake 存储层一次定义 + Entra Agent ID OBO 令牌穿透 + Purview 标签继承”的零信任架构闭环。  
> **数据溯源与分母隔离声明（Four-Tier Provenance & Dual Latency Denominators）**：本文所有数值严格区分四类溯源标签——`[measured_local_harness]`（本地确定性评测引擎实测：`30/30` 单元测试 `0.025s` 通过，`67/68 = 98.53%` 路由决策准确率）、`[vendor_published_spec_as_of_2026]`（附 9 条官方公开文档/价格链接，`as_of: 2026-11-08`）、`[synthetic_scenario_model]`（售前架构参考仿真模型，**显式区分两个独立延迟分母**：**分母 A `n=68` 路由矩阵任务均值 = `516.0 ms`**；**分母 B `n=13` 行业本体端到端闭环仿真均值 = `562.0 ms`**，范围 `431–780 ms`）以及 `[not_measured]`（未在付费生产云集群上实测物理极限并发 P99）。

![Multi-Cloud AI Governance & Entra Agent ID OBO Selection Summary](../assets/svg/14-onelake-purview-obo-governance-vs-uc-horizon-faq.svg)

---

## ① 📌 核心结论速览（Executive Summary）

1. **什么时候首选 Microsoft Fabric（OneLake 统一 RLS/CLS/OLS + Entra Agent ID OBO + Microsoft Purview）？**  
   当同一份湖仓表既要被 Spark 数据工程、T-SQL 分析端点、Eventhouse KQL、Power BI DirectLake 读取，又要被 **M365 Copilot 与 Fabric Data Agent** 调用时，**无脑首选 OneLake 统一细粒度安全（OneLake Unified Security）+ Entra Agent ID 代理令牌穿透（On-Behalf-Of, OBO）**（`[vendor_published_spec_as_of_2026]`：[OneLake Table/Column/Row Security](https://learn.microsoft.com/en-us/fabric/onelake/security/table-column-row-security)、[OneLake Access Control Model](https://learn.microsoft.com/en-us/fabric/onelake/security/data-access-control-model)）。在OneLake存储层定义一次行级（RLS）、列级（CLS）与对象级（OLS）权限，5 大引擎与 AI 智能体自动继承；在跨 5 引擎治理参考模型中，将月度权限同步与审计运维 TCO 从 **$9,360/mo 压降至 $1,480/mo（节省 84.2%，即省下 $7,880/mo，`[synthetic_scenario_model]`）**。
2. **什么时候选择与 Databricks Unity Catalog / Snowflake Horizon / AWS Lake Formation / GCP Dataplex 联邦共存（Better Together）？**  
   - **已有 Databricks Unity Catalog (ABAC) + Mosaic AI Gateway**：当客户在 Databricks 上管理多云 Spark/ML 特征、开源模型微调，并用 Mosaic AI Gateway 做外部 LLM 端点的速率限制、花费配额与 PII 拦截时（`[vendor_published_spec_as_of_2026]`：[Unity Catalog ABAC](https://docs.databricks.com/en/data-governance/unity-catalog/abac.html)），**保留 Unity Catalog + Mosaic AI Gateway**，通过 **Mirrored Unity Catalog + OneLake Shortcuts** 零拷贝联邦至 Fabric，使 Power BI 与 M365 Copilot 通过 Entra OBO 自动遵守行级/列级掩码。  
   - **已有 Snowflake Horizon Catalog + Cortex Guard**：当客户在 Snowflake 内使用基于标签的动态数据脱敏（Tag-based Dynamic Data Masking）与 Cortex Guard 并对外提供 B2B Clean Rooms 时（`[vendor_published_spec_as_of_2026]`：[Snowflake Access Control](https://docs.snowflake.com/en/user-guide/security-access-control-overview)），**保留 Snowflake Horizon**，将分类标签映射至 **Microsoft Purview** 并通过 OneLake Iceberg Shortcut 挂载。  
   - **已有 AWS Lake Formation / Bedrock Guardrails 或 GCP Dataplex**：保留源云原生权限控制（`[vendor_published_spec_as_of_2026]`：[AWS Lake Formation](https://docs.aws.amazon.com/lake-formation/latest/dg/what-is-lake-formation.html)、[GCP Dataplex](https://cloud.google.com/dataplex/docs/introduction)），通过 OneLake S3/GCS Shortcut + Purview 统一 DLP 策略汇聚至业务消费层。
3. **核心第一性原理本质（存储层单点强制 + OBO 身份透传 vs. 四引擎重复配权 + 超级账号越权）**：  
   传统 AI 智能体最大的安全黑洞是 **“Service Principal 超级账号绕过（Super-Token Bypass）”**——智能体用共享高权限账号查库，导致底层数据库看不到真实提问人是谁。在今晚新增的 **欧盟主权临床试验药物警戒仿真（场景 M `sovereign_healthcare_obo_purview_vs_uc_abac`，`[synthetic_scenario_model]`）** 中，德国心内科首席研究员（PI）通过智能体排查 `145,000` 名受试者数据：Entra Agent ID OBO + OneLake RLS/CLS 在 **`11 ms` 建模延迟**内内联拦截 `112,400` 条非德国受试者记录并脱敏基因序列号（越权泄漏率 **`0.0%`**），联合 Fabric IQ 识别 `19` 个 QTc 间期延长高危批次并在 **`431 ms` 端到端建模延迟**（**`n=13` 行业本体仿真均值 `562.0 ms`**；**`n=68` 路由矩阵任务均值 `516.0 ms`**）内回写 1GB 免费 Fabric SQL 与院端 SQL Server on Azure Local (ALDO)，单次建模规避 **$2,800,000** GDPR 第 83 条与 EMA 临床合规罚金风险。

---

## ② 🎯 客户与架构师灵魂拷问 Q&A（FAQ-Driven，大白话第一性原理）

### Q1：到底什么是 OneLake 统一细粒度安全（RLS/CLS/OLS）与 Entra Agent ID OBO 穿透？以前企业不用它时痛点在哪？它是怎么帮客户堵住 AI 泄密黑洞的？

- **通俗大白话解释**：
  - **OneLake 统一细粒度安全（OneLake Unified Security）**：就像在“金库大门（OneLake 存储层）”装了一套认人又认格子的虹膜锁——**对象级安全（OLS）**决定你能不能看到某张表或某个文件夹（连表名元数据都对你隐藏）；**列级安全（CLS）**决定你能不能看到 `身份证号/基因序列/底价` 这几列；**行级安全（RLS）**决定你只能看到 `Country = 'DE'`（德国区）这几行。最关键的是：**在 OneLake 定义一次，上面所有的引擎（Spark、SQL、Power BI DirectLake、Data Agent）全部自动生效**（`[vendor_published_spec_as_of_2026]`：[OneLake Table/Column/Row Security](https://learn.microsoft.com/en-us/fabric/onelake/security/table-column-row-security)）。
  - **Entra Agent ID 与 OBO（On-Behalf-Of 代理令牌穿透）**：给每个 AI 智能体发一张受 Microsoft Entra ID 监管的“实名工牌（Agent ID）”，并强制它在查数据时必须揣着**当前提问用户的委托授权信（OBO Token）**，绝不允许拿一张“万能总管房卡（Service Principal Super-Token）”去开所有人的抽屉。
- **以前企业不用它时的两大痛点**：
  1. **四套引擎四套锁，漏改一处全盘穿孔**：以前同一份 Parquet 数据，数据工程师在 Spark 里配一套视图权限，DBA 在数仓里写一套 SQL 角色，BI 团队在 Power BI 里写一套 DAX RLS，AI 团队又在向量库里写一套 Metadata 过滤。只要有 1 个团队改表时忘了同步规则，敏感数据立刻裸奔。
  2. **AI 智能体“万能公章”越权泄密（Super-Token Bypass）**：很多自建 RAG 或旧版智能体为了图省事，后台用同一个高权限 Service Principal 连接数仓。结果普通销售在对话框里换个问法，就能让 AI 把全公司高管薪酬或别国患者隐私总结出来。
- **底层第一性原理怎么省钱、怎么防泄密？**
  - **存储层单点下推（Storage-Layer Predicate Pushdown）**：OneLake 采用基于授权（Grant-based）的零信任模型（无授权即默认拒绝），当 Spark、DirectLake 或 Data Agent 发起读取时，OneLake 存储网关直接根据调用者 Entra OBO 令牌中的身份声明（Claims），在文件块/行列投影阶段裁剪掉无权访问的行与列。
  - **省掉 84.2% 跨引擎权限同步运维成本**：在 500 人企业、5 套分析与 AI 引擎的参考模型中（`[synthetic_scenario_model]`），消除了 4 套重复策略同步脚本与独立 PII 代理网关，月度治理运维 TCO 从 **$9,360/mo 降至 $1,480/mo（节省 $7,880/mo）**。

---

### Q2：Microsoft Fabric (OneLake + Purview + Entra OBO) vs. Databricks (Unity Catalog ABAC + Mosaic AI Gateway) vs. Snowflake (Horizon + Cortex Guard) vs. AWS / GCP 到底怎么选？

- **通俗大白话选型口诀**：
  - **业务分析、M365 Copilot 办公协同与多引擎统一底座 → 选 Microsoft Fabric (OneLake Security + Purview + Entra OBO)**：唯一能把“湖仓底层行列权限（OneLake）+ 企业身份与智能体工牌（Entra Agent ID OBO）+ Office/Teams 导出防泄漏（Purview DLP）”打通成一条链路的方案。哪怕用户把 AI 查出的数据复制到 Word 或发进 Teams，Purview 敏感度标签依然跟着走。
  - **多云 Spark 数据科学、开源大模型网关与算力配额管控 → 选 Databricks Unity Catalog (ABAC) + Mosaic AI Gateway**：Unity Catalog 的基于属性访问控制（ABAC）非常适合跨 AWS/Azure/GCP 的复杂工程标签级联；而 **Mosaic AI Gateway** 擅长对模型推理 Endpoint 做速率限制（Rate Limiting）、Token 预算配额、负载路由与输入输出 PII 审计。
  - **Snowflake 原生数仓、动态掩码与跨企业商业变现 → 选 Snowflake Horizon + Cortex Guard**：如果数据重力 100% 在 Snowflake 内部，Horizon 的 Tag-based Dynamic Data Masking（如根据角色自动把手机号显示为 `***-****-1234`）与 Data Clean Rooms 极其成熟，Cortex Guard 则负责拦截 Snowflake 内部 LLM 的越狱提示词。
  - **AWS / GCP 单云原生闭环 → 选 AWS Lake Formation + Bedrock Guardrails 或 GCP Dataplex**：当企业工作负载完全运行在 S3 + Athena + Bedrock 或 BigQuery + Vertex AI 内部时，优先启用源云原生治理服务。

---

### Q3：如果客户已经在 Databricks Unity Catalog 或 Snowflake Horizon 配好了几百条权限标签，怎么和 Fabric 实现“零拷贝安全联邦（Better Together）”？

- **千万别让客户手工重写权限表！标准三步联邦打法**：
  1. **目录与标签元数据镜像（Catalog & Tag Federation）**：通过 Fabric 的 **Mirrored Unity Catalog** 或 **OneLake Snowflake Iceberg Shortcut**，将外部表连同其 Unity Catalog ABAC 标签 / Snowflake Horizon 分类标签同步映射到 **Microsoft Purview 数据地图（Data Map）**。
  2. **双向身份委托（Entra ID OBO Passthrough）**：在 Azure Databricks 与 Snowflake 中启用 **Microsoft Entra ID 联合认证（SCIM + OAuth OBO 令牌透传）**。当用户在 Power BI 或 M365 Copilot 中提问时，用户的 Entra 身份直接穿透或映射至 OneLake Unified Security 角色。
  3. **AI 网关双保险（Mosaic AI Gateway / Cortex Guard + Foundry IQ）**：底层模型推理端点继续由 Databricks Mosaic AI Gateway 或 Snowflake Cortex Guard 管控 Token 速率与模型花费；业务层行动派单则由 **Fabric IQ Ontology + Foundry IQ 合规护栏 + Microsoft Agent 365** 完成前置规则校验与审计留痕。

---

### Q4：对于医疗、国防、国有银行等要求“核心敏感数据绝不出本地机房 / 主权边界”的客户，怎么落地？

- **边缘主权与云端协同双轨架构（SQL Server on Azure Local ALDO + Sovereign Cloud）**：
  - **院端/工厂断网边缘（SQL Server on Azure Local - ALDO）**：将含原始基因序列、患者姓名或军工工艺参数的明细表部署在本地机房的 **SQL Server on Azure Local (ALDO)**（支持断网离线运行与本地 DiskANN 向量检索），原始 PII 字节 **0 出境**。
  - **主权合规云端（Fabric Sovereign Cloud / GCC High + OneLake Security）**：仅将脱敏后的聚合队列特征或经 Purview 加密标记的合规字段同步至主权区域 OneLake，由 OneLake RLS/CLS + Entra Agent ID OBO 实施国别隔离（如德国研究员仅见 `DE` 队列，法国研究员仅见 `FR` 队列）。

---

## ③ 🧭 直观可视化图解（Mermaid 选型决策树 + 传统四引擎割裂 vs OneLake 零信任对比图 + 场景 M 闭环时序图）

### 图 1：五大云平台数据治理、AI 网关与主权合规选型决策树（`flowchart TD`）

```mermaid
flowchart TD
    Start(["🎯 企业多云 AI 治理与智能体安全选型起点"]) --> Q1{"核心痛点与受众是？"}

    Q1 -->|"跨 Spark/SQL/Power BI/M365 Copilot 多引擎共享 + 防 Agent 越权"| FabricPath["✅ 首选 Microsoft Fabric 零信任治理底座<br/>OneLake Unified Security (RLS/CLS/OLS) +<br/>Entra Agent ID (OBO) + Microsoft Purview DLP<br/>• 1 次定义权限，5 大引擎自动强制 (-84.2% 运维 TCO)<br/>• OBO 令牌杜绝 Service Principal 超级账号越权"]

    Q1 -->|"多云 Spark/ML 工程治理 + 模型 Endpoint 速率/成本网关"| DBXPath["🤝 首选 Databricks Unity Catalog + Mosaic AI Gateway<br/>• Unity Catalog ABAC 标签级联行列掩码<br/>• Mosaic AI Gateway 管控模型 QPS、配额与 PII<br/>• 通过 Mirrored Unity Catalog + Entra OBO 联邦至 Fabric"]

    Q1 -->|"Snowflake 核心数仓动态脱敏 + 跨企 Clean Room 变现"| SnowPath["❄️ 首选 Snowflake Horizon + Cortex Guard<br/>• Tag-based Dynamic Data Masking 动态掩码<br/>• Cortex Guard 提示词安全 + Data Clean Rooms<br/>• 通过 OneLake Iceberg Shortcut + Purview 标签映射共存"]

    Q1 -->|"AWS / GCP 单云原生负载"| CloudPath{"哪朵公有云为主？"}
    CloudPath -->|"AWS S3 / Redshift / Bedrock"| AWSPath["🟠 AWS Lake Formation + Bedrock Guardrails<br/>• LF-Tag 单元格级过滤 + Bedrock 敏感词/PII 拦截<br/>• S3 Shortcut 挂载至 OneLake 供全局高管 BI"]
    CloudPath -->|"GCP BigQuery / Vertex AI"| GCPPath["🔵 GCP Dataplex + Cloud DLP + Vertex Safety<br/>• BigQuery Policy Tags + Cloud DLP 脱敏<br/>• BigQuery Mirroring 零拷贝接入 Fabric IQ"]

    FabricPath --> SovereignCheck{"是否有严苛本地物理驻留/断网要求？"}
    SovereignCheck -->|"是 (医疗基因/国防/核心柜面)"| ALDO["🛡️ SQL Server on Azure Local (ALDO) + Fabric Sovereign Cloud<br/>原始 PII 留存本地机房 · 脱敏队列经 Entra OBO 跨院协同"]
    SovereignCheck -->|"否 (标准跨国/多部门合规)"| CloudFabric["🌐 OneLake RLS/CLS/OLS + Purview 跨 Office/Teams 全链路保护"]

    style Start fill:#0F172A,stroke:#38BDF8,stroke-width:2px,color:#F8FAFC
    style FabricPath fill:#064E3B,stroke:#10B981,stroke-width:2px,color:#ECFDF5
    style DBXPath fill:#3B0764,stroke:#A855F7,stroke-width:2px,color:#FAF5FF
    style SnowPath fill:#0C4A6E,stroke:#38BDF8,stroke-width:2px,color:#F0F9FF
    style AWSPath fill:#451A03,stroke:#F59E0B,stroke-width:2px,color:#FEF3C7
    style GCPPath fill:#064E3B,stroke:#34D399,stroke-width:2px,color:#ECFDF5
    style ALDO fill:#1E1B4B,stroke:#818CF8,stroke-width:2px,color:#E0E7FF
```

---

### 图 2：传统四引擎重复配权与超级账号越权 vs. OneLake 存储层统一安全 + Entra OBO 架构对比图（`flowchart LR`）

```mermaid
flowchart LR
    subgraph Legacy["⛔ 传统割裂架构：4 套引擎重复配权 + Service Principal 超级账号越权 (建模运维 $9,360/mo)"]
        direction TB
        L_Data[("Parquet / Delta 湖存储<br/>(无细粒度行列锁)")] --> L_E1["1. Spark 视图 ACL 脚本"]
        L_Data --> L_E2["2. 数仓 SQL 行列安全角色"]
        L_Data --> L_E3["3. BI 语义模型 DAX RLS"]
        L_Data --> L_E4["4. RAG 向量库 Metadata 过滤"]
        L_Data --> L_Agent["⚠️ AI 智能体使用共享 Service Principal<br/>('Super-Token' 丢失提问人身份 -> 跨国数据越权泄漏)"]
    end

    subgraph FabricZeroTrust["✅ Fabric 零信任架构：OneLake 存储层一次定义 + Entra Agent ID OBO 穿透 (建模运维 $1,480/mo · -84.2%)"]
        direction TB
        Caller["👤 提问者：德国心内科 PI<br/>(Entra UPN: pi.de@pharma.eu)"] -->|"签发 OBO 委托令牌"| AgentID["🤖 Fabric Data Agent<br/>(Entra Agent ID · 禁止超级令牌)"]
        AgentID -->|"携带调用者 OBO Claims (11ms)"| OneLakeSec["🔒 OneLake Unified Security<br/>存储层单点强制 RLS (Country='DE') +<br/>CLS (遮蔽 SSN/Genomic_ID) + OLS"]
        OneLakeSec --> F_All["⚡ 5 大引擎自动一致生效 (0 重复脚本)<br/>Spark · T-SQL · DirectLake · Eventhouse KQL · Data Agent"]
        F_All --> Purview["🛡️ Microsoft Purview 敏感度标签继承<br/>连同导出的 Excel / Word / Teams 消息自动加密防泄漏"]
    end

    Legacy -.->|"消除 4 套重复策略与超级账号漏洞"| FabricZeroTrust

    style Legacy fill:#2A1215,stroke:#EF4444,stroke-width:2px,color:#FECACA
    style FabricZeroTrust fill:#062E26,stroke:#10B981,stroke-width:2px,color:#ECFDF5
```

---

### 图 3：场景 M 欧盟主权临床试验药物警戒端到端闭环时序图（`sequenceDiagram`，`431 ms` 建模延迟，`[synthetic_scenario_model]`）

```mermaid
sequenceDiagram
    autonumber
    participant PI as 🇩🇪 德国心内科 PI<br/>(M365 Copilot / Agentic App)
    participant Entra as 🔑 Microsoft Entra Agent ID<br/>(OBO Token Service)
    participant OneLake as 🔒 OneLake Unified Security<br/>(RLS/CLS/OLS + Purview)
    participant Fed as 🤝 联邦目录 (Mirrored UC ABAC +<br/>Snowflake Horizon Iceberg)
    participant IQ as 🧠 Fabric IQ Ontology &<br/>Foundry IQ (EMA SOP)
    participant Edge as 🏥 1GB Free Fabric SQL &<br/>ALDO 院端主权边缘库

    PI->>Entra: 发起临床安全排查：“检索本院 CYP3A4 联用且 QTc 延长 >60ms 的三期受试者批次”
    Entra->>OneLake: 签发 Entra Agent ID OBO 令牌 (Role=DE-Cardiology-PI, Country=DE · 拒绝 Service Principal 超级令牌)
    OneLake->>OneLake: 11ms 存储层内联执行 RLS (过滤拦截 112,400 条非德国患者行, 越权泄漏率 0.0%) + CLS (遮蔽基因序列号)
    OneLake->>Fed: 零拷贝关联 Databricks UC 生物标志物表与 Snowflake Horizon 实验室 Iceberg 表 (74ms KQL + 102ms 图谱)
    Fed-->>IQ: 返回德国区合规受试者队列：检出 19 个批次存在 DeltaQTcMs > 60ms 心脏毒性信号
    IQ->>IQ: Foundry IQ 核验 EMA EudraVigilance GVP Module IX 规范 (阻断未脱敏基因导出 · 置信度 0.99 -> Confirm)
    IQ->>Edge: 经由 Power BI Agentic App (1GB 免费 Fabric SQL) 下发 19 个给药批次隔离指令至院端 ALDO 数据库
    Edge-->>PI: 431ms 端到端闭环完成！0 跨境隐私泄漏，单次规避 $2,800,000 GDPR Art.83 与 EMA 临床合规罚金风险
```

---

## ④ 📊 五大平台架构师选型决策矩阵（Architect Decision Matrix）

| 评估维度 | Microsoft Fabric (OneLake Security + Purview + Entra OBO) | Databricks (Unity Catalog ABAC + Mosaic AI Gateway) | Snowflake (Horizon Catalog + Cortex Guard) | GCP (Dataplex Universal Catalog + Cloud DLP) | AWS (Lake Formation + Bedrock Guardrails) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **核心适用场景** | **跨 Spark/SQL/BI/KQL/Agent 统一细粒度权限 + M365 Copilot OBO 穿透 + 院端 ALDO 主权边缘** | **多云 Spark/ML 工程治理 + 模型推理 Endpoint 速率/配额/PII 网关** | **Snowflake 原生数仓动态数据脱敏 + 跨企业 B2B Data Clean Rooms** | **GCP BigQuery 原生数仓列级策略标签 + Cloud DLP 自动敏感数据发现** | **AWS S3 Tables / Athena / Redshift 单元格过滤 + Bedrock 生成式 AI 护栏** |
| **细粒度权限模型 (RLS/CLS/OLS)** | **存储层一次定义（OneLake RLS/CLS/OLS）**，5 大内置引擎与开放 API 自动继承（`[vendor_published_spec_as_of_2026]`） | **Unity Catalog ABAC**（基于 Tag 的行过滤与列掩码函数，覆盖 Delta/Iceberg/模型/Volume） | **Horizon RBAC + Tag-based Dynamic Data Masking** + Row Access Policies | **BigQuery Policy Tags** + Dataplex 数据资产分类与 IAM 条件绑定 | **Lake Formation LF-Tags**（表、列、行/单元格级 Data Filters） |
| **AI 智能体身份与防越权机制** | **Entra Agent ID + On-Behalf-Of (OBO) 强制调用者身份穿透**（零超级账号绕过）+ Foundry IQ SOP 护栏 | **Mosaic AI Gateway**（统一模型端点治理、Token 速率限制、PII 检测与审计日志）+ UC 权限校验 | **Cortex Guard**（LLM 提示词有害内容过滤）+ Snowflake 角色上下文继承 | **Vertex AI Safety Filters** + IAM 服务账号/终端用户凭证传递 | **Amazon Bedrock Guardrails**（PII 脱敏、拒绝主题、上下文接地检查）+ IAM Role |
| **数据防泄漏 (DLP) 延伸半径** | **全链路延伸至办公端**：Purview 敏感度标签从 OneLake 自动继承至 Power BI、Excel、Word、Teams 与邮件 | 聚焦数据湖仓与 ML/AI Endpoint 内部审计，不含 Office 文档端原生加密锁 | 聚焦 Snowflake 数仓、Streamlit 应用与 Clean Room 共享边界 | 聚焦 GCP 存储与 BigQuery 扫描脱敏（Cloud Sensitive Data Protection） | 聚焦 AWS S3（Amazon Macie）与 Bedrock API 输入输出拦截 |
| **跨云共存模式 (Better Together)** | 作为**全局企业身份与业务语义治理汇聚层**，零拷贝挂载四云 Catalog | **Mirrored Unity Catalog** 同步元数据至 Fabric，结合 Entra OBO 穿透查询 | **OneLake Iceberg Shortcut** 挂载 Horizon/Polaris 表，标签映射至 Purview | **BigQuery Mirroring / BigLake Shortcut** 接入 OneLake 并继承 Purview 标签 | **OneLake S3 Shortcut** 挂载 S3 Tables，通过 IAM OIDC 与 OneLake RLS 对齐 |
| **5 引擎跨栈治理建模月度 TCO** | **$1,480/mo**（OneLake 单点定义 + F64 内含治理链路，较四套重复策略省 **84.2%**，`[synthetic_scenario_model]`） | 需为外部 BI/Office 消费层额外同步策略或配置联邦网关 | 需按动态脱敏查询与 Cortex Guard Token 消耗计入 Credit | Cloud DLP 按扫描 TB 量阶梯计费 + BigQuery Slot 消耗 | Lake Formation 免费元数据但 Macie/Bedrock Guardrails 按扫描量/字符数计费 |

---

## ⑤ 🧪 简明定量测评与 TCO/性能拐点洞察（Quantitative Benchmark & Provenance Audit）

### 5.1 跨 5 引擎细粒度权限同步与 AI 防越权架构月度 TCO 对比（`[synthetic_scenario_model]`）

> **测算基准（Synthetic Reference Model）**：145,000 名受试者 / 客户主数据规模，数据同时供 **Spark 数据工程、SQL 数仓、实时流 KQL、高管 BI 报表、AI 智能体（RAG/Agent）** 5 类引擎消费，包含 180 条跨国行级隔离规则（RLS）与 45 个 PII/PHI 敏感列掩码规则（CLS）。

| 治理架构方案 | 跨引擎策略同步与脚本维护 | 独立 AI PII 代理网关与审计存储 | 越权与合规漂移整改隐性成本 | 建模月度总 TCO (USD/mo) | 相对传统多引擎割裂方案节省 |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **传统 4 引擎各自配权 + Service Principal 代理网关** | $4,200/mo | $3,160/mo | $2,000/mo | **$9,360/mo** | 基准 (Baseline) |
| **Databricks Unity Catalog ABAC + 外部 BI 策略同步** | $1,650/mo | $1,450/mo | $600/mo | **$3,700/mo** | -60.5% |
| **Snowflake Horizon Dynamic Masking + 外部同步** | $1,800/mo | $1,620/mo | $650/mo | **$4,070/mo** | -56.5% |
| **Microsoft Fabric OneLake Security + Purview + Entra OBO** | **$480/mo**（存储层一次定义） | **$1,000/mo**（Purview + Agent 365 审计） | **$0/mo**（OBO 零越权漂移） | **$1,480/mo** | **-84.2%（月省 $7,880）** |

---

### 5.2 场景 M 定量闭环指标与双分母延迟口径核验（`sovereign_healthcare_obo_purview_vs_uc_abac`）

- **场景 M 核心仿真指标（`[synthetic_scenario_model]`）**：
  - **受试者总规模**：`145,000` 人（含德国 `DE` 队列 `32,600` 人，法/美/瑞等非德国队列 `112,400` 人）。
  - **Entra Agent ID OBO + OneLake RLS/CLS 内联评估延迟**：**`11 ms`**（直接阻断 `112,400` 条非德国受试者行，Service Principal 越权行泄漏率 = **`0.0%`**）。
  - **跨源联邦与临床规则推理**：`74 ms` Eventhouse KQL 心电遥测聚合 + `102 ms` Fabric IQ 本体图谱遍历，检出 **`19` 个给药批次**出现 `DeltaQTcMs > 60ms` 且联用 `CYP3A4` 抑制剂。
  - **端到端闭环总延迟（Scenario M）**：**`431 ms`**，通过 Power BI Agentic App（**1GB 免费 Fabric SQL**）与院端 **SQL Server on Azure Local (ALDO)** 锁定异常批次并提交 `Confirm` 人工复核门禁（置信度 `0.99`），单次建模规避 **$2,800,000** GDPR 第 83 条跨境隐私泄漏与 EMA 临床安全罚金风险。
- **双延迟分母严格隔离说明（Dual Latency Denominators Reconciliation，封存报告 `data-lab-fabric-vs-4clouds-2026-11-09-r6`）**：
  1. **分母 A — 架构路由决策矩阵任务均值（`scenario_evaluation.avg_latency_ms`）**：
     - 当前 Round 6 范围：**`n = 68` 条独立架构选型路由评测任务（`DL-01..DL-68`）**，通过 **`67 / 68`（准确率 `98.53%` [`measured_local_harness`]，唯一显式负例 `DL-23` 捕获无语义层裸表查询 `+14.2%` 口径漂移）**。
     - 算术平均建模延迟：**`35,088 ms / 68 = 516.0 ms`（精确值）**（历史快照：Round 5 `n=64` 为 `521.0 ms`；Round 4 `n=60` 为 `526.5 ms`；Round 3 `n=56` 为 `532.0 ms`）。
  2. **分母 B — 行业本体端到端闭环仿真均值（`ontology_simulations_summary.ontology_simulation_mean_modeled_latency_ms`）**：
     - 当前 Round 6 范围：**`n = 13` 个跨系统多跳行业本体闭环仿真（场景 A 至场景 M）**，各场景端到端建模延迟分别为 `[780, 640, 710, 660, 590, 560, 530, 515, 495, 480, 465, 450, 431] ms`（范围 `431–780 ms`）。
     - 算术平均建模延迟：**`7,306 ms / 13 = 562.0 ms`（精确值）**（历史快照：Round 5 `n=12` 为 `572.92 ms`；Round 4 `n=11` 为 `584.09 ms`；Round 3 `n=10` 为 `596.0 ms`）。

---

### 5.3 官方技术规约与价格溯源链接表（`vendor_published_spec_references`，`as_of: 2026-11-08`）

| 编号 | 厂商 | 核验规约与产品能力声明 | 官方权威文档链接 (`https://`) |
| :--- | :--- | :--- | :--- |
| `SPEC-01` | Microsoft | Fabric F64 容量（$8,409.60/mo PAYG / ~$5,004/mo 1-Yr RI）内含 Power BI Free 阅览者 $0 席位费 | [Azure Fabric Pricing](https://azure.microsoft.com/en-us/pricing/details/microsoft-fabric/) · [Fabric Licenses](https://learn.microsoft.com/en-us/fabric/enterprise/licenses) |
| `SPEC-02` | Microsoft | Fabric Database Mirroring 与 Open Mirroring 免收复制算力费（$0 CU）并赠容量等额免费镜像存储 | [Fabric Mirrored Database](https://learn.microsoft.com/en-us/fabric/database/mirrored-database/overview) · [Open Mirroring](https://learn.microsoft.com/en-us/fabric/database/mirrored-database/open-mirroring) |
| `SPEC-03` | Microsoft | OneLake 支持 Delta ↔ Iceberg 双向元数据虚拟化（XTable）与 Snowflake Iceberg 直写，$0 转换算力 | [OneLake Iceberg Tables](https://learn.microsoft.com/en-us/fabric/onelake/onelake-iceberg-tables) · [OneLake Shortcuts](https://learn.microsoft.com/en-us/fabric/onelake/onelake-shortcuts) |
| `SPEC-04` | Snowflake | Dynamic Tables 最小可配 `TARGET_LAG = 60s`（1 分钟）；Polaris 提供开源 Iceberg REST Catalog | [Dynamic Tables Docs](https://docs.snowflake.com/en/user-guide/dynamic-tables-about) · [Snowflake Iceberg Tables](https://docs.snowflake.com/en/user-guide/tables-iceberg) |
| `SPEC-05` | Databricks | Unity Catalog 支持 Delta UniForm 异步生成 Iceberg 元数据、Managed Iceberg 与 Lakeflow Connect | [Delta UniForm Docs](https://docs.databricks.com/en/delta/uniform.html) · [Lakeflow Connect](https://docs.databricks.com/en/ingestion/lakeflow-connect/index.html) |
| `SPEC-06` | AWS | Amazon S3 Tables 提供原生 Apache Iceberg 存储与 Glue REST Catalog；Aurora Zero-ETL 同步 Redshift | [Amazon S3 Tables](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables.html) · [Aurora Zero-ETL](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/zero-etl.html) |
| `SPEC-07` | Google Cloud | BigLake 支持 Apache Iceberg 表；BigQuery Continuous Queries 提供实时流 SQL | [BigQuery Iceberg Tables](https://cloud.google.com/bigquery/docs/iceberg-tables) · [Continuous Queries](https://cloud.google.com/bigquery/docs/continuous-queries-introduction) |
| `SPEC-08` | MS / DBX / Snow / GCP | Cosmos DB in Fabric 与 Azure SQL 支持 SSD 级 DiskANN；Databricks Lakebase、Snowflake Unistore、AlloyDB ScaNN | [Cosmos DB Vector Index](https://learn.microsoft.com/en-us/fabric/database/cosmos-db/index-vector-data) · [Azure SQL DiskANN GA](https://devblogs.microsoft.com/azure-sql/diskann-vector-index-search-are-now-generally-available-in-azure-sql/) |
| `SPEC-09` | MS / DBX / Snow / AWS / GCP | OneLake 统一 RLS/CLS/OLS + Entra ID OBO 穿透；Unity Catalog ABAC；Snowflake Horizon；Lake Formation；Dataplex | [OneLake RLS/CLS/OLS](https://learn.microsoft.com/en-us/fabric/onelake/security/table-column-row-security) · [OneLake Access Control](https://learn.microsoft.com/en-us/fabric/onelake/security/data-access-control-model) · [Databricks UC ABAC](https://docs.databricks.com/en/data-governance/unity-catalog/abac.html) · [Snowflake Access Control](https://docs.snowflake.com/en/user-guide/security-access-control-overview) |

---

## ⑥ 🛠️ 附录：生产落地与售前打单快速核验清单（Architect Checklist）

- [ ] **1. 严禁 AI 智能体使用共享 Service Principal “超级账号”查库**：在所有客户 PoC 与生产架构评审中，核查 Fabric Data Agent、Copilot Studio 或自建 RAG 是否已强制启用 **Microsoft Entra Agent ID + On-Behalf-Of (OBO) 令牌透传**，确保底层数据库与 OneLake 按真实提问人的身份执行 RLS/CLS。
- [ ] **2. 将细粒度权限下沉至 OneLake 存储层单点定义**：排查客户是否在 Spark 视图、T-SQL 存储过程和 Power BI DAX 中维护了多套重复的行列过滤逻辑；引导客户开启 **OneLake Unified Security (RLS/CLS/OLS)**，注意提醒客户 Workspace Admin/Member/Contributor 默认拥有管理豁免权，业务消费者与智能体应分配 Viewer + OneLake Data Access Role。
- [ ] **3. 跨云目录坚持“标签联邦映射”而非推倒重写**：当客户已有 Databricks Unity Catalog (ABAC) 或 Snowflake Horizon 动态脱敏策略时，采用 **Mirrored Unity Catalog / OneLake Iceberg Shortcut + Microsoft Purview 标签映射**，并在模型推理层保留客户的 Mosaic AI Gateway 或 Cortex Guard。
- [ ] **4. 打通从湖仓到 Office 文档的 Purview DLP 最后一公里**：验证 OneLake 表上的 Microsoft Purview 敏感度标签（如 `Highly Confidential - Clinical Trial PII`）在数据流入 Power BI 语义模型并导出为 Excel/PDF 或粘贴至 Teams 时，是否自动继承加密与外发拦截策略。
- [ ] **5. 针对断网/数据不出境场景必推 ALDO + Sovereign Cloud 双轨部署**：遇到医院基因库、军工制造或核心银行柜面等要求原始数据物理不出机房的客户，采用 **SQL Server on Azure Local (ALDO)** 本地处理明细 + **Fabric Sovereign Cloud** 汇总脱敏指标的协同方案。
- [ ] **6. 在高管汇报材料中严格区分双延迟分母与四级数据溯源**：向客户展示评测卡片时，明确标注 **`n=68` 路由矩阵均值 `516.0 ms`** 与 **`n=13` 行业端到端本体闭环均值 `562.0 ms`** 的口径边界，区分本地实测（`[measured_local_harness]`）、官方规约（`[vendor_published_spec_as_of_2026]`）与场景参考模型（`[synthetic_scenario_model]`）。
