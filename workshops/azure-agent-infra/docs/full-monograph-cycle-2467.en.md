# Cycle #2467 Core Engineering Monograph: Entra Federation + CAE (en)

- Round/Cycle: `1062 / 2467`
- Topic: `entra-agent-id-workload-identity-federation-cae-rbac-faq-r1062`

## 1) Core formulas

```text
cache_entries = active_workloads * tenants_per_workload * audiences
blast_radius = affected_resources / total_resources_in_tenant_scope
cae_revoke_latency_sec = signal_propagation_sec + token_recheck_sec + policy_eval_sec
```

Thresholds:
- `token cache hit >= 90%`
- `blast_radius <= 10%`
- `cae_revoke_p95_sec <= 120`

## 2) Runnable snippets

### Bicep (federated credential)

```bicep
resource fic 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31-preview' = {
  name: 'uami-agent/federated-aks'
}
```

### YAML (workload identity)

```yaml
metadata:
  annotations:
    azure.workload.identity/client-id: "<uami-client-id>"
```

### APIM policy (tenant-claim binding)

```xml
<validate-jwt header-name="Authorization">
  <required-claims><claim name="tid"><value>@(context.Request.Headers.GetValueOrDefault("x-tenant-id",""))</value></claim></required-claims>
</validate-jwt>
```

### KQL (exchange failure / revocation triage)

```kql
IdentityGuardLogs
| where TimeGenerated > ago(30m)
| summarize fail=countif(Event=="TokenExchangeFail"), revoke_p95=percentile(CaeRevokeLatencySec,95) by TenantId
| where fail > 0 or revoke_p95 > 120
```

## 3) Failure modes

1. OIDC issuer/subject drift causes exchange failures.
2. Over-broad role scope expands blast radius.
3. Slow CAE propagation keeps stale tokens valid.
4. Shared tenant caches contaminate authorization boundaries.

## 4) Rollout checklist

- Lifecycle governance for federated credentials.
- Tenant-ring RBAC domain partitioning.
- CAE propagation load tests and alerts.
- Token-cache auditing and key-rotation policy.
