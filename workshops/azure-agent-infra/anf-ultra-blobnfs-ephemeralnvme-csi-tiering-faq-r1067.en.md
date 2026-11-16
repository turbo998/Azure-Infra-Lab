# Round 1067 / Cycle 2472 · Azure AI Agent Infra FAQ & Decision Guide (en)

> Topic: **Azure NetApp Files Ultra vs Blob NFS v3 vs Ephemeral NVMe CSI storage tiering**  
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2472-benchmark.json`

## 1) Executive Summary

For stateful coding/research agent workspaces, one storage medium usually fails under burst concurrency through metadata IOPS saturation, POSIX lock contention, and long rollback windows.  
Result: **ANF Ultra (hot state) + Blob NFS v3 (warm/cold objectized workspace) + Ephemeral NVMe CSI (scratch)** gives the best p95 startup, throughput stability, and rollback RTO balance.

## 2) Daily hottest breakthroughs (fetched 2026-11-17)

1. APIM AI Gateway / Unified Model API (`measured`)  
   - https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. ACA Dynamic Sessions (`measured`)  
   - https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. Runtime/Sandbox upstream cadence (`measured`)  
   - Firecracker/Kata/Wasmtime/E2B releases (see `evidence/cycle-2472-sources.json`)

## 3) Sizing and latency formulas (reproducible)

### Q1: How to estimate small-file metadata IOPS?

```text
metadata_iops_required =
  (files_created_per_sec * op_per_create)
+ (files_listed_per_sec * op_per_list)
+ (files_deleted_per_sec * op_per_delete)
```

Use `op_per_create = 2..4` for inode + dir-entry + ACL/xattr and reserve 20% jitter headroom:

```text
metadata_iops_budget = metadata_iops_required * 1.2
```

### Q2: When does POSIX lock contention become the bottleneck?

```text
lock_wait_p95_ms ≈ (contended_locks_per_sec * avg_lock_hold_ms) / worker_count
```

Recommended thresholds:
- `lock_wait_p95_ms <= 35`: healthy
- `35 < lock_wait_p95_ms <= 80`: degradation warning (enable workspace sharding)
- `> 80`: congestion (trigger tenant-level throttling and isolation migration)

### Q3: Can snapshot-clone rollback stay sub-second?

```text
rollback_rto_ms =
  snapshot_mount_ms
+ delta_replay_ms
+ metadata_rebind_ms
```

Target: `rollback_rto_ms < 1000`; above this threshold enforce read-only degraded template.

## 4) Runnable snippets (Bicep / YAML / CSI / KQL)

### 4.1 Bicep: ANF Ultra capacity pool + volume

```bicep
resource anfAccount 'Microsoft.NetApp/netAppAccounts@2023-11-01' = {
  name: 'anf-agent-prod'
  location: resourceGroup().location
}

resource capacityPool 'Microsoft.NetApp/netAppAccounts/capacityPools@2023-11-01' = {
  name: '${anfAccount.name}/ultra-pool'
  properties: {
    serviceLevel: 'Ultra'
    size: 4398046511104 // 4 TiB
  }
}
```

### 4.2 YAML: three-tier mount contract

```yaml
workspaceTiers:
  hot:
    class: anf-ultra-rwx
    mountPath: /workspace/hot
  warm:
    class: blob-nfs-rwx
    mountPath: /workspace/warm
  scratch:
    class: nvme-ephemeral-rwo
    mountPath: /workspace/scratch
```

### 4.3 CSI: Ephemeral NVMe per-pod scratch

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: agent-worker
spec:
  volumes:
    - name: scratch
      ephemeral:
        volumeClaimTemplate:
          spec:
            accessModes: ["ReadWriteOnce"]
            storageClassName: nvme-ephemeral-rwo
            resources:
              requests:
                storage: 80Gi
```

### 4.4 KQL: lock contention + rollback RTO triage

```kql
AgentWorkspaceStorageLogs
| where TimeGenerated > ago(30m)
| summarize
    lock_wait_p95=percentile(LockWaitMs,95),
    metadata_iops_p95=percentile(MetadataIOPS,95),
    rollback_rto_p95=percentile(RollbackRtoMs,95)
    by TenantId, StorageTier
| where lock_wait_p95 > 80 or metadata_iops_p95 > 18000 or rollback_rto_p95 > 1000
| order by rollback_rto_p95 desc, lock_wait_p95 desc
```

## 5) Data evidence and reproducible math (with n denominator source)

Total sample `n = 4410` (from `evidence/cycle-2472-benchmark.json`):

- `unfenced_anf_blobnfs_nvme_tiering_guard_drift_rate = 534 / 4410 = 12.1%`
- `anf_blobnfs_nvme_tiering_guard_variance_rate = 216 / 4410 = 4.9%`
- `anf_blobnfs_nvme_tiering_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

Recompute:

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) Decision tree (Good fit vs Not for)

1. If workload is high-concurrency small-file + lock-heavy: prioritize ANF Ultra hot tier.  
2. If workload is low-frequency access + archival-friendly: prioritize Blob NFS v3 warm tier.  
3. If workload is short-lived scratch only: prioritize Ephemeral NVMe.  
4. For mixed multi-tenant traffic: combine all three and enforce tenant QoS boundaries.

**Good fit**
- Needs second/sub-second rollback recovery.
- Needs stable POSIX semantics with tenant isolation.

**Not for**
- Single-tenant stateless temporary tasks with no shared file semantics (object store + local disk is enough).
