# Agent APIM PTU Spillover Fallback Selection FAQ (Azure AI Agent Infra)

## 1) 3-minute conclusions
- **Without spillover fallback at PTU saturation, APIM can cascade into concentrated rejects and retry storms.**
- **Use pre-threshold triggering + tiered fallback + quality guardrails.**
- **Targets: `ptu_reject <0.6%`, `fallback_p95 <280ms`, `quality_drop <2%`.**

## 2) Q1 / Q2 / Q3
- **Why cascade happens?** PTU congestion drives synchronized retries into backup channels.
- **Why not always route to fallback?** Higher cost and quality variance.
- **Minimum loop?** Warning thresholds, staged diversion, quality gates.

### Q1: When to trigger spillover?
When PTU utilization stays near saturation.

### Q2: When to return to PTU?
When congestion clears and latency stabilizes.

### Q3: How to quantify gain?
Compare reject reduction against cost lift.

## 3) Mermaid diagrams
### 3.1 Decision tree
```mermaid
flowchart TD
  A[Request enters gateway] --> B{PTU utilization > threshold?}
  B -- Yes --> C[Trigger spillover tier-1]
  B -- No --> D[Serve on PTU]
  C --> E{quality guard pass?}
  E -- Yes --> F[Serve on fallback model]
  E -- No --> G[Apply degrade-safe response]
  F --> H[Monitor reject/cost drift]
  D --> H
  G --> H
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Hard reject on PTU full] --> B1[Low immediate cost]
  B1 --> C1[High user failure]

  A2[Spillover fallback] --> B2[Higher success rate]
  B2 --> C2[Needs quality/cost control]
```

### 3.3 Sequence
```mermaid
sequenceDiagram
  participant Client
  participant APIM
  participant PTU
  participant Fallback
  Client->>APIM: infer request
  APIM->>PTU: try primary
  PTU-->>APIM: busy/ok
  alt PTU busy
    APIM->>Fallback: route spillover
    Fallback-->>APIM: response
  end
  APIM-->>Client: final response
```

## 4) Decision matrix
| Dimension | Reject when PTU full | Spillover fallback (Recommended) |
|---|---:|---:|
| Success rate | Low | High |
| Cost control | High | Medium-high |
| Ops complexity (1-10) | 3 | 8 |
| User experience | Low | High |
| Quality stability | Medium | Medium-high |

## 5) Quant model + 7-card insights
- Gain: `RejectGain = BaselineReject - FallbackReject`
- Cost lift: `CostLift = FallbackCost - PTUCost`
- Example (`synthetic_assumed`):
  - `BaselineReject=2.8%, FallbackReject=0.5%`
  - `RejectGain=2.3%`
  - `PTUCost=$0.010/session, FallbackCost=$0.012/session`
  - `CostLift=$0.002/session`
- Evidence:
  - `workshops/azure-agent-infra/evidence/cycle-1487-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-1487-sources.json`
- Labels: `official/synthetic_assumed/not_measured`.

## 6) Production verification checklist
- [ ] PTU warning thresholds and diversion rules are versioned
- [ ] Fallback quality guards are auditable
- [ ] Reject/cost drift alerts are configured
- [ ] PTU return conditions are auto-validated
- [ ] FAQ/7-card source labels are complete
