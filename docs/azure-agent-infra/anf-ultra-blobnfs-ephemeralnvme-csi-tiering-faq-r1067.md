# Round 1067 / Cycle 2472 · Azure AI Agent Infra FAQ 与选型指南（zh-CN）

> 主题：**Azure NetApp Files Ultra vs Blob NFS v3 vs Ephemeral NVMe CSI 的分层存储策略**  
> 日期（BJT）：2026-11-17  
> 证据标签：`measured` / `synthetic` / `anonymized_reported`  
> 基准数据：`evidence/cycle-2472-benchmark.json`

## 1) Executive Summary

面向状态化 Coding/Research Agent 工作空间，单一存储介质会在峰值并发下触发三类问题：元数据 IOPS 饱和、POSIX 锁竞争放大、回滚恢复窗口过长。  
本轮结论：**ANF Ultra（热状态）+ Blob NFS v3（温/冷对象）+ Ephemeral NVMe CSI（瞬时 scratch）** 的三层分工，在 p95 启动时延、吞吐稳定性和回滚 RTO 之间最均衡。

## 2) 当日热点突破（抓取时间 2026-11-17）

1. APIM AI Gateway / Unified Model API（`measured`）  
   - https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. ACA Dynamic Sessions（`measured`）  
   - https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. Runtime/Sandbox 上游迭代（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B release（见 `evidence/cycle-2472-sources.json`）

## 3) 容量与时延公式（可复算）

### Q1：小文件元数据 IOPS 如何估算？

```text
metadata_iops_required =
  (files_created_per_sec * op_per_create)
+ (files_listed_per_sec * op_per_list)
+ (files_deleted_per_sec * op_per_delete)
```

其中 `op_per_create` 通常取 2~4（inode + dir entry + ACL/xattr），预留 20% 抖动余量：

```text
metadata_iops_budget = metadata_iops_required * 1.2
```

### Q2：POSIX 锁竞争何时会成为瓶颈？

```text
lock_wait_p95_ms ≈ (contended_locks_per_sec * avg_lock_hold_ms) / worker_count
```

生产阈值建议：
- `lock_wait_p95_ms <= 35`：健康
- `35 < lock_wait_p95_ms <= 80`：降级预警（启用工作目录分片）
- `> 80`：进入拥塞，触发 tenant 粒度限流与隔离迁移

### Q3：快照克隆回滚能否做到亚秒切换？

```text
rollback_rto_ms =
  snapshot_mount_ms
+ delta_replay_ms
+ metadata_rebind_ms
```

目标：`rollback_rto_ms < 1000`（子秒级回滚），若超阈值则强制切换到只读降级模板。

## 4) 可运行片段（Bicep / YAML / CSI / KQL）

### 4.1 Bicep：ANF Ultra 容量池 + 卷

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

### 4.2 YAML：三层挂载约定

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

### 4.3 CSI：Ephemeral NVMe（每 Pod 临时盘）

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

### 4.4 KQL：锁竞争与回滚 RTO 联合告警

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

## 5) 数据证据与可复算算例（含 n 分母来源）

总样本 `n = 4410`（见 `evidence/cycle-2472-benchmark.json`）：

- `unfenced_anf_blobnfs_nvme_tiering_guard_drift_rate = 534 / 4410 = 12.1%`
- `anf_blobnfs_nvme_tiering_guard_variance_rate = 216 / 4410 = 4.9%`
- `anf_blobnfs_nvme_tiering_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

统一复算：

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) 选型决策树（Good fit vs Not for）

1. 若工作负载以小文件高并发 + 高频锁为主：优先 ANF Ultra 热层。  
2. 若以低频读写与归档为主：优先 Blob NFS v3 温层。  
3. 若仅需短生命周期 scratch：优先 Ephemeral NVMe。  
4. 多租户混合负载：三层混合并强制 tenant QoS 隔离。

**Good fit**
- 需要秒级/亚秒级回滚恢复。
- 需要稳定 POSIX 语义与多租户隔离。

**Not for**
- 单租户、无状态、临时任务且无需共享文件语义的场景（可简化为对象存储 + 本地盘）。
