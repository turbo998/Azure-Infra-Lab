# Agent APIM Policy Bundle Signature Rollout Selection FAQ (Azure AI Agent Infra)

## 1) 3-minute conclusions
- **If policy bundle updates exceed 4/day and tamper alerts appear, enforce signature verification with progressive rollout.**
- **On signature verification failure, block execution and rollback to the prior signed stable bundle.**
- **Targets: `signature_verify_fail <0.05%`, `rollback_p95 <40s`, `policy_eval_p95 <20ms`.**

## 2) Q1 / Q2 / Q3
- **Why sign policy bundles?** To prevent tampering and supply-chain drift.
- **Why progressive rollout?** To limit blast radius from policy misconfiguration.
- **Minimum viable loop?** Signed release, runtime verification, rollback, auditable evidence.

### Q1: When must rollout be blocked?
When signature validation fails or signer identity is not trusted.

### Q2: When is fast full rollout acceptable?
Low-risk changes with successful replay validation.

### Q3: How to quantify gain?
Compare false-reject incidents reduced versus signing overhead.

## 3) Mermaid diagrams
### 3.1 Decision tree
```mermaid
flowchart TD
  A[Start: APIM policy rollout] --> B{signature valid?}
  B -- No --> C[Block rollout + rollback previous signed bundle]
  B -- Yes --> D[Progressive shard rollout]
  D --> E{error_rate > threshold?}
  E -- Yes --> F[Rollback signed previous bundle]
  E -- No --> G[Complete rollout]
  C --> H[Audit + alert]
  F --> H
  G --> H
```

### 3.2 Path comparison
```mermaid
flowchart LR
  A1[Unsigned direct rollout] --> B1[Fast but risky]
  B1 --> C1[Higher tamper/misconfig risk]

  A2[Signed + progressive rollout] --> B2[Safer governance]
  B2 --> C2[Slight release overhead]
```

### 3.3 Sequence
```mermaid
sequenceDiagram
  participant CI as Policy CI
  participant Sig as Signing Service
  participant APIM as APIM Gateway
  participant Obs as Observability
  CI->>Sig: request signature
  Sig-->>CI: signed bundle
  CI->>APIM: deploy signed bundle
  APIM->>APIM: verify signature and issuer
  APIM-->>Obs: rollout metrics + verify logs
  alt verify fail or error spike
    APIM->>APIM: rollback prior signed bundle
  end
```

## 4) Decision matrix
| Dimension | Unsiged direct rollout | Signed + progressive rollout (Recommended) |
|---|---:|---:|
| Tamper protection | Low | High |
| Rollout risk | High | Low |
| Rollout speed | High | Medium |
| Ops complexity (1-10) | 3 | 7 |
| Audit traceability | Medium | High |

## 5) Quant model + 7-card insights
- Verify risk: `VerifyRisk = VerifyFail / TotalRollouts`
- Rollback gain: `RollbackGain = IncidentLossBaseline - IncidentLossNew`
- Example (`synthetic_assumed`):
  - `VerifyFail=2, TotalRollouts=520`
  - `VerifyRisk=0.38%`
  - `IncidentLossBaseline=$320/day, IncidentLossNew=$70/day`
  - `RollbackGain=$250/day`
- Evidence:
  - `workshops/azure-agent-infra/evidence/cycle-1467-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-1467-sources.json`
- Labels: `official/synthetic_assumed/not_measured`.

## 6) Production verification checklist
- [ ] Bundle signature and signer verification are enforced
- [ ] Progressive rollout and auto-rollback are linked
- [ ] Signature-failure alerts trace back to source commit
- [ ] Replay validation covers critical-tenant paths
- [ ] FAQ/7-card source labels are complete
