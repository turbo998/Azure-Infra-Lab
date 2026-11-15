# 航空 IROPS 恢复、机组合法性与旅客改签 Agent 基础设施 FAQ（Round 1035 / Cycle 2440）

## 1) 执行摘要
本轮聚焦恶劣天气枢纽中断恢复：以实时飞行状态流 + 多 Agent 协同 + CP-SAT 确定性合法性校验 + 座位锁幂等提交 + 全渠道通知，构建分钟级可执行恢复能力。

## 2) Q1 / Q2 / Q3
Q1：为什么纯 LLM 规划难以胜任 IROPS 恢复？  
A1：机组值勤合法性、MEL、机位互斥和级联延误是组合优化问题，必须由确定性求解器校验。

Q2：如何在 50x 流量峰值下保持改签一致性？  
A2：使用 APIM 优先队列 + Cosmos 乐观并发座位锁幂等，保护上游 PSS/NDC 限流边界。

Q3：如何抑制枢纽延误级联放大？  
A3：构建实时中断级联图，并对机队/机组/旅客联合求解，执行前强制合法性闸门。

## 3) 端到端流程
```mermaid
flowchart LR
  A[天气/地停事件] --> B[Event Hubs + ADX 级联图]
  B --> C[机队/机组/旅客 Agents]
  C --> D[CP-SAT 合法性校验器]
  D --> E[PSS/NDC 座位提交 + Cosmos 锁]
  E --> F[ACS 全渠道改签通知]
```

## 4) 决策矩阵
| 方案 | 恢复速度 | 合法性保障 | 突发韧性 | 运维复杂度 | 适配场景 |
|---|---:|---:|---:|---:|---|
| 传统 OCC 串行人工恢复 | 低 | 中 | 低 | 中 | 小规模中断 |
| 纯 LLM 建议路径 | 中 | 低 | 中 | 低 | 仅分诊建议 |
| 混合 Agent + CP-SAT 联合恢复 | 高 | 最高 | 高 | 高 | 大规模枢纽 IROPS |

## 5) 航司 IROPS 生产清单
- ACARS/ADS-B/METAR/NOTAM 事件接入需可回放与可追溯。
- FAA Part 117 / EASA FTL / MEL / 机位互斥必须硬约束。
- Cosmos 座位锁采用乐观并发 + 幂等提交键。
- APIM 优先队列保护遗留 PSS/NDC 合作方限流。
- ACS 全渠道推送改签动作并提供回退通道。
- 持续监控合法性拦截率、突发完成率与看订比保护指标。

## 6) Good fit vs Not for 与百分比合约绑定
Good fit：需要“高突发+强合规”恢复能力的航司 OCC 场景。  
Not for：无法执行确定性合法性与库存一致性约束的建议型试点。

百分比合约键（绑定 `evidence/cycle-2440-benchmark.json`，并声明 `production_validation=not_measured`）：
- `percentage_contract.full_schedule_recovery_time_improvement_rate`
- `percentage_contract.crew_mel_compliance_rate`
- `percentage_contract.passenger_rebooking_burst_sla_rate`
- `percentage_contract.pss_ndc_look_to_book_protection_rate`
