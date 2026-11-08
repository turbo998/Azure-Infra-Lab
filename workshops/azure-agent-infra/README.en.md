# Azure AI Agent Infrastructure Playbook (Compact)

> 🌐 **Language Switch**: **[🇨🇳 Chinese (`README.md`)](README.md)** | **🇬🇧 English (`README.en.md`)**  
> 🔎 **Cycle #434 highlights**: [benchmark-cards.en.html](benchmark-cards.en.html) · [benchmark-cards.html](benchmark-cards.html) · [workbench-cycle-434.html](workbench-cycle-434.html) · [daily-report-2026-11-09.en.md](daily-report-2026-11-09.en.md)

---

## 1) Cycle #434 release summary (2026-11-09)

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
| **Cycle #434 deck (EN)** | New archetype-aligned deck | [`benchmark-cards.en.html`](benchmark-cards.en.html) |
| **Cycle #434 deck (ZH)** | New archetype-aligned deck | [`benchmark-cards.html`](benchmark-cards.html) |
| **Cycle #434 workbench** | Interactive benchmark surface | [`workbench-cycle-434.html`](workbench-cycle-434.html) |

---

## 3) Reproducible evidence bundle

- Canonical payload: [`evidence/cycle-434-benchmark.json`](evidence/cycle-434-benchmark.json)
- Source ledger: [`evidence/cycle-434-sources.json`](evidence/cycle-434-sources.json)
- Metric CSV files:
  - [`cycle-434-latency.csv`](evidence/cycle-434-latency.csv)
  - [`cycle-434-throughput.csv`](evidence/cycle-434-throughput.csv)
  - [`cycle-434-policy.csv`](evidence/cycle-434-policy.csv)
  - [`cycle-434-cost.csv`](evidence/cycle-434-cost.csv)

---

## 4) Reports and visuals

- Daily report (EN): [`daily-report-2026-11-09.en.md`](daily-report-2026-11-09.en.md)
- Daily report (ZH): [`daily-report-2026-11-09.md`](daily-report-2026-11-09.md)
- One-page SVG: [`assets/34-cycle-434-daily-breakthroughs.svg`](assets/34-cycle-434-daily-breakthroughs.svg)
- Monograph addendum (EN): [`docs/full-monograph-cycle-434.en.md`](docs/full-monograph-cycle-434.en.md)
- Monograph addendum (ZH): [`docs/full-monograph-cycle-434.md`](docs/full-monograph-cycle-434.md)
- Selection FAQ (EN, Runtime Wasm Component Cache Prewarm Governance): [`agent-runtime-wasm-component-cache-prewarm-selection-faq.en.md`](agent-runtime-wasm-component-cache-prewarm-selection-faq.en.md)
- Selection FAQ (ZH, Runtime Wasm Component Cache Prewarm Governance): [`agent-runtime-wasm-component-cache-prewarm-selection-faq.md`](agent-runtime-wasm-component-cache-prewarm-selection-faq.md)
- Full archive (EN): [`docs/full-monograph-archive.en.md`](docs/full-monograph-archive.en.md)
- Full archive (ZH): [`docs/full-monograph-archive.md`](docs/full-monograph-archive.md)

---

## 5) Validation commands

```bash
python workshops/azure-agent-infra/simulator/cycle_434_pipeline.py --write
python workshops/azure-agent-infra/simulator/cycle_434_pipeline.py --check
python workshops/azure-agent-infra/simulator/agent_infra_sizer.py --check
python -m unittest workshops/azure-agent-infra/simulator/test_agent_infra_sizer.py
```

---

## 6) Build and runtime scripts

- Generator pipeline: [`simulator/cycle_434_pipeline.py`](simulator/cycle_434_pipeline.py)
- Runtime sizer: [`simulator/agent_infra_sizer.py`](simulator/agent_infra_sizer.py)
- Test suite: [`simulator/test_agent_infra_sizer.py`](simulator/test_agent_infra_sizer.py)
- Workshop runbook: [`workshop-runbook.md`](workshop-runbook.md)









