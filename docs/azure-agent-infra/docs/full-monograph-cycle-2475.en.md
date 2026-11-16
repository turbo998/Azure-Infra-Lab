# Cycle #2475 Core Engineering Monograph: Cilium + Tetragon Multi-Tenant Kernel Sandbox (en)

- Round/Cycle: `1070 / 2475`
- Topic: `aks-cilium-tetragon-ebpf-sandbox-faq-r1070`
- Window (BJT): `2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) Engineering objective

Establish a closed loop for MCP/tool execution pods: network isolation + syscall blocking + auditable replay, minimizing escape and lateral movement windows.

## 2) Core formulas

```text
dns_race_prob ≈ (cache_ttl_miss_qps * upstream_dns_latency_ms) / 1000
ebpf_map_mem_bytes ≈ entries * (key+value+overhead)
ring_buffer_mem_bytes ≈ event_rate_per_sec * avg_event_size * retention_seconds
enforcement_latency_ms = detect + match + dispatch
```

Thresholds:
- `dns_race_prob < 0.02`
- `map_memory_utilization < 0.75`
- `enforcement_latency_p95_ms < 1.0`

## 3) Runnable snippets (Bicep / CiliumNetworkPolicy / Tetragon / KQL)

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

## 4) Triage flow

1. On high-risk syscall hit, execute immediate `SIGKILL`.  
2. Isolate affected pod + tenant context and freeze outbound policy.  
3. Replay network and eBPF event lineage; progressively unfreeze after verification.

## 5) Conclusion

Network-only controls cannot stop kernel-level escapes; syscall-only controls cannot prevent lateral communications. Cilium + Tetragon is the required joint baseline for multi-tenant agent tool execution.
