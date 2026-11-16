# Round 1058 / Cycle 2463 · Azure AI Agent Infra FAQ & 决策指南（zh-CN）

> Topic: **Azure Confidential Containers (SEV-SNP) 远程证明 + Managed HSM SKR：主权多方 Clean-room Agent**
>
> Date (BJT): 2026-11-17  
> Evidence labels: `measured` / `synthetic` / `anonymized_reported`  
> Benchmark payload: `evidence/cycle-2463-benchmark.json`

## 1) Executive Summary

本轮面向高合规多方协作场景：在不互信主体之间运行 Agent，既要机密执行又要可审计密钥释放。  
核心结论：**SEV-SNP 证明链 + SKR 策略绑定 + clean-room 网络分区** 是落地主权协作 Agent 的三要素。

## 2) Daily capability breakthroughs radar（2026-11-16 抓取）

1. **APIM AI Gateway / Unified Model API**（`measured`）  
   - Learn: https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
   - Changelog: https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md
2. **ACA Dynamic Sessions**（`measured`）  
   - Docs: https://learn.microsoft.com/en-us/azure/container-apps/sessions
3. **Sandbox/runtime releases**（`measured`）  
   - Firecracker/Kata/Wasmtime/E2B（见 `evidence/cycle-2463-sources.json`）

## 3) 核心公式（证明 / 延迟 / 容量）

### Q1: 证明门禁延迟预算

```text
attestation_gate_ms = quote_gen_ms + verifier_eval_ms + policy_eval_ms + skr_release_ms
```

建议生产目标：`attestation_gate_p95_ms <= 900`。

### Q2: 机密节点容量估算

```text
required_nodes = ceil(concurrent_sessions / sessions_per_confidential_node)
effective_util = workload_cpu_ms / node_available_cpu_ms
```

保持 `effective_util <= 0.7` 以降低证明高峰抖动。

### Q3: SKR 拒绝率阈值

`skr_deny_rate = denied_skr_requests / total_skr_requests`

- `skr_deny_rate <= 0.5%` 常态  
- `> 2%` 触发策略回滚与证明链审计

## 4) Runnable snippets（Bicep / YAML / Policy / KQL）

### 4.1 Bicep（机密容器组）

```bicep
resource cg 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'cc-agent-cleanroom'
  location: resourceGroup().location
  properties: {
    sku: 'Confidential'
    containers: [
      {
        name: 'agent'
        properties: {
          image: 'myacr.azurecr.io/agent-cleanroom:1.0.0'
          resources: { requests: { cpu: 4, memoryInGB: 16 } }
        }
      }
    ]
  }
}
```

### 4.2 YAML（attestation sidecar + SKR）

```yaml
containers:
  - name: agent-runtime
    image: myacr.azurecr.io/agent-cleanroom:1.0.0
  - name: attestation-proxy
    image: myacr.azurecr.io/attest-proxy:0.4.2
    env:
      - name: SKR_ENDPOINT
        value: https://mhsm-prod.managedhsm.azure.net
```

### 4.3 Policy JSON（SKR 仅放行已证明工作负载）

```json
{
  "if": {
    "allOf": [
      { "field": "attestation.svn", "less": 6 },
      { "field": "attestation.measurement", "notIn": "[parameters('approvedMeasurements')]" }
    ]
  },
  "then": { "effect": "deny" }
}
```

### 4.4 KQL（证明与 SKR 拒绝排障）

```kql
CleanroomAudit
| where TimeGenerated > ago(30m)
| summarize attest_p95=percentile(AttestationGateMs,95),
            skr_deny=countif(SkrDecision=="Deny"),
            skr_total=count(),
            token_p95=percentile(TokenLatencyMs,95)
            by TenantRing, Workload
| extend skr_deny_rate = todouble(skr_deny) / skr_total
| where attest_p95 > 900 or skr_deny_rate > 0.02
| order by skr_deny_rate desc, attest_p95 desc
```

## 5) 数据证据与可复算算例（含 n 分母来源）

样本总量 `n = 4410`（`evidence/cycle-2463-benchmark.json -> percentage_contract`）：

- `unfenced_confidential_attestation_skr_cleanroom_guard_drift_rate = 534 / 4410 = 12.1%`
- `confidential_attestation_skr_cleanroom_guard_variance_rate = 216 / 4410 = 4.9%`
- `confidential_attestation_skr_cleanroom_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算：`percentage = round((numerator / denominator) * 100, 1)`。

## 6) Decision matrix（主权协作方案）

| 方案 | 机密性 | 可审计性 | 性能 | 运维复杂度 | 推荐 |
|---|---:|---:|---:|---:|---|
| 普通容器 + 静态密钥 | 低 | 低 | 高 | 低 | 禁用于高合规 |
| 机密容器无 SKR | 中 | 中 | 中 | 中 | 过渡方案 |
| SEV-SNP + SKR + Clean-room Policy | **高** | **高** | 中高 | 高 | **生产推荐** |

## 7) Production failure-triage checklist

1. `attestation_gate_p95_ms > 900`：检查 quote 生成与 verifier 负载。  
2. `skr_deny_rate > 2%`：回看 measurement 白名单与 SVN 策略。  
3. token 延迟上升且证明正常：排查 clean-room 出口策略。  
4. 多租户冲突：按 tenant ring 分离 HSM key hierarchy。  
5. 证据链缺失：强制中止会话并触发合规工单。
