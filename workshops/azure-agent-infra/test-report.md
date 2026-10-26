# Azure AI Agent Infrastructure Playbook：6 大运行时与 12 场景架构基准评测报告（7 页 4:5 视觉卡片版 · 中英双语）

> 🌐 **Language / 语言切换**: **[🇨🇳 中文版 (test-report.md)](test-report.md)** | **[🇬🇧 English Version (test-report.en.md)](test-report.en.md)** | **[📘 Playbook 中文版](README.zh-CN.md)** | **[📘 Playbook English](README.en.md)** | **[🖼️ 7-Card HTML (CSP Locked)](test-report-cards.html)**

**来源性质：** `anonymized_reported + deterministic_architecture_verifier (independently_reproduced=false)`，基于 Microsoft Azure AI Infra 一手架构材料（`Agent Runtime Customer Pitch`、`AKSClaw Multi-Tenant Kubernetes`、`Agent Infra Playbook`、`E2B on Azure CheckRide v2 / Deep Dive v0.2` 及脱敏 `Selection Logic` 方法论）与本地确定性容量/选型核验器 `simulator/agent_infra_sizer.py`（涵盖 **226 章、221 套 Bicep/Terraform/YAML 蓝图、220 项物理仿真器、229/229 单元测试**）生成。所有内部客户名单与敏感财务行已在提取前严格物理剥离。

结构化数据与可离线预览工件：
- [7 页 4:5 视觉评测卡片 HTML（CSP 锁定自包含）](test-report-cards.html)
- [完整卡片与容量测算 JSON](report.json)
- [12 项生产场景架构选型核验 CSV](evidence/test-scenarios.csv)
- [6 项代际硬件与边界扰动鲁棒性 CSV](evidence/test-robustness.csv)
- [6 档沙箱启动与恢复延迟对比 CSV](evidence/test-batch-latency.csv)

---

## Card 1（`1 / 7` · `HANDS-ON · AZURE AI AGENT INFRASTRUCTURE BENCHMARK`）：总览与选型工作台

**核心发现标题：** **6 Azure Agent Runtimes, 108ms MicroVM restore**（六大 Azure Agent 运行时梯度互补，E2B on `D96as_v7` 实现 108ms 级 MicroVM 恢复）。

| 工作台决策字段 | 题型 | 核心评测问题 | 评测输出 | 置信度 / 比例 | 动作分档 | 分布明细 |
|---|---|---|---|---:|---|---|
| `e2b_turin_v7_speedup` | `choice` | Azure `D96as_v7`（第五代 AMD EPYC Turin + Azure Boost）在 E2B 沙箱启动上是否全面优于 `D96s_v6` 与 `D96as_v6`？ | `108 ms Base / 132 ms Code-Interpreter V1` | `0.926`（92.6%） | `Act automatically` | `D96as_v7` 108ms/132ms, `D96s_v6` 116ms/159ms, `D96as_v6` 239ms/255ms |
| `aksclaw_security_enforcement` | `choice` | 多租户 K8s Agent 平台（`AKSClaw`）的 5 项安全边界是否全部由平台层强制执行而不依赖 Agent 自觉？ | `5 / 5 platform hard boundaries (100.0%)` | `1.000`（100.0%） | `Act automatically` | IMDS 封禁、出网白名单、凭据注入代理、Entra Agent ID、Unified AI Gateway |
| `playbook_delivery_gate` | `score` | 当企业需要超越托管服务的底层控制但缺乏自有研发团队时，能否直接退回推荐 Foundry Hosted Agents？ | `0% shortcut allowed (Hold for CSU / Partner)` | `0.750`（75.0%） | `Send to a human` | 9/12 正向选型成立，3/12 架构反模式被精准拦截 |

---

## Card 2（`2 / 7` · `SCENARIO: MANUS × E2B 100K+ VIRTUAL COMPUTERS & AKSCLAW FLEET`）：单样本深度拆解

**核心发现标题：** **261 D96as_v7 nodes serve 100K sandboxes at 108ms**（单规模集 261 台 `D96as_v7` 宿主机即可承载 10 万并发沙箱，启动延迟低至 108ms）。

| 决策字段 | 题型 | 深度拆解问题 | 核验结果 | 置信度 / 比例 | 动作分档 | 分布明细 |
|---|---|---|---|---:|---|---|
| `vmss_100k_capacity_fit` | `choice` | 100,000 并发 E2B 沙箱是否可容纳在单个 Azure VMSS Flexible 规模集（上限 1,000 台 VM）内？ | `Yes · 261 Client Nodes (26.1% of limit)` | `0.850`（85.0%） | `Act automatically` | 384 GiB × 85% HugePages × 60% 扩容水位 = 384 稳态沙箱/节点 |
| `apim_appgw_dual_hop_isolation` | `noul` | `AppGW WAF v2`（双前端 IP）+ `APIM rate-limit-by-key` 能否隔离 10 万+ 动态沙箱子域名并透传 WebSocket？ | `Yes (100% per-Host isolation)` | `P(true) = 1.0` | `Act automatically` | `counter-key="@(context.Request.Headers.GetValueOrDefault("Host"))"` |
| `upstream_e2b_production_readiness` | `score` | 未改造的开源版 E2B API Server 能否直接多实例水平扩展并抵抗宿主机重启？ | `1 / 4 HA criteria met (25.0%)` | `0.250`（25.0%） | `Confirm` | 开源版将节点状态存于单进程内存且缺乏重启孤儿沙箱回收，必须做状态外置改造 |

---

## Card 3（`3 / 7` · `WHAT I TESTED`）：6 大场景 12 项架构选型核验全矩阵

| 场景编号与分类 | 架构选型核验问题 | 核验结果（报告百分比） | 预期是否成立 | 动作分档 | 证据锚点 |
|---|---|---|---:|---|---|
| `S01 · 01 Customer-Facing Agent` | 30K+ monthly sessions, ~75% autonomous resolution over approved banking APIs with shared context | `Foundry + ACA/AKS + Cosmos DB (100%)` | 是 | `Auto` | Pitch Slide 15 (Commerzbank case) |
| `S02 · 01 Customer-Facing Agent` | Executes untrusted LLM-generated Python scripts and file parsing with low wait time | `ACA Apps + Dynamic Sessions (100%)` | 是 | `Auto` | Pitch Slides 7-8 (ACA Dynamic Sessions) |
| `S03 · 03 Digital-Native AI Product` | Requires custom OCI image, persistent workspace files, and explicit pause/resume across user tasks | `ACA Sandboxes Preview + HorizonDB (92%)` | 是 | `Confirm` | Pitch Slides 7, 9, 11 (Preview region/SLA check required) |
| `S04 · 03 Digital-Native AI Product` | Requires <150ms Firecracker MicroVM restore, per-Host session rate limiting, and WebSocket desktop/terminal streaming | `E2B on VMSS D96as_v7 108ms/132ms (100%)` | 是 | `Auto` | E2B CheckRide Slides 13-20 (Measured 108ms Base / 132ms Code-Interpreter) |
| `S05 · 02 Enterprise Agent Platform` | Per-engineer persistent agent, BYO Harness (Copilot/Hermes/OpenClaw), IcM auto-triage, Follow-the-Sun handoff | `AKSClaw 5-Boundary Runtime on AKS (100%)` | 是 | `Auto` | AKSClaw Slides 3-17 (Skills, Sandbox, Security, Identity, AI Gateway, Governance) |
| `S06 · 05 Multi-Agent Workflow` | Multi-agent review + mandatory human approval wait + deterministic retry/recovery independent of compute pod lifecycle | `Durable Functions + ACA Apps + DB (100%)` | 是 | `Auto` | Pitch Slides 6, 7, 12 & Playbook Slide 10 |
| `S07 · 05 Multi-Agent Workflow` | LangGraph Triage Agent -> GH Copilot SDK Coding Agent (Shell/MCP) -> Foundry Compliance Agent | `MAF + GH Copilot SDK + Foundry (100%)` | 是 | `Auto` | Pitch Slide 13 (MAF + GitHub Copilot SDK loop) |
| `S08 · 04 Agent Factory` | To-B standard internal agents needing SAP/Salesforce/Slack/M365 integration with minimal infra management | `Foundry Hosted Agents + MCP Toolboxes (100%)` | 是 | `Auto` | Playbook Slide 7 & Pitch Slides 6, 14 |
| `S09 · 06 Regulated Industry Agent` | Customer demands deep infra control beyond managed hosting, but has NO dedicated development/ops team | `Direct Foundry fallback rejected; CSU/Partner gate triggered (0% shortcut)` `✕` | 否 | `Human` | Playbook Slide 7 Notes (Do not route unmet control requirement to Foundry due to missing devs) |
| `S10 · 02 Enterprise Agent Platform` | Can stock open-source E2B API process scale horizontally across nodes without state loss on reboot? | `Single-process in-memory node state lost on reboot (25%)` `✕` | 否 | `Confirm` | e2b infra deep dive v0.2 Slide 34 (E2B Architecture Weakness) |
| `S11 · 06 Regulated Industry Agent` | Does deploying an Agent container to ACA/AKS automatically enable full Entra Agent ID governance & block user token inheritance? | `Not automatic; requires explicit Agent ID + Gateway key custody (33%)` `✕` | 否 | `Confirm` | Pitch Slide 16 & AKSClaw Slides 14-16 |
| `S12 · 04 Agent Factory` | Does failing the $10,000/mo Jun-Aug Foundry Models gate automatically disqualify an account from Strong ACR / P1? | `No; non-model Specific or General+3 Foundations still qualify (100%)` | 是 | `Auto` | Playbook Slide 13 & Selection Logic (Signal vs Amount rule) |

---

## Card 4（`4 / 7` · `UNDER THE HOOD`）：APIM 动态 Host 限流与 AKSClaw 五道硬边界协议链路

```xml
<!-- 1. E2B on Azure: APIM Per-Sandbox Dynamic Subdomain Rate Limit (<port>-<sandboxId>.domain.com) -->
<inbound>
  <base />
  <rate-limit-by-key calls="300" renewal-period="60"
    counter-key="@(context.Request.Headers.GetValueOrDefault(&quot;Host&quot;, &quot;unknown&quot;))"
    increment-condition="@(context.Response.StatusCode &gt;= 200 &amp;&amp; context.Response.StatusCode &lt; 400)" />
  <set-backend-service base-url="http://10.240.0.10:8080" /> <!-- Callback to AppGW Private Frontend -->
</inbound>
```

` ↓ 结合 AKSClaw Kata Pod VM 硬件虚拟化沙箱 + Entra Agent ID + Unified AI Gateway ↓ `

```yaml
# 2. AKSClaw Kata Pod VM + NetworkPolicy + AI Gateway Contract (Zero LLM API Key in Agent Pod)
runtimeClassName: kata-mshv-vm-isolation   # 独立 Hypervisor 内核隔离
serviceAccountName: entra-agent-id-alice   # Blueprint + Sponsor 双重身份归属
env:
  - name: OPENAI_BASE_URL
    value: "http://ai-gateway.platform.svc.cluster.local/v1" # Prefix-Cache 亲和 + RPM/TPM 硬熔断
# 容器内零 API Key；NetworkPolicy 封禁 169.254.169.254 IMDS -> <answer>
```

---

## Card 5（`5 / 7` · `ROBUSTNESS CHECK`）：代际硬件、状态回收与安全边界扰动检验

| 评测维度 | 配对比较定义（Original vs Perturbed / Upgraded） | 基线比例 % | 扰动/升级后 % | 变化（百分点） | 主结论是否保持 |
|---|---|---:|---:|---:|---|
| `E2B Sandbox Cold Start: AMD Turin v7 vs Intel v6 (Code-Interpreter V1)` | D96s_v6 Intel (159 ms -> 62.9% speed index) vs D96as_v7 AMD Turin (132 ms -> 75.8% speed index) | `62.9` | `75.8` | `+12.9` | 是 |
| `E2B Sandbox Cold Start: AMD Genoa v6 vs AMD Turin v7 (Base MicroVM)` | D96as_v6 Genoa (239 ms -> 41.8% speed index) vs D96as_v7 Turin (108 ms -> 92.6% speed index) | `41.8` | `92.6` | `+50.8` | 是 |
| `State Persistence Across Idle Reclamation (Dynamic Sessions vs Sandboxes)` | ACA Dynamic Sessions (0% workspace retained after idle reclamation) vs ACA Sandboxes Preview + HorizonDB (100% snapshot + ACID state retained) | `0.0` | `100.0` | `+100.0` | 是 |
| `Multi-Tenant Security Controls: In-Agent Prompt Rules vs Platform Hard Boundaries` | Agent-Side Soft Config (0% immune to prompt injection / --yolo bypass) vs AKSClaw Platform Hard Controls (100% IMDS block + Egress + AI Gateway) | `0.0` | `100.0` | `+100.0` | 是 |
| `VMSS Autoscaling Direction Asymmetry (CPU Scale-Out vs HugePages Scale-In)` | Scale-Out @ 60% CPU (100% automated reactive horizontal expansion) vs Scale-In (0% blind termination; 100% gated by HugePages drain & live migration) | `100.0` | `100.0` | `0.0` | 是 |
| `Propensity Screening Gate: Historical $1,000 vs Adopted $10,000 Foundry Models Rule` | Raw Relevant ACR Dollar Retention (100% preserved in both releases) vs Non-Model Strong ACR Route Eligibility (100% preserved when model gate <$10K) | `100.0` | `100.0` | `0.0` | 是 |

---

## Card 6（`6 / 7` · `LATENCY & STARTUP SCALING`）：沙箱启动与恢复延迟对比

| 延迟对比层级 | 优化路径延迟 (`#2563EB`) | 基线路径延迟 (`#CBD5E1`) | 数据来源与说明 |
|---|---|---|---|
| `E2B Base Sandbox Restore (D96as_v7 Turin vs D96as_v6 Genoa)` | **108 ms (AMD v7 Turin + UFFD)** | 239 ms (AMD v6 Genoa) | Measured in E2B_CheckRide_Reordered_v2.pdf Slide 19 |
| `E2B Base Sandbox Restore (D96as_v7 Turin vs D96s_v6 Intel)` | **108 ms (AMD v7 Turin)** | 116 ms (Intel v6 Emerald Rapids) | Measured in E2B_CheckRide_Reordered_v2.pdf Slide 19 |
| `E2B Code-Interpreter V1 Startup (D96as_v7 Turin vs D96as_v6 Genoa)` | **132 ms (AMD v7 Turin + Jupyter/envd)** | 255 ms (AMD v6 Genoa) | Measured in E2B_CheckRide_Reordered_v2.pdf Slide 19 |
| `E2B Code-Interpreter V1 Startup (D96as_v7 Turin vs D96s_v6 Intel)` | **132 ms (AMD v7 Turin)** | 159 ms (Intel v6 Emerald Rapids) | Measured in E2B_CheckRide_Reordered_v2.pdf Slide 19 |
| `ACA Dynamic Sessions Allocation (Pre-Warmed Pool vs Cold Container)` | **~210 ms (Pre-Warmed Hyper-V Pool)** | ~2,200 ms (Unwarmed Container Cold Start) | Architecture reference model (Pitch Slide 8 pre-warmed pool) |
| `ACA Sandboxes Workspace Recovery (Memory/Disk Snapshot vs Full Rebuild)` | **~320 ms (Snapshot Resume)** | ~1,650 ms (Cold OCI + Volume Init) | Architecture reference model (Pitch Slide 9 snapshot restore) |

---

## Card 7（`7 / 7` · `MY TAKE`）：适用场景（Good Fit）与架构禁区（Not For）

- **✅ Good Fit（强烈推荐）**：
  1. **Foundry Hosted Agents**：To-B 标准企业助手，直接复用 1,400+ MCP 工具箱与 Entra Agent ID，零集群运维。
  2. **Azure Functions + Durable Functions**：长周期审批、跨系统事务与人机回环等待（Wait/Resume）场景。
  3. **ACA Dynamic Sessions / ACA Sandboxes (Preview)**：不可信代码短时执行（Hyper-V 预热池 `~210ms`）或需显式 `pause/resume` 快照的 Coding/Browser 工作区。
  4. **AKS + Kata (`AKSClaw`)**：企业多租户 Agent 平台与研发/SRE 舰队，共享只读技能市场 + 实例独占状态卷 + 5 道平台硬边界。
  5. **E2B on Azure VMSS (`D96as_v7`)**：10 万+ 并发云端虚拟电脑（Manus 模式），`108ms` Base / `132ms` Code-Interpreter 极速恢复。
- **⛔ Not For（严格禁区）**：
  1. 客户需要超越托管的底层控制但无研发团队时，**严禁**强行塞回 Foundry（必须先引入 CSU/Partner 交付力量）。
  2. **严禁**将持久业务状态仅保存在 ACA Dynamic Sessions 本地磁盘（空闲回收即清零，必须外置到 `HorizonDB` 或 `Cosmos DB`）。
  3. **严禁**在 E2B VMSS 上仅凭常规内存/CPU 指标盲目缩容（Firecracker 占用 HugePages，必须先做沙箱热迁移排空）。
  4. **严禁**在 Agent 容器内挂载静态 LLM API Key 或直接继承用户登录 Token。
