# Round 1070 / Cycle 2475 · Azure AI Agent Infra Six-Section FAQ (en)

> Topic: **AKS Cilium eBPF Overlay + Tetragon kernel-level syscall sandboxing**  
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2475-benchmark.json`

## 1) Scenario objective

Core risks in multi-tenant MCP/tool execution pods are network overreach, container escape, and syscall storm amplification.  
Objective: combine Cilium eBPF CNI isolation (L3/L7) with Tetragon syscall-level real-time blocking.

## 2) Core formulas (capacity / latency / race)

```text
dns_race_prob ≈ (cache_ttl_miss_qps * upstream_dns_latency_ms) / 1000
```

```text
ebpf_map_mem_bytes ≈ entries * (key_size + value_size + per_entry_overhead)
ring_buffer_mem_bytes ≈ event_rate_per_sec * avg_event_size * retention_seconds
```

```text
enforcement_latency_ms =
  detect_syscall_ms + policy_match_ms + kill_signal_dispatch_ms
```

Recommended thresholds:
- `dns_race_prob < 0.02`
- `map_memory_utilization < 0.75`
- `enforcement_latency_ms p95 < 1.0`

## 3) Control layering (CNI + syscall)

1. CiliumNetworkPolicy: default deny + explicit MCP-required FQDN/port allowlist.  
2. Tetragon TracingPolicy: block high-risk syscalls (`unshare`, `mount`, `ptrace`).  
3. Runtime action: sub-millisecond `SIGKILL` + immutable audit event on critical hits.

## 4) Runnable snippets (Bicep / CiliumNetworkPolicy / Tetragon / KQL)

### 4.1 Bicep: AKS with Cilium policy plane

```bicep
resource aks 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: 'aks-agent-secure'
  location: resourceGroup().location
  properties: {
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'cilium'
    }
  }
}
```

### 4.2 CiliumNetworkPolicy: minimal egress allowlist

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: mcp-egress-allowlist
spec:
  endpointSelector:
    matchLabels:
      app: tool-exec
  egress:
    - toFQDNs:
        - matchName: api.github.com
        - matchName: login.microsoftonline.com
```

### 4.3 Tetragon TracingPolicy: escape syscall kill

```yaml
apiVersion: cilium.io/v1alpha1
kind: TracingPolicy
metadata:
  name: deny-escape-syscalls
spec:
  kprobes:
    - call: "sys_unshare"
      syscall: true
      selectors:
        - matchActions:
            - action: Sigkill
```

### 4.4 KQL: enforcement latency and burst triage

```kql
TetragonEvents
| where TimeGenerated > ago(30m)
| summarize
    kill_p95=percentile(EnforcementLatencyMs,95),
    kill_count=countif(Action == "Sigkill"),
    dns_race=avg(DnsRaceProbability)
    by TenantId, bin(TimeGenerated, 5m)
| where kill_p95 > 1.0 or dns_race > 0.02
| order by kill_p95 desc
```

## 5) Data evidence and recomputable math (with n denominator source)

Total sample `n = 4410` (`evidence/cycle-2475-benchmark.json`):

- `unfenced_cilium_tetragon_guard_drift_rate = 534 / 4410 = 12.1%`
- `cilium_tetragon_guard_variance_rate = 216 / 4410 = 4.9%`
- `cilium_tetragon_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute contract:

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) Rollout checklist (Good fit vs Not for)

**Good fit**
- Multi-tenant tool-execution pods requiring strict network + syscall isolation.  
- Need traceable, enforceable, auditable container-escape control loops.

**Not for**
- Single-tenant low-risk batch environments.  
- Runtime planes without kernel-level observability and enforcement hooks.
