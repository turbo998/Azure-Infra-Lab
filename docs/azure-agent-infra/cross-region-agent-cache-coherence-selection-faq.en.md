# Cross-Region Agent Cache Coherence Selection FAQ (Cycle 1780)

## 1) Three-minute decision
- **The dominant risk in cross-region agent caching is mismatch between coherence policy and origin-read fallback, not hit rate itself.**
- **Recommendation:** short strong-consistency window for hot keys + eventual consistency for cold keys + origin-budget gating.
- **Goal:** balance latency and availability while preventing stale-read cascades into policy errors.

## 2) Core questions (Q1/Q2/Q3)
### Q1: Why is global strong consistency impractical?
1) cross-region write amplification increases latency,
2) network jitter magnifies global stalls,
3) cost scales steeply with write pressure.

### Q2: How to operationalize tiered coherence?
- hot keys (policy/quota): short strong-consistency windows,
- cold keys (historical summaries): eventual consistency,
- origin-read fallback with budget thresholds.

### Q3: How to validate effectiveness?
- stale-read rate stays under threshold,
- cross-region write latency remains within budget,
- fallback behavior is controllable and replayable during incidents.

## 3) Reference architecture
```mermaid
flowchart LR
  R[Regional Requests] --> G[Cache Coherence Policy]
  G --> H[Hot-Key Strong Window]
  G --> C[Cold-Key Eventual Window]
  H --> O[Origin Read Budget Gate]
  C --> O
  O --> L[Coherence Decision Ledger]
```

## 4) Decision matrix
| Dimension | Global strong consistency | Tiered coherence + origin gate (Recommended) |
|---|---:|---:|
| Latency control | Low | High |
| Stale-read risk | Low | Low-Medium |
| Multi-region availability | Medium | High |
| Cost control | Low | High |
| Ops explainability | Medium | High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-1780-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-1780-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1780-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1780-policy.csv`
- Labels: `measured / synthetic / anonymized_reported`.
- validation7 requires bilingual structure, CSP self-contained cards, evidence consistency, and replayability trace.

## 6) Production checklist
- [ ] Hot-key set and strong-consistency window are explicit.
- [ ] Cold-key coherence delay metrics are observable.
- [ ] Origin-budget gate has circuit-break/degrade logic.
- [ ] Decisions and replay logs are audit-ledgered.
- [ ] FAQ/H5/SVG/7-card references are cycle-aligned.
