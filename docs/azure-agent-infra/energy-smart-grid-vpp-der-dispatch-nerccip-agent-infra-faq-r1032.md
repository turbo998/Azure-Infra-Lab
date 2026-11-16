# 能源智能电网 DER 调度、VPP 与 NERC-CIP Agent 基础设施 FAQ（Cycle 2437）

## 1) 执行摘要
本轮面向公用事业级可再生能源调度：以天气/辐照概率预测驱动 VPP 出价与 DER 调度，并通过 AC-OPF 物理约束闸门和 NERC-CIP ESP/DMZ 边界确保高影响动作不越界。

## 2) Q1 / Q2 / Q3
Q1：在云端运行 VPP Agent 时如何保证 NERC-CIP 边界不被破坏？  
A1：云端仅做 advisory，所有高影响执行必须经 ESP/DMZ 受控通道。  
Q2：概率天气预测与确定性电力物理约束如何耦合？  
A2：先输出候选调度，再由 AC-OPF 校验热稳定、电压与频率约束后执行。  
Q3：如何在 500k DER 扇出下保持可控时延？  
A3：分区扇出、队列回压、重试边界与 setpoint 校验联合控制。

## 3) 端到端流程（天气/PMU -> 预测 -> AC-OPF -> OpenADR 执行）
```mermaid
flowchart LR
    A[天气 + PMU + AMI 流] --> B[ADX 与 GPU 预测]
    B --> C[VPP 出价与调度规划]
    C --> D[Pandapower AC-OPF 物理闸门]
    D --> E[OpenADR/DMZ 设定值下发]
    E --> F[审计回放与合规控制]
```

## 4) 决策矩阵：云 VPP advisory+DMZ vs 边缘微电网 vs 传统 SCADA 规则栈
| 方案 | 弃风弃光控制 | 合规姿态 | 调度扩展性 | 运维复杂度 | 适配场景 |
|---|---:|---:|---:|---:|---|
| 云 VPP advisory + DMZ | 高 | 最高 | 最高 | 高 | 公用事业级 DER 车队 |
| 变电站边缘微电网 | 中高 | 高 | 中 | 中高 | 局部韧性岛 |
| 传统 SCADA 规则栈 | 中 | 中 | 中 | 低 | 保守增量改造 |

## 5) 智能电网上线清单（含当日热点）
- 对 NERC-CIP 边界严格执行“云 advisory、受控执行”原则。  
- AC-OPF 热/压/频约束校验必须前置且不可跳过。  
- 500k DER 扇出采用分区通道与回压重试治理。  
- 弃电、出价与抢修恢复结果必须具备可回放证据链。

## 6) Good fit vs Not for 与百分比合约绑定
Good fit：需要在严格合规边界内实现大规模 DER 优化调度的电网运营方。  
Not for：为追求速度而绕过物理约束或 CIP 边界的架构。

百分比合约绑定：
- `percentage_contract.renewable_curtailment_reduction_rate`
- `percentage_contract.acopf_thermal_voltage_violation_block_rate`
- `percentage_contract.openadr_dispatch_sla_rate`
- `percentage_contract.per_der_month_tco_reduction_rate`

以上键绑定 `cycle-2437-benchmark.json`，并标注 `production_validation=not_measured`。
