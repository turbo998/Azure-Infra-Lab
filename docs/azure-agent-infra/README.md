# Azure AI Agent Infrastructure Playbook（精简版）

> 🌐 **Language / 语言切换**: **🇨🇳 中文 (`README.md`)** | **[🇬🇧 English (`README.en.md`)](README.en.md)**  
> 🔎 **Cycle #974 重点资产**: [benchmark-cards.html](benchmark-cards.html) · [benchmark-cards.en.html](benchmark-cards.en.html) · [workbench-cycle-974.html](workbench-cycle-974.html) · [daily-report-2026-11-12.md](daily-report-2026-11-12.md)

---

## 一、Cycle #974 发布摘要（2026-11-12）

- **主题**：云原生 Agent Infra（Runtime/Sandbox、AI Gateway、MCP/A2A 编排与可观测）
- **当日证据口径**：2026 官方文档 / changelog / release notes 优先
- **标签体系**：`measured` / `synthetic` / `anonymized_reported`
- **核心交付**：
  1. 双语 7-card 4:5 卡组（CSP self-contained）
  2. 交互式工作台（浏览器可直接运行）
  3. 可复现实验证据（JSON/CSV）
  4. 日报双语与专著增补

---

## 二、核心入口（保留导航）

| 资产 | 说明 | 链接 |
|---|---|---|
| 全景工作台 | Playbook 导览入口 | [`index.html`](index.html) |
| 双轨仿真 Demo | AKSClaw × E2B | [`demo.html`](demo.html) |
| 选型与容量测算 | 决策树 + 10 万沙箱估算 | [`selector.html`](selector.html) |
| 历史 7-card 卡组 | 既有可视化入口 | [`cards.html`](cards.html) |
| **Cycle #974 卡组（中文）** | 新规范 7-card | [`benchmark-cards.html`](benchmark-cards.html) |
| **Cycle #974 卡组（英文）** | 新规范 7-card | [`benchmark-cards.en.html`](benchmark-cards.en.html) |
| **Cycle #974 工作台** | 新增交互实验台 | [`workbench-cycle-974.html`](workbench-cycle-974.html) |

---

## 三、可复现实验与证据

- 基准主文件：[`evidence/cycle-974-benchmark.json`](evidence/cycle-974-benchmark.json)
- 来源台账：[`evidence/cycle-974-sources.json`](evidence/cycle-974-sources.json)
- 指标 CSV：
  - [`cycle-974-latency.csv`](evidence/cycle-974-latency.csv)
  - [`cycle-974-throughput.csv`](evidence/cycle-974-throughput.csv)
  - [`cycle-974-policy.csv`](evidence/cycle-974-policy.csv)
  - [`cycle-974-cost.csv`](evidence/cycle-974-cost.csv)

---

## 四、文档与图形交付

- 日报（中文）：[`daily-report-2026-11-12.md`](daily-report-2026-11-12.md)
- 日报（英文）：[`daily-report-2026-11-12.en.md`](daily-report-2026-11-12.en.md)
- 一图流 SVG：[`assets/34-cycle-974-daily-breakthroughs.svg`](assets/34-cycle-974-daily-breakthroughs.svg)
- 专著增补（中文）：[`docs/full-monograph-cycle-974.md`](docs/full-monograph-cycle-974.md)
- 专著增补（英文）：[`docs/full-monograph-cycle-974.en.md`](docs/full-monograph-cycle-974.en.md)
- 选型 FAQ（中文）：[`agent-aca-session-pool-coldstart-burst-auto-cycle-974-selection-faq.md`](agent-aca-session-pool-coldstart-burst-auto-cycle-974-selection-faq.md)
- 选型 FAQ（英文）：[`agent-aca-session-pool-coldstart-burst-auto-cycle-974-selection-faq.en.md`](agent-aca-session-pool-coldstart-burst-auto-cycle-974-selection-faq.en.md)
- 完整历史专著（中文）：[`docs/full-monograph-archive.md`](docs/full-monograph-archive.md)
- 完整历史专著（英文）：[`docs/full-monograph-archive.en.md`](docs/full-monograph-archive.en.md)

---

## 五、验证命令（发布门禁）

```bash
python workshops/azure-agent-infra/simulator/cycle_974_pipeline.py --write
python workshops/azure-agent-infra/simulator/cycle_974_pipeline.py --check
python workshops/azure-agent-infra/simulator/agent_infra_sizer.py --check
python -m unittest workshops/azure-agent-infra/simulator/test_agent_infra_sizer.py
```

---

## 六、实现与运行脚本

- 生成管线：[`simulator/cycle_974_pipeline.py`](simulator/cycle_974_pipeline.py)
- 运行时测算器：[`simulator/agent_infra_sizer.py`](simulator/agent_infra_sizer.py)
- 测试集：[`simulator/test_agent_infra_sizer.py`](simulator/test_agent_infra_sizer.py)
- 现场执行手册：[`workshop-runbook.md`](workshop-runbook.md)


















