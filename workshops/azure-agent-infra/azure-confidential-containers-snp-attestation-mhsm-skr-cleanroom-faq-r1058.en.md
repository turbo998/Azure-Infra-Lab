# Round 1058 / Cycle 2463 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **Azure Confidential Containers (SEV-SNP) attestation + Managed HSM SKR for sovereign multi-party clean-room agents**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2463-benchmark.json`

## 1) Executive Summary

This round targets high-compliance multi-party collaboration where agents run across partially trusted parties with strict key release controls.  
Key result: **SEV-SNP attestation chain + SKR policy binding + clean-room network partitioning** is the minimum sovereign pattern.

## 2) Daily capability breakthroughs radar (fetched 2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2463-sources.json`)

## 3) Core formulas (attestation / latency / capacity)

### Q1: Attestation gate latency budget

```text
attestation_gate_ms = quote_gen_ms + verifier_eval_ms + policy_eval_ms + skr_release_ms
```

Recommended production target: `attestation_gate_p95_ms <= 900`.

### Q2: Confidential node capacity

```text
required_nodes = ceil(concurrent_sessions / sessions_per_confidential_node)
effective_util = workload_cpu_ms / node_available_cpu_ms
```

Keep `effective_util <= 0.7` to reduce attestation burst jitter.

### Q3: SKR deny-rate threshold

`skr_deny_rate = denied_skr_requests / total_skr_requests`

- Normal: `skr_deny_rate <= 0.5%`
- If `> 2%`: trigger policy rollback + attestation-chain audit

## 4) Runnable snippets (Bicep / YAML / Policy / KQL)

### 4.1 Bicep (confidential container group)

```bicep
resource cg 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'cc-agent-cleanroom'
  location: resourceGroup().location
  properties: {
    sku: 'Confidential'
    containers: [
      {
        name: 'agent'
        properties: {
          image: 'myacr.azurecr.io/agent-cleanroom:1.0.0'
          resources: { requests: { cpu: 4, memoryInGB: 16 } }
        }
      }
    ]
  }
}
```

### 4.2 YAML (attestation sidecar + SKR)

```yaml
containers:
  - name: agent-runtime
    image: myacr.azurecr.io/agent-cleanroom:1.0.0
  - name: attestation-proxy
    image: myacr.azurecr.io/attest-proxy:0.4.2
    env:
      - name: SKR_ENDPOINT
        value: https://mhsm-prod.managedhsm.azure.net
```

### 4.3 Policy JSON (release keys only to attested workloads)

```json
{
  "if": {
    "allOf": [
      { "field": "attestation.svn", "less": 6 },
      { "field": "attestation.measurement", "notIn": "[parameters('approvedMeasurements')]" }
    ]
  },
  "then": { "effect": "deny" }
}
```

### 4.4 KQL (attestation and SKR deny triage)

```kql
CleanroomAudit
| where TimeGenerated > ago(30m)
| summarize attest_p95=percentile(AttestationGateMs,95),
            skr_deny=countif(SkrDecision=="Deny"),
            skr_total=count(),
            token_p95=percentile(TokenLatencyMs,95)
            by TenantRing, Workload
| extend skr_deny_rate = todouble(skr_deny) / skr_total
| where attest_p95 > 900 or skr_deny_rate > 0.02
| order by skr_deny_rate desc, attest_p95 desc
```

## 5) Data evidence and reproducible math (with n denominator)

Total sample `n = 4410` (`evidence/cycle-2463-benchmark.json -> percentage_contract`):

- `unfenced_confidential_attestation_skr_cleanroom_guard_drift_rate = 534 / 4410 = 12.1%`
- `confidential_attestation_skr_cleanroom_guard_variance_rate = 216 / 4410 = 4.9%`
- `confidential_attestation_skr_cleanroom_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute formula: `percentage = round((numerator / denominator) * 100, 1)`.

## 6) Decision matrix (sovereign collaboration patterns)

| Pattern | Confidentiality | Auditability | Performance | Ops complexity | Recommendation |
|---|---:|---:|---:|---:|---|
| Standard containers + static keys | Low | Low | High | Low | Not for regulated workloads |
| Confidential containers without SKR | Medium | Medium | Medium | Medium | Transitional |
| SEV-SNP + SKR + clean-room policy | **High** | **High** | Medium-high | High | **Production default** |

## 7) Production failure-triage checklist

1. `attestation_gate_p95_ms > 900`: inspect quote generation and verifier load.
2. `skr_deny_rate > 2%`: review measurement allowlist and SVN policy.
3. Token latency rises with healthy attestation: inspect clean-room egress policy.
4. Multi-tenant conflicts: split HSM key hierarchy by tenant ring.
5. Missing evidence chain: hard-stop sessions and raise compliance incident.
