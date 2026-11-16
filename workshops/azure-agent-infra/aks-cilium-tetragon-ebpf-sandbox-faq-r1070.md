# Round 1070 / Cycle 2475 · Azure AI Agent Infra 六段式 FAQ（zh-CN）

> 主题：**AKS Cilium eBPF Overlay + Tetragon 内核级 syscall 沙箱治理**  
> 日期（BJT）：2026-11-17  
> 证据标签：`measured` / `synthetic` / `anonymized_reported`  
> 基准数据：`evidence/cycle-2475-benchmark.json`

## 1) 场景目标

多租户 MCP/tool 执行 Pod 的核心风险：跨租户网络越权、容器逃逸、异常系统调用风暴。  
目标是将网络面与内核面联动治理：Cilium eBPF CNI 提供 L3/L7 隔离，Tetragon 提供 syscall 级实时阻断。

## 2) 核心公式（容量/时延/竞态）

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

生产阈值建议：
- `dns_race_prob < 0.02`
- `map_memory_utilization < 0.75`
- `enforcement_latency_ms p95 < 1.0`

## 3) 策略分层（CNI + syscall）

1. CiliumNetworkPolicy：默认拒绝，显式允许 MCP 必需出口域名/端口。  
2. Tetragon TracingPolicy：对高危 syscall（`unshare`, `mount`, `ptrace`）执行阻断。  
3. 运行时处置：命中高危规则时亚毫秒 `SIGKILL` 并打审计事件。

## 4) 可运行片段（Bicep / CiliumNetworkPolicy / Tetragon / KQL）

### 4.1 Bicep：AKS 网络策略启用

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

### 4.2 CiliumNetworkPolicy：最小出口白名单

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

### 4.3 Tetragon TracingPolicy：高危 syscall 阻断

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

### 4.4 KQL：阻断时延与异常突刺

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

## 5) 数据证据与可复算算例（含 n 分母来源）

总样本 `n = 4410`（`evidence/cycle-2475-benchmark.json`）：

- `unfenced_cilium_tetragon_guard_drift_rate = 534 / 4410 = 12.1%`
- `cilium_tetragon_guard_variance_rate = 216 / 4410 = 4.9%`
- `cilium_tetragon_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) 落地清单（Good fit vs Not for）

**Good fit**
- 多租户工具执行 Pod、需严格网络与 syscall 双隔离。  
- 需要容器逃逸可追踪、可阻断、可审计闭环。

**Not for**
- 单租户低风险批处理环境。  
- 无内核级可观测与策略执行能力的运行平面。
