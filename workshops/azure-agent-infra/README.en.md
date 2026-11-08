# Azure AI Agent Infrastructure Playbook (Compact)

> 🌐 **Language Switch**: **[🇨🇳 Chinese (`README.md`)](README.md)** | **🇬🇧 English (`README.en.md`)**  
> 🔎 **Cycle #437 highlights**: [benchmark-cards.en.html](benchmark-cards.en.html) · [benchmark-cards.html](benchmark-cards.html) · [workbench-cycle-437.html](workbench-cycle-437.html) · [daily-report-2026-11-09.en.md](daily-report-2026-11-09.en.md)

---

## 1) Cycle #437 release summary (2026-11-09)

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
| **Cycle #437 deck (EN)** | New archetype-aligned deck | [`benchmark-cards.en.html`](benchmark-cards.en.html) |
| **Cycle #437 deck (ZH)** | New archetype-aligned deck | [`benchmark-cards.html`](benchmark-cards.html) |
| **Cycle #437 workbench** | Interactive benchmark surface | [`workbench-cycle-437.html`](workbench-cycle-437.html) |

---

## 3) Reproducible evidence bundle

- Canonical payload: [`evidence/cycle-437-benchmark.json`](evidence/cycle-437-benchmark.json)
- Source ledger: [`evidence/cycle-437-sources.json`](evidence/cycle-437-sources.json)
- Metric CSV files:
  - [`cycle-437-latency.csv`](evidence/cycle-437-latency.csv)
  - [`cycle-437-throughput.csv`](evidence/cycle-437-throughput.csv)
  - [`cycle-437-policy.csv`](evidence/cycle-437-policy.csv)
  - [`cycle-437-cost.csv`](evidence/cycle-437-cost.csv)

---

## 4) Reports and visuals

- Daily report (EN): [`daily-report-2026-11-09.en.md`](daily-report-2026-11-09.en.md)
- Daily report (ZH): [`daily-report-2026-11-09.md`](daily-report-2026-11-09.md)
- One-page SVG: [`assets/34-cycle-437-daily-breakthroughs.svg`](assets/34-cycle-437-daily-breakthroughs.svg)
- Monograph addendum (EN): [`docs/full-monograph-cycle-437.en.md`](docs/full-monograph-cycle-437.en.md)
- Monograph addendum (ZH): [`docs/full-monograph-cycle-437.md`](docs/full-monograph-cycle-437.md)
- Selection FAQ (EN, Memory Tiering Governance): [`agent-memory-tiering-hot-cold-store-selection-faq.en.md`](agent-memory-tiering-hot-cold-store-selection-faq.en.md)
- Selection FAQ (ZH, Memory Tiering Governance): [`agent-memory-tiering-hot-cold-store-selection-faq.md`](agent-memory-tiering-hot-cold-store-selection-faq.md)
- Full archive (EN): [`docs/full-monograph-archive.en.md`](docs/full-monograph-archive.en.md)
- Full archive (ZH): [`docs/full-monograph-archive.md`](docs/full-monograph-archive.md)

---

## 5) Validation commands

```bash
python workshops/azure-agent-infra/simulator/cycle_437_pipeline.py --write
python workshops/azure-agent-infra/simulator/cycle_437_pipeline.py --check
python workshops/azure-agent-infra/simulator/agent_infra_sizer.py --check
python -m unittest workshops/azure-agent-infra/simulator/test_agent_infra_sizer.py
```

---

## 6) Build and runtime scripts

- Generator pipeline: [`simulator/cycle_437_pipeline.py`](simulator/cycle_437_pipeline.py)
- Runtime sizer: [`simulator/agent_infra_sizer.py`](simulator/agent_infra_sizer.py)
- Test suite: [`simulator/test_agent_infra_sizer.py`](simulator/test_agent_infra_sizer.py)
- Workshop runbook: [`workshop-runbook.md`](workshop-runbook.md)









