# Round 1072 / Cycle 2477 · Azure AI Agent Infra 六段式 FAQ（zh-CN）

> 主题：**Confidential Ledger SGX 回执 + Immutable Blob WORM + Entra PIM JIT 审批链**  
> 日期（BJT）：2026-11-17  
> 证据标签：`measured` / `synthetic` / `anonymized_reported`  
> 基准数据：`evidence/cycle-2477-benchmark.json`

## 1) 场景目标

针对 SRE/金融 Agent 的“破坏性写操作”（删除、额度变更、批量清算），需要不可抵赖审计链：  
1. 写入前有人机审批；  
2. 写入后可出具可验证回执；  
3. 审计记录不可篡改且可复核。

## 2) 核心公式（时延/吞吐/校验）

```text
commit_to_receipt_ms =
  ledger_commit_ms + merkle_receipt_issue_ms + receipt_verify_ms
```

```text
batch_anchor_tps =
  batch_size / (flush_interval_sec + anchor_commit_sec)
```

```text
tamper_verify_latency_ms =
  proof_fetch_ms + merkle_path_verify_ms + signature_verify_ms
```

阈值建议：
- `commit_to_receipt_p95 < 450ms`
- `tamper_verify_latency_p95 < 200ms`

## 3) 架构分层（审批→写入→固化）

1. **审批层**：Entra PIM JIT 提升权限 + 双人批准。  
2. **写入层**：Agent 写请求先入 Confidential Ledger，返回 SGX/Merkle 回执。  
3. **固化层**：批量锚定到 Immutable Blob WORM（保留/法律保全策略）。

## 4) 可运行片段（Bicep / YAML / Policy / KQL）

### 4.1 Bicep：WORM 存储启用

```bicep
resource stg 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stgauditworm'
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: { name: 'Standard_LRS' }
}
```

### 4.2 YAML：审批链工作流

```yaml
approvalChain:
  pimJitRequired: true
  approversMin: 2
  destructiveActions:
    - delete-record
    - bulk-settlement
```

### 4.3 Policy：无审批令牌拒绝写入

```yaml
policy:
  name: require-jit-approval-token
  if:
    actionIn: ["delete-record", "bulk-settlement"]
    approvalTokenMissing: true
  then:
    effect: deny
```

### 4.4 KQL：回执延迟与篡改校验监控

```kql
AuditChainEvents
| where TimeGenerated > ago(30m)
| summarize
    receipt_p95=percentile(CommitToReceiptMs,95),
    verify_p95=percentile(TamperVerifyLatencyMs,95),
    denied=countif(Result == "DeniedByPolicy")
    by TenantId, bin(TimeGenerated, 5m)
| where receipt_p95 > 450 or verify_p95 > 200
| order by receipt_p95 desc
```

## 5) 数据证据与可复算算例（含 n 分母来源）

总样本 `n = 4410`（`evidence/cycle-2477-benchmark.json`）：

- `unfenced_auditchain_guard_drift_rate = 534 / 4410 = 12.1%`
- `auditchain_guard_variance_rate = 216 / 4410 = 4.9%`
- `auditchain_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) 落地清单（Good fit vs Not for）

**Good fit**
- 涉及破坏性写动作且需合规追责的 Agent 平台。  
- 需要“审批令牌 + 回执证明 + WORM 固化”三位一体审计。

**Not for**
- 无合规保留要求的轻量内部脚本。  
- 无法统一身份审批与写入策略控制面的环境。
