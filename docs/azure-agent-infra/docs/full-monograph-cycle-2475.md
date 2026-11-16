# Cycle #2475 核心工程专著：Cilium + Tetragon 多租户内核沙箱（zh-CN）

- Round/Cycle: `1070 / 2475`
- Topic: `aks-cilium-tetragon-ebpf-sandbox-faq-r1070`
- 时间窗口（BJT）：`2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) 工程目标

在 MCP/tool 执行 Pod 侧完成“网络隔离 + syscall 阻断 + 审计回放”三联闭环，压缩容器逃逸与横向移动窗口。

## 2) 关键公式

```text
dns_race_prob ≈ (cache_ttl_miss_qps * upstream_dns_latency_ms) / 1000
ebpf_map_mem_bytes ≈ entries * (key+value+overhead)
ring_buffer_mem_bytes ≈ event_rate_per_sec * avg_event_size * retention_seconds
enforcement_latency_ms = detect + match + dispatch
```

阈值：
- `dns_race_prob < 0.02`
- `map_memory_utilization < 0.75`
- `enforcement_latency_p95_ms < 1.0`

## 3) Runnable snippets（Bicep / CiliumNetworkPolicy / Tetragon / KQL）

### Bicep

```bicep
resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-agent-secure'
  properties: { networkProfile: { networkPolicy: 'cilium' } }
}
```

### CiliumNetworkPolicy

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata: { name: mcp-egress-allowlist }
spec:
  endpointSelector: { matchLabels: { app: tool-exec } }
  egress:
    - toFQDNs:
        - matchName: api.github.com
```

### Tetragon TracingPolicy

```yaml
apiVersion: cilium.io/v1alpha1
kind: TracingPolicy
metadata: { name: deny-escape-syscalls }
spec:
  kprobes:
    - call: "sys_unshare"
      syscall: true
      selectors:
        - matchActions: [{ action: Sigkill }]
```

### KQL

```kql
TetragonEvents
| where TimeGenerated > ago(30m)
| summarize kill_p95=percentile(EnforcementLatencyMs,95), dns_race=avg(DnsRaceProbability) by TenantId, bin(TimeGenerated, 5m)
| where kill_p95 > 1.0 or dns_race > 0.02
```

## 4) 处置流程

1. 发现高危 syscall 命中，立即 `SIGKILL`。  
2. 锁定命中 Pod 与租户上下文，冻结外连策略。  
3. 回放链路日志与 eBPF 事件，恢复后渐进解封。

## 5) 结论

仅做网络策略无法覆盖内核层逃逸；仅做 syscall 阻断无法限制横向通信。Cilium + Tetragon 的联合控制是多租户 Agent 工具执行面的必要基线。
