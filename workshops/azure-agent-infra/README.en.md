# Azure AI Agent Infrastructure Playbook — Enterprise Runtime Selection & Capacity Sizing

> 🌐 **Language / 语言切换**: **[🇨🇳 中文 (`README.md`)](README.md)** | **🇬🇧 English (`README.en.md`)**

An **Azure AI Solution Architect (SA)** reference suite for evaluating cloud-native agent execution runtimes, hardware isolation boundaries, and 100K-sandbox fleet sizing across **AKS Kata Confidential/VM Pods**, **E2B Firecracker MicroVMs**, **Azure Container Apps Dynamic Sessions**, **Azure Functions Flex**, **APIM AI Gateway**, and **MCP/A2A** orchestration.

---

## 1. Interactive SA Workbenches

| Asset | SA Use Case & Capability | Link |
| :--- | :--- | :--- |
| **Executive Architecture Hub** | End-to-end comparison of 6 Azure agent runtime patterns and security boundaries | [`index.html`](index.html) |
| **AKSClaw × E2B Dual-Track Live Sim** | Firecracker snapshot resume breakdown, Kata VM node density, and HorizonDB PgBouncer SLOs | [`demo.html`](demo.html) |
| **Decision Tree & Fleet Sizer (Tools 1–34)** | 34 cloud-native agent infrastructure calculators (fleet TCO, KV-cache affinity, zero-trust egress, Spot drain, FinOps guardrails) | [`selector.html`](selector.html) |
| **7-Card 4:5 Visual Benchmark Deck** | Self-contained 7-card evaluation deck covering routing accuracy, perturbation robustness, and tail latency | [`cards.html`](cards.html) · [`benchmark-cards.en.html`](benchmark-cards.en.html) |

---

## 2. Architecture Selection FAQs & Reference Blueprints

- **Runtime Isolation Selection FAQ**: [ACA Dynamic Sessions vs Firecracker MicroVM Isolation Guide (EN)](aca-vs-firecracker-runtime-isolation-selection-faq.en.md) · [中文](aca-vs-firecracker-runtime-isolation-selection-faq.md)
- **MCP / A2A Idempotency Selection FAQ**: [Agent MCP & A2A Idempotency Key Architecture Guide (EN)](agent-mcp-a2a-idempotency-key-selection-faq.en.md) · [中文](agent-mcp-a2a-idempotency-key-selection-faq.md)
- **Benchmark Reports**: [Technical Benchmark Report (EN)](test-report.en.md) · [中文评测报告](test-report.md)
- **Production Bicep IaC Blueprints**: [`blueprints/`](blueprints/) (34 Azure Bicep templates for AKS Kata, ACA Dynamic Sessions, APIM AI Gateway, Entra Agent ID, Confidential SNP, and multi-region DR)

---

## 3. Verification Commands

```bash
python workshops/azure-agent-infra/simulator/agent_infra_sizer.py --check
python workshops/azure-agent-infra/demo/run_live_demo.py --self-test
python -m unittest discover -s workshops/azure-agent-infra/simulator -p "test_*.py"
```
