# Round 1069 / Cycle 2474 · Azure AI Agent Infra 六段式 FAQ（zh-CN）

> 主题：**Foundry Evaluation CI/CD Gate + ACA/APIM Shadow→Canary 渐进发布**  
> 日期（BJT）：2026-11-17  
> 证据标签：`measured` / `synthetic` / `anonymized_reported`  
> 基准数据：`evidence/cycle-2474-benchmark.json`

## 1) 场景与目标

生产 Agent 的 prompt/tool 版本发布不能只看离线分数，必须同时满足在线 SLO：  
- 评测门禁：阻断低质量版本进入流量面；  
- 渐进发布：5%→25%→100% 逐级放量；  
- 自动回滚：任何阶段 SLO 破线即时撤回。

## 2) 统计与样本量公式（Wilson / Binomial / pass@k）

```text
pass_at_k = passed_cases / total_cases
```

Wilson 置信区间（95%）：

```text
z = 1.96
phat = x / n
center = (phat + z^2/(2n)) / (1 + z^2/n)
half = z * sqrt((phat*(1-phat) + z^2/(4n))/n) / (1 + z^2/n)
CI = [center-half, center+half]
```

样本量下界（近似）：

```text
n_min ≈ z^2 * p*(1-p) / e^2
```

其中 `e` 为容忍误差；门禁建议 `pass@k` 下界（Wilson lower bound）≥ 0.90。

## 3) 渐进发布闸门策略（5%→25%→100%）

1. **Shadow**：仅镜像流量，不影响用户返回。  
2. **Canary 5%**：观察错误率、p95、成本漂移。  
3. **Canary 25%**：通过后放大；若破线则回滚。  
4. **100%**：满足连续窗口稳定后全量切换。

SLO 破线回滚阈值示例：
- `error_rate > 1.5%` 或  
- `latency_p95_ms > baseline * 1.2` 或  
- `cost_per_req > baseline * 1.3`

## 4) 可运行片段（Bicep / GitHub Actions / APIM Policy / KQL）

### 4.1 Bicep：APIM + ACA 发布标记

```bicep
resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: 'apim-agent-rollout'
  location: resourceGroup().location
  sku: { name: 'PremiumV2', capacity: 2 }
}
```

### 4.2 GitHub Actions：Foundry Eval 门禁 + 渐进放量

```yaml
name: foundry-eval-gate
on: [workflow_dispatch]
jobs:
  evaluate-and-rollout:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run foundry eval gate
        run: python scripts/foundry_eval_gate.py --min-wilson-lb 0.90 --max-p95-regression 1.2
      - name: Shift traffic to 5%
        run: az apim api release create --api-id agent-api --notes "canary-5"
```

### 4.3 APIM Policy：灰度路由与失败回退

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

### 4.4 KQL：阶段性放量健康判定

```kql
AgentRolloutMetrics
| where TimeGenerated > ago(30m)
| summarize
    err=avg(ErrorRate),
    p95=percentile(LatencyMs,95),
    cost=avg(CostPerRequestUsd)
    by RolloutStage, bin(TimeGenerated, 5m)
| where err > 0.015 or p95 > 1.2 * toscalar(AgentBaseline | summarize avg(BaselineP95Ms)) or cost > 1.3 * toscalar(AgentBaseline | summarize avg(BaselineCostPerReq))
| order by TimeGenerated desc
```

## 5) 数据证据与可复算算例（含 n 分母来源）

总样本 `n = 4410`（`evidence/cycle-2474-benchmark.json`）：

- `unfenced_eval_canary_gate_drift_rate = 534 / 4410 = 12.1%`
- `eval_canary_gate_variance_rate = 216 / 4410 = 4.9%`
- `eval_canary_gate_recovery_gain_pts = 330 / 4410 = 7.5 pts`

复算公式：

```text
percentage = round((numerator / denominator) * 100, 1)
```

## 6) 落地清单（Good fit vs Not for）

**Good fit**
- 高频迭代 prompt/tool 的生产 Agent 平台。  
- 已具备 APIM 统一入口与可观测数据面。  
- 需要门禁统计显著性与自动回滚机制。

**Not for**
- 无线上流量、仅离线评测的实验环境。  
- 无法提供稳定 baseline 指标的系统。
