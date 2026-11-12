# Azure AI Agent Infrastructure Playbook (Compact)

> 🌐 **Language Switch**: **[🇨🇳 Chinese (`README.md`)](README.md)** | **🇬🇧 English (`README.en.md`)**  
> 🔎 **Cycle #947 highlights**: [benchmark-cards.en.html](benchmark-cards.en.html) · [benchmark-cards.html](benchmark-cards.html) · [workbench-cycle-947.html](workbench-cycle-947.html) · [daily-report-2026-11-12.en.md](daily-report-2026-11-12.en.md)

---

## 1) Cycle #947 release summary (2026-11-12)

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
| **Cycle #947 deck (EN)** | New archetype-aligned deck | [`benchmark-cards.en.html`](benchmark-cards.en.html) |
| **Cycle #947 deck (ZH)** | New archetype-aligned deck | [`benchmark-cards.html`](benchmark-cards.html) |
| **Cycle #947 workbench** | Interactive benchmark surface | [`workbench-cycle-947.html`](workbench-cycle-947.html) |

---

## 3) Reproducible evidence bundle

- Canonical payload: [`evidence/cycle-947-benchmark.json`](evidence/cycle-947-benchmark.json)
- Source ledger: [`evidence/cycle-947-sources.json`](evidence/cycle-947-sources.json)
- Metric CSV files:
  - [`cycle-947-latency.csv`](evidence/cycle-947-latency.csv)
  - [`cycle-947-throughput.csv`](evidence/cycle-947-throughput.csv)
  - [`cycle-947-policy.csv`](evidence/cycle-947-policy.csv)
  - [`cycle-947-cost.csv`](evidence/cycle-947-cost.csv)

---

## 4) Reports and visuals

- Daily report (EN): [`daily-report-2026-11-12.en.md`](daily-report-2026-11-12.en.md)
- Daily report (ZH): [`daily-report-2026-11-12.md`](daily-report-2026-11-12.md)
- One-page SVG: [`assets/34-cycle-947-daily-breakthroughs.svg`](assets/34-cycle-947-daily-breakthroughs.svg)
- Monograph addendum (EN): [`docs/full-monograph-cycle-947.en.md`](docs/full-monograph-cycle-947.en.md)
- Monograph addendum (ZH): [`docs/full-monograph-cycle-947.md`](docs/full-monograph-cycle-947.md)
- Selection FAQ (EN, Cosmos DB Vector Index Write Budget Auto Cycle 947): [`agent-cosmosdb-vector-index-write-budget-auto-cycle-947-selection-faq.en.md`](agent-cosmosdb-vector-index-write-budget-auto-cycle-947-selection-faq.en.md)
- Selection FAQ (ZH, Cosmos DB Vector Index Write Budget Auto Cycle 947): [`agent-cosmosdb-vector-index-write-budget-auto-cycle-947-selection-faq.md`](agent-cosmosdb-vector-index-write-budget-auto-cycle-947-selection-faq.md)
- Full archive (EN): [`docs/full-monograph-archive.en.md`](docs/full-monograph-archive.en.md)
- Full archive (ZH): [`docs/full-monograph-archive.md`](docs/full-monograph-archive.md)

---

## 5) Validation commands

```bash
python workshops/azure-agent-infra/simulator/cycle_947_pipeline.py --write
python workshops/azure-agent-infra/simulator/cycle_947_pipeline.py --check
python workshops/azure-agent-infra/simulator/agent_infra_sizer.py --check
python -m unittest workshops/azure-agent-infra/simulator/test_agent_infra_sizer.py
```

---

## 6) Build and runtime scripts

- Generator pipeline: [`simulator/cycle_947_pipeline.py`](simulator/cycle_947_pipeline.py)
- Runtime sizer: [`simulator/agent_infra_sizer.py`](simulator/agent_infra_sizer.py)
- Test suite: [`simulator/test_agent_infra_sizer.py`](simulator/test_agent_infra_sizer.py)
- Workshop runbook: [`workshop-runbook.md`](workshop-runbook.md)




















