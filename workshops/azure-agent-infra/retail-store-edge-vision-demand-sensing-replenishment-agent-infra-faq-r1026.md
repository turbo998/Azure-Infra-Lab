# 零售全渠道需求感知与门店边缘运营 Agent 基础设施 FAQ（Cycle 2431）

## 1) 执行摘要
本轮聚焦 5,000 门店规模的全渠道零售运营：门店边缘通过 Arc + IoT Operations 承载货架视觉识别与断网续跑，云端 Fabric Eventstreams 聚合 POS/电商/天气与活动信号，需求感知 Agent 驱动 OR-Tools/Pyomo MILP 补货求解，再通过 SAP/D365 采购门禁控制下发，降低缺货与牛鞭放大风险。

## 2) Q1 / Q2 / Q3
Q1：为何 10,000+ 门店摄像头不能全部上云实时推理？  
A1：全量视频回传会压垮门店 WAN，边缘先做 VLM 推理并仅上送事件与特征可大幅降带宽。  
Q2：如何防止多代理协同造成牛鞭放大？  
A2：补货动作必须由 MILP 约束求解器执行，设置安全库存上下界与跨店联动约束。  
Q3：生鲜品“降价清仓”与“补货”如何协调？  
A3：将保质期衰减、折价曲线与补货窗口同时纳入优化目标，避免同时过补与过期损耗。

## 3) 门店边缘到补货闭环流程（边缘识别→需求感知→MILP补货→ERP门禁）
```mermaid
flowchart LR
    A[Store RTSP and POS Signals] --> B[Arc Edge VLM Inference]
    B --> C[Fabric Eventstream]
    C --> D[Demand-Sensing Agent]
    D --> E[OR-Tools or Pyomo MILP Solver]
    E --> F[ERP PO Guardrail Gate]
    F --> G[DC to Store Replenishment]
```

## 4) 决策矩阵：门店边缘 Arc K8s vs 云端集中视觉 vs 分层混合
| 方案 | WAN 压力 | 实时性 | 成本 | 运维复杂度 | 适配场景 |
|---|---:|---:|---:|---:|---|
| 门店边缘 Arc K8s | 最低 | 最高 | 中 | 高 | 大规模门店与弱网场景 |
| 云端集中视觉 | 最高 | 中 | 中低 | 中 | 小规模、网络稳定场景 |
| 分层混合 | 低 | 高 | 中 | 中高 | 大多数全国连锁场景 |

## 5) 零售补货 Agent 上线清单（含当日热点）
- 视觉推理优先在门店边缘执行，上传事件摘要而非原始流。  
- 需求预测与补货动作必须经过确定性 MILP 求解器。  
- ERP 下单前必须经过采购门禁（上限、预算、黑白名单、异常阈值）。  
- 生鲜品需把保质期与降价策略纳入统一优化。  
- 当日热点（抓取日：2026-11-16，官方/Release 优先）：  
  - Arc + IoT Operations 在边缘自治运行方面的官方能力（`measured`）。  
  - Fabric 实时事件流对门店/电商融合信号的处理路径（`anonymized_reported`）。  
  - OR-Tools/Pyomo 约束补货对抑制牛鞭效应的工程可行性（`synthetic`）。

## 6) Good fit vs Not for 与百分比合约绑定
Good fit：  
1. 全国连锁门店需要在弱网环境下保持 OOS 检测与补货连续性的企业。  
2. 需要降低生鲜损耗并抑制补货波动放大的供应链团队。

Not for：  
1. 无边缘自治能力且依赖全量视频上云实时推理的系统。  
2. 无 ERP 门禁直接放行 Agent 订单决策的组织。

百分比合约绑定：
- `percentage_contract.store_wan_egress_reduction_rate`
- `percentage_contract.oos_detection_to_restock_latency_improvement_rate`
- `percentage_contract.perishable_spoilage_reduction_rate`
- `percentage_contract.milp_vs_unconstrained_order_accuracy_gain_rate`

以上键绑定 `cycle-2431-benchmark.json`，并标注 `production_validation=not_measured`。
