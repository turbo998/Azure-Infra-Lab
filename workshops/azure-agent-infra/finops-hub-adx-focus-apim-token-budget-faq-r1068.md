# Round 1068 / Cycle 2473 · Azure AI Agent Infra 六段式 FAQ（zh-CN）

> 主题：**FinOps Hub ADX FOCUS 1.0 多 BU Agent 成本分摊 + APIM 实时 token 预算治理**  
> 日期（BJT）：2026-11-17  
> 证据标签：`measured` / `synthetic` / `anonymized_reported`  
> 基准数据：`evidence/cycle-2473-benchmark.json`

## 1) 问题定义：为什么要做“成本归因 + 实时预算闸门”？

多租户 Agent 体系常见失控点不是吞吐，而是**不可见的 token 燃烧**：  
- 按团队/BU 难以归因到会话级与模型级；  
- PTU 资源闲置与 PAYGO 溢出并存；  
- 异常循环（tool loop / retry storm）在分钟级放大成本。

本轮目标：以 FinOps Hub + ADX 落地 FOCUS 口径成本可观测，并在 APIM 层进行实时预算闸门与降级。

## 2) 核心公式：PTU 摊销 + PAYGO 溢出 + 单会话成本

```text
ptu_unit_cost_per_1k_tokens =
  (ptu_hourly_usd * active_hours) / (ptu_tokens_capacity / 1000)

spillover_unit_cost_per_1k_tokens = paygo_price_per_1k_tokens

effective_unit_cost_per_1k_tokens =
  (ptu_tokens_used_ratio * ptu_unit_cost_per_1k_tokens)
+ (spillover_ratio * spillover_unit_cost_per_1k_tokens)
```

```text
session_cost_usd =
  (input_tokens/1000 * effective_input_unit_cost)
+ (output_tokens/1000 * effective_output_unit_cost)
+ gateway_overhead_usd
```

```text
burn_rate_x =
  current_5m_cost_usd / baseline_5m_cost_usd
```

建议阈值：`burn_rate_x >= 3` 且持续 `>= 3` 个窗口触发降级策略。

## 3) 架构与分工：FOCUS 账务面 + APIM 控制面

1. **账务面**：FinOps Hub 落地 FOCUS 1.0 成本明细至 ADX（BU/产品线/租户/环境标签）。  
2. **控制面**：APIM AI Gateway 执行 token 预算、速率限制、策略降级。  
3. **闭环面**：ADX KQL 识别 runaway loop，反向下发策略档位（模型降级、温度收敛、工具并发上限）。

## 4) 可运行片段（Bicep / APIM Policy / KQL）

### 4.1 Bicep：成本洞察与网关标签一致化

```bicep
resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: 'apim-agent-finops'
  location: resourceGroup().location
  sku: { name: 'PremiumV2', capacity: 2 }
  tags: {
    costCenter: 'BU-AI'
    focusProfile: 'focus-1.0'
  }
}
```

### 4.2 APIM Policy：实时 token 预算 + 模型降级

```xml
<policies>
  <inbound>
    <base />
    <set-variable name="tenantId" value="@(context.Request.Headers.GetValueOrDefault(\"x-tenant-id\",\"unknown\"))" />
    <rate-limit-by-key calls="180" renewal-period="60" counter-key="@(context.Variables[\"tenantId\"])" />
    <choose>
      <when condition="@(context.Request.Headers.GetValueOrDefault(\"x-budget-tier\",\"standard\") == \"restricted\")">
        <set-header name="x-model-route" exists-action="override">
          <value>gpt-4o-mini</value>
        </set-header>
      </when>
    </choose>
  </inbound>
  <backend><base /></backend>
  <outbound><base /></outbound>
</policies>
```

### 4.3 KQL：runaway loop 成本燃烧探测

```kql
AgentCostLedger
| where TimeGenerated > ago(30m)
| summarize
    cost_5m = sum(CostUsd),
    tokens_5m = sum(TotalTokens)
    by TenantId, bin(TimeGenerated, 5m)
| join kind=leftouter (
    AgentCostBaseline
    | summarize baseline_5m = avg(CostUsd) by TenantId
) on TenantId
| extend burn_rate_x = iif(baseline_5m == 0, 0.0, cost_5m / baseline_5m)
| where burn_rate_x >= 3 and tokens_5m > 100000
| order by burn_rate_x desc
```

## 5) 数据证据与可复算算例（含 n 分母来源）

总样本 `n = 4410`（`evidence/cycle-2473-benchmark.json`）：

- `unfenced_finops_token_budget_guard_drift_rate = 534 / 4410 = 12.1%`
- `finops_token_budget_guard_variance_rate = 216 / 4410 = 4.9%`
- `finops_token_budget_guard_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算口径：

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) 落地清单（Good fit vs Not for）

**Good fit**
- 多 BU / 多租户 Agent 平台，需要模型调用成本归因到会话级。  
- 已采用 APIM 网关，能在入口执行预算闸门与模型路由。  
- 需要“发现异常 → 自动降级 → 成本回落”的分钟级闭环。

**Not for**
- 单团队、固定负载、预算弹性很高且无 chargeback 要求。  
- 无统一网关控制点，无法执行策略一致性。
