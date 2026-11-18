# Azure AI Agent Infrastructure Playbook — 企业级 AI 智能体基础设施选型与容量手册

> 🌐 **Language / 语言切换**: **🇨🇳 中文 (`README.md`)** | **[🇬🇧 English (`README.en.md`)](README.en.md)**

面向 **Azure AI Solution Architect (SA)** 的云原生智能体运行底座选型、隔离边界评估与 10 万级并发沙箱容量规划工作台。聚焦真实企业生产负载（AKS Kata VM 隔离、Firecracker/E2B 微虚机、Azure Container Apps Dynamic Sessions、Azure Functions Flex、APIM AI Gateway、MCP/A2A 协议治理与多区域容灾）。

---

## 一、核心交互资产（Interactive Workbenches）

| 资产名称 | SA 适用场景与核心能力 | 入口链接 |
| :--- | :--- | :--- |
| **全景架构工作台** | 6 类 Azure 运行时架构选型总览、控制平面与数据平面边界解析 | [`index.html`](index.html) |
| **AKSClaw × E2B 实时仿真台** | Firecracker 快照恢复耗时拆解、Kata VM 节点密度与 HorizonDB 连接池压测 | [`demo.html`](demo.html) |
| **架构决策树与容量测算器 (Tools 1–34)** | 34 项云原生 Agent 基础设施交互测算器（并发沙箱、KV Cache 路由、零信任出站、Spot 优雅排空、FinOps 成本护栏） | [`selector.html`](selector.html) |
| **7-Card 4:5 基准测试卡组** | 遵循标准 7 卡视觉规范的运行时延迟、策略鲁棒性与扩展性评测报告 | [`cards.html`](cards.html) · [`benchmark-cards.html`](benchmark-cards.html) |

---

## 二、深度架构选型指南（SA Selection FAQs & Reports）

- **运行时安全隔离选型 FAQ**：[ACA Dynamic Sessions vs Firecracker 微虚机隔离边界选型指南（中文）](aca-vs-firecracker-runtime-isolation-selection-faq.md) · [English](aca-vs-firecracker-runtime-isolation-selection-faq.en.md)
- **多智能体协议幂等治理 FAQ**：[Agent MCP × A2A 跨服务调用幂等键与状态恢复指南（中文）](agent-mcp-a2a-idempotency-key-selection-faq.md) · [English](agent-mcp-a2a-idempotency-key-selection-faq.en.md)
- **基准评测报告**：[技术评测报告（中文）](test-report.md) · [Technical Benchmark Report (EN)](test-report.en.md)
- **Bicep 参考部署蓝图**：[`blueprints/`](blueprints/)（34 套生产级 Azure Bicep IaC 模板，涵盖 AKS Kata、ACA Dynamic Sessions、APIM AI Gateway、Entra Agent ID、Confidential Containers 等）

---

## 三、本地复现与自动化验证（Verification）

```bash
python workshops/azure-agent-infra/simulator/agent_infra_sizer.py --check
python workshops/azure-agent-infra/demo/run_live_demo.py --self-test
python -m unittest discover -s workshops/azure-agent-infra/simulator -p "test_*.py"
```
