# APIM MCP Reentry Resilience Guard Lane Latency Bucket FAQ (Cycle 2175)

## 1) Three-minute decision
- **Core issue:** when reentry peaks overlap policy oscillation, weak resilience causes fairness jitter and rollback amplification.
- **Recommendation:** adopt a closed loop of resilience guard lanes, latency-bucket credit allocation, fallback downgrade gates, and replay audit.
- **Goal:** preserve multi-tenant fairness while shortening recovery windows and constraining blast radius.

## 2) Q1 / Q2 / Q3
### Q1: Why introduce a resilience guard lane?
1) unified throttling cannot segment requests by recovery resilience class,
2) resilience lanes isolate high-volatility traffic during policy transitions,
3) with latency buckets, credit burn, recovery ordering, and failure radius are jointly bounded.

### Q2: How should production layering be deployed?
- **Resilience guard layer:** map tenant tier + failure signature into recovery lanes,
- **Credit allocation layer:** grant/renew/reclaim lane-scoped latency-bucket credits,
- **Suppression layer:** reclaim burst overdrafts and stop cross-lane propagation,
- **Degrade layer:** trigger fallback downgrade at peak with replayable accountability evidence.

### Q3: What is the release bar?
- unfenced resilience drift trends down continuously,
- lane variance remains stable and explainable,
- recovery gain (percentage points) is reproducible across windows.

## 3) Reference architecture
```mermaid
flowchart LR
  A[MCP Reentry Ingress] --> B[Resilience Guard Lane Classifier]
  B --> C[Credit Latency Bucket Controller]
  C --> D[Resilience-aware Recovery Scheduler]
  D --> E[Fallback Downgrade Gate]
  E --> F[Resilience Priority Lane]
  E --> G[Standard Lane]
  F --> H[Gateway Response]
  G --> H
  H --> I[Replay + Accountability Timeline]
```

## 4) Decision matrix
| Dimension | Unified latency bucket | Resilience Guard Lane + Latency Bucket (Recommended) |
|---|---:|---:|
| Resilience drift control | Medium | High |
| Cross-tenant propagation suppression | Medium | High |
| Replay accountability | Medium | High |
| Peak downgrade stability | Medium | High |
| Implementation complexity | Medium | Medium-High |

## 5) Evidence and reproducibility
- Evidence files:
  - `workshops/azure-agent-infra/evidence/cycle-2175-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-2175-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2175-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-2175-cost.csv`
- Contract keys:
  - `percentage_contract.unfenced_reentry_resilienceguardlane_drift_rate`
  - `percentage_contract.reentry_resilienceguardlane_variance_rate`
  - `percentage_contract.reentry_resilienceguardlane_recovery_gain_pts`
- Labels: `measured / synthetic / anonymized_reported`.

## 6) Production checklist
- [ ] Resilience-lane mapping is tenant-tier replayable.
- [ ] Bucket grant/renew/reclaim is resilience-lane consistent.
- [ ] Resilience-priority lanes remain starvation-free during peak downgrade.
- [ ] Audit trails bind policy version, failure signature, and recovery path.
- [ ] FAQ/H5/SVG/7-card/evidence stay cycle-topic consistent.
