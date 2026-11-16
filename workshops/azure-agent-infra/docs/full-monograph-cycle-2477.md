# Cycle #2477 核心工程专著：Confidential Ledger + WORM 审计证明链（zh-CN）

- Round/Cycle: `1072 / 2477`
- Topic: `confidential-ledger-worm-pim-jit-auditchain-faq-r1072`
- 时间窗口（BJT）：`2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) 控制目标

破坏性写操作必须满足：审批可追踪、回执可验证、证据不可篡改。

## 2) 关键公式

```text
commit_to_receipt_ms = ledger_commit + receipt_issue + receipt_verify
batch_anchor_tps = batch_size / (flush_interval + anchor_commit)
tamper_verify_latency_ms = proof_fetch + merkle_verify + signature_verify
```

阈值：
- `commit_to_receipt_p95 < 450ms`
- `tamper_verify_p95 < 200ms`

## 3) Runnable snippets（Bicep / YAML / Policy / KQL）

### Bicep

```bicep
resource stg 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'stgauditworm'
}
```

### YAML

```yaml
approvalChain:
  pimJitRequired: true
  approversMin: 2
```

### Policy

```yaml
policy:
  if: { actionIn: ["delete-record","bulk-settlement"], approvalTokenMissing: true }
  then: { effect: deny }
```

### KQL

```kql
AuditChainEvents
| where TimeGenerated > ago(30m)
| summarize receipt_p95=percentile(CommitToReceiptMs,95), verify_p95=percentile(TamperVerifyLatencyMs,95) by TenantId, bin(TimeGenerated, 5m)
| where receipt_p95 > 450 or verify_p95 > 200
```

## 4) 处置流程

1. 无审批令牌：直接拒绝写入。  
2. 回执超时：降级为只读并触发人工复核。  
3. 锚定失败：暂停批量写，优先修复证明链。

## 5) 结论

“审批→回执→WORM 固化”必须闭环，不可拆分，否则审计链会在关键写操作路径上出现不可追责断点。
