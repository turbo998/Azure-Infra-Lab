# Round 1062 / Cycle 2467 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **Microsoft Entra Agent ID + AKS/ACA Workload Identity Federation：OIDC 交换缓存、RBAC 爆炸半径、CAE 吊销延迟**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2467-benchmark.json`

## 1) Executive Summary

本轮解决多租户 Agent 身份治理三难：频繁 token 交换开销、权限边界过宽、吊销生效慢。  
核心结论：**OIDC 交换缓存预算 + tenant 级 RBAC 最小域 + CAE 快速吊销路径** 必须协同设计。

## 2) Daily capability breakthroughs radar（2026-11-16 抓取）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2467-sources.json`）

## 3) 核心公式（交换缓存 / 权限域 / 吊销）

### Q1: OIDC 交换缓存容量

```text
cache_entries = active_workloads * tenants_per_workload * audiences
cache_memory_mb = cache_entries * avg_token_record_kb / 1024
```

要求 token cache hit rate `>= 90%` 才能避免认证链抖动。

### Q2: RBAC 爆炸半径估算

```text
blast_radius = affected_resources / total_resources_in_tenant_scope
```

生产目标：`blast_radius <= 0.1`（10% 以内）。

### Q3: CAE 吊销生效延迟

```text
cae_revoke_latency_sec = signal_propagation_sec + token_recheck_sec + policy_eval_sec
```

建议 `cae_revoke_p95_sec <= 120`。

## 4) Runnable snippets（Bicep / YAML / APIM policy / KQL）

### 4.1 Bicep（Federated Identity Credential）

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

### 4.2 YAML（AKS/ACA Workload Identity）

```yaml
metadata:
  annotations:
    azure.workload.identity/client-id: "<uami-client-id>"
spec:
  serviceAccountName: agent-sa
```

### 4.3 APIM policy（按租户 scope 强约束）

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

### 4.4 KQL（交换失败与吊销延迟）

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

## 5) 数据证据与可复算算例（含 n 分母来源）

样本总量 `n = 4410`（`evidence/cycle-2467-benchmark.json -> percentage_contract`）：

- `unfenced_entra_workload_identity_cae_rbac_guard_drift_rate = 534 / 4410 = 12.1%`
- `entra_workload_identity_cae_rbac_guard_variance_rate = 216 / 4410 = 4.9%`
- `entra_workload_identity_cae_rbac_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：`percentage = round((numerator / denominator) * 100, 1)`。

## 6) Decision matrix（身份治理策略）

| 策略 | 安全性 | 可用性 | 延迟 | 运维复杂度 | 推荐 |
|---|---:|---:|---:|---:|---|
| 静态密钥/长期凭证 | 低 | 高 | 低 | 低 | 不推荐 |
| Federation 无 CAE 细化 | 中 | 中 | 中 | 中 | 过渡 |
| Federation + tenant RBAC + CAE | **高** | **中高** | **中高** | 中高 | **生产推荐** |

## 7) Production failure-triage checklist

1. token 交换失败突增：检查 OIDC issuer/subject 绑定。  
2. `cae_revoke_p95_sec > 120`：核查策略传播链路与 token recheck。  
3. `blast_radius_p95 > 10%`：立即收缩 role scope。  
4. 跨租户误授权：按 tenant ring 拆分 identity domain。  
5. 缓存命中率低：增大 token cache 并优化 audience 复用。
