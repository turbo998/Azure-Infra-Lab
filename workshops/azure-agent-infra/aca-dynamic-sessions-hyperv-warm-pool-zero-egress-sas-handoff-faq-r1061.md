# Round 1061 / Cycle 2466 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **ACA Dynamic Sessions Hyper-V 沙箱池容量：readySessionInstances 补池与突发耗尽、零外联隔离、SAS 交付**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2466-benchmark.json`

## 1) Executive Summary

本轮聚焦 ACA Dynamic Sessions 在生产突发中的“补池速度 vs 耗尽速度”矛盾，并覆盖零外联与工件交付。  
核心结论：**readySessionInstances 动态补池公式 + burst 护栏 + 用户委托 SAS 受控交付** 是可落地基线。

## 2) Daily capability breakthroughs radar（2026-11-16 抓取）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2466-sources.json`）

## 3) 核心公式（补池 / 突发 / 交付）

### Q1: warm pool 补池平衡

```text
ready_target = ceil(burst_qps * session_hold_sec / sessions_per_instance)
replenish_rate = max(0, ready_target - readySessionInstances) / replenish_window_sec
```

要求 `readySessionInstances >= ready_target` 的时间占比 > 95%。

### Q2: 突发耗尽阈值

```text
exhaustion_risk = max(0, incoming_sessions - readySessionInstances) / incoming_sessions
```

`exhaustion_risk > 0.2` 连续 2 窗口即触发扩容/降级。

### Q3: SAS 安全交付窗口

```text
sas_ttl_sec = upload_latency_p95_sec + validation_sec + retrieval_buffer_sec
```

建议 `sas_ttl_sec <= 900`，最小权限 + 单用途。

## 4) Runnable snippets（Bicep / YAML / policy / KQL）

### 4.1 Bicep（Session Pool）

```bicep
resource sess 'Microsoft.App/sessionPools@2024-08-02-preview' = {
  name: 'aca-ds-agent'
  location: resourceGroup().location
  properties: {
    poolManagementType: 'Dynamic'
    scaleConfiguration: {
      maxConcurrentSessions: 2000
      readySessionInstances: 120
    }
  }
}
```

### 4.2 YAML（零外联 + SAS 交付）

```yaml
network:
  egressMode: deny-all
  allowedPrivateEndpoints:
    - blob-private-endpoint
artifactHandoff:
  mode: user-delegation-sas
  maxTtlSeconds: 900
```

### 4.3 Policy JSON（SAS 最小权限）

```json
{
  "if": {
    "anyOf": [
      { "field": "sas.permissions", "contains": "d" },
      { "field": "sas.expirySeconds", "greater": 900 }
    ]
  },
  "then": { "effect": "deny" }
}
```

### 4.4 KQL（补池与耗尽排障）

```kql
DynamicSessionPoolLogs
| where TimeGenerated > ago(30m)
| summarize ready_p95=percentile(ReadyInstances,95),
            incoming_p95=percentile(IncomingSessions,95),
            exhaust_events=countif(Event=="PoolExhausted"),
            sas_deny=countif(Event=="SasPolicyDeny")
            by PoolName, TenantRing
| extend exhaustion_risk = iif(incoming_p95==0, 0.0, max_of(0.0, (incoming_p95-ready_p95)/incoming_p95))
| where exhaustion_risk > 0.2 or exhaust_events > 0
| order by exhaustion_risk desc, exhaust_events desc
```

## 5) 数据证据与可复算算例（含 n 分母来源）

样本总量 `n = 4410`（`evidence/cycle-2466-benchmark.json -> percentage_contract`）：

- `unfenced_aca_dynamic_sessions_warm_pool_guard_drift_rate = 534 / 4410 = 12.1%`
- `aca_dynamic_sessions_warm_pool_guard_variance_rate = 216 / 4410 = 4.9%`
- `aca_dynamic_sessions_warm_pool_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：`percentage = round((numerator / denominator) * 100, 1)`。

## 6) Decision matrix（Session 池策略）

| 策略 | 可用性 | 成本 | 安全性 | 运维复杂度 | 推荐 |
|---|---:|---:|---:|---:|---|
| 无 warm pool | 低 | 高 | 中 | 低 | 不推荐 |
| 固定 warm pool | 中 | 中 | 中 | 中 | 中等流量 |
| 动态 warm pool + zero-egress + SAS policy | **高** | **中高** | **高** | 中高 | **生产推荐** |

## 7) Production failure-triage checklist

1. `exhaustion_risk > 0.2`：提高 ready target 并缩短 replenish window。  
2. `exhaust_events` 突增：启动 burst 降级与队列背压。  
3. `sas_deny` 异常：排查权限模板与 TTL 策略漂移。  
4. 零外联误拦截：核对私有终结点与 DNS。  
5. 跨租户泄漏风险：按 tenant ring 拆池并独立密钥域。
