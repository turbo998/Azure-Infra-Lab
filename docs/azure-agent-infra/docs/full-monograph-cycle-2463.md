# Cycle #2463 核心工程专著：机密 Agent Clean-room（zh-CN）

- Round/Cycle: `1058 / 2463`
- Topic: `azure-confidential-containers-snp-attestation-mhsm-skr-cleanroom-faq-r1058`

## 1) 核心预算公式

```text
attestation_gate_ms = quote_gen_ms + verifier_eval_ms + policy_eval_ms + skr_release_ms
required_nodes = ceil(concurrent_sessions / sessions_per_confidential_node)
skr_deny_rate = denied_skr_requests / total_skr_requests
```

阈值：
- `attestation_gate_p95_ms <= 900`
- `skr_deny_rate <= 0.5%`（>2% 进入应急）

## 2) Runnable snippets

### Bicep（Confidential 容器）

```bicep
resource cg 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'cc-agent-cleanroom'
  properties: { sku: 'Confidential' }
}
```

### YAML（attestation sidecar）

```yaml
containers:
  - name: agent-runtime
  - name: attestation-proxy
    env:
      - name: SKR_ENDPOINT
        value: https://mhsm-prod.managedhsm.azure.net
```

### Policy JSON（SKR 放行策略）

```json
{
  "if": { "field": "attestation.svn", "less": 6 },
  "then": { "effect": "deny" }
}
```

### KQL（证明+SKR 排障）

```kql
CleanroomAudit
| where TimeGenerated > ago(30m)
| summarize attest_p95=percentile(AttestationGateMs,95), deny=countif(SkrDecision=="Deny"), total=count() by Workload
| extend deny_rate=todouble(deny)/total
| where attest_p95 > 900 or deny_rate > 0.02
```

## 3) 失效模式

1. 证明链超时导致会话雪崩。  
2. measurement 漂移触发 SKR 大量拒绝。  
3. clean-room 出口策略误配导致 token 延迟飙升。  
4. 多方 key hierarchy 混用引起隔离边界失效。

## 4) 落地清单

- 证明策略版本化 + 审批流程。  
- SKR 白名单与 SVN 升级同步。  
- clean-room 入口/出口显式策略。  
- ADX 审计日志不可篡改归档。
