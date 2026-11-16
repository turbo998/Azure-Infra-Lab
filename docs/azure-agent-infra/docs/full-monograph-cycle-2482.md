# Cycle #2482 核心工程专著：Private Link Hub-Spoke Zero-Trust Egress（zh-CN）

- Round/Cycle: `1077 / 2482`
- Topic: `private-link-hubspoke-zero-trust-egress-faq-r1077`
- 时间窗口（BJT）：`2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) 目标

为 Foundry/AKS/ACA 混合面建立“私网访问 + 集中出口 + 分层策略”的零信任网络底座。

## 2) 关键公式

```text
required_ips = pods + node_overhead + reserves + surge
min_prefix = 32 - ceil(log2(required_ips))
required_snat_ports = concurrency * conn_per_session * retry_factor
failover_rto_seconds = detect + dns_ttl + switch + warmup
```

阈值：
- `ip_utilization_p95 < 0.85`
- `snat_utilization_p95 < 0.70`
- `failover_rto_p95 < 90s`

## 3) Runnable snippets（Bicep / YAML / Policy / KQL）

### Bicep

```bicep
resource firewall 'Microsoft.Network/azureFirewalls@2023-11-01' = {
  name: 'afw-agent-hub-premium'
  sku: { name: 'AZFW_VNet', tier: 'Premium' }
}
```

### YAML

```yaml
egressPolicy:
  defaultDeny: true
  maxSnatUtilization: 0.70
```

### Policy

```yaml
policy:
  if: { privateEndpointBypassDetected: true }
  then: { effect: deny }
```

### KQL

```kql
ZeroTrustEgressTelemetry
| where TimeGenerated > ago(30m)
| summarize ip_util_p95=percentile(SubnetIpUtilization,95), snat_p95=percentile(SnatUtilization,95), rto_p95=percentile(FailoverRtoSeconds,95) by TenantId, bin(TimeGenerated, 5m)
| where ip_util_p95 > 0.85 or snat_p95 > 0.7 or rto_p95 > 90
```

## 4) 处置流程

1. 子网利用率超阈值：限制新会话并扩容 CIDR。  
2. SNAT 饱和：限流 + 增配出口端口池。  
3. DNS 漂移：切换到回退解析链路并冻结发布。

## 5) 结论

零信任出口拓扑是 Agent 生产稳定性的底层约束：不先解决网络与解析一致性，模型层优化无法兑现 SLA。
