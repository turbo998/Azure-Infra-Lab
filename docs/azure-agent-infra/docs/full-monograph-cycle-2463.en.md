# Cycle #2463 Core Engineering Monograph: Confidential Agent Clean-room (en)

- Round/Cycle: `1058 / 2463`
- Topic: `azure-confidential-containers-snp-attestation-mhsm-skr-cleanroom-faq-r1058`

## 1) Core budget formulas

```text
attestation_gate_ms = quote_gen_ms + verifier_eval_ms + policy_eval_ms + skr_release_ms
required_nodes = ceil(concurrent_sessions / sessions_per_confidential_node)
skr_deny_rate = denied_skr_requests / total_skr_requests
```

Thresholds:
- `attestation_gate_p95_ms <= 900`
- `skr_deny_rate <= 0.5%` (>2% enters incident mode)

## 2) Runnable snippets

### Bicep (confidential container)

```bicep
resource cg 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'cc-agent-cleanroom'
  properties: { sku: 'Confidential' }
}
```

### YAML (attestation sidecar)

```yaml
containers:
  - name: agent-runtime
  - name: attestation-proxy
    env:
      - name: SKR_ENDPOINT
        value: https://mhsm-prod.managedhsm.azure.net
```

### Policy JSON (SKR release guard)

```json
{
  "if": { "field": "attestation.svn", "less": 6 },
  "then": { "effect": "deny" }
}
```

### KQL (attestation + SKR triage)

```kql
CleanroomAudit
| where TimeGenerated > ago(30m)
| summarize attest_p95=percentile(AttestationGateMs,95), deny=countif(SkrDecision=="Deny"), total=count() by Workload
| extend deny_rate=todouble(deny)/total
| where attest_p95 > 900 or deny_rate > 0.02
```

## 3) Failure modes

1. Attestation-chain timeout cascades session failures.
2. Measurement drift causes SKR deny spikes.
3. Clean-room egress policy mistakes inflate token latency.
4. Mixed key hierarchy weakens tenant isolation boundaries.

## 4) Rollout checklist

- Version attestation policies with approvals.
- Sync SKR allowlist with SVN upgrade policy.
- Enforce explicit clean-room ingress/egress rules.
- Archive ADX audit logs as tamper-evident records.
