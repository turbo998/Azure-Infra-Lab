# Cycle #2466 核心工程专著：ACA Dynamic Sessions 容量与隔离（zh-CN）

- Round/Cycle: `1061 / 2466`
- Topic: `aca-dynamic-sessions-hyperv-warm-pool-zero-egress-sas-handoff-faq-r1061`

## 1) 关键公式

```text
ready_target = ceil(burst_qps * session_hold_sec / sessions_per_instance)
replenish_rate = max(0, ready_target - readySessionInstances) / replenish_window_sec
exhaustion_risk = max(0, incoming_sessions - readySessionInstances) / incoming_sessions
sas_ttl_sec = upload_latency_p95_sec + validation_sec + retrieval_buffer_sec
```

阈值：
- `exhaustion_risk <= 0.2`
- `sas_ttl_sec <= 900`

## 2) Runnable snippets

### Bicep（Session Pool）

```bicep
resource sess 'Microsoft.App/sessionPools@2024-08-02-preview' = {
  name: 'aca-ds-agent'
  properties: {
    scaleConfiguration: {
      readySessionInstances: 120
      maxConcurrentSessions: 2000
    }
  }
}
```

### YAML（零外联 + SAS）

```yaml
network: { egressMode: deny-all }
artifactHandoff: { mode: user-delegation-sas, maxTtlSeconds: 900 }
```

### Policy（SAS 最小权限）

```json
{
  "if": { "field": "sas.expirySeconds", "greater": 900 },
  "then": { "effect": "deny" }
}
```

### KQL（耗尽风险排障）

```kql
DynamicSessionPoolLogs
| where TimeGenerated > ago(30m)
| summarize ready_p95=percentile(ReadyInstances,95), incoming_p95=percentile(IncomingSessions,95) by PoolName
| extend exhaustion_risk=iif(incoming_p95==0,0.0,max_of(0.0,(incoming_p95-ready_p95)/incoming_p95))
| where exhaustion_risk > 0.2
```

## 3) 失效模式

1. warm pool 补池慢于突发流入。  
2. zero-egress 误配导致工件通路中断。  
3. SAS TTL 过长形成凭证风险。  
4. 跨租户共享池造成隔离边界不稳。

## 4) 落地清单

- readySessionInstances 动态调参闭环。  
- zero-egress 与私有终结点联调。  
- user delegation SAS 最小权限模板化。  
- tenant ring 级别独立池与审计仪表板。
