# Cycle #2474 核心工程专著：Foundry 评测门禁与 Shadow→Canary 发布（zh-CN）

- Round/Cycle: `1069 / 2474`
- Topic: `foundry-eval-cicd-shadow-canary-gate-faq-r1069`
- 时间窗口（BJT）：`2026-11-16 23:00 ~ 2026-11-17 05:15`

## 1) 控制目标

1. 进入生产前，候选版本需通过统计显著门禁。  
2. 上线采用 5%→25%→100% 渐进流量迁移。  
3. 任一阶段触发 SLO 破线时自动回滚。

## 2) 统计与阈值公式

```text
pass_at_k = passed / total
burn_regression = candidate_metric / baseline_metric
```

Wilson 下界（95%）：

```text
center = (phat + z^2/(2n)) / (1 + z^2/n)
half = z * sqrt((phat*(1-phat)+z^2/(4n))/n) / (1 + z^2/n)
lower_bound = center - half
```

建议：
- `lower_bound(pass@k) >= 0.90`
- `p95_latency_regression <= 1.20`
- `cost_per_req_regression <= 1.30`

## 3) Runnable snippets（Bicep / GitHub Actions / APIM Policy / KQL）

### Bicep

```bicep
resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: 'apim-agent-rollout'
  location: resourceGroup().location
}
```

### GitHub Actions

```yaml
name: foundry-eval-gate
on: [workflow_dispatch]
jobs:
  gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: python scripts/foundry_eval_gate.py --min-wilson-lb 0.90
```

### APIM Policy

```xml
<inbound>
  <base />
  <set-variable name="canaryPct" value="25" />
  <choose>
    <when condition="@(new System.Random().Next(0,100) < (int)context.Variables[\"canaryPct\"])">
      <set-header name="x-model-route" exists-action="override"><value>candidate</value></set-header>
    </when>
    <otherwise>
      <set-header name="x-model-route" exists-action="override"><value>stable</value></set-header>
    </otherwise>
  </choose>
</inbound>
```

### KQL

```kql
AgentRolloutMetrics
| where TimeGenerated > ago(30m)
| summarize err=avg(ErrorRate), p95=percentile(LatencyMs,95), cost=avg(CostPerRequestUsd) by RolloutStage, bin(TimeGenerated, 5m)
| where err > 0.015 or p95 > 1.2 * toscalar(AgentBaseline | summarize avg(BaselineP95Ms)) or cost > 1.3 * toscalar(AgentBaseline | summarize avg(BaselineCostPerReq))
```

## 4) 生产回滚流程

1. Shadow 阶段仅观测不切流。  
2. Canary 5% 与 25% 各自通过连续窗口健康检查。  
3. 破线即切回 stable 并冻结 candidate 发布。

## 5) 结论

评测门禁与渐进发布必须绑定执行。仅有离线评测没有在线回滚，仍会在生产引入不可控质量与成本抖动。
