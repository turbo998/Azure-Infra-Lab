# Cycle #2473 核心工程专著：FOCUS 成本归因与 APIM Token 预算治理（zh-CN）

- Round/Cycle: `1068 / 2473`
- Topic: `finops-hub-adx-focus-apim-token-budget-faq-r1068`
- 时间窗口（BJT）：`2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) 控制目标

在多 BU Agent 平台中，实现三件事：
1. 会话级成本可归因（FOCUS 1.0 口径）。  
2. 预算超阈值时网关实时限流/降级。  
3. 异常燃烧（runaway loop）分钟级发现并自动回收。

## 2) 关键公式与阈值

```text
ptu_unit_cost_per_1k_tokens =
  (ptu_hourly_usd * active_hours) / (ptu_tokens_capacity / 1000)

effective_unit_cost_per_1k_tokens =
  ptu_tokens_used_ratio * ptu_unit_cost_per_1k_tokens
  + spillover_ratio * paygo_unit_cost_per_1k_tokens

session_cost_usd =
  (input_tokens/1000 * input_unit_cost)
  + (output_tokens/1000 * output_unit_cost)
  + gateway_overhead_usd
```

```text
burn_rate_x = cost_5m / baseline_cost_5m
```

阈值建议：
- `burn_rate_x >= 3` 连续 3 个窗口：强制模型降级。  
- `burn_rate_x >= 5`：进入熔断，阻断高成本工具链。

## 3) Runnable snippets（Bicep / APIM Policy / KQL）

### Bicep（网关成本标签）

```bicep
resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: 'apim-agent-finops'
  location: resourceGroup().location
  tags: { costCenter: 'BU-AI', focusProfile: 'focus-1.0' }
}
```

### APIM Policy（预算闸门 + 降级）

```xml
<inbound>
  <base />
  <set-variable name="tenantId" value="@(context.Request.Headers.GetValueOrDefault(\"x-tenant-id\",\"unknown\"))" />
  <rate-limit-by-key calls="180" renewal-period="60" counter-key="@(context.Variables[\"tenantId\"])" />
  <choose>
    <when condition="@(context.Request.Headers.GetValueOrDefault(\"x-budget-tier\",\"standard\") == \"restricted\")">
      <set-header name="x-model-route" exists-action="override"><value>gpt-4o-mini</value></set-header>
    </when>
  </choose>
</inbound>
```

### KQL（异常燃烧检测）

```kql
AgentCostLedger
| where TimeGenerated > ago(30m)
| summarize cost_5m=sum(CostUsd), tokens_5m=sum(TotalTokens) by TenantId, bin(TimeGenerated, 5m)
| join kind=leftouter (AgentCostBaseline | summarize baseline_5m=avg(CostUsd) by TenantId) on TenantId
| extend burn_rate_x = iif(baseline_5m == 0, 0.0, cost_5m / baseline_5m)
| where burn_rate_x >= 3 and tokens_5m > 100000
| order by burn_rate_x desc
```

## 4) 生产处置流程

1. 检测：KQL 连续窗口命中异常。  
2. 降级：APIM 切换低成本模型与更严限流。  
3. 复位：成本回归后逐步恢复标准路由，保留审计轨迹。

## 5) 结论

“账务可见 + 网关可控”必须同时存在，单做任一侧都会留下成本失控窗口。FOCUS 口径与 APIM 实时策略结合，是多租户 Agent 成本治理的最短闭环路径。
