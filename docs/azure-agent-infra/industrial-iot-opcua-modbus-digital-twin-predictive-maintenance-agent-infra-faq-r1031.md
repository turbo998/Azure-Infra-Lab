# 工业 IoT OPC UA/Modbus 数字孪生与预测性维护 Agent 基础设施 FAQ（Cycle 2436）

## 1) 执行摘要
本轮沉淀工业 IoT 生产架构：将 OPC UA 与 Modbus 信号归一化到数字孪生语义模型，预测性维护 Agent 输出可执行分诊建议，并通过 OT 安全闸门阻断不安全控制写路径进入 PLC 域。

## 2) Q1 / Q2 / Q3
Q1：如何同时接入 OPC UA 与 Modbus 且不丢失语义上下文？  
A1：先做协议归一化，再按数字孪生实体映射并执行序列补偿。  
Q2：如何避免 Agent 越权写入 PLC？  
A2：高风险写路径必须由策略引擎与人工审批托管，Agent 仅提供建议。  
Q3：如何避免工单风暴？  
A3：维护工单必须经过置信度阈值、冷却窗口与去重策略。

## 3) 端到端流程（OT 采集→孪生归一→预测评分→受控执行）
```mermaid
flowchart LR
    A[OPC UA 与 Modbus 遥测] --> B[协议归一化网关]
    B --> C[数字孪生状态图]
    C --> D[预测性维护 Agent]
    D --> E[工单队列与排程]
    E --> F[策略托管安全写闸门]
    F --> G[审计回放与 ROI 追踪]
```

## 4) 决策矩阵：规则栈 vs 混合孪生+Agent vs 纯云预测
| 方案 | 上下文保真 | 安全控制 | 扩展性 | 运维复杂度 | 适配场景 |
|---|---:|---:|---:|---:|---|
| 规则栈 | 中 | 高 | 中 | 低 | 保守短期改造 |
| 混合孪生+Agent | 高 | 最高 | 高 | 中高 | 生产级 OT 优化 |
| 纯云预测 | 中 | 中 | 高 | 中 | 非关键分析优先场景 |

## 5) 上线清单（含当日热点）
- 完成 OPC UA/Modbus 到孪生语义事件的统一映射。  
- 严格执行读写分离与高风险写审批闸门。  
- 工单流程必须启用冷却窗口与去重机制。  
- 追踪跨站点配方漂移并保留策略回放证据。  
- 当日热点（抓取日：2026-11-16，官方/Release 优先）：  
  - Azure IoT Operations 与 ADT 集成路径（`measured`）。  
  - ADX 工业高吞吐遥测分析能力（`measured` + `anonymized_reported`）。  
  - 预测维护与安全策略重放结果（`measured` + `synthetic`）。

## 6) Good fit vs Not for 与百分比合约绑定
Good fit：  
1. 需要严格安全控制与预测维护协同的多站点工厂。  
2. 需要对高影响动作保留可回放证据链的工业场景。

Not for：  
1. 允许 Agent 直接写入安全关键 PLC 逻辑的架构。  
2. 无置信度阈值与冷却机制的工单流程。

百分比合约绑定：
- `percentage_contract.unplanned_downtime_reduction_rate`
- `percentage_contract.safety_write_unauthorized_block_rate`
- `percentage_contract.predictive_maintenance_ticket_precision_rate`
- `percentage_contract.per_site_month_tco_reduction_hybrid_rate`

以上键绑定 `cycle-2436-benchmark.json`，并标注 `production_validation=not_measured`。
