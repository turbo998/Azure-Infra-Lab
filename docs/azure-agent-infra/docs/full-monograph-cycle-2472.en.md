# Cycle #2472 Core Engineering Monograph: ANF/Blob NFS/NVMe Tiered Workspace Storage (en)

- Round/Cycle: `1067 / 2472`
- Topic: `anf-ultra-blobnfs-ephemeralnvme-csi-tiering-faq-r1067`
- Window (BJT): `2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) Production tiering principles

1. **Hot tier (ANF Ultra)** for high-concurrency writes, lock-heavy metadata, and checkpoint commits.  
2. **Warm tier (Blob NFS v3)** for lower-frequency shared reads/writes and archival-friendly workspace state.  
3. **Scratch tier (Ephemeral NVMe CSI)** for compile caches, transient vector intermediates, and short-lived temp files.

## 2) Recomputable sizing and thresholds

```text
metadata_iops_budget =
 ((create_qps*op_create)+(list_qps*op_list)+(delete_qps*op_delete)) * 1.2

lock_wait_p95_ms ≈ (contended_locks_per_sec * avg_lock_hold_ms) / worker_count

rollback_rto_ms = snapshot_mount_ms + delta_replay_ms + metadata_rebind_ms
```

Recommended thresholds:
- `metadata_iops_p95 <= 18000`
- `lock_wait_p95_ms <= 80`
- `rollback_rto_p95_ms <= 1000`

## 3) Runnable snippets (Bicep / YAML / CSI / KQL)

### Bicep (ANF Ultra)

```bicep
resource anfAccount 'Microsoft.NetApp/netAppAccounts@2023-11-01' = {
  name: 'anf-agent-prod'
  location: resourceGroup().location
}
resource ultraPool 'Microsoft.NetApp/netAppAccounts/capacityPools@2023-11-01' = {
  name: '${anfAccount.name}/ultra-pool'
  properties: { serviceLevel: 'Ultra', size: 4398046511104 }
}
```

### YAML (three-tier mounts)

```yaml
workspaceTiers:
  hot:    { class: anf-ultra-rwx, mountPath: /workspace/hot }
  warm:   { class: blob-nfs-rwx, mountPath: /workspace/warm }
  scratch:{ class: nvme-ephemeral-rwo, mountPath: /workspace/scratch }
```

### CSI (Ephemeral NVMe)

```yaml
volumes:
  - name: scratch
    ephemeral:
      volumeClaimTemplate:
        spec:
          storageClassName: nvme-ephemeral-rwo
          accessModes: ["ReadWriteOnce"]
          resources: { requests: { storage: 80Gi } }
```

### KQL (lock contention + rollback RTO alerts)

```kql
AgentWorkspaceStorageLogs
| where TimeGenerated > ago(30m)
| summarize lock_wait_p95=percentile(LockWaitMs,95),
            metadata_iops_p95=percentile(MetadataIOPS,95),
            rollback_rto_p95=percentile(RollbackRtoMs,95)
            by TenantId, StorageTier
| where lock_wait_p95 > 80 or metadata_iops_p95 > 18000 or rollback_rto_p95 > 1000
| order by rollback_rto_p95 desc
```

## 4) Failure triage runbook

1. `lock_wait_p95 > 80`: shard by tenant/workspace, then degrade warm-tier writes and force hot-only checkpoint mode.  
2. `metadata_iops_p95 > 18000`: increase hot-tier budget and move high-churn directories to NVMe scratch.  
3. `rollback_rto_p95 > 1000`: switch to read-only degraded template and trigger fast snapshot-clone rollback.

## 5) Conclusion

Tiered storage is not optional tuning for stateful multi-tenant agents; it is a **stability baseline**. Single-tier storage typically fails all three targets under burst traffic: latency, throughput, and recovery time.
