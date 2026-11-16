# Cycle #2467 核心工程专著：Entra Federation + CAE（zh-CN）

- Round/Cycle: `1062 / 2467`
- Topic: `entra-agent-id-workload-identity-federation-cae-rbac-faq-r1062`

## 1) 关键公式

```text
cache_entries = active_workloads * tenants_per_workload * audiences
blast_radius = affected_resources / total_resources_in_tenant_scope
cae_revoke_latency_sec = signal_propagation_sec + token_recheck_sec + policy_eval_sec
```

阈值：
- `token cache hit >= 90%`
- `blast_radius <= 10%`
- `cae_revoke_p95_sec <= 120`

## 2) Runnable snippets

### Bicep（Federated credential）

```bicep
resource fic 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31-preview' = {
  name: 'uami-agent/federated-aks'
}
```

### YAML（workload identity）

```yaml
metadata:
  annotations:
    azure.workload.identity/client-id: "<uami-client-id>"
```

### APIM policy（租户 claim 绑定）

```xml
<validate-jwt header-name="Authorization">
  <required-claims><claim name="tid"><value>@(context.Request.Headers.GetValueOrDefault("x-tenant-id",""))</value></claim></required-claims>
</validate-jwt>
```

### KQL（交换失败与吊销排障）

```kql
IdentityGuardLogs
| where TimeGenerated > ago(30m)
| summarize fail=countif(Event=="TokenExchangeFail"), revoke_p95=percentile(CaeRevokeLatencySec,95) by TenantId
| where fail > 0 or revoke_p95 > 120
```

## 3) 失效模式

1. OIDC issuer/subject 漂移导致交换失败。  
2. role scope 过宽导致爆炸半径扩大。  
3. CAE 吊销传播慢导致旧 token 继续生效。  
4. 租户共享缓存导致授权污染。

## 4) 落地清单

- Federated credential 生命周期管控。  
- tenant ring 级 RBAC 分域。  
- CAE 传播链路压测与告警。  
- token cache 审计与密钥轮换策略。
