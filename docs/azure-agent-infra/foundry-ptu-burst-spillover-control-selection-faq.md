# Foundry PTU Burst 溢出控制选型 FAQ（Cycle 1774）

## 1) 3 分钟结论
- **PTU 体系的稳定性关键不在平均负载，而在突发峰值时的溢出控制路径。**
- **推荐：** 主 PTU 车道 + 溢出缓冲车道 + 成本阈值闸门三段联动。
- **目标：** 在高峰保持关键任务可达，同时避免突发流量把总成本拉爆。

## 2) 关键问题（Q1/Q2/Q3）
### Q1：为什么 PTU 仍会在峰值“看似有配额却超时”？
1) 峰值到达速率超过调度收敛速度；
2) 瞬时重试放大同一时窗负载；
3) 无溢出优先级策略导致关键请求被挤压。

### Q2：溢出控制最小架构是什么？
- 主 PTU：承载稳定基线请求；
- Burst Spillover：承接短时峰值并可限流；
- 成本闸门：超阈值时自动降级非关键链路。

### Q3：如何验证溢出控制有效？
- 高峰回放下关键任务成功率提升；
- 溢出时延在预算内；
- 成本曲线不再随峰值线性失控。

## 3) 架构图
```mermaid
flowchart LR
  Q[Incoming Requests] --> C[PTU Classifier]
  C --> P[Primary PTU Lane]
  C --> B[Burst Spillover Lane]
  B --> G[Cost Guardrail Gate]
  P --> O[Observability]
  B --> O
  G --> L[Spillover Decision Ledger]
```

## 4) 选型矩阵
| 维度 | 单 PTU 车道 | PTU + Spillover + 成本闸门（推荐） |
|---|---:|---:|
| 峰值稳定性 | 低 | 高 |
| 关键任务保障 | 中 | 高 |
| 成本可控性 | 低 | 高 |
| 运维复杂度 | 低 | 中 |
| 故障可解释性 | 中 | 高 |

## 5) 证据与复算口径
- 证据文件：
  - `workshops/azure-agent-infra/evidence/cycle-1774-benchmark.json`
  - `workshops/azure-agent-infra/evidence/cycle-1774-latency.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1774-throughput.csv`
  - `workshops/azure-agent-infra/evidence/cycle-1774-cost.csv`
- 标签：`measured / synthetic / anonymized_reported`。
- validation7：双语结构、CSP、证据一致、可复放链路全部通过。

## 6) 生产检查清单
- [ ] 主 PTU 与溢出车道切换阈值明确。
- [ ] 溢出请求优先级策略可配置。
- [ ] 成本闸门触发后有降级回滚路径。
- [ ] 溢出决策与结果进入审计账本。
- [ ] FAQ/H5/SVG/7-card 与 evidence 轮次一致。
