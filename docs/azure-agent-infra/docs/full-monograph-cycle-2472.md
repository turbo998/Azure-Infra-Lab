# Cycle #2472 核心工程专著：ANF/Blob NFS/NVMe 分层存储（zh-CN）

- Round/Cycle: `1067 / 2472`
- Topic: `anf-ultra-blobnfs-ephemeralnvme-csi-tiering-faq-r1067`
- 时间窗口（BJT）：`2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) 生产分层原则

1. **热层（ANF Ultra）**：承担高并发写入、锁密集元数据、checkpoint 提交。  
2. **温层（Blob NFS v3）**：承担低频读写与归档态共享。  
3. **瞬时层（Ephemeral NVMe CSI）**：承担编译缓存、临时向量中间文件、短生命周期 scratch。

## 2) 可复算容量与阈值

```text
metadata_iops_budget =
 ((create_qps*op_create)+(list_qps*op_list)+(delete_qps*op_delete)) * 1.2

lock_wait_p95_ms ≈ (contended_locks_per_sec * avg_lock_hold_ms) / worker_count

rollback_rto_ms = snapshot_mount_ms + delta_replay_ms + metadata_rebind_ms
```

建议阈值：
- `metadata_iops_p95 <= 18000`
- `lock_wait_p95_ms <= 80`
- `rollback_rto_p95_ms <= 1000`

## 3) Runnable snippets（Bicep / YAML / CSI / KQL）

### Bicep（ANF Ultra）

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

### YAML（三层挂载）

```yaml
workspaceTiers:
  hot:    { class: anf-ultra-rwx, mountPath: /workspace/hot }
  warm:   { class: blob-nfs-rwx, mountPath: /workspace/warm }
  scratch:{ class: nvme-ephemeral-rwo, mountPath: /workspace/scratch }
```

### CSI（Ephemeral NVMe）

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

### KQL（锁竞争 + RTO 告警）

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

## 4) 故障处置 Runbook（核心）

1. `lock_wait_p95 > 80`：先按 tenant/workspace 分片，再降级 warm 层写并启用 hot-only checkpoint。  
2. `metadata_iops_p95 > 18000`：提高 hot 层配额并迁移高 churn 目录到 NVMe scratch。  
3. `rollback_rto_p95 > 1000`：切换只读模板 + 触发 snapshot clone 快速回滚。

## 5) 结论

三层分工并非“可选优化”，而是多租户状态化 Agent 生产系统的**稳定性基线**。若只保留单层存储，通常会在并发突刺阶段同时损失延迟、吞吐和恢复时间目标。
