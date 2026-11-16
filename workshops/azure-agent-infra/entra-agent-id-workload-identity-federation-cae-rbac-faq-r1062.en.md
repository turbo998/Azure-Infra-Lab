# Round 1062 / Cycle 2467 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **Microsoft Entra Agent ID + AKS/ACA Workload Identity Federation: OIDC exchange cache, tenant RBAC blast-radius, CAE revocation latency**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2467-benchmark.json`

## 1) Executive Summary

This round addresses the three identity pain points for multi-tenant agents: token-exchange overhead, over-broad permissions, and slow revocation effects.  
Key result: **OIDC exchange cache sizing + tenant-scoped RBAC + fast CAE revocation path** must be designed together.

## 2) Daily capability breakthroughs radar (fetched 2026-11-16)

1. **APIM AI Gateway / Unified Model API** (`measured`)  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions** (`measured`)  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases** (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B (see `evidence/cycle-2467-sources.json`)

## 3) Core formulas (exchange cache / blast radius / revocation)

### Q1: OIDC exchange-cache sizing

```text
cache_entries = active_workloads * tenants_per_workload * audiences
cache_memory_mb = cache_entries * avg_token_record_kb / 1024
```

Require token-cache hit rate `>= 90%` to avoid auth-chain jitter.

### Q2: RBAC blast-radius estimation

```text
blast_radius = affected_resources / total_resources_in_tenant_scope
```

Production target: `blast_radius <= 0.1` (within 10%).

### Q3: CAE revocation latency

```text
cae_revoke_latency_sec = signal_propagation_sec + token_recheck_sec + policy_eval_sec
```

Recommended `cae_revoke_p95_sec <= 120`.

## 4) Runnable snippets (Bicep / YAML / APIM policy / KQL)

### 4.1 Bicep (federated identity credential)

```bicep
resource fic 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31-preview' = {
  name: 'uami-agent/federated-aks'
  properties: {
    issuer: 'https://oidc.prod-aks.azure.com/<cluster-guid>/'
    subject: 'system:serviceaccount:agent-ns:agent-sa'
    audiences: [ 'api://AzureADTokenExchange' ]
  }
}
```

### 4.2 YAML (AKS/ACA workload identity)

```yaml
metadata:
  annotations:
    azure.workload.identity/client-id: "<uami-client-id>"
spec:
  serviceAccountName: agent-sa
```

### 4.3 APIM policy (strict tenant claim binding)

```xml
<policies>
  <inbound>
    <base />
    <validate-jwt header-name="Authorization">
      <required-claims>
        <claim name="tid"><value>@(context.Request.Headers.GetValueOrDefault("x-tenant-id",""))</value></claim>
      </required-claims>
    </validate-jwt>
  </inbound>
</policies>
```

### 4.4 KQL (exchange failures and revocation lag)

```kql
IdentityGuardLogs
| where TimeGenerated > ago(30m)
| summarize token_exchange_fail=countif(Event=="TokenExchangeFail"),
            cae_revoke_p95=percentile(CaeRevokeLatencySec,95),
            blast_radius_p95=percentile(BlastRadiusPct,95)
            by TenantId, Workload
| where token_exchange_fail > 0 or cae_revoke_p95 > 120 or blast_radius_p95 > 10
| order by token_exchange_fail desc, cae_revoke_p95 desc
```

## 5) Data evidence and reproducible math (with n denominator)

Total sample `n = 4410` (`evidence/cycle-2467-benchmark.json -> percentage_contract`):

- `unfenced_entra_workload_identity_cae_rbac_guard_drift_rate = 534 / 4410 = 12.1%`
- `entra_workload_identity_cae_rbac_guard_variance_rate = 216 / 4410 = 4.9%`
- `entra_workload_identity_cae_rbac_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute formula: `percentage = round((numerator / denominator) * 100, 1)`.

## 6) Decision matrix (identity-governance patterns)

| Pattern | Security | Availability | Latency | Ops complexity | Recommendation |
|---|---:|---:|---:|---:|---|
| Static secrets / long-lived credentials | Low | High | Low | Low | Not recommended |
| Federation without CAE refinement | Medium | Medium | Medium | Medium | Transitional |
| Federation + tenant RBAC + CAE | **High** | **Medium-high** | **Medium-high** | Medium-high | **Production default** |

## 7) Production failure-triage checklist

1. Token exchange failure spike: verify OIDC issuer/subject bindings.
2. `cae_revoke_p95_sec > 120`: inspect policy propagation and token recheck path.
3. `blast_radius_p95 > 10%`: immediately reduce role scope.
4. Cross-tenant authorization drift: split identity domains by tenant ring.
5. Low cache hit rate: increase token-cache capacity and audience reuse.
