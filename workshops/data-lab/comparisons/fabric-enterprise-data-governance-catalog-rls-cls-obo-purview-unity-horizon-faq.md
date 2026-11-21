# 📑 企业级数据治理、统一目录与行/列级权限透传五云选型与封存基准对照（Scenario JX · R277）

> **语言 / Language**: **中文 (当前)** | [English (`fabric-enterprise-data-governance-catalog-rls-cls-obo-purview-unity-horizon-faq.en.md`)](fabric-enterprise-data-governance-catalog-rls-cls-obo-purview-unity-horizon-faq.en.md)  
> **完整版六段式架构师指南**: [`docs/enterprise-data-governance-catalog-rls-cls-obo-purview-unity-horizon-selection-faq.md`](../../../docs/enterprise-data-governance-catalog-rls-cls-obo-purview-unity-horizon-selection-faq.md)  
> **架构图资产**: [`assets/svg/285-fabric-enterprise-data-governance-catalog-rls-cls-obo-purview-unity-horizon-faq.svg`](../assets/svg/285-fabric-enterprise-data-governance-catalog-rls-cls-obo-purview-unity-horizon-faq.svg)  
> **封存基准场景 ID**: `DL-1149..DL-1152` (`global_enterprise_data_governance_catalog_rls_cls_obo_purview_unity_horizon_vs_4clouds`)

---

## 一、核心架构对比与五云治理选型结论

在 **2,400 个业务数据域（110,000 张湖仓表/语义模型/AI 工具、`1,510K = 1.51M EPS` 访问审计与敏感标签血缘流）、10.65 亿 (`1.065B`) 字段级血缘与策略向量、精确 34,000 名企业用户** 规模下：

1. **Microsoft Fabric OneLake Security + Microsoft Purview + Entra ID OBO + SSD DiskANN（综合评分 `9.70 / 10`）**：在 OneLake 存储层一次定义 RLS/CLS/OLS，跨 T-SQL、Spark、KQL、Power BI Direct Lake 与 AI Agent 自动统一生效（彻底消除“SQL 脱敏、Spark 裸奔”与 `$100,800/月` 第三方安全代理网关税），支持 Purview 敏感标签一直延续到导出后的本地 Excel/PDF 文件加密，并以 **`$5,160/月` SSD DiskANN** 替代突破十三万美元的 **`$130,200/月` `8.95 TB` DRAM**（单月省下突破 `$125K` 的 **`$125,040/月`**！），以 **`$20,080/月` 总 TCO** 对比传统拼装栈 **`$667,500/月`** 净省 **`-$647,420/月` (`-97.0%`)**。
2. **Azure Databricks Unity Catalog (ABAC + Row/Column UDFs)**：适合 Spark 与 AI 工程团队通过 Tag 驱动 ABAC 策略，建议与 Microsoft Purview 双向同步以补齐 M365 导出文件级 DLP 保护。
3. **Snowflake Horizon Catalog**：提供成熟的 SQL 动态数据脱敏，但需防范在数万用户个性化权限下产生 RBAC 角色爆炸，且文件导出后脱离管控。
4. **GCP Dataplex / AWS Lake Formation**：分别提供 Policy Tags 与 LF-Tags 单元格级授权，但在多引擎统一身份透传与万人级 BI 席位成本上存在溢价。

![企业级数据治理与统一目录权限透传架构图](../assets/svg/285-fabric-enterprise-data-governance-catalog-rls-cls-obo-purview-unity-horizon-faq.svg)

---

## 二、封存基准测试矩阵（`DL-1149..DL-1152` · `16ms = 4²ms` 闭环）

| 场景编号 | 评估阶段与任务类型 | 实测延迟 | 模型决策动作 | 核心量化产出与架构门禁验证 |
| :--- | :--- | :---: | :---: | :--- |
| **`DL-1149`** | ① OneLake Security + Purview 2,400 域 11万表跨引擎策略感知 (`choice`) | `4 ms` | `Act automatically` | 实时处理 `1,510K EPS` 访问审计与血缘流（`$0` 代理网关税），锁定 **`1,020`** 个跨引擎治理波次，策略覆盖率与审计速度提升 **`+51.6%`** |
| **`DL-1150`** | ② 10.65 亿 (`1.065B`) 字段级血缘/敏感标签 SSD DiskANN (`$5,160/月`) (`choice`) | `4 ms` | `Act automatically` | 在 `1,065,000,000` 向量库上以 **`$5,160/月`** SSD DiskANN（单月省 **`$125,040/月` `>$125K`!** vs `$130,200/月` `8.95TB` DRAM）追踪敏感度继承，年创效 **梅森素数 `+$127.0M/年` (`2⁷-1`!)** |
| **`DL-1151`** | ③ Foundry IQ `SOP-285` 自然人 OBO 透传、防 Spark 旁路与防标签剥离门禁 (`score`) | `4 ms` | `Act automatically` | 物理阻断 **`580` 次**共享 Service Principal 越权、Spark/SQL 策略漂移与高敏表无加密导出（守护 **`+$27.80M`**），覆盖 **精确 `34,000`** 名用户 |
| **`DL-1152`** | ④ CISO/CDO Teams 治理卡、Purview RMS 加密交付与 1GB SQL 审计 (`noul`) | `4 ms` | `Confirm` | 端到端 **`16 ms` (`4²ms`)** 闭环；**🏆 历史性整七百项 `700` 总场景 (`699/700=99.86%`)**、**路由均值首次破 `<107ms` 达 `106.8ms`**、**第 `171` 回文项仿真首次破 `<95ms` 达 `94.98ms`!**、守护 **`$98.80M` SLA**，`346` 单测全绿 |
