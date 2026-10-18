# Azure AI Agent Infrastructure Playbook：从四层全栈架构、六大计算运行时到 AKSClaw 与 E2B on Azure 生产实践

- **研究日期**：2026-10-18
- **研究定位**：AI Infrastructure 架构师视角全栈方案设计、技术选型、代际实测对比、多租户安全治理与现场落地手册（Playbook）
- **核心覆盖范围**：
  - **L1 Build（Agent Harness 编排层）**：Microsoft Agent Framework (MAF)、GitHub Copilot SDK、LangGraph / AutoGen / CrewAI、OpenClaw / Hermes、MCP & A2A 开放协议
  - **L2 Run（Agent Runtime 六级计算光谱）**：Foundry Hosted Agents、Azure Functions + Durable Functions、ACA Dynamic Sessions（Hyper-V 预热池）、ACA Sandboxes (Preview)、AKS Automatic / Standard + Kata Pod VM（`AKSClaw` 多租户架构）、E2B on Azure VMSS Flexible（`Standard_D96as_v7` + Firecracker MicroVM）
  - **L3 Ground（模型、知识与状态记忆底座）**：Foundry Models (11,000+)、Foundry Tools (1,400+ MCP 连接器)、Azure AI Search / Foundry IQ、**Azure HorizonDB (Preview)**（PostgreSQL ACID + JSONB + DiskANN Vector + 存算分离）、Azure Cosmos DB、Sandbox Snapshot（`UFFD` + `NBD`）
  - **L4 Control & Govern（零信任身份、网关与舰队治理）**：**Microsoft Entra Agent ID**（Blueprint + Sponsor 双重身份归属）、Unified AI Gateway（APIM：容器零密钥、Prefix-Cache 亲和路由、三级配额硬熔断、10 万+ 动态沙箱 Host 限流）、Microsoft Defender & Purview
  - **Field Playbook（六大场景与五步落地法）**：To-B vs To-C 双阶段选型决策树、四大技术底座（14 服务家族）资质筛查模型、`$10,000` 模型信号门禁与五步法（Screening → Discovery → Define → Validate → Implement）
- **交互式资产与评测套件**：
  - 📊 [7 页 4:5 视觉评测卡片报告（Markdown 版）](test-report.md) · [自包含 CSP 锁定 HTML 卡片版](test-report-cards.html) · [结构化评测数据 `report.json`](report.json)
  - 🧮 [确定性架构选型与容量测算器 `simulator/agent_infra_sizer.py`](simulator/agent_infra_sizer.py) · [单元测试 `simulator/test_agent_infra_sizer.py`](simulator/test_agent_infra_sizer.py)
  - 🌐 交互式 H5 Playbook & Demo 工作台（同步归档于 `turbo998/Azure-Infra-Lab/workshops/azure-agent-infra/`）

---

## 0. 一页纸架构师核心结论（Executive Summary）

从 AI Infra 架构师视角审视，企业级 AI 应用正从 **“无状态单次 Prompt 问答（Stateless Chat）”** 演进为 **“长周期、有状态、会写代码、会调工具、会操作完整计算机的自主智能体（Stateful Autonomous Agent）”**。这一范式转移彻底改写了底层云基础设施的设计约束：

1. **计算与状态解耦（Compute-State Decoupling）是生产级 Agent 架构的第一性原理**：
   - Agent 往往需要跨数分钟至数天执行多步推理、动态生成并运行不可信代码、等待人工审批（Human-in-the-Loop），并在工具超时或容器漂移后从最近检查点（Checkpoint）精确恢复。
   - **Azure 的核心破局点在于提供了一条从“全托管省心”到“极致内核控制”连续演进的 6 级运行时光谱（Runtime Spectrum）**，并且明确提出：**托管式 AI 平台（Microsoft Foundry）与现代化 PaaS/IaaS 底座（ACA / AKS / Functions / VMSS）是互补协同关系，而非二选一**。
2. **六大运行时精准卡位不同隔离边界与恢复延迟需求**：
   - **标准受控 API 助手** → **Foundry Hosted Agents**（直接挂载 1,400+ MCP 企业连接器与 Entra Agent ID，零集群运维）；
   - **跨天人工审批与事务编排** → **Azure Functions + Durable Functions**（零算力消耗挂起等待外部事件、确定性重放与幂等重试）；
   - **短时不可信代码执行** → **ACA Dynamic Sessions**（Hyper-V 硬件虚拟化预热池，`~210ms` 级分配，空闲自动回收）；
   - **有状态 Coding / Browser 工作区** → **ACA Sandboxes (Preview)**（支持显式 `create / pause / resume / delete`、内存与磁盘快照、自定义 OCI 镜像与持久卷挂载）；
   - **企业多租户 Agent 平台与 SRE 舰队** → **AKS + Kata Containers Pod VM（`AKSClaw` 模式）**（独立 Guest Kernel 隔离 + 团队共享只读技能市场 + 实例独占状态卷 + 5 道不可绕过的平台安全硬边界）；
   - **10 万+ 并发云端虚拟电脑（`Manus × E2B` 模式）** → **E2B on Azure VMSS Flexible (`Standard_D96as_v7`)**（基于 KVM + Firecracker + `UFFD` 缺页流式内存恢复 + `NBD` 块差分快照，实测 Base 沙箱 **`108 ms`** 启动、Code-Interpreter V1 **`132 ms`** 启动）。
3. **第五代 AMD EPYC Turin (`Dasv7/Easv7`) + Azure Boost 带来了代际沙箱性能跃迁**：
   - 在 East US 2 与 Central US 的 E2B 实测基准中，搭载第五代 AMD EPYC Turin（最高 4.5GHz）与 Azure Boost 硬件卸载的 **`Standard_D96as_v7`（96 vCPU / 384 GiB）** 将 Base Sandbox 启动延迟从上代 `D96as_v6`（Genoa，`239 ms`）缩短至 **`108 ms`（提速 54.8%）**，将 Code-Interpreter V1（含 Jupyter 内核与 `envd`）启动延迟从 `255 ms` 缩短至 **`132 ms`（提速 48.2%）**，全面超越同规格 Intel `D96s_v6`（`116 ms` / `159 ms`，`$4.838/hr`）。
   - 结合 `85% HugePages` 预留与 `60% CPU` 扩容水位，仅需 **261 台 `D96as_v7` 客户端宿主机**即可在单个 Azure VMSS Flexible 规模集（上限 1,000 台 VM）内稳态承载 **100,000 个并发 512MiB MicroVM 沙箱**。
4. **状态底座迎来 AI 原生收敛：Azure HorizonDB (Preview) + Cosmos DB + Sandbox Snapshot 三位一体**：
   - 数据库只能存结构化变量，无法冻结已打开的浏览器 DOM 或 Python 内存对象；而纯沙箱快照又无法做跨会话关系查询与向量检索。
   - 生产架构必须采用 **“数据库存业务检查点与长期记忆 + 沙箱快照存进程与文件系统现场”** 的双层设计。其中 **Azure HorizonDB (Preview)** 在单一 PostgreSQL 引擎内融合 **ACID 事务 + JSONB 半结构化文档 + DiskANN 向量检索 + 存算分离与 15 只读副本**，直接对齐 OpenAI 支撑 8 亿用户、100 万+ QPS 的 PostgreSQL 读写分离架构范式；**Azure Cosmos DB** 则在德国商业银行（Commerzbank）虚拟助手 Ava 中实证支撑每月 **30,000+ 会话**与 **~75% 自动闭环率**。
5. **安全与治理绝不能依赖 Agent 自觉（Never Trust the Prompt）**：
   - 无论是开发者开启 `--yolo` 豁免权限，还是黑客通过文档注入恶意指令，Agent 内部的 Prompt 规则都只是“软约束”。
   - 真正的企业级架构必须将控制权收归平台层：通过 **Microsoft Entra Agent ID** 强制绑定 Blueprint 与责任人（严禁 Agent 直接继承用户登录 Token，按单次动作签发短时最小权限凭证），通过 **Unified AI Gateway (APIM)** 实现 **容器内零 LLM API Key、Prefix-Cache 会话亲和路由、三级（用户/团队/实例）RPM·TPM·预算硬熔断**，以及通过 **NetworkPolicy 强制封禁 `169.254.169.254` (IMDS)**。

---

## 1. 全景视图：AI Agent Infra on Azure 四层全栈架构与可视化导览

> **📐 高清矢量架构与工作流图谱（SVG Visual Atlas）**：本 Playbook 配套 8 张自包含矢量架构图（`assets/01-*.svg` 至 `assets/08-*.svg`，全部通过 `xml.etree.ElementTree` 严格 XML 语法校验）：
> 1. [图 1：Azure AI Agent Infra 四层全栈参考架构全景图 (Build · Run · Ground · Govern)](assets/01-azure-agent-infra-4layer-panorama.svg)
> 2. [图 2：Azure 六大 Agent Runtime 责任边界、隔离机制与恢复延迟矩阵](assets/02-runtime-spectrum-6tier-matrix.svg)
> 3. [图 3：AI Agent Infra 双阶段架构选型决策树与数据底座配对图](assets/03-scenario-decision-tree-and-routing.svg)
> 4. [图 4：AKSClaw 多租户 Kubernetes Agent 平台参考架构 (6 大支柱与 5 道平台硬边界)](assets/04-aksclaw-multi-tenant-k8s-architecture.svg)
> 5. [图 5：E2B on Azure VMSS 生产级参考架构图 (Manus × E2B 10万+ 并发云端沙箱底座)](assets/05-e2b-on-azure-vmss-reference-architecture.svg)
> 6. [图 6：Firecracker MicroVM 沙箱内部机理 (UFFD + NBD) 与 Azure v6/v7 实测启动延迟对比](assets/06-e2b-microvm-internals-and-vm-benchmark.svg)
> 7. [图 7：多智能体协同工作流 (MAF × Copilot SDK × Durable) 与状态持久化选型矩阵](assets/07-multi-agent-workflow-and-state-checkpoint.svg)
> 8. [图 8：Azure Agent Infra Playbook 六大高优场景、四维资质筛查与五步落地工作流](assets/08-field-playbook-5step-execution-flow.svg)

### 1.1 四层全栈架构全景图（Build · Run · Ground · Control & Govern）

![Azure AI Agent Infra 四层全栈参考架构全景图](assets/01-azure-agent-infra-4layer-panorama.svg)

```mermaid
flowchart TB
    subgraph L1["Layer 1 · Build (Agent Harness 编排与执行循环层)"]
        direction LR
        H1["Microsoft Agent Framework (MAF)\n跨运行时统一多 Agent 编排与状态恢复"]
        H2["GitHub Copilot SDK\n生产级 Coding / Shell / MCP 执行内核"]
        H3["BYO 开源与三方框架\nLangGraph · OpenClaw · Hermes · CrewAI"]
        H4["开放互操作协议\nMCP (Model Context) & A2A (Agent-to-Agent)"]
    end

    subgraph L2["Layer 2 · Run (Azure 6-Tier Agent Runtime 计算与隔离层)"]
        direction LR
        R1["1. Foundry Hosted Agents\nAgent 级全托管 · 1,400+ MCP 工具"]
        R2["2. Durable Functions\nServerless 长周期审批挂起与重放"]
        R3["3. ACA Dynamic Sessions\nHyper-V 预热会话池 (~210ms)"]
        R4["4. ACA Sandboxes (Preview)\n显式 Pause/Resume · 内存/磁盘快照"]
        R5["5. AKS + Kata Pod VM (AKSClaw)\n多租户独立内核 · 共享技能库"]
        R6["6. E2B on Azure VMSS (D96as_v7)\nFirecracker MicroVM · 108ms 恢复"]
    end

    subgraph L3["Layer 3 · Ground (模型、知识检索与状态记忆层)"]
        direction LR
        G1["Foundry Models (11,000+)\nAOAI · Claude · DeepSeek · Llama"]
        G2["Foundry IQ & AI Search\n混合向量检索 · 语义重排 · 权限裁剪"]
        G3["Azure HorizonDB (Preview)\nPG ACID + JSONB + DiskANN Vector"]
        G4["Cosmos DB & Blob Snapshots\n全球多活会话流 + UFFD/NBD 快照卷"]
    end

    subgraph L4["Layer 4 · Control & Govern (零信任身份、网关与舰队治理层)"]
        direction LR
        C1["Microsoft Entra Agent ID\nBlueprint + Sponsor · 逐动作短时令牌"]
        C2["Unified AI Gateway (APIM)\n容器零密钥 · Prefix-Cache 亲和 · 配额硬熔断"]
        C3["Platform Security & Audit\n封禁 IMDS · 出网白名单 · OTel + Defender/Purview"]
    end

    L1 --> L2 --> L3 --> L4
```

### 1.2 为什么传统 Web 微服务基础设施无法直接承载生产级 Agent？

在传统云原生 Web 应用中，一次 HTTP 请求通常在 `50ms ~ 500ms` 内完成，无状态容器（Stateless Pod）配合关系型数据库即可满足需求。然而，当企业将 AI Agent 推向生产时，会立即遭遇以下 **五大基础设施结构性冲突**：

| 结构性冲突维度 | 传统 Web / 微服务假设 | 生产级 AI Agent 真实负载特征 | 对应的 Azure Agent Infra 破局机制 |
|---|---|---|---|
| **1. 执行时长与挂起等待** | 请求秒级返回，连接断开即任务失败 | 单次任务可持续数分钟至数天（如等待采购主管邮件审批或跨时区排障） | **Durable Functions** 零算力挂起等待外部事件 + **ACA Sandboxes / E2B** 快照冻结恢复 |
| **2. 不可信代码与系统调用** | 仅运行经过 CI/CD 严格审查的静态编译代码 | Agent 实时生成未知 Python/Bash 脚本、安装第三方包、操作无头浏览器甚至执行 `kubectl` | **ACA Dynamic Sessions** (Hyper-V)、**AKS Kata Pod VM** (`kata-mshv-vm-isolation`)、**E2B Firecracker MicroVM** |
| **3. 状态形态的多样性** | 结构化行记录（SQL）或简单键值缓存（Redis） | 同时包含：**ACID 业务元数据**、**JSONB 对话与工具树**、**高维语义向量**，以及**已打开的进程内存与文件系统现场** | **Azure HorizonDB (Preview)** / **Cosmos DB** 存结构化与向量检查点 + **Sandbox Snapshot (`UFFD`+`NBD`)** 存进程与磁盘现场 |
| **4. 身份归属与越权爆炸半径** | 服务使用单一全局 Managed Identity 或透传用户 OBO Token | 若 Agent 继承用户完整登录态，一旦遭 Prompt 注入即可删库、读机密邮件或窃取宿主机 IMDS 凭据 | **Microsoft Entra Agent ID**（独立工作负载身份 + 责任人绑定 + 按动作签发短时最小权限 Token）+ **封禁 `169.254.169.254`** |
| **5. Token 成本失控与网关限流** | 按 QPS 限流，单次请求成本恒定且可预测 | Agent 陷入推理死循环可在数分钟内耗尽整月 Token 预算；或 10 万个动态沙箱子域名同时发起 WebSocket 流 | **Unified AI Gateway (APIM)** 三级（用户/团队/实例）RPM·TPM·预算硬熔断 + `rate-limit-by-key` 按动态 `Host` 独立限流 |

---

## 2. 运行时光谱与技术选型深度对比：Azure 六大 Agent Runtime 横向评测

![Azure 六大 Agent Runtime 责任边界、隔离机制与恢复延迟矩阵](assets/02-runtime-spectrum-6tier-matrix.svg)

### 2.1 六大运行时 12 维度全景对比表

Azure 并未试图用单一产品统合所有 Agent 负载，而是沿着 **“平台托管体验（Managed Experience） ↔ 底层基础设施控制力（Deep Infrastructure Control）”** 构建了 6 个梯度分明的运行时选项：

| 对比维度 | 1. Foundry Hosted Agents | 2. Azure Functions + Durable Functions | 3. ACA Dynamic Sessions | 4. ACA Sandboxes (Preview) | 5. AKS + Kata Pod VM (`AKSClaw`) | 6. E2B on Azure VMSS (`D96as_v7`) |
|---|---|---|---|---|---|---|
| **核心抽象粒度** | Agent 实例与会话线程（Thread） | 事件触发函数 + 有状态编排器（Orchestrator） | 预热隔离执行会话池（Session Pool） | 可编程有状态容器工作区（Workspace） | 多租户 Kubernetes Pod / Pod VM 舰队 | 毫秒级克隆的轻量级虚拟机（Firecracker MicroVM） |
| **底层隔离边界** | 平台托管多租户服务边界 | Serverless Worker 进程/实例隔离 | **Hyper-V 硬件级虚拟化边界** | 隔离容器工作区 + 显式端口/网络策略 | **Kata Containers 独立 Guest Kernel (Pod VM)** | **KVM + Firecracker MicroVM + 独立 NetNS (`ns-N`)** |
| **支持不可信代码执行** | 否（仅调用受控 API / MCP 工具） | 否（聚焦控制流编排与确定性重放） | **是**（内置 Python 解释器或自定义容器） | **是**（支持完整自定义 OCI 镜像与 Shell） | **是**（Pod VM 硬件隔离执行任意 CLI/脚本） | **是**（完整 Linux 内核、Root 权限、GUI 桌面） |
| **状态持久化与文件系统** | 托管会话线程（可外接自有 Cosmos DB） | Durable Task Scheduler 自动持久化执行历史 | 会话存活期内保留本地文件；**空闲回收后清零** | **支持内存与磁盘快照（Snapshot）+ 持久卷挂载** | **团队共享只读技能 PV + 实例独占读写状态 PV** | **UFFD 内存按需缺页恢复 + NBD 块设备差分快照** |
| **显式 Pause / Resume** | 平台自动管理生命周期 | 支持 `wait_for_external_event` 无限期挂起唤醒 | 不支持（按冷却超时参数自动回收） | **支持编程式 `create / pause / resume / delete`** | 支持（结合 KEDA 缩容至 0 与 PV 状态重挂载） | **支持编程式 Pause/Resume（实测 `108ms` 恢复）** |
| **典型启动 / 恢复延迟** | `~180–850 ms`（服务端托管调度） | `~95 ms` 热唤醒 / `~1.2 s` 冷启动 | **`~210 ms`**（预热池分配） vs `~2.2 s` 冷启动 | **`~320 ms`**（快照恢复） vs `~1.65 s` 冷启动 | `~160 ms` 常驻唤醒 / `~1.4 s` Pod VM 拉起 | **实测 `108 ms` Base / `132 ms` Code-Interpreter V1** |
| **最大单次运行窗口** | 会话级持久化，单步工具调用受超时约束 | **无上限**（可持续数天至数月等待审批） | 短时任务（通常数分钟至数小时，空闲即回收） | 跨任务长期保留（支持休眠数天后续接） | **7×24 全天候常驻**或按事件/排班动态唤醒 | 支持长连接流式桌面（可配置任意 Timeout 与续期） |
| **网络与多协议暴露** | 标准 HTTPS REST / OpenAI 兼容端点 | HTTP Trigger / Event Grid / Service Bus | 受控 Session API 路由（默认禁公网直连） | **支持自定义暴露端口（Web 预览 / 调试端口）** | K8s Ingress / Service Mesh / 严格 Egress 白名单 | **通配符子域名 `<port>-<id>.domain` + 原生 WebSocket/VNC** |
| **内置工具与生态集成** | **1,400+ Foundry Toolboxes (MCP / Logic Apps)** | 原生绑定 Azure 事件流与 Durable 活动函数 | 原生集成 LangChain / Semantic Kernel / MAF | 兼容任意容器化研发工具链、Playwright、Git | **共享团队 Skill 市场** + Sidecar MCP Server | 内置 `envd` (`:49982`)、Jupyter (`:8888`)、XFCE/noVNC (`:6080`) |
| **弹性扩缩容机制** | 平台全自动托管弹性 | 事件驱动毫秒级 Scale-to-Zero | 预热池容量（Ready Sessions）自动补齐 | 按工作区 API 调用动态创建与休眠 | **KEDA 事件/队列驱动 + Cluster Autoscaler / Karpenter** | **VMSS Flexible（60% CPU 扩容 + HugePages 排空缩容）** |
| **客户运维负担 (1~6)** | `1 / 6`（极低：仅关注 Prompt 与工具配置） | `2 / 6`（低：仅编写无状态编排函数） | `3 / 6`（中低：管理池大小与自定义镜像） | `3 / 6`（中低：管理工作区生命周期与快照策略） | `5 / 6`（高：需 K8s 平台工程与网络/安全治理能力） | `6 / 6`（极高：需自建 Nomad/Consul/Firecracker/NBD 控制面） |
| **最佳代表案例 / 原型** | 企业内部 HR/IT/销售助手、快速 PoC | 采购寻源、财务付款审批、跨系统订单履约 | ChatGPT/Copilot 类代码解释器、Excel 动态分析 | 云端 Coding Agent、自动化浏览器测试工作台 | **微软内部 SRE/研发智能体平台 (`AKSClaw`)** | **Manus 云端虚拟电脑（10万+ 并发 E2B 沙箱）** |

### 2.2 核心易混概念辨析：ACA Dynamic Sessions vs ACA Sandboxes (Preview) vs E2B on VMSS

在实际架构评审中，团队最容易混淆 **ACA Dynamic Sessions**、**ACA Sandboxes (Preview)** 与 **E2B on Azure VMSS**。三者的核心分水岭在于 **“状态是否需要跨任务冻结恢复”** 以及 **“并发规模与恢复延迟是否突破平台托管上限”**：

1. **何时选 ACA Dynamic Sessions（会话级短平快隔离池）**：
   - 你的 Agent 住在 `ACA Apps` 或 `Foundry` 中，绝大多数时间只做推理和 API 调用，偶尔需要运行一段 LLM 生成的 Python 代码画图、算表或解析上传的 PDF。
   - 你需要 **Hyper-V 硬件级隔离** 和 **预热池带来的 `~210ms` 极速分配**，但**不需要**在明天用户再次提问时保留昨天的本地临时目录（所有业务结果在任务结束时已写回 `HorizonDB` 或 `Cosmos DB`）。
2. **何时选 ACA Sandboxes (Preview)（工作区级有状态编程环境）**：
   - 你正在构建一个 **Coding Agent** 或 **Browser Automation Agent**。Agent 克隆了一个 2GB 的 Git 仓库、安装了 `node_modules`、启动了本地 Dev Server 并打开了特定端口预览。
   - 用户审阅代码可能需要 3 小时。你希望在用户离开时调用 `pause` 将整个工作区的**内存与磁盘制作快照**并释放计算计费，在用户回来点击“继续修改”时调用 `resume` 秒级恢复现场，且**不想自己运维 Kubernetes 或 Firecracker 集群**。
3. **何时选 E2B on Azure VMSS (`Standard_D96as_v7`)（超大规模自定义虚拟电脑底座）**：
   - 你是像 **Manus** 一样的数字原生（AI-Native）产品公司，核心产品承诺就是“给每个用户任务分配一台完整的云端电脑（含 Linux CLI、Jupyter 内核、Chrome 浏览器和实时可交互的 noVNC 远程桌面）”。
   - 你的并发规模达到 **10,000 ~ 100,000+ 在线沙箱**，要求沙箱从快照恢复到可执行指令的延迟稳定在 **`108ms ~ 132ms`**，并且需要按每个动态沙箱子域名（`<port>-<sandboxId>.domain.com`）执行独立网关限流与极致单位算力成本优化。

### 2.3 跨云厂商 Agent Runtime 横向对标（Azure vs AWS vs GCP vs 阿里云）

| 能力层级 | Microsoft Azure (本 Playbook 体系) | AWS (Amazon Web Services) | Google Cloud (GCP) | 阿里云 (Alibaba Cloud) |
|---|---|---|---|---|
| **全托管 Agent 服务** | **Foundry Hosted Agents** (1,400+ MCP 工具箱 + Entra Agent ID) | **Amazon Bedrock Agents / AgentCore** | **Vertex AI Agent Engine** | **阿里云百炼 Agent / 函数计算 AgentRun** |
| **Serverless 持久状态机** | **Azure Durable Functions + Durable Task Scheduler** | AWS Step Functions | Google Cloud Workflows | 阿里云 Serverless 工作流 (FnF) |
| **托管代码解释器 / 会话池** | **ACA Dynamic Sessions** (Hyper-V 硬件虚拟化预热池) | Bedrock Code Interpreter / Lambda | Vertex AI Code Execution | 百炼代码解释器 / 函数计算实例级快照 |
| **有状态容器沙箱** | **ACA Sandboxes (Preview)** (显式 Pause/Resume + 内存/磁盘快照) | ECS Fargate + EFS (缺乏原生内存快照 API) | Cloud Run Jobs + GCS FUSE | **无影 AgentBay** / ACS 容器计算 |
| **多租户 K8s 硬件虚拟化** | **AKS + Kata Containers PodSandboxing (`kata-mshv-vm-isolation`)** | EKS + Firecracker / Bottlerocket | GKE Sandbox (**gVisor** 用户态内核拦截，非独立 VM) | ACK + 袋鼠云沙箱 / 灵骏 ACS |
| **自建高密 MicroVM 宿主机** | **`Standard_D96as_v7` (5th Gen EPYC Turin + Azure Boost, `108ms` E2B)** | EC2 Bare Metal (`i3en.metal` / `m7i.metal` + Nitro) | Compute Engine C3/C4 (支持 Nested Virtualization) | ECS 裸金属 (`ebmg7` / `ebmc7` + CIPU) |
| **AI 原生 PG 状态与向量库** | **Azure HorizonDB (Preview)** + **Azure Cosmos DB** | Amazon Aurora PostgreSQL + DynamoDB | Cloud SQL / AlloyDB AI + Firestore | PolarDBPG + Lindorm / Tablestore |
| **原生 Agent 身份与网关** | **Microsoft Entra Agent ID** + **APIM AI Gateway** | IAM Roles Anywhere + API Gateway | Workforce Identity + Apigee | RAM 角色 + Higress AI 网关 |

---

## 3. 双阶段架构选型决策树与六大高优场景映射（Decision Tree & Scenario Routing）

![AI Agent Infra on Azure 双阶段架构选型决策树与数据底座配对图](assets/03-scenario-decision-tree-and-routing.svg)

### 3.1 阶段 A：商务模式与交付团队门控（提炼自 `Agent_Infra_Playbook.pptx` Slide 7）

在现场架构设计中，最常见的失败并非技术选错，而是 **“将客户的组织交付能力与基础设施控制诉求错配”**。Playbook 确立了严格的三步前置门控：

```mermaid
flowchart TD
    Start(["开始：评估客户 AI Agent 工作负载"]) --> Q1{"Q1: 目标客群是 To-B 还是 To-C？"}
    Q1 -->|"To-C (消费者/数字原生产品)"| ToC["直通 Modernization PaaS / Azure VM\n(追求百万级弹性、低延迟与极致单位成本)"]
    Q1 -->|"To-B (企业内部或 B2B 客户)"| Q2{"Q2: 是否需要超越平台托管的底层控制？\n(自定义OS/私有网络/不可信代码沙箱/成本定制)"}
    Q2 -->|"否 (标准 API / 知识检索 / 受控工具)"| Foundry["推荐：Microsoft Foundry Hosted Agents\n+ 1,400+ MCP 工具箱 + Entra Agent ID\n(注：仍需应用层 Prompt 与工具联调开发)"]
    Q2 -->|"是 (托管服务无法满足控制或隔离需求)"| Q3{"Q3: 客户是否拥有专职研发/平台团队？"}
    Q3 -->|"否 (缺乏自有工程交付团队)"| Hold["⛔ 交付门禁拦截 (Hold Gate)\n必须先引入 CSU 或 AI 合作伙伴补齐研发力量\n【铁律：严禁因缺人手而把需底层控制的场景硬塞回 Foundry】"]
    Q3 -->|"是 (具备研发与运维团队)"| StageB["✅ 进入 Stage B：按工作负载特征\n精准选择 ACA / AKS / Functions / VMSS"]
    ToC --> StageB
```

> **⚠️ 架构师必读铁律（来自 `Agent_Infra_Playbook.pptx` Slide 7 Speaker Notes）**：
> 1. **Foundry Hosted Agents 绝不等于“零代码配置”**：即便选择全托管 Foundry，客户依然需要编写与调优 Agent 逻辑、工具契约和评测集，只是免去了容器集群和底层运行时的基础设施运维。
> 2. **严禁反向错配（No Fallback Misrouting）**：如果客户在 Q2 中明确需要超越托管服务的底层基础设施控制（例如必须执行不可信动态脚本、要求自定义容器镜像或特殊内网路由），但在 Q3 中缺乏自有开发团队，**绝对不能因此回头推荐 Foundry Hosted Agents**——因为 Foundry 无法满足其底层控制硬约束，强推只会导致 PoC 失败。正确动作是保持在 Modernization PaaS 路径上，先通过微软 CSU 或认证合作伙伴补齐工程交付团队。

### 3.2 阶段 B：六大经典业务场景到运行时与数据底座的确定性映射

结合 `Agent Runtime Customer Pitch - ZH-CN v1.pptx`（Slides 6–15）与 `simulator/agent_infra_sizer.py` 的形式化规则，以下为 6 类核心场景的标准架构配对：

| 场景编号 | 典型业务工作负载 | 首选宿主与执行运行时 (Run) | 推荐状态与记忆底座 (Ground) | 核心编排与治理组件 (Build & Govern) |
|---|---|---|---|---|
| **场景 A** | **标准企业助手与部门 Agent 工厂**<br>（HR 问答、IT 服务台、CRM/ERP 查询） | **Foundry Hosted Agents** | Foundry IQ (AI Search) + **Azure Cosmos DB** | Foundry Toolboxes (1,400+ MCP) + **Entra Agent ID** |
| **场景 B** | **面向客户的交互式业务助手**<br>（如德国商业银行 Ava：3万+月会话，75%自动闭环） | **Foundry Agent Service + ACA Apps + AKS** | **Azure Cosmos DB**（跨子 Agent 共享实时上下文）+ AI Search | Microsoft Agent Framework (MAF) + Defender + Purview |
| **场景 C** | **研究分析、文档处理与动态代码解释器**<br>（LLM 实时生成 Python 处理 CSV/PDF/图表） | **ACA Apps（宿主编排）+ ACA Dynamic Sessions（预热隔离池）** | **Azure HorizonDB (Preview)** 或 Cosmos DB（外部持久化结果） | LangGraph / MAF + APIM AI Gateway |
| **场景 D** | **云端 Coding Agent 与浏览器自动化工作台**<br>（需保留 Git 工作树、依赖包、开启端口并跨天恢复） | **ACA Apps / AKS + ACA Sandboxes (Preview)** | **Sandbox 内存/磁盘快照 + Persistent Volume + HorizonDB** | **GitHub Copilot SDK** + Playwright MCP + Entra Agent ID |
| **场景 E** | **长周期采购、财务审批与跨系统事务工作流**<br>（多 Agent 协同校验 + 挂起数天等待人工审批 + 失败重试） | **Azure Functions + Durable Functions + ACA Apps** | **Durable Task Scheduler + Azure HorizonDB**（ACID 事务检查点） | MAF + Logic Apps 连接器 + Teams/Slack 审批卡片 |
| **场景 F** | **多租户研发/SRE 舰队 (`AKSClaw`) 与 10万+ 虚拟电脑 (`E2B`)**<br>（全员专属持久 Agent 或 AI Native 虚拟桌面产品） | **AKS + Kata Pod VM (`AKSClaw`)** 或 **E2B on Azure VMSS (`D96as_v7`)** | **共享只读技能 PV + 实例状态 PV + HorizonDB** / **UFFD + NBD 快照** | OpenClaw / Hermes / Copilot SDK + **APIM 按 Host 限流** + **5 道平台硬边界** |

---

## 4. 企业级多租户 Kubernetes Agent 平台深度解析：AKSClaw 参考架构

> 本节提炼自 `08 AKSClaw-Multi-Tenant-Kubernetes.pptx`（全部 19 页幻灯片及内嵌架构图完整 OCR 还原）。

当企业从“单点 Agent 试点”迈向 **“为数百名研发/SRE 工程师或数千个外部企业租户每人配备一个 7×24 在线的专属 Agent”** 时，单机或零散容器方案会迅速暴露出 **技能碎片化、权限失控、容器逃逸风险、Token 账单爆炸与人员离职孤儿 Agent** 五大顽疾。**AKSClaw（Multi-Tenant Agent Runtime on AKS）** 给出了经过生产验证的六支柱参考架构：

![AKSClaw 多租户 Kubernetes Agent 平台参考架构](assets/04-aksclaw-multi-tenant-k8s-architecture.svg)

### 4.1 支柱一：团队级共享技能市场（Team Skill Marketplace）与状态读写分离

在没有统一平台前，工程师 A 写了一个高质量的 `aks-node-not-ready-diagnosis` 排障技能，工程师 B 和 C 只能靠手动复制粘贴，一旦底层命令更新，全员版本立即漂移。

AKSClaw 在 AKS 存储层实现了精妙的 **“只读技能共享 + 读写状态隔离”** 双卷挂载模型：
- **共享只读技能卷（`/skills`，`ReadWriteMany` 对 Agent Pod 以 `readOnly: true` 挂载）**：
  - 1 人编写 Skill（包含排障 SOP、Bicep 规范、IcM 查询脚本）→ 提交 Git PR 通过安全与代码审查 → 发布至团队技能库 → **全团队所有运行中的 Agent 实例即刻可见可用**。
  - 每个技能具备 **语义描述（Semantic Discovery）**、**风险等级标签（只读查询 vs 生产变更）** 与 **版本可回滚机制**。
- **实例独占状态卷（`/workspace` 与 `/memory`，`Per-Instance PersistentVolume` + `Azure HorizonDB`）**：
  - 虽然所有 Agent 共享同一个技能市场，但每位工程师/租户的对话上下文、个人偏好（`MEMORY.md`）、克隆的代码分支与临时凭据严格隔离在各自独立的 PV 与数据库命名空间中，绝不串租户。

### 4.2 支柱二：Kata Containers 硬件级沙箱隔离与 BYO Agent Harness

AKSClaw 不绑定单一 Agent 框架，而是基于 **通用 Agent 容器契约（Universal Agent Contract）** 支持多框架混部：
- **支持任意主流 Harness**：`OpenClaw`、`Hermes`、`GitHub Copilot SDK`、`Claude Code`、`Microsoft Agent Framework (MAF)`、`LangGraph` 均可封装为标准 OCI 容器运行在同一 AKS 集群中。
- **Kata Containers Pod Sandboxing (`runtimeClassName: kata-mshv-vm-isolation`)**：
  - 由于工程与运维 Agent 需要在容器内执行 `bash`、`python`、`kubectl`、`az` 甚至编译未知代码，普通共享宿主机 Linux 内核的 `runc` 容器一旦遭遇内核提权漏洞即危及同节点其他租户。
  - AKS 原生支持的 **Kata Containers (Pod Sandboxing)** 为每个 Agent Pod 分配轻量级 Hypervisor 虚拟化边界与**独立 Guest Kernel**，结合严格的 `ResourceQuota`（CPU/Memory/Ephemeral-Storage）与 **KEDA 空闲自动休眠 / 事件秒级唤醒**，兼具安全性与高密成本效益。

### 4.3 支柱三：事件驱动自动预诊断（Event-Driven Triage）与跨时区 Follow-the-Sun 接力

```mermaid
sequenceDiagram
    autonumber
    participant Event as IcM 告警 / GitHub PR / 定时巡检
    participant GW as AKSClaw Event Gateway
    participant Agent as 专属 Agent 实例 (Kata Pod VM)
    participant Tool as 受控 MCP 工具 / Kusto / Git
    participant Chat as Teams / Slack 协同群 (Redmond → 欧洲 → 亚太)

    Event->>GW: 触发 P1 生产告警 (如 Pod CrashLoop / 延迟飙升)
    GW->>Agent: 秒级唤醒对应服务的值班 Agent 实例
    Agent->>Tool: 自动拉取 Pod 日志、Kusto 指标、最近 2 小时变更 PR
    Tool-->>Agent: 返回结构化遥测与 Diff 上下文
    Agent->>Chat: 推送《根因预诊断摘要 + 建议回滚/修复命令》卡片
    Note over Chat,Agent: 值班工程师上线即看到完整分析，无需从零查日志
    Chat->>Agent: 工程师点击 [Approve Remediation] (人工审批门控)
    Agent->>Tool: 使用签发的短时最小权限 Token 执行修复并更新 IcM
    Note over Agent,Chat: 换班时欧洲/亚太工程师直接在同一 Agent 实例接力，上下文零丢失
```

### 4.4 支柱四：五道不可绕过的平台级安全硬边界（5 Non-Bypassable Hard Boundaries）

AKSClaw 的核心安全哲学是：**“永远假设 Agent 内部逻辑会被 Prompt 注入攻破，或被用户开启 `--yolo` 自动执行模式”**。因此，以下 5 道防线全部在 Kubernetes 网络、身份代理与网关层强制实施，Agent 进程本身无权修改或绕过：

1. **封禁节点元数据服务（IMDS Block）**：通过 Kubernetes `NetworkPolicy` 强制阻断所有 Agent Pod 访问 `169.254.169.254`，彻底杜绝恶意脚本通过 WireServer/IMDS 窃取宿主机 Kubelet 或 VM Managed Identity 令牌。
2. **严格出向网络白名单（Egress Lockdown）**：默认拒绝（Default Deny）公网任意出站连接，仅放行集群内部 **Unified AI Gateway**、受控 **MCP 代理网关** 与白名单仓库域名，防止敏感代码或客户数据被外发渗出。
3. **凭据注入代理（Credential Proxy · 容器内零原始密钥）**：Agent 容器的环境变量与磁盘中**不包含任何长期有效的云账号密钥、数据库连接串或 LLM API Key**。当 Agent 需要执行受控操作时，由平台代理校验策略后注入仅对该动作有效的短时凭据。
4. **不可伪造的平台级身份（Entra Agent ID Workload Identity）**：Agent 的身份由平台在 Pod 调度层通过 Azure Workload Identity 硬件级绑定，Agent 无法自称是其他租户或伪造高权限管理员身份。
5. **旁路强制全链路审计（Mandatory Out-of-Band Audit）**：所有模型推理请求、MCP 工具调用与外部命令执行均在 AI Gateway 和凭据代理层强制落盘审计，即使 Agent 删除自身容器内的日志文件，平台审计链路依然 100% 完整。

### 4.5 支柱五 & 六：统一 AI 网关（Unified AI Gateway）与舰队生命周期治理

- **Unified AI Gateway 五大核心能力**：
  1. **API Key 集中托管**：容器内仅配置 `OPENAI_BASE_URL=http://ai-gateway.platform.svc.cluster.local/v1`，真实上游密钥保存在网关绑定的 Azure Key Vault 中。
  2. **Prefix-Cache 会话亲和路由**：将同一 Agent Session 的多轮长上下文请求固定路由至同一后端推理实例，最大化命中 KV Cache 前缀缓存，大幅降低首字延迟（TTFT）与输入 Token 成本。
  3. **OTel GenAI 零侵入遥测**：遵循 OpenTelemetry GenAI 语义约定，自动记录每次调用的模型版本、Prompt/Completion Tokens、延迟分布与工具调用链。
  4. **三级配额与预算硬熔断（Hard Stop）**：按 **User（个人） → Team（团队） → Agent Instance（单实例）** 实施 RPM、TPM 与日/月美元预算三级门限；一旦某个 Agent 陷入死循环触发阈值，网关直接返回 `429 Budget Exceeded` 硬熔断，保护全局账单。
  5. **多模型动态路由与故障转移**：当主力模型遇到区域性 `429/5xx` 时自动切换备用区域或降级模型。
- **舰队治理与“僵尸 Agent”清理**：
  - 每个 Agent 实例创建时必须在 **Entra Agent ID** 注册 **Owner / Sponsor（人类责任人）**、业务用途与有效期；当责任人离职、转岗或实例连续闲置超期时，平台自动触发冻结、凭据吊销与归档。

---

## 5. 超高密云端虚拟电脑底座深度解析：E2B on Azure VMSS (`Manus × E2B` 10万+ 并发沙箱参考架构)

> 本节提炼自 `Microsoft - E2B on Azure Solution - v1.pdf`、`E2B_CheckRide_Reordered_v2.pdf`（27 页）与 `e2b infra deep dive v0.2.pptx`（38 页）。

以 **Manus** 为代表的下一代通用自主 Agent 之所以惊艳，关键在于它不只是在对话框里输出文本，而是 **为每个任务实时分配一台独立的云端虚拟电脑（Cloud Sandbox）**——Agent 可以在里面自由运行 Bash、编写并执行 Python/Node.js 代码、使用无头或图形化浏览器抓取网页、操作桌面 GUI 软件，并通过实时画面流（VNC/WebSocket）向用户直播全过程。

要在 Azure 上自建支撑 **10,000 ~ 100,000+ 并发虚拟电脑**、且启动/恢复延迟低于 **`150ms`** 的 E2B（Environment-to-Build）生产集群，需要一套深度定制的云原生基础设施架构：

![E2B on Azure VMSS 生产级参考架构图](assets/05-e2b-on-azure-vmss-reference-architecture.svg)

### 5.1 为什么采用 Application Gateway (WAF v2) + APIM 双跳双前端网关架构？

在 E2B 架构中，每个正在运行的沙箱及其暴露的端口都会通过动态子域名对外提供服务，格式为：
`https://<port>-<sandboxId>.<your-domain>.com`（例如 `8888-sbx9f2a.e2b.contoso.com` 访问 Jupyter，`6080-sbx9f2a.e2b.contoso.com` 访问 noVNC 桌面 WebSocket）。

当并发沙箱达到 **100,000+** 时，单靠一层网关无法同时满足 **通配符 TLS 卸载 + WAF 防护 + 百万级动态域名独立限流 + 动态后端 VMSS 负载均衡**。参考架构设计了精巧的 **“AppGW 双前端 + APIM 环回”** 拓扑：

```mermaid
sequenceDiagram
    autonumber
    participant Client as Agent SDK / 用户浏览器
    participant AppGW_Pub as AppGW WAF v2 (Public IP :443)
    participant APIM as Azure API Management (APIM)
    participant AppGW_Priv as AppGW WAF v2 (Private IP :8080)
    participant Proxy as API Pool VMSS (Client Proxy :3002)
    participant Node as Client Pool VMSS (D96as_v7 :49982)

    Client->>AppGW_Pub: HTTPS / WSS 请求 (Host: 6080-sbx123.e2b.domain.com)
    Note over AppGW_Pub: 1. 通配符证书 TLS 卸载 (*.e2b.domain.com)<br/>2. OWASP WAF 规则拦截恶意载荷
    AppGW_Pub->>APIM: 转发至内网 APIM 网关
    Note over APIM: 3. 执行 rate-limit-by-key 策略<br/>counter-key = Request.Headers["Host"]<br/>确保 10万+ 沙箱会话彼此独立限流互不干扰
    APIM->>AppGW_Priv: 回调 AppGW 内网私有前端 (Private IP :8080)
    Note over AppGW_Priv: 4. 规避 APIM 无法直接挂载动态 VMSS 后端池的限制<br/>执行对 API Pool VMSS 的健康探测与负载均衡
    AppGW_Priv->>Proxy: 路由至 API Pool 中的 Client Proxy (:3002)
    Proxy->>Node: 根据 Consul/路由表直达对应 D96as_v7 宿主机上的 MicroVM
```

**APIM 核心限流策略配置（隔离 10 万+ 并发沙箱会话）**：
```xml
<policies>
    <inbound>
        <base />
        <!-- 按动态 Host 请求头（即每个独立的 <port>-<sandboxId> 会话）独立计算配额 -->
        <rate-limit-by-key calls="300"
                           renewal-period="60"
                           counter-key="@(context.Request.Headers.GetValueOrDefault("Host", "unknown"))"
                           increment-condition="@(context.Response.StatusCode >= 200 && context.Response.StatusCode < 400)" />
        <!-- 限流通过后回调 Application Gateway 的内网 Private Frontend IP -->
        <set-backend-service base-url="http://10.240.0.10:8080" />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
</policies>
```

### 5.2 Firecracker MicroVM 沙箱内部机理：为什么能做到 `108ms` 极速恢复？

![Firecracker MicroVM 沙箱内部机理与 Azure v6/v7 实测启动延迟对比](assets/06-e2b-microvm-internals-and-vm-benchmark.svg)

传统 Docker 容器冷启动拉取镜像需要数秒，而完整虚拟机冷启动更需要十余秒。E2B on Azure 之所以能将沙箱启动压缩到 **`108 ms`（Base） / `132 ms`（Code-Interpreter V1）**，核心在于它**不走冷启动（Cold Boot），而是走基于 `UFFD` + `NBD` 的快照热恢复（Snapshot Restore）**：

1. **构建期预热并冻结快照（Template Build Phase）**：
   - `Template Manager` 将用户的 `Dockerfile` 构建为 `rootfs.ext4` 根文件系统，启动一个真实的 Firecracker MicroVM，拉起内部的 **`envd` 守护进程（端口 `:49982`，基于 Connect RPC 实现进程执行、文件读写流与系统指标采集）**、**Jupyter Server (`:8888`)** 或 **XFCE4 + `x11vnc` (`:5900`) + `websockify/noVNC` (`:6080`) + `xdotool` 桌面栈**。
   - 待所有服务初始化就绪后，编排器立即暂停该 MicroVM，将其内存状态转储为 `memfile`，将磁盘块保存为基础镜像，上传至远端对象存储（Azure Blob / Files / Managed Lustre）。
2. **运行期 `UFFD (userfaultfd)` 内存按需缺页流式恢复**：
   - 当 Agent 请求创建一个新沙箱（或恢复一个已暂停的沙箱）时，宿主机**无需等待把数 GB 的 `memfile` 完整下载到本地内存**。
   - Firecracker 直接映射虚拟内存地址空间并立即恢复 vCPU 执行；当 Guest OS 访问尚未加载的内存页触发内核态 **Page Fault** 时，通过 Linux `userfaultfd` 机制由宿主机用户态守护进程实时从存储层拉取对应的 `4KB / 2MB` 内存页填入 **HugePages**。
3. **运行期 `NBD (Network Block Device)` + Dirty Bitmap 增量块设备**：
   - 根文件系统通过 `virtio-blk` 挂载在宿主机的 `nbdX` 设备上。基础只读块在宿主机本地高速缓存中多沙箱共享；沙箱产生的写操作仅写入本地差分层（Overlay），并通过 **Dirty Bitmap** 精确标记被修改的块。
   - 当沙箱执行 `pause` 时，仅需将增量脏内存页和脏磁盘块上传至存储层，实现百毫秒级冻结与恢复。
4. **独立网络命名空间（`ns-N`）与健康探针**：
   - 每个 Firecracker MicroVM 拥有独立的网络命名空间 `ns-N`，内部 `eth0` 绑定虚拟网卡 `tap0` 与 `veth` 对，宿主机通过 `iptables SNAT/DNAT` 完成端口映射，并通过 `169.254.0.21:49982/health` 每 `200ms` 轮询 `envd` 存活状态。

### 5.3 Azure VM v6 vs v7 实测沙箱启动基准（East US 2 / Central US 实测数据）

根据 `E2B_CheckRide_Reordered_v2.pdf`（Slides 18–19）在 **East US 2** 与 **Central US** 区域的实测基准，不同代际与处理器架构的 96 vCPU / 384 GiB 宿主机表现出显著差异：

| Azure VM SKU | 处理器代际与核心架构 | 规格 (vCPU / RAM) | Base Sandbox 启动延迟 | Code-Interpreter V1 启动延迟 | 按量付费价格参考 (Linux) | 架构评测结论 |
|---|---|---|---:|---:|---|---|
| **`Standard_D96as_v7`** | **5th Gen AMD EPYC 9005 (Turin, 最高 4.5GHz) + Azure Boost** | 96 vCPU / 384 GiB | **`108 ms`** 🏆 | **`132 ms`** 🏆 | 待区域全面 GA 公布 | **全场最优**：相比上代 AMD v6 提速 **54.8% / 48.2%**，相比 Intel v6 提速 **6.9% / 17.0%** |
| **`Standard_D96s_v6`** | 4th Gen Intel Xeon Platinum 8473C (Emerald Rapids) | 96 vCPU / 384 GiB | `116 ms` | `159 ms` | `$4.838 / hr`<br>(`$3,532 / mo` @ 730h) | 性能稳健，可作为 v7 尚未覆盖区域的生产主力机型 |
| **`Standard_D96as_v6`** | 4th Gen AMD EPYC 9V74 (Genoa) | 96 vCPU / 384 GiB | `239 ms` | `255 ms` | 见区域价表 | UFFD/NBD 密集页中断下延迟显著偏高，建议直接升级至 **v7** |

**为什么 `Dasv7 / Easv7` 对高密 MicroVM 沙箱具有决定性优势（Slide 18）？**
- **5th Gen AMD EPYC Turin + 无超线程物理核性能**：全核最高睿频达 **4.5 GHz**，支持最高 **160 vCPU / 1,280 GiB DDR5（`Easv7` 系列）**，单核 IPC 与 L3 Cache 局部性大幅降低了 Firecracker 创建与 `UFFD` 缺页中断上下文切换开销。
- **Azure Boost 软硬一体卸载**：将虚拟化网络与远端存储协议栈卸载至专用硬件，带来最高 **+35% 性价比提升、+20% 远端存储 IOPS、+50% 远端存储吞吐量以及 +75% 网络带宽**（在内存缓存负载上实测提升 `+65%`，加密负载 `+80%`，Web 服务 `+130%`）。

### 5.4 VMSS 非对称弹性扩缩容法则与开源版 E2B 的三大生产缺陷

1. **VMSS Flexible 非对称扩缩容铁律（Scale-Out 易，Scale-In 难）**：
   - **扩容（Scale-Out）**：配置当 Client Pool VMSS 平均 **CPU 利用率达到 `60%`** 时自动横向扩容新节点，预留 `40%` 算力缓冲吸收突发沙箱创建洪峰。
   - **缩容（Scale-In）**：**绝对不能仅凭 CPU 下降或常规 OS 内存指标触发缩容！** 因为 Firecracker MicroVM 的内存由宿主机 **HugePages（大页内存）** 静态预留，常规监控无法反映沙箱真实活跃状态，盲目销毁 VM 会直接杀死正在运行的客户沙箱。必须通过自定义指标采集宿主机 HugePages 分配率，并在缩容前触发 **沙箱快照热迁移（Live Drain）**。
   - **单规模集 10 万沙箱容量算账（由 `simulator/agent_infra_sizer.py` 验证）**：
     - 单台 `Standard_D96as_v7` 拥有 `384 GiB` 内存，按 `85%` 预留给 HugePages 可得 `334,233 MiB`；
     - 若每个沙箱平均分配 `512 MiB`，单机理论峰值可容纳 `652` 个沙箱，按 `60%` 稳态扩容水位计算，单机稳态承载 **`384` 个并发沙箱**；
     - 承载 **100,000 个并发沙箱**仅需 **`261` 台 `D96as_v7` 客户端节点**（外加 12 台 API 节点与 5 台 Nomad/Consul Server 节点，总计 `278` 台），完全可以放入**单个 Azure VMSS Flexible 规模集（上限 1,000 台 VM）** 中！
2. **开源版 E2B 直接上生产的三大致命缺陷及 Azure 加固方案（`e2b infra deep dive v0.2` Slide 34）**：
   - **缺陷 1：API Server 单点内存态无法水平扩展**：上游开源版 E2B 的 `api` 服务在单个进程内存中维护所有 `Node` 与沙箱的映射状态，若直接部署多副本会出现状态分裂，且进程重启即丢失全量节点状态。**加固方案**：将节点与会话注册表外置到 **Azure Database for PostgreSQL + Azure Managed Redis**。
   - **缺陷 2：宿主机重启后孤儿沙箱无自动恢复/清理**：当某台 Client Node VM 发生计划内维护或意外重启时，上游缺乏自动垃圾回收（GC）与沙箱漂移恢复机制。**加固方案**：结合 Nomad 健康检查与 VMSS 自动实例修复，在节点失联时自动将活跃会话引导至新节点从最近 NBD/UFFD 快照恢复。
   - **缺陷 3：网关层缺乏多租户动态域名限流**：上游仅靠简单反向代理转发，一旦单个租户沙箱发起洪泛请求会打垮全局代理。**加固方案**：前置 **AppGW WAF v2 + APIM `rate-limit-by-key`**。

---

## 6. 多智能体编排、持久工作流与状态记忆底座（MAF · Copilot SDK · Durable · HorizonDB · Cosmos DB）

![多智能体协同工作流与状态持久化选型矩阵](assets/07-multi-agent-workflow-and-state-checkpoint.svg)

### 6.1 多智能体协同范式：Microsoft Agent Framework (MAF) + GitHub Copilot SDK

在复杂企业场景中，单一 Agent 往往无法兼顾“全局业务状态流转”与“深度代码/工具实操”。`Agent Runtime Customer Pitch`（Slide 13）展示了极具代表性的双核协同模式：
- **外层编排总控（Microsoft Agent Framework / LangGraph）**：运行于 AKS、ACA Apps 或 Durable Functions 之上，负责定义多智能体协作拓扑（如：**诊断 Agent → 修复 Agent → 合规审查 Agent**）、管理全局状态检查点，并自动继承平台级的 OpenTelemetry 追踪、Entra Agent ID 身份与安全护栏。
- **内层专业执行器（GitHub Copilot SDK）**：作为经过 GitHub 亿级开发者验证的生产级执行内核，嵌入在 **ACA Sandboxes** 或 **AKS Kata Pod VM** 内部，直接调用内置的文件编辑、Shell 执行、测试运行与自定义 MCP Server，完成高难度的代码补丁生成与自动化修复。

### 6.2 状态与记忆底座深度选型：Azure HorizonDB (Preview) vs Cosmos DB vs Sandbox Snapshot

| 评估维度 | Azure HorizonDB (Preview) | Azure Cosmos DB | Sandbox Snapshot (`UFFD` / ACA Snapshot) |
|---|---|---|---|
| **核心技术定位** | **AI 原生 PostgreSQL 融合数据库**（存算分离 + 向量 + JSONB + ACID） | **全球分布式多模型 NoSQL 数据库**（毫秒级多活 + 高并发文档/事件流） | **运行时执行环境快照**（冻结进程内存页 + 磁盘文件系统差分块） |
| **统一承载的数据形态** | 单库同时承载 **关系表 (ACID) + 半结构化消息树 (JSONB) + 语义向量 (DiskANN)** | JSON 文档流 + 键值会话状态 + 内置向量索引 + Change Feed 事件流 | Linux 进程内存树（Python/Node 变量、DOM 状态）+ 本地磁盘文件树 |
| **扩展性与高可用架构** | 存算分离架构，支持快速拉起最高 **15 个只读副本（Read Replicas）** | 全球多区域双活/多活写入，99.999% SLA，自动弹性吞吐（Autoscale RU/s） | 依托远端对象存储（Blob/Lustre）与宿主机本地 NVMe / HugePages 缓存 |
| **框架 Checkpoint 集成** | 原生兼容 `LangGraph PostgresSaver`、MAF 与 Semantic Kernel 状态表 | Foundry Agent Service 原生支持 BYO Cosmos DB 线程存储与恢复 | 通过 Runtime API (`pause` / `resume`) 整机冻结与毫秒级唤醒 |
| **生产标杆案例与规模锚点** | 架构理念对标 **OpenAI on Azure PostgreSQL**（单主 + **~50 只读副本**，支撑 **8 亿用户**、**100万+ QPS**） | **德国商业银行 (Commerzbank) Ava**（支撑每月 **30,000+ 会话**，**~75%** 自动解决率） | **Manus × E2B on Azure**（`D96as_v7` 实测 **`108ms`** Base / **`132ms`** Code-Interpreter 恢复） |
| **工程防坑指南** | 1. 当前为 Preview，立项需核验目标 Region 可用性（生产可用 Azure DB for PG Flexible Server 兜底）；<br>2. 高并发下必须前置 **PgBouncer**（将连接建立从 `45ms` 降至 `5ms`，严控 5,000 最大连接数）与 **Cache Lease Lock** 防缓存击穿（`E2B CheckRide` Slide 21）。 | 按分区键（如 `tenantId + sessionId`）均匀打散，避免单分区热点（Hot Partition）超过 20GB 或 10,000 RU/s。 | **切勿将业务交易记录仅保存在沙箱快照中**——重要业务状态必须同步写回 HorizonDB 或 Cosmos DB，快照仅用于加速工作区现场恢复。 |

---

## 7. 零信任控制面：Microsoft Entra Agent ID、AI Gateway 与安全治理闭环

随着企业内部 Agent 数量从几个膨胀到数千个（甚至超过人类员工数量），传统的“给应用发一个 Client Secret 或 Managed Identity”模式彻底失效。Azure 构建了三层零信任控制面：

1. **Microsoft Entra Agent ID（将 Agent 作为独立的一等公民身份治理）**：
   - **Agent Blueprint（蓝图模板）+ Agent Identity（实例身份）**：在 Entra ID 中统一注册管理所有运行在 Foundry、ACA、AKS 或第三方云上的 Agent。
   - **强制绑定人类责任人（Owner / Sponsor）**：每个 Agent 实例必须有明确的业务责任人；当责任人离职或部门重组时，身份生命周期策略自动介入。
   - **最小权限与双重审计归属（Dual Attribution）**：Agent **绝不直接继承用户的完整登录 Token**；每次调用下游 API 或 MCP 工具时，由平台按需签发短时、限定作用域（Scoped）的工作负载令牌，并在审计日志中同时记录 `Initiating User` 与 `Acting Agent ID`。
2. **Unified AI Gateway（基于 Azure API Management 的模型与工具总控台）**：
   - 实现 **容器内零密钥（Keyless Pod）**、**Prefix-Cache 会话亲和路由**、**三级（User/Team/Agent）Token 速率与预算硬熔断**、**MCP Server 统一注册鉴权** 以及 **OpenTelemetry GenAI 全链路追踪**。
3. **Microsoft Defender for Cloud + Microsoft Purview**：
   - Defender 实时检测容器/沙箱内的异常进程执行、反弹 Shell 与恶意包下载；Purview 对进出 Agent 的敏感数据实施自动分类标签、防泄漏（DLP）拦截与合规留存。

---

## 8. Azure Agent Infra Field Playbook：六大高优场景、四维资质筛查模型与五步落地法

> 本节提炼自 `Agent_Infra_Playbook.pptx`（19 页）与 `GCR_Agent_Runtime_Priority_Accounts.xlsx` 中的 `Selection Logic` 及 `Summary` 方法论工作表（**严格遵循隐私合规红线：仅提取通用的四维技术信号分类模型、持续性门禁规则与 `$10,000` 模型信号阈值逻辑，100% 剔除任何具体客户名称、TPID 与内部财务行数据**）。

![Azure Agent Infra Playbook 六大高优场景、四维资质筛查与五步落地工作流](assets/08-field-playbook-5step-execution-flow.svg)

### 8.1 四维技术底座信号模型（4 Technical Foundations · 14 服务家族）

如何从海量云客户中科学识别出真正具备 **生产级 Agent 基础设施扩展潜力（High Propensity for Agent Infra）** 的目标架构？Playbook 建立了一套基于 **5 个月滚动观测窗口** 的四维信号筛查模型：

| 技术底座维度 (Foundation) | 强信号专用锚点服务 (Specific Anchor Families) | 通用基础支撑服务 (General Foundation Families) | 架构指示意义 |
|---|---|---|---|
| **1. Application & Runtime**<br>（应用与计算运行时） | **Azure Container Apps (ACA)**<br>**Azure Kubernetes Service (AKS)** | Azure App Service, Azure Functions, Azure Batch, Azure Virtual Machines | 决定客户是否已具备现代化容器/Serverless 宿主底座 |
| **2. Data, State & Knowledge**<br>（数据、状态与记忆） | **Azure Database for PostgreSQL / HorizonDB**<br>**Azure Cosmos DB**<br>**Azure Managed Redis** | Azure SQL Database, Azure Storage (Blob/Files) | 决定客户是否具备承载会话状态、Checkpoint 与缓存的能力 |
| **3. AI & Integration**<br>（模型、检索与集成网关） | **Foundry Models (Azure OpenAI)**<br>**Azure AI Search**<br>**Foundry Tools**<br>**Azure API Management (APIM)** | Azure Event Grid, Azure Service Bus | 决定客户是否已进入 RAG、工具网关与事件驱动集成阶段 |
| **4. Operations, Security & Governance**<br>（可观测、安全与治理） | —（作为跨底座生产成熟度乘数） | **Azure Monitor / App Insights**<br>**Azure Key Vault**<br>**Microsoft Defender for Cloud** | 决定客户工作负载是否已脱离玩具级 PoC 进入企业生产治理 |

### 8.2 核心筛查门禁规则（Persistence Gate、`$10,000` 模型信号门禁与五项潜客门禁）

1. **非模型服务持续性门禁（Persistence Rule）**：
   - 某个非模型服务家族必须在 **5 个月观测窗口内至少活跃 `>= 3` 个月**，且**必须包含最近连续 `2` 个月**，才被认定为有效生产信号（过滤一次性测试脉冲）。
2. **`$10,000` Foundry Models 强信号门禁与“信号 vs 金额分离铁律（Signal vs Amount Separation）”**：
   - **为什么将模型信号门槛从 `$1,000/月` 提升至 `$10,000/月`？** 小额模型消费往往只是零散 API 实验；只有当客户在**最近连续 3 个月每月 Foundry Models 消费均 `>= $10,000`** 时，才将其单独认定为经过验证的规模化模型锚点（Specific Model Anchor）。
   - **关键精算准则**：未达到 `$10,000/月` 的模型消费仅代表**不触发“单一模型强信号标签”**，但其真实消费金额依然 100% 保留在客户的相关基数（Relevant ACR）中；且客户依然可以通过 **非模型 Specific 锚点（如 ACA/AKS/PG/Cosmos/Search/APIM）** 或 **跨 `>=3` 个技术底座（Runtime + Data/AI）** 晋级为高优队列（Strong ACR / P1）！
3. **五项潜客晋级门禁（5 Potential Gates · 满足 `>= 3` 项即触发架构师深潜）**：
   - `Gate 1`：相关基础设施月均体量达到队列基准中位数以上；
   - `Gate 2`：同时具备生产级 **Runtime** 信号与 **Data 或 AI** 信号；
   - `Gate 3`：活跃服务横跨 **`>= 3` 个技术底座（Multi-Foundation Readiness）**；
   - `Gate 4`：至少命中 1 个 **Specific Anchor** 专用服务家族；
   - `Gate 5`：非模型相关基础设施消费在 5 个月窗口内前后端均值增长率 **`>= +20%`**。

### 8.3 五步现场推进工作流（5-Step Field Execution Workflow）

```mermaid
flowchart LR
    S1["01 Initial Screening\n四维底座信号初筛\n锁定 P1/P2 与赞助人"] --> S2["02 Discovery\n深潜 To-B/To-C 诉求\n识别沙箱/状态/合规痛点"]
    S2 --> S3["03 Define\n走双阶段决策树\n锁定 Runtime + 状态底座"]
    S3 --> S4["04 Validate (核心转化抓手)\n半日/一日动手工坊 (Workshop)\n+ 目标架构白板推演 (Whiteboard)"]
    S4 --> S5["05 Implement\n制定生产上线里程碑\n接入 AI Gateway 与舰队复制"]
```

- **Step 04 Validate（1/2 Day Hands-on Workshop + Architecture Design Session）是整个漏斗的决定性转化点**：
  - 📋 **配套现场执行手册**：详见 [`workshop-runbook.md`（Step 04 半日/一日客户动手工坊与白板推演手册）](workshop-runbook.md)，内含分钟级议程、三大实验赛道（Track A `ACA Dynamic Sessions` / Track B `AKSClaw Kata` / Track C `E2B on VMSS D96as_v7`）及 6 项上线门禁检查表；
  - 🧱 **12 套生产级 IaC 与网关策略蓝图**：[`aksclaw-kata-fleet.yaml`](blueprints/aksclaw-kata-fleet.yaml) · [`e2b-vmss-d96as-v7.bicep`](blueprints/e2b-vmss-d96as-v7.bicep) · [`e2b-apim-per-host-policy.xml`](blueprints/e2b-apim-per-host-policy.xml) · [`aca-dynamic-sessions-pool.bicep`](blueprints/aca-dynamic-sessions-pool.bicep) · [`entra-agent-id-ai-gateway-policy.xml`](blueprints/entra-agent-id-ai-gateway-policy.xml) · [`horizondb-langgraph-checkpointer.py`](blueprints/horizondb-langgraph-checkpointer.py) · [`agent-finops-cost-anomaly-alert.bicep`](blueprints/agent-finops-cost-anomaly-alert.bicep) · [`aksclaw-confidential-snp-nodepool.bicep`](blueprints/aksclaw-confidential-snp-nodepool.bicep) · [`aksclaw-zero-trust-egress-firewall-pls.bicep`](blueprints/aksclaw-zero-trust-egress-firewall-pls.bicep) · [`aksclaw-gpu-mig-kaito-nodepool.bicep`](blueprints/aksclaw-gpu-mig-kaito-nodepool.bicep) · [`aksclaw-otel-adx-tetragon-observability.bicep`](blueprints/aksclaw-otel-adx-tetragon-observability.bicep) · [`aksclaw-dapr-workflow-keda-scaler.bicep`](blueprints/aksclaw-dapr-workflow-keda-scaler.bicep)；
  - 上午通过 **Hands-on Workshop** 让客户研发团队亲手在 Azure 上跑通 `ACA Dynamic Sessions / Sandboxes` 或 `AKS Kata + MAF + HorizonDB` 的端到端 Demo；
  - 下午通过 **Whiteboard Architecture Session** 对齐并发容量、网络隔离（VNet/Private Endpoint/AppGW+APIM）、身份边界（Entra Agent ID）与故障恢复链路，当场产出经双方架构师确认的 **Target Architecture Diagram** 与上线倒排计划。

---

## 9. 深度定量建模：Firecracker 缺页分解、AKSClaw Kata 密度与 HorizonDB 留存模型

> 本章由确定性工程仿真模块 [`simulator/e2b_aksclaw_deep_benchmark.py`](simulator/e2b_aksclaw_deep_benchmark.py) 与输出台账 [`evidence/deep-benchmark-models.json`](evidence/deep-benchmark-models.json) 驱动，解答架构评审中最常被追问的三个定量边界问题。

### 9.1 E2B Firecracker MicroVM 恢复延迟四段式分解（1x 单发 vs 50x 并发突发）

为什么 `Standard_D96as_v7` 能在挂载 `2 GiB` Guest RAM 与 `Code-Interpreter` 根文件系统的前提下实现 **`108 ms` 单发 / `132 ms` 50 倍并发突发恢复**？核心在于启动瞬间**仅通过 UFFD 按需缺页拉取约 `64 MiB`（占 `2048 MiB` 的 `3.12%`）的热工作集页**，而非全量复制 `2 GiB` 内存快照：

| Azure 宿主机机型 | 并发度 | 总恢复耗时 (`ms`) | ① VMM/KVM 套接字初始化 (`21%`) | ② UFFD 热工作集缺页拉取 (`44%`) | ③ NBD RootFS 块元数据挂载 (`22%`) | ④ TAP + iptables SNAT 命名空间 (`13%`) | 热工作集占比 (`64/2048 MiB`) |
|---|---:|---:|---:|---:|---:|---:|---:|
| **`Standard_D96as_v7` (Turin v7 推荐)** | **1x** | **`108.0 ms`** | `22.68 ms` | `47.52 ms` | `23.76 ms` | `14.04 ms` | `3.12%` |
| **`Standard_D96as_v7` (Turin v7 推荐)** | **50x** | **`132.0 ms`** | `27.72 ms` | `58.08 ms` | `29.04 ms` | `17.16 ms` | `3.12%` |
| `Standard_D64as_v7` | 1x / 50x | `112.0` / `154.0 ms` | `23.52` / `32.34 ms` | `49.28` / `67.76 ms` | `24.64` / `33.88 ms` | `14.56` / `20.02 ms` | `3.12%` |
| `Standard_D32as_v7` | 1x / 50x | `126.0` / `247.0 ms` | `26.46` / `51.87 ms` | `55.44` / `108.68 ms` | `27.72` / `54.34 ms` | `16.38` / `32.11 ms` | `3.12%` |
| `Standard_D96s_v6` (Intel Emerald Rapids) | 1x / 50x | `141.0` / `158.0 ms` | `29.61` / `33.18 ms` | `62.04` / `69.52 ms` | `31.02` / `34.76 ms` | `18.33` / `20.54 ms` | `3.12%` |
| `Standard_D64s_v6` | 1x / 50x | `122.0` / `148.0 ms` | `25.62` / `31.08 ms` | `53.68` / `65.12 ms` | `26.84` / `32.56 ms` | `15.86` / `19.24 ms` | `3.12%` |
| `Standard_D32s_v6` | 1x / 50x | `125.0` / `221.0 ms` | `26.25` / `46.41 ms` | `55.00` / `97.24 ms` | `27.50` / `48.62 ms` | `16.25` / `28.73 ms` | `3.12%` |

### 9.2 AKSClaw 多租户节点沙箱密度对比（`kata-vm-isolation` vs `runc`）

在 AKS 宿主机上开启 `runtimeClassName: kata-vm-isolation`（Cloud Hypervisor 独立 Guest Kernel）会为每个沙箱 Pod 引入约 **`144 MiB`** 的 VMM + Guest 内核常驻内存开销，并扣除宿主机 `8% + 1.5 GiB` 的 Kubelet/Cilium/Tetragon 系统预留（单沙箱配额按 `0.5 vCPU / 2048 MiB` 测算）：

| AKS 工作节点 SKU | 规格 (vCPU / GiB) | 隔离运行时 (`RuntimeClass`) | 单 Pod Kata VMM 开销 | 扣减预留后可用内存 | 内存上限 Pod 数 | CPU 上限 Pod 数 | 实际可承载沙箱数/节点 | 有效业务内存利用率 |
|---|---|---|---|---:|---:|---:|---:|---:|---:|
| `Standard_D16s_v6` | 16 vCPU / 64 GiB | `kata-vm-isolation` | `+144 MiB` | `58,752 MiB` | 26 | 29 | **26 个** | `81.25%` |
| `Standard_D32s_v6` | 32 vCPU / 128 GiB | `kata-vm-isolation` | `+144 MiB` | `119,040 MiB` | 54 | 61 | **54 个** | `84.38%` |
| **`Standard_D64s_v6` (推荐)** | **64 vCPU / 256 GiB** | **`kata-vm-isolation`** | **`+144 MiB`** | **`239,616 MiB`** | **109** | **125** | **109 个** | **`85.16%`** |
| `Standard_D64s_v6` (对比基线) | 64 vCPU / 256 GiB | `runc` (共享内核，无硬件隔离) | `0 MiB` | `239,616 MiB` | 117 | 125 | **117 个** | `91.41%` |

> **架构师结论**：在 `Standard_D64s_v6` 节点上启用 `kata-vm-isolation` 仅牺牲约 **`6.8%` 的单节点沙箱密度（109 vs 117）**，却换取了每个租户独立的硬件虚拟化内核边界，性价比极高。

### 9.3 Azure HorizonDB + PgBouncer 连接池复用与 128 TB 存储留存边界

当大规模 LangGraph / MAF / Durable 舰队以每分钟 `4~6` 次的频率写入 `16 KiB` 状态 Checkpoint 时，如果不做连接池复用与热数据 TTL 压缩归档，将直接触发两道硬瓶颈：

| 并发活跃 Agent 线程数 | 总写入吞吐 (`QPS`) | 直连所需 PG 连接数 | PgBouncer 后端连接数 | 连接收敛倍率 | 端到端 Checkpoint P95 (`ms`) | 每日原始写入量 (`GiB/day`) | 未压缩年化累积量 (`TiB/yr`) | 30天热留存 + ZSTD 压缩 (`TiB`) | 是否满足 HorizonDB `128 TB` 上限 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| `1,000` | `100.0 QPS` | 1,000 | `100` | **`10x`** | `9.42 ms` | `131.84 GiB` | `47.01 TiB` | `1.35 TiB` | ✅ 满足 |
| **`10,000` (主力规模)** | **`1,000.0 QPS`** | **10,000 (超直连上限)** | **`200`** | **`50x`** | **`11.40 ms`** | **`1,318.36 GiB`** | **`470.05 TiB` (❌ 超限)** | **`13.52 TiB`** | **✅ 开启 30天热留存后满足** |
| `50,000` (超大规模) | `3,333.33 QPS` | 50,000 (超直连上限) | `400` | **`125x`** | `16.53 ms` | `4,394.53 GiB` | `1,566.85 TiB` (❌ 超限) | `45.06 TiB` | **✅ 开启 30天热留存后满足** |

---

## 10. 跨区域双活容灾与有状态沙箱故障切换（Multi-Region Active-Active Agent Infra DR & Stateful Sandbox Failover）

> 本章由确定性容灾演练模型 [`simulate_multiregion_dr_failover()`](simulator/agent_infra_sizer.py) 与全链路验证追踪 [`demo/latest-demo-trace.json`](demo/latest-demo-trace.json) 驱动，解决生产级 AI Agent 平台在主区域（Primary Region）发生区级中断时，**如何同时保障“业务状态零丢失（Low RPO）”与“活跃沙箱 5 秒内热恢复（Warm RTO ≤ 5.0s）”** 的工程难题。

### 10.1 有状态 Agent 跨区容灾的四层协同挑战

与传统无状态微服务只需在 Azure Front Door 切换流量不同，有状态自主 Agent 在故障瞬间存在三类易失现场：
1. **正在执行的推理与工具调用上下文（LangGraph / MAF / Durable Checkpoint）**：若未及时持久化，切换至备区后将从第 0 步重新推理，导致外部 API 被重复调用；
2. **Firecracker MicroVM / Kata 沙箱内的内存页与本地未提交代码文件（`UFFD` Dirty Bitmap + `NBD` 差分块）**：全量 `2 GiB` 内存快照跨区同步带宽开销巨大，必须采用**增量脏页位图（Dirty-Bitmap Delta，均值 `~32 MiB`）+ RA-GZRS 异地只读块存储**；
3. **跨区域配额与限流状态（APIM Token Circuit Breaker）**：主区故障流量瞬间涌入备区时，必须防止备区 PTU 模型配额被单租户打穿。

### 10.2 跨区域双活与热备沙箱恢复四阶段架构设计

```mermaid
sequenceDiagram
    autonumber
    participant AFD as Azure Front Door + APIM Multi-Region Gateway
    participant HDB as Azure HorizonDB (Cross-Region Replica + PgBouncer :6432)
    participant Blob as Azure Blob Storage (RA-GZRS UFFD/NBD Snapshot Store)
    participant VMSS as Secondary VMSS Pool (Standard_D96as_v7 Warm Standby)

    Note over AFD,VMSS: 稳态运行：每 15s 增量归档 Firecracker 脏页位图 (~32 MiB) 至 RA-GZRS；HorizonDB 异步 WAL 流复制 (RPO ~25–48ms)
    AFD->>AFD: ① 探测 Primary Region 异常并触发多区域路由与配额切换 (1,731–1,803 ms)
    AFD->>HDB: ② 提升备区 HorizonDB 只读副本为主库 + PgBouncer 5ms 连接池重绑 (1,453–1,514 ms)
    VMSS->>Blob: ③ 从 RA-GZRS 拉取最近一次增量脏页位图与 NBD 快照清单 (87.6–122.8 ms)
    VMSS->>VMSS: ④ 25% 预热 D96as_v7 节点池并发恢复 2,500 个热执行沙箱 (3 批次 × 132ms = 396.0 ms)
    Note over AFD,VMSS: 总计端到端有状态故障切换 RTO = 3.67s ~ 3.84s (满足 ≤ 5.0s 交互式 SLO)；其余 75% 闲置会话按需惰性恢复
```

### 10.3 三大 Azure 跨区配对实测/仿真 RPO 与 RTO 分解对比（10,000 并发沙箱）

基于 `simulate_multiregion_dr_failover(active_sandboxes=10_000, dirty_memory_delta_mib=32.0, checkpoint_interval_sec=15)`，对比 **25% 预热备池（Warm Standby，`7` 台 `Standard_D96as_v7` 常驻热备承载 `2,500` 个活跃执行态沙箱首波恢复）** 与 **5% 冷备缩容池（Cold Pilot-Light，需临时触发 VMSS 节点扩容）** 的端到端 RTO 表现：

| Azure 跨区域配对 (Primary ↔ Secondary) | 跨区骨干网 RTT | 备区预热比例 (`D96as_v7` 节点) | HorizonDB WAL RPO | 沙箱增量快照 RPO | ① AFD+APIM 探测切换 | ② HorizonDB 副本提升+PgBouncer | ③ RA-GZRS 快照清单拉取 | ④ Firecracker 批次恢复 | 冷扩容惩罚 | **端到端总 RTO** | **≤ 5.0s 交互式 SLO** |
|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| **`East US 2 ↔ Central US` (25% 热备推荐)** | `18.0 ms` | **`25%` (`7 / 26` 台)** | **`25.2 ms`** | `15 s` | `1,731.0 ms` | `1,453.4 ms` | `87.6 ms` | `396.0 ms` | `0.0 ms` | **`3.67 s` (`3,668 ms`)** | **✅ 达标** |
| **`Sweden Central ↔ West Europe` (25% 热备)** | `24.0 ms` | **`25%` (`7 / 26` 台)** | **`33.6 ms`** | `15 s` | `1,758.0 ms` | `1,476.2 ms` | `100.8 ms` | `396.0 ms` | `0.0 ms` | **`3.73 s` (`3,731 ms`)** | **✅ 达标** |
| **`Southeast Asia ↔ East Asia` (25% 热备)** | `34.0 ms` | **`25%` (`7 / 26` 台)** | **`47.6 ms`** | `15 s` | `1,803.0 ms` | `1,514.2 ms` | `122.8 ms` | `396.0 ms` | `0.0 ms` | **`3.84 s` (`3,836 ms`)** | **✅ 达标** |
| `East US 2 ↔ Central US` (`5%` 冷备对比基线) | `18.0 ms` | `5%` (`2 / 26` 台) | `25.2 ms` | `15 s` | `1,731.0 ms` | `1,453.4 ms` | `87.6 ms` | `1,452.0 ms` | `+36,000.0 ms` | **`40.72 s` (`40,724 ms`)** | **❌ 超时 8.1 倍** |

> **容灾架构黄金法则**：在任何给定时刻，10,000 个在线沙箱中通常仅有约 **20%~25%（`~2,500` 个）正处于当前 Turn 的代码/工具执行态**，其余 75% 处于等待用户输入或 LLM 流式生成的空闲态。因此，备区只需维持 **25% 的 `Standard_D96as_v7` 预热 HugePages 节点池（7 台 VM）** 即可在 **`3.67 秒`** 内无损接管全部活跃执行态沙箱，而无需为备区支付 100% 的双倍计算成本。

---

## 11. Agentic FinOps 多租户成本归因与 Spot 抢占优雅排空护栏（Multi-Tenant FinOps Chargeback & Spot Preemption Checkpoint Drain）

> 本章由确定性 FinOps 仿真模型 [`simulate_finops_spot_eviction_drain()`](simulator/agent_infra_sizer.py) 与生产蓝图 [`blueprints/agent-finops-cost-anomaly-alert.bicep`](blueprints/agent-finops-cost-anomaly-alert.bicep) 驱动，解决大规模 AI Agent 舰队上生产后的两大核心成本治理命题：**① 如何安全利用 Azure Spot VMSS（最高 `72%` 折扣）而不丢失任何有状态沙箱会话？② 如何将 LLM Token 与沙箱算力秒级分摊到具体责任人与业务部门？**

### 11.1 Azure Spot VMSS `30s ScheduledEvents` 抢占通知下的优雅排空物理学

当承载 `391` 个并发 Firecracker 沙箱的 `Standard_D96as_v7` Spot 节点收到 Azure Metadata `ScheduledEvents`（`http://169.254.169.254/metadata/scheduledevents?api-version=2020-07-01`）下发的 **`30 秒 Preempt 抢占倒计时`** 时，为什么传统全量内存转储必败，而 **增量脏页位图（Dirty-Bitmap Delta）+ ZSTD 流式压缩** 能在 **`2.40 秒`** 内无损排空？

| 排空策略与集群配比 (100,000 并发沙箱 · 256 台 `D96as_v7`) | On-Demand 基座 / Spot 节点 / 缓冲池 | 单节点待排空载荷 (`391` 沙箱) | ① 快照刷盘耗时 (Azure Boost 32Gbps) | ② HorizonDB Checkpoint 屏障 | ③ 保底热池批次恢复 (`4 × 132ms`) | **单节点总排空耗时** | **30s 抢占窗口安全性** | **月度算力总成本 (`USD/mo`)** | **净算力节省率** |
|---|---|---|---|---:|---:|---:|---:|---:|---:|
| **`60% Spot + 40% On-Demand` (增量脏页 + ZSTD 推荐)** | `102` 按需 + `154` Spot + `7` 缓冲 | **`5,255.0 MiB` (`13.4 MiB/sbx`)** | `1,663.0 ms` | `210.0 ms` | `528.0 ms` | **`2.40 s`** | **✅ 安全 (`余量 27.6s`)** | **`$537,288 / mo`** | **`-40.6%`** |
| **`70% Spot + 30% On-Demand` (激进弹性挡)** | `77` 按需 + `179` Spot + `8` 缓冲 | **`5,255.0 MiB` (`13.4 MiB/sbx`)** | `1,663.0 ms` | `210.0 ms` | `528.0 ms` | **`2.40 s`** | **✅ 安全 (`余量 27.6s`)** | **`$477,244 / mo`** | **`-47.2%`** |
| `100% Pure On-Demand` (纯按需基线) | `256` 按需 + `0` Spot + `0` 缓冲 | — | — | — | — | `0.00 s` | ✅ 无抢占 | `$904,192 / mo` | `0.0%` |
| `60% Spot` 但**未开启增量脏页 (全量 `2 GiB` RAM 转储反模式)** | `102` 按需 + `154` Spot + `7` 缓冲 | `800,768.0 MiB` (`2,048 MiB/sbx`) | `347,935.6 ms` | `210.0 ms` | `528.0 ms` | **`348.67 s`** | **❌ 超时 11.6 倍 (会话丢失)** | `$537,288 / mo` | 不可用 |

### 11.2 基于 `Entra Agent ID + Sponsor OID` 的双重身份计费分摊（Dual-Attribution Chargeback）与异常熔断

在多租户企业平台（`AKSClaw` / `Foundry + ACA`）中，单次 Agent 任务的总成本由 **LLM Token 消耗（占 `~88%–91%`）** 与 **沙箱执行时长（占 `~9%–12%`）** 共同构成。我们在 [`blueprints/agent-finops-cost-anomaly-alert.bicep`](blueprints/agent-finops-cost-anomaly-alert.bicep) 中落地了三层 FinOps 护栏：

1. **双重身份归因标签（`entra.agent.azp` + `entra.sponsor.oid`）**：Unified AI Gateway (APIM) 在每次调用与沙箱分配时，强制从 JWT 提取 `AgentBlueprintId` 与人类责任人 `SponsorUserOid` 写入 OpenTelemetry `CustomDimensions`；
2. **APIM Prefix-Cache 会话亲和路由降本**：通过将同一 `x-session-id` 路由至相同后端模型副本，Prompt 缓存命中率可达 `65%~75%`，将每 1,000 次复杂 Agent 任务的端到端总成本（含 Token + 沙箱）从 **`$19.37`** 压降至 **`$8.91 ~ $10.40`（降幅最高达 `54.0%`）**；
3. **15 分钟滑动窗口 KQL 异常检测与自动熔断**：通过 `Microsoft.Insights/scheduledQueryRules` 每 5 分钟聚合各 `AgentBlueprintId` 的 `Tokens15m` 与 `SandboxHours15m`，一旦单实例 15 分钟消耗突破 `450,000 Tokens` 或 `$25`，立即触发 Action Group 回调 APIM 将该实例降级为只读或熔断。

---

## 12. 机密计算沙箱与硬件级零信任远程证明（Confidential Agent Sandboxes — AMD SEV-SNP / Kata-CC + MAA + Key Vault Managed HSM SKR）

> 本章由确定性机密计算仿真模型 [`simulate_confidential_sandbox_attestation()`](simulator/agent_infra_sizer.py) 与生产蓝图 [`blueprints/aksclaw-confidential-snp-nodepool.bicep`](blueprints/aksclaw-confidential-snp-nodepool.bicep) 驱动，面向金融核心交易、医疗隐私数据（PHI）及主权云强监管场景，解决 **“当 Agent 沙箱内正在处理高敏明文数据或解密专有模型权重时，如何从硬件层面防止宿主机 Root 管理员或云平台侧通过内存转储（Memory Dump）窃取数据”** 的零信任命题。

### 12.1 为什么常规 Kata Pod VM 仍不足以抵御宿主机内存窥探？

在常规 `Standard_D64s_v6` 上运行 `kata-vm-isolation` 可以阻止**容器向宿主机逃逸（Guest → Host Escape）**，但无法阻止**拥有宿主机 Root 权限的攻击者向容器内窥探（Host → Guest Inspection）**（例如通过 `/dev/mem` 或 Hypervisor 内存转储直接读取沙箱内的明文 Prompt、客户财报与私钥）。

在 **Azure Confidential VMs (`Standard_DC64as_v5` / `EC64as_v5` · AMD EPYC SEV-SNP)** 上启用 **`KataCcIsolation` (`kata-cc`)** 构建了完整的硬件可信执行环境（Hardware TEE）：

1. **AMD SEV-SNP 硬件内存加密与反向映射表（RMP）完整性保护**：每个 Kata-CC 沙箱 Pod VM 拥有由 AMD 安全处理器（PSP）生成的独立 AES-128 内存加密密钥，且通过硬件 RMP 表防止 Hypervisor 重放或篡改物理内存页；
2. **Microsoft Azure Attestation (MAA) + Key Vault Managed HSM 安全密钥释放（SKR）**：沙箱内的 `Attestation Agent (AA)` 与 `Confidential Data Hub (CDH)` 将 AMD PSP 签名的 SNP 硬件报告提交至 **MAA** 验证（确认 `x-ms-attestation-type == sevsnpvm` 且 `is-debuggable == false`），换取 MAA 签发的 JWT 后向 **Key Vault Managed HSM** 请求释放客户托管密钥（CMK），实现**“密钥仅在经硬件证明的 TEE 沙箱内存内解封”**；
3. **`dm-verity` + `dm-crypt` 根文件系统完整性校验**：防止宿主机篡改 Agent 容器镜像层或注入恶意二进制后门。

### 12.2 机密计算沙箱 (`Standard_DC64as_v5` Kata-CC) vs 常规沙箱 (`Standard_D64s_v6` Kata) 定量性能与密度对比

基于 `simulate_confidential_sandbox_attestation()`，对 64 vCPU / 256 GiB 规格下开启 AMD SEV-SNP 硬件内存加密、MAA+SKR 远程证明握手及 `dm-verity` 校验的开销分解如下：

| 宿主机 SKU 与隔离层级 | 远程证明与密钥释放模式 | 单 Pod VMM+TEE 开销 | 单节点可承载沙箱数 | ① 基础 Kata 热恢复 | ② SEV-SNP RMP 内存初始化 | ③ MAA+HSM SKR 密钥释放 | ④ `dm-verity` 挂载校验 | **端到端启动延迟** | **CPU 内存加密开销 / 块 I/O 开销** | **抵御宿主机 Root 内存转储** |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| **`Standard_DC64as_v5` (`kata-cc` SEV-SNP)** | **冷启动完整 MAA + HSM SKR 握手** | `+192 MiB` | **`106 个`** | `165.0 ms` | `+14.2 ms` | **`+18.5 ms`** | `+10.6 ms` | **`208.3 ms`** (✅ `≤220ms`) | `+5.8% CPU` / `+6.4% I/O` | **✅ 硬件级阻断** |
| **`Standard_DC64as_v5` (`kata-cc` SEV-SNP)** | **MAA 证明令牌缓存复用 (`cached_jwt`)** | `+192 MiB` | **`106 个`** | `165.0 ms` | `+14.2 ms` | **`+1.2 ms`** | `+10.6 ms` | **`191.0 ms`** (✅ `≤220ms`) | `+5.8% CPU` / `+6.4% I/O` | **✅ 硬件级阻断** |
| `Standard_D64s_v6` (`kata-vm` 常规隔离) | 无硬件 TEE 证明 (`none`) | `+144 MiB` | `109 个` | `165.0 ms` | `0.0 ms` | `0.0 ms` | `0.0 ms` | **`165.0 ms`** | `0.0%` / `0.0%` | ❌ 宿主机 Root 可读内存 |

> **机密沙箱选型结论**：在 `Standard_DC64as_v5` 上启用 AMD SEV-SNP `kata-cc` 仅使单节点沙箱密度从 `109` 微降至 **`106`（仅损失 `2.8%`）**，端到端热恢复延迟保持在 **`191.0 ms ~ 208.3 ms`**（严格满足 `≤ 220 ms` 交互式 SLO），即可为金融与医疗核心 Agent 提供硬件级内存加密与零信任密钥释放保障。

---

## 13. 多租户 Agent 沙箱零信任出向网络治理、SNAT 端口容量物理学与 MCP 供应链签名准入（Multi-Tenant Agent Sandbox Zero-Trust Egress Governance, SNAT Port Physics & MCP Supply-Chain Attestation）

> 本章由确定性仿真模型 [`simulate_egress_exfiltration_and_mcp_supply_chain()`](simulator/agent_infra_sizer.py) 与生产蓝图 [`blueprints/aksclaw-zero-trust-egress-firewall-pls.bicep`](blueprints/aksclaw-zero-trust-egress-firewall-pls.bicep) 驱动，解决大规模自主 Agent 在执行未知代码与加载第三方 MCP Server 时的三大生产网络与供应链隐患：**① Prompt 注入通过 DNS 隧道或隐蔽信道外带敏感数据；② 数万沙箱并发调用工具瞬间打满 Azure NAT Gateway 64,000 SNAT 端口导致连接静默丢包；③ 恶意或未签名 MCP 工具镜像在沙箱内提权或横向探测。**

### 13.1 零信任出向治理与 MCP 准入四层纵深防线

1. **Layer 1 · Cilium eBPF Socket-Level Filter + IMDS/WireServer 物理黑洞**：
   - 在宿主机内核 `cgroup/connect4` 挂载 Cilium eBPF 过滤器，直接阻断沙箱对 `169.254.169.254/32`（Azure IMDS）、`168.63.129.16/32`（Azure WireServer）及内网 RFC1918 东西向网段的套接字发起请求；
   - **性能优势**：eBPF O(1) 哈希查找仅需 **`0.06 ms`**（`< 0.08 ms`），相比传统 `iptables` 遍历 5,000 条线性规则链（**`1.90 ms`**）降低 **96.8%** 的策略损耗。
2. **Layer 2 · CoreDNS 香农熵过滤 + Azure Firewall Premium TLS/IDPS 深度检测**：
   - 拦截通过 `nslookup <base32-secret>.attacker.com` 发起的 DNS 隧道数据外带：在 CoreDNS / Firewall DNS Proxy 层对查询标签执行实时香农熵检测（拦截 `Shannon entropy > 4.1 bits/char` 或单级子域名长度 `> 52 chars`），实现 **`99.94%`** 的 DNS 隧道外带阻断率；
   - 出网 HTTPS 流量强制经 **Azure Firewall Premium** 执行 TLS 解密检查、IDPS 签名阻断与 FQDN 白名单过滤（仅放行受控镜像源如 `*.pypi.org`、`registry.npmjs.org`），仅引入 **`+2.40 ms` p95** 检测耗时。
3. **Layer 3 · Azure Private Link 全私网数据面卸载 vs 公网 NAT Gateway SNAT 端口耗尽物理学**：
   - Azure NAT Gateway 每个公网 IP 提供 **`64,000` 个 SNAT 临时端口**（单网关最高挂载 `16` 个公网 IP = `1,024,000` 端口）。若 `25,000` 个并发沙箱直接通过公网访问模型、存储与数据库（平均每沙箱 `6` 条并发连接 = `150,000` 个 SNAT 端口），仅配置 `2` 个公网 IP（`128,000` 端口）将导致 **`117.2%` 端口过载与大规模 `SYN` 丢包**；
   - 通过将 Foundry Models、Azure Blob Storage、Key Vault 与 HorizonDB 全部切换至 **Azure Private Link (Private Endpoints)**，可直接在私网卸载 **`78%` 的出向连接**（公网 SNAT 占用从 `150,000` 骤降至 **`33,000`**），同时消除公网 Hairpin 绕行，使端到端工具调用 P95 RTT **净降低 `-1.34 ms`（Private Link `-3.80 ms` 抵消防火墙 `+2.46 ms` 后仍快于公网直连）**。
4. **Layer 4 · MCP 工具镜像 Notation/Cosign (SLSA Level 3) 签名校验与能力清单准入**：
   - 沙箱动态拉起外部 MCP Server 时，强制校验 OCI 制品的 **Notation / Sigstore Cosign 签名与 SLSA Level 3 构建溯源证明**，并解析最小权限能力清单（如 `fs:read-only`、`net:none`、`secret:none`），本地缓存命中校验仅需 **`4.60 ms`**（冷校验 `21.00 ms`），100% 阻断未签名或超权 MCP 插件。

### 13.2 四层零信任出向治理与 SNAT 容量定量对比矩阵

| 架构方案与并发沙箱规模 | L1 策略引擎耗时 | DNS 隧道外带拦截率 | 原始出向连接数 | Private Link 私网卸载率 | 公网 SNAT 活跃端口数 | NAT Gateway 公网 IP 数 (总容量) | **SNAT 端口利用率 (安全线 ≤80%)** | **净出向 P95 RTT 变化** | **L4 MCP 签名准入耗时** |
|---|---:|---:|---:|---:|---:|---|---:|---:|---:|
| **`25,000` 沙箱 · Cilium eBPF + FW Premium + Private Link (推荐)** | **`0.06 ms`** | **`99.94%`** | `150,000` | **`78.0%`** | **`33,000`** | `8 IPs` (`/29` · `512,000` 端口) | **`6.4%` (✅ 极安全)** | **`-1.34 ms` (更快)** | **`4.60 ms` (`cached`)** |
| **`100,000` 沙箱 · Cilium eBPF + FW Premium + Private Link (超大规模)** | **`0.06 ms`** | **`99.94%`** | `600,000` | **`78.0%`** | **`132,000`** | `8 IPs` (`/29` · `512,000` 端口) | **`25.8%` (✅ 安全)** | **`-1.34 ms` (更快)** | **`4.60 ms` (`cached`)** |
| `25,000` 沙箱 · 传统 `iptables` + 纯公网 NAT (无 Private Link 反模式) | `1.90 ms` | `0.00%` (无拦截) | `150,000` | `0.0%` | `150,000` | `2 IPs` (`128,000` 端口) | **`117.2%` (❌ SNAT 耗尽丢包)** | `+1.90 ms` | `0.00 ms` (❌ 无校验) |

---

## 14. GPU/CPU 异构 Agent 沙箱编排、NVIDIA MIG vs CUDA MPS 切分物理模型与 KAITO/vLLM 前缀缓存推理边车测算（Heterogeneous GPU/CPU Agent Orchestration — NVIDIA MIG vs CUDA MPS & KAITO Prefix-Cache Sizing）

> 本章由确定性异构算力仿真模型 [`simulate_gpu_heterogeneous_sandbox_mps_mig()`](simulator/agent_infra_sizer.py) 与生产蓝图 [`blueprints/aksclaw-gpu-mig-kaito-nodepool.bicep`](blueprints/aksclaw-gpu-mig-kaito-nodepool.bicep) 驱动，面向 Computer-Use 视觉接地（GUI Grounding，如 `OmniParser-v2` / `Florence-2`）、本地多模态重排（Reranker）与小参数推理边车（SLM Sidecar）场景，解决 **“如何避免为成千上万个大部分时间处于等待态的 CPU 沙箱盲目绑定整块 H100/H200 GPU，并在多租户硬件隔离（MIG）与单租户极致吞吐（CUDA MPS）之间精准选型”** 的架构问题。

### 14.1 三种 GPU 切分与异构沙箱协同拓扑物理机制对比

1. **NVIDIA 硬件级多实例 GPU (`MIG 1g.10gb` on `Standard_NC40ads_H100_v5` / `1g.18gb` on `Standard_ND96isr_H200_v5`)**：
   - 将单块 H100（94 GB HBM3）或 H200（141 GB HBM3e）从硬件显存控制器、L2 Cache、数据交叉开关（Crossbar）到流式多处理器（SM）物理切分为 **7 个完全独立的硬件实例**；
   - **核心收益**：跨租户噪声邻居抖动（Noisy-Neighbor Jitter）为 **`0.0%`**，单个切片发生 CUDA Out-of-Memory 或 Xid 硬件异常不会波及同卡其余 6 个实例，是多租户非信任视觉接地与推理边车的唯一硬件级隔离选型。
2. **CUDA MPS (`Multi-Process Service` + 活动线程配额上限)**：
   - 多个进程共享同一 GPU 上下文并动态复用空闲 SM，在 32 并发视觉接地 Agent 压力下相比默认时间片轮转（Time-Slicing，`p95 = 54.6 ms`）提升 **`+28.4%` 吞吐量**，并将接地延迟压缩至 **`p95 = 38.2 ms`（H100） / `34.0 ms`（H200）**；
   - **风险边界**：共享显存地址空间与故障域（跨进程抖动约 `8.5%`），仅适用于单租户受信任的高吞吐推理池。
3. **存算分离 CPU 沙箱池 (`Standard_D64s_v6` / `D96as_v7`) + KAITO/vLLM 前缀缓存（Prefix-Cache Aware）H100 推理池 (`Standard_NC80adis_H100_v5`)**：
   - Computer-Use Agent 的每一步 GUI 截屏推理都携带高度重复的 **System Prompt + 50+ MCP 工具 Schema 定义（通常占上下文的前 `70%–80%`）**；
   - 通过 AKS **KAITO (Kubernetes AI Toolchain Operator)** 部署开启 `--enable-prefix-caching` 的 vLLM 推理服务，配合网关层会话亲和路由实现 **`78%` 的 KV Cache 前缀命中率**，可将首字延迟（TTFT）从 **`185.0 ms` 骤降至 `42.0 ms`（提速 `-77.3%`）**，并将每 10,000 条完整 Computer-Use 任务轨迹（每条含 15 步 GUI 视觉推理 + 沙箱执行）的 GPU+CPU 综合成本从 **`$160.50` 降至 `$91.77`（节省 `-42.8%`）**。

### 14.2 H100 / H200 异构切分模式与 KAITO 前缀缓存定量对比表

| Azure GPU 节点机型 | 切分与共享模式 | 单节点 GPU 数 × 单卡切片数 | 硬件故障域隔离 | 跨租户尾延迟抖动 | GUI 视觉接地 `P95` | 相比时间片吞吐增益 | KAITO 前缀缓存命中率 | **首字延迟 `TTFT` (基线 `185ms`)** | **每 10,000 条 CUA 轨迹综合成本** |
|---|---|---|---:|---:|---:|---:|---:|---:|---:|
| **`Standard_NC40ads_H100_v5` (多租户推荐)** | **`MIG 1g.10gb` (硬件切分)** | `1 × 7 = 7 实例` (`94GB HBM3`) | **✅ 硬件级隔离** | **`0.0%`** | **`41.5 ms`** | `+18.2%` | **`78.0%`** | **`42.0 ms` (`-77.3%`)** | **`$91.77 / 10K`** |
| **`Standard_NC80adis_H100_v5` (单租户极速)** | **`CUDA MPS` (共享 SM)** | `2 × 8 = 16 切片` (`2×94GB`) | ❌ 共享故障域 | `8.5%` | **`38.2 ms` 🏆** | **`+28.4%`** | **`78.0%`** | **`42.0 ms` (`-77.3%`)** | **`$91.77 / 10K`** |
| **`Standard_ND96isr_H200_v5` (旗舰高密池)** | **`MIG 1g.18gb` (硬件切分)** | `8 × 7 = 56 实例` (`8×141GB`) | **✅ 硬件级隔离** | **`0.0%`** | **`36.8 ms`** | `+18.2%` | **`78.0%`** | **`42.0 ms` (`-77.3%`)** | **`$91.77 / 10K`** |
| `Standard_NC40ads_H100_v5` (未优化基线) | 默认 `Time-Slicing` + 无前缀缓存 | `1 × 8 = 8 切片` | ❌ 共享故障域 | `31.0%` | `54.6 ms` | `0.0%` | `0.0%` | `185.0 ms` | `$160.50 / 10K` |

---

## 15. 十万级 Agent 沙箱全链路可观测性、OpenTelemetry GenAI 语义规范 (`gen_ai.*`)、Tetragon eBPF 系统调用审计与尾部采样成本物理模型（End-to-End Agentic Observability — OpenTelemetry GenAI Traces, Tetragon eBPF Syscall Auditing & ADX Tail-Sampling Physics）

> 本章由确定性可观测性流水线仿真器 [`simulate_otel_ebpf_observability_pipeline()`](simulator/agent_infra_sizer.py) 与生产级 Bicep 蓝图 [`blueprints/aksclaw-otel-adx-tetragon-observability.bicep`](blueprints/aksclaw-otel-adx-tetragon-observability.bicep) 驱动，面向 `1,000` -> `25,000` -> `100,000` 并发沙箱的金融级审计与 SRE 排障诉求，解决 **“当 10 万个并发 Agent 沙箱每秒产生 `4.85 GB/s`（`419.0 TB/天`）原始推理 Trace 与内核系统调用日志时，如何兼顾 `< 1.2%` 宿主机 CPU 开销、`100%` 异常/越权事件零漏报以及 `-88.4%` 存储成本削减”** 的工程挑战。

### 15.1 三层混合尾部采样架构（3-Tier Hybrid Observability Pipeline）

1. **Layer 1：Tetragon eBPF 内核态 Ring-Buffer 过滤（In-Kernel Syscall Filtering）**：
   - 摒弃高开销的用户态 `auditd` 或全量 `strace`（消耗 `6.40%` 宿主机 CPU），在内核 `tracepoint/kprobe` 层直接过滤并仅向用户态 Ring-Buffer 投递高危事件（沙箱内 `execve` 提权执行、`ptrace` 注入、非白名单 IP `connect`、敏感凭证路径 `openat`）；
   - **物理指标**：宿主机 eBPF 审计 CPU 开销稳定在 **`0.95%`（严格满足 `< 1.2%` 生产 SLO）**。
2. **Layer 2：OpenTelemetry Collector `gen_ai.*` 语义规范与尾部采样处理器（Tail-Sampling Processor）**：
   - 统一注入 OpenTelemetry GenAI 标准属性（`gen_ai.system`、`gen_ai.request.model`、`gen_ai.usage.input_tokens`、`mcp.tool.name`、`entra.agent.id`、`sandbox.id`）；
   - 在 OTel Collector 网关层执行 **Tail-Based Sampling**：对健康且无越权的常规轨迹执行 **`5%` 基准采样**，对包含工具报错、HTTP `4xx/5xx`、慢调用（`> 2s`）或关联到 Tetragon eBPF 安全告警的轨迹执行 **`100%` 全量保留**。
3. **Layer 3：Managed Prometheus 指标汇聚 + Azure Data Explorer (Kusto) 流式摄取（ZSTD `8.4x` 列式压缩）**：
   - 将高基数 Trace 与 eBPF 安全事件流式写入 **Azure Data Explorer (ADX/Kusto)**，结合尾部采样与 ZSTD `8.4x` 列式压缩，把 10 万沙箱日均落盘数据量从 **`419.00 TB/天` 压缩至 `35.20 TB/天`（削减 `-91.6%`）**；
   - **成本与时效收益**：每 1,000 次 Agent 任务的可观测性成本从全量无采样写入标准日志工作区的 **`$3.62` 降至 `$0.42`（节省 `-88.4%`）**，同时安全越权事件端到端告警延迟达到 **`p95 = 1.8 s`**（相比传统批处理日志管道 `14.5 s` 提速 `8.1x`）。

### 15.2 `1K` -> `25K` -> `100K` 并发沙箱可观测性吞吐、CPU 开销与成本对比表

| 并发沙箱规模与采集架构 | 单沙箱原始速率 | 集群原始摄取带宽 | 原始日产生量 | **落盘日存储量 (削减率)** | 宿主机 eBPF CPU 开销 | 常规轨迹采样率 | **异常/安全事件保留率** | ADX 列式压缩比 | 安全告警 `P95` | **每千次 Agent 任务观测成本** |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **`1,000` 沙箱 · 三层混合尾部采样 + ADX** | `48.5 KB/s` | `0.0485 GB/s` | `4.19 TB/天` | **`0.35 TB/天` (`-91.6%`)** | **`0.95%` (✅ `<1.2%`)** | `5.0%` | **`100.0%`** | `8.4x` | **`1.8 s`** | **`$0.42 / 1K` (`-88.4%`)** |
| **`25,000` 沙箱 · 三层混合尾部采样 + ADX** | `48.5 KB/s` | `1.2125 GB/s` | `104.75 TB/天` | **`8.80 TB/天` (`-91.6%`)** | **`0.95%` (✅ `<1.2%`)** | `5.0%` | **`100.0%`** | `8.4x` | **`1.8 s`** | **`$0.42 / 1K` (`-88.4%`)** |
| **`100,000` 沙箱 · 三层混合尾部采样 + ADX (推荐)** | `48.5 KB/s` | **`4.8500 GB/s`** | **`419.00 TB/天`** | **`35.20 TB/天` (`-91.6%`)** | **`0.95%` (✅ `<1.2%`)** | `5.0%` | **`100.0%`** | `8.4x` | **`1.8 s`** | **`$0.42 / 1K` (`-88.4%`)** |
| `100,000` 沙箱 · 100% 全量无采样直写标准日志 (反模式) | `48.5 KB/s` | `4.8500 GB/s` | `419.00 TB/天` | `419.00 TB/天` (`0.0%`) | `6.40%` (❌ 超标) | `100.0%` | `100.0%` | `1.0x` | `14.5 s` | `$3.62 / 1K` (基准) |

---

## 16. 长周期有状态 Agent 工作流编排、休眠唤醒省钱物理模型、Transactional Outbox Saga 幂等补偿与僵尸沙箱自动回收（Long-Horizon Stateful Agent Workflows — Suspend-on-Wait Hibernation, Outbox Saga & Zombie-Sandbox Garbage Collection）

> 本章由确定性长周期工作流仿真器 [`simulate_durable_agent_workflow_saga_gc()`](simulator/agent_infra_sizer.py) 与生产蓝图 [`blueprints/aksclaw-dapr-workflow-keda-scaler.bicep`](blueprints/aksclaw-dapr-workflow-keda-scaler.bicep) 驱动，面向跨数十分钟至数小时的企业级异步 Agent 任务（CI/CD 构建自愈、跨系统采购审批、深度代码重构，单任务 `10–250` 步），解决 **“长等待期间沙箱内存常驻造成 `94.2%` 算力空转、节点故障重放导致外部 API 重复扣款/发单（`4.8%` 脏写率）以及断连孤儿沙箱泄漏 `18.0%` 集群内存”** 三大顽疾。

### 16.1 长周期 Agent 工作流的三大基础设施物理机制

1. **`> 10s` 异步等待自动快照休眠与极速唤醒（Suspend-on-Wait Hibernation + Snapshot Rehydration）**：
   - 在平均包含 `15 min` 外部等待（Webhook 回调、CI 流水线或人工审批）的 40 步工作流中，若让沙箱常驻内存等待（Pinned In-Memory Wait），**`94.2%` 的 vCPU/RAM 秒级算力处于空转等待态**（5,000 并发长工作流日成本高达 **`$1,420.00/天`**）；
   - 当 Dapr Workflow / Durable Functions 检测到外部等待 `> 10s` 时，立即将 Firecracker / ACA Sandbox 增量脏页刷入 Azure Blob ZRS 并释放计算槽位；当 Azure Service Bus Premium 唤醒事件到达时，通过 UFFD 按需页回填在 **`188.0 ms`** 内恢复沙箱执行上下文，将沙箱内存驻留时长削减 **`89.7%`**，日成本从 **`$1,420.00` 骤降至 `$146.20`（节省 `-89.7%`）**。
2. **Transactional Outbox + Saga 逆向补偿状态机（HorizonDB 幂等键账本）**：
   - 严禁 Agent 在沙箱内直接裸调具有外部资金/工单副作用的写接口；所有写操作必须先在 **Azure HorizonDB** 同一 ACID 事务内写入 `OutboxIdempotencyLedger (workflow_id, step_seq, idempotency_key)` 并投递至 Service Bus 会话队列（开启 `requiresDuplicateDetection: true`）；
   - 当后续步骤失败或超时触发重试/回滚时，自动按逆序执行 Saga 补偿队列（`agent-saga-compensation-dlq`），将节点崩溃重放导致的外部重复副作用率从无保护重试的 **`4.8%` 降至 `0.0%`（严格 `Exactly-Once`）**。
3. **三层僵尸沙箱租约回收器（3-Tier Zombie Sandbox Lease Reaper）**：
   - 结合 **Control-Plane TTL 租约心跳 + KEDA 队列深度缩放 + 内核态 eBPF Cgroup OOM/Fork-Bomb 进程树收割器**，在客户端异常断连或死循环发生后 **`4.5 s`** 内强制回收孤儿微虚拟机与残留 Network Namespace，彻底消除未托管集群中常见的 **`18.0%` 僵尸 VM 内存泄漏**。

### 16.2 长周期工作流常驻等待 vs 休眠唤醒 + Outbox Saga 定量对比表

| 并发长工作流规模与执行策略 | 平均外部等待时长 | 常驻等待算力空转率 | 常驻内存日成本 | **休眠唤醒日成本 (节省率)** | 内存驻留时长削减 | 事件唤醒延迟 `P95` | 外部重复副作用率 | **僵尸沙箱回收耗时 / 内存泄漏** |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| **`5,000` 并发 · 10s 休眠唤醒 + Outbox Saga + 三层回收 (推荐)** | `15.0 min` (40 步) | `94.2%` | `$1,420.00/天` | **`$146.20/天` (`-89.7%`)** | **`-89.7%`** | **`188.0 ms`** | **`0.0%` (✅ 幂等)** | **`4.5 s` / `0.0%` 泄漏** |
| **`25,000` 并发 · 10s 休眠唤醒 + Outbox Saga + 三层回收** | `30.0 min` (120 步) | `97.0%` | `$14,200.00/天` | **`$1,462.00/天` (`-89.7%`)** | **`-89.7%`** | **`188.0 ms`** | **`0.0%` (✅ 幂等)** | **`4.5 s` / `0.0%` 泄漏** |
| `5,000` 并发 · 内存常驻等待 + 无 Outbox 裸重试 (传统反模式) | `15.0 min` (40 步) | `94.2%` (浪费) | `$1,420.00/天` | `$1,420.00/天` (`0.0%`) | `0.0%` | `0.0 ms` (常驻占坑) | `4.8%` (❌ 脏写) | `3,600.0 s` / **`18.0%` 内存泄漏** |

---

## 17. 7-Card 4:5 架构评测结论摘要与可复现验证命令

本 Playbook 严格遵循 `turbo998/benchmark-harness-engineering` 的 **7-Card 4:5 视觉评测报告规范**，配套提供可离线运行并复现全部容量测算、选型矩阵与 SVG 图表的 Python 工具链：

- 📄 **7 页 4:5 视觉评测报告**：[Markdown 完整版 (`test-report.md`)](test-report.md) · [CSP 锁定自包含 HTML 卡片版 (`test-report-cards.html`)](test-report-cards.html)
- 🗂️ **证据台账与审校记录**：[`evidence.json`](evidence.json) · [`review.md`](review.md) · [`evidence/deep-benchmark-models.json`](evidence/deep-benchmark-models.json)

### 本地一键复现与校验命令

```bash
# 1. 运行确定性架构选型器与 10万并发 E2B 集群容量测算校验
python simulator/agent_infra_sizer.py --check

# 2. 运行深度定量模型（Firecracker 缺页分解 + AKSClaw Kata 密度 + HorizonDB 留存 + 跨区 DR + FinOps Spot 排空 + SEV-SNP 机密沙箱 + 零信任出网/MCP 准入 + GPU MIG/MPS/KAITO + OTel/eBPF/ADX + 长周期休眠/Saga/GC）
python simulator/e2b_aksclaw_deep_benchmark.py

# 3. 运行全部 20 项单元测试（验证 6 大运行时契约、v6/v7 延迟基准、跨区 DR、FinOps Spot 排空、SEV-SNP 机密沙箱、零信任出网 SNAT/MCP 准入、GPU MIG/MPS/KAITO、OTel/eBPF/ADX、长周期休眠/Saga/GC 与链接完整性）
python simulator/test_agent_infra_sizer.py -v

# 4. 重新生成并校验全部 8 张 SVG 架构图、H5 交互套件与 7-Card 评测报告
python simulator/generate_visual_assets.py
python simulator/generate_h5_suite.py
```
