# Round 1072 / Cycle 2477 · Azure AI Agent Infra Six-Section FAQ (en)

> Topic: **Confidential Ledger SGX receipts + Immutable Blob WORM + Entra PIM JIT approval chain**  
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2477-benchmark.json`

## 1) Scenario objective

For destructive SRE/financial agent write actions (delete, limit changes, bulk settlement), the platform needs non-repudiable auditability:  
1. human approval before write,  
2. verifiable receipt after write,  
3. immutable evidence retention for replay.

## 2) Core formulas (latency / throughput / verification)

```text
commit_to_receipt_ms =
  ledger_commit_ms + merkle_receipt_issue_ms + receipt_verify_ms
```

```text
batch_anchor_tps =
  batch_size / (flush_interval_sec + anchor_commit_sec)
```

```text
tamper_verify_latency_ms =
  proof_fetch_ms + merkle_path_verify_ms + signature_verify_ms
```

Recommended thresholds:
- `commit_to_receipt_p95 < 450ms`
- `tamper_verify_latency_p95 < 200ms`

## 3) Architecture layering (approve → commit → anchor)

1. **Approval layer**: Entra PIM JIT elevation + two-person approval.  
2. **Commit layer**: write intent enters Confidential Ledger and returns SGX/Merkle receipt.  
3. **Anchor layer**: batch anchor to Immutable Blob WORM retention policy.

## 4) Runnable snippets (Bicep / YAML / Policy / KQL)

### 4.1 Bicep: WORM storage anchor

```bicep
resource stg 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stgauditworm'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: { name: 'Standard_LRS' }
}
```

### 4.2 YAML: approval-chain contract

```yaml
approvalChain:
  pimJitRequired: true
  approversMin: 2
  destructiveActions:
    - delete-record
    - bulk-settlement
```

### 4.3 Policy: deny destructive writes without approval token

```yaml
policy:
  name: require-jit-approval-token
  if:
    actionIn: ["delete-record", "bulk-settlement"]
    approvalTokenMissing: true
  then:
    effect: deny
```

### 4.4 KQL: receipt latency and tamper verification SLO

```kql
AuditChainEvents
| where TimeGenerated > ago(30m)
| summarize
    receipt_p95=percentile(CommitToReceiptMs,95),
    verify_p95=percentile(TamperVerifyLatencyMs,95),
    denied=countif(Result == "DeniedByPolicy")
    by TenantId, bin(TimeGenerated, 5m)
| where receipt_p95 > 450 or verify_p95 > 200
| order by receipt_p95 desc
```

## 5) Data evidence and recomputable math (with n denominator source)

Total sample `n = 4410` (`evidence/cycle-2477-benchmark.json`):

- `unfenced_auditchain_guard_drift_rate = 534 / 4410 = 12.1%`
- `auditchain_guard_variance_rate = 216 / 4410 = 4.9%`
- `auditchain_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute contract:

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) Rollout checklist (Good fit vs Not for)

**Good fit**
- Agent platforms with destructive writes and compliance liability.  
- Need approval token + receipt proof + immutable WORM anchoring in one chain.

**Not for**
- Lightweight internal scripts without retention obligations.  
- Environments lacking unified identity approval and policy control planes.
