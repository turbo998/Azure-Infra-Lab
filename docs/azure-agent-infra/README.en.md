# Azure AI Agent Infrastructure Playbook (Compact)

> 🌐 **Language Switch**: **[🇨🇳 Chinese (`README.md`)](README.md)** | **🇬🇧 English (`README.en.md`)**  
> 🔎 **Cycle #1052 highlights**: [benchmark-cards.en.html](benchmark-cards.en.html) · [benchmark-cards.html](benchmark-cards.html) · [workbench-cycle-1052.html](workbench-cycle-1052.html) · [daily-report-2026-11-12.en.md](daily-report-2026-11-12.en.md)

---

## 1) Cycle #1052 release summary (2026-11-12)

- **Scope**: Cloud-native Agent Infra (Runtime/Sandbox, AI Gateway, MCP/A2A orchestration and observability)
- **Evidence policy**: 2026 official docs/changelogs/releases first
- **Trace labels**: `measured` / `synthetic` / `anonymized_reported`
- **Deliverables**:
  1. Bilingual 7-card 4:5 visual decks (CSP self-contained)
  2. Browser-runnable benchmark workbench
  3. Reproducible benchmark evidence bundle (JSON/CSV)
  4. Bilingual daily reports and monograph addendum

---

## 2) Core navigation (existing entries preserved)

| Asset | Purpose | Link |
|---|---|---|
| Playbook hub | Architecture and workflow entry | [`index.html`](index.html) |
| Dual-track demo | AKSClaw × E2B simulation | [`demo.html`](demo.html) |
| Decision + sizing | Runtime/storage selection and capacity | [`selector.html`](selector.html) |
| Historical 7-card deck | Existing visual report entry | [`cards.html`](cards.html) |
| **Cycle #1052 deck (EN)** | New archetype-aligned deck | [`benchmark-cards.en.html`](benchmark-cards.en.html) |
| **Cycle #1052 deck (ZH)** | New archetype-aligned deck | [`benchmark-cards.html`](benchmark-cards.html) |
| **Cycle #1052 workbench** | Interactive benchmark surface | [`workbench-cycle-1052.html`](workbench-cycle-1052.html) |

---

## 3) Reproducible evidence bundle

- Canonical payload: [`evidence/cycle-1052-benchmark.json`](evidence/cycle-1052-benchmark.json)
- Source ledger: [`evidence/cycle-1052-sources.json`](evidence/cycle-1052-sources.json)
- Metric CSV files:
  - [`cycle-1052-latency.csv`](evidence/cycle-1052-latency.csv)
  - [`cycle-1052-throughput.csv`](evidence/cycle-1052-throughput.csv)
  - [`cycle-1052-policy.csv`](evidence/cycle-1052-policy.csv)
  - [`cycle-1052-cost.csv`](evidence/cycle-1052-cost.csv)

---

## 4) Reports and visuals

- Daily report (EN): [`daily-report-2026-11-12.en.md`](daily-report-2026-11-12.en.md)
- Daily report (ZH): [`daily-report-2026-11-12.md`](daily-report-2026-11-12.md)
- One-page SVG: [`assets/34-cycle-1052-daily-breakthroughs.svg`](assets/34-cycle-1052-daily-breakthroughs.svg)
- Monograph addendum (EN): [`docs/full-monograph-cycle-1052.en.md`](docs/full-monograph-cycle-1052.en.md)
- Monograph addendum (ZH): [`docs/full-monograph-cycle-1052.md`](docs/full-monograph-cycle-1052.md)
- Selection FAQ (EN, Cosmos DB RU Spike Dampening Auto Cycle 1052): [`agent-cosmosdb-ru-spike-dampening-auto-cycle-1052-selection-faq.en.md`](agent-cosmosdb-ru-spike-dampening-auto-cycle-1052-selection-faq.en.md)
- Selection FAQ (ZH, Cosmos DB RU Spike Dampening Auto Cycle 1052): [`agent-cosmosdb-ru-spike-dampening-auto-cycle-1052-selection-faq.md`](agent-cosmosdb-ru-spike-dampening-auto-cycle-1052-selection-faq.md)
- Full archive (EN): [`docs/full-monograph-archive.en.md`](docs/full-monograph-archive.en.md)
- Full archive (ZH): [`docs/full-monograph-archive.md`](docs/full-monograph-archive.md)

---

## 5) Validation commands

```bash
python workshops/azure-agent-infra/simulator/cycle_1052_pipeline.py --write
python workshops/azure-agent-infra/simulator/cycle_1052_pipeline.py --check
python workshops/azure-agent-infra/simulator/agent_infra_sizer.py --check
python -m unittest workshops/azure-agent-infra/simulator/test_agent_infra_sizer.py
```

---

## 6) Build and runtime scripts

- Generator pipeline: [`simulator/cycle_1052_pipeline.py`](simulator/cycle_1052_pipeline.py)
- Runtime sizer: [`simulator/agent_infra_sizer.py`](simulator/agent_infra_sizer.py)
- Test suite: [`simulator/test_agent_infra_sizer.py`](simulator/test_agent_infra_sizer.py)
- Workshop runbook: [`workshop-runbook.md`](workshop-runbook.md)




















