# Agent Tool Output Hash Attestation Selection FAQ (Log-Only Trace vs Verifiable Hash+Signature Chain)

## 0) Executive takeaway
- **Default to a verifiable hash+signature chain in production**; log-only trace is not enough for anti-tamper proof.
- **Log-only is acceptable only for low-risk internal flows**.
- **In regulated workloads, content hash, signing identity, and replay verification must be unified in the gateway control plane**.

## 1) What are you deciding?
- Option A: log-only trace (request ID + plain payload)
- Option B: SHA-256 hash + signature + immutable evidence

## 2) When log-only is acceptable
- non-critical operations
- no cross-organization dispute workflow
- no strong non-repudiation requirement

## 3) When hash attestation is mandatory
- payments/risk/compliance approvals
- tool outputs are transformed across systems
- audit must prove exactly which output version was executed

## 4) Architecture sketch
```mermaid
flowchart LR
  Req[Agent Request] --> GW[APIM Gateway]
  GW --> Tool[Tool Runtime]
  Tool --> H[SHA-256 Hash]
  H --> Sig[Service Signature]
  Sig --> Ledger[Immutable Ledger]
  Ledger --> Replay[Audit Replay Verifier]
```

## 5) Decision matrix
| Dimension | Log-only trace | Verifiable hash+signature chain |
|---|---|---|
| Implementation cost | Low | Medium |
| Provability | Low | High |
| Cross-system consistency | Medium | High |
| Audit non-repudiation | Weak | Strong |
| Long-term governance | Medium | High |

## 6) Recomputable example
Assume 40 dispute investigations per month:
- Log-only: direct attribution rate = 62%
- Hash attestation chain: direct attribution rate = 93%

Under this assumption, first-pass attribution improves by **31 percentage points**.
