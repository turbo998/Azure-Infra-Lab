# Retail Omnichannel Demand Sensing and Store-Edge Replenishment Agent Infrastructure FAQ (Cycle 2431)

## 1) Executive summary
This cycle targets 5,000-store omnichannel operations. Arc-enabled edge inference handles shelf OOS and shrinkage under WAN brownouts, Fabric Eventstreams fuses POS and ecommerce demand signals, and deterministic OR-Tools or Pyomo MILP allocation governs replenishment before SAP or D365 purchase-order guardrails admit execution.

## 2) Q1 / Q2 / Q3
Q1: Why not run all 10,000+ store cameras in centralized cloud inference?  
A1: Full stream uplink saturates store bandwidth; edge inference should publish only event summaries and confidence signals.  
Q2: How do we prevent multi-agent bullwhip amplification?  
A2: Replenishment must be bounded by deterministic MILP constraints and safety-stock envelopes, not unconstrained language-model arithmetic.  
Q3: How do we orchestrate markdown versus replenishment for perishables?  
A3: Optimize shelf-life decay, markdown curves, and replenishment windows jointly in the solver objective.

## 3) Closed-loop flow (edge vision, demand sensing, MILP, ERP gate)
```mermaid
flowchart LR
    A[Store RTSP and POS Signals] --> B[Arc Edge VLM Inference]
    B --> C[Fabric Eventstream]
    C --> D[Demand-Sensing Agent]
    D --> E[OR-Tools or Pyomo MILP Solver]
    E --> F[ERP PO Guardrail Gate]
    F --> G[DC to Store Replenishment]
```

## 4) Decision matrix: store-edge Arc Kubernetes vs cloud-centralized vision vs hybrid tiered
| Option | WAN pressure | Real-time response | Cost | Ops complexity | Best fit |
|---|---:|---:|---:|---:|---|
| Store-edge Arc Kubernetes | Lowest | Highest | Medium | High | Large distributed retail footprint |
| Cloud-centralized vision | Highest | Medium | Medium-Low | Medium | Smaller stable-network chains |
| Hybrid tiered model | Low | High | Medium | Medium-High | Most national omnichannel retailers |

## 5) Retail production checklist (with daily breakthroughs)
- Run shelf vision inference at store edge and upload event summaries instead of raw streams.  
- Require deterministic MILP checks before replenishment decisions are admitted.  
- Enforce ERP purchase-order guardrails for budget, caps, and anomaly thresholds.  
- Model perishables with shelf-life decay and markdown economics in the same optimization loop.  
- Daily breakthroughs (fetched on 2026-11-16, official/release-first):  
  - Arc plus IoT Operations edge autonomy baseline (`measured`).  
  - Fabric real-time signal fusion for POS and ecommerce feeds (`anonymized_reported`).  
  - OR-Tools and Pyomo constrained replenishment effectiveness (`synthetic`).

## 6) Good fit vs Not for with percentage contract bindings
Good fit:  
1. Retailers operating large weak-network store fleets requiring resilient edge operations.  
2. Supply-chain teams targeting lower spoilage and reduced bullwhip volatility.

Not for:  
1. Architectures that depend on full camera uplink and central-only inference.  
2. Platforms without ERP PO guardrails for automated order execution.

Percentage contract bindings:
- `percentage_contract.store_wan_egress_reduction_rate`
- `percentage_contract.oos_detection_to_restock_latency_improvement_rate`
- `percentage_contract.perishable_spoilage_reduction_rate`
- `percentage_contract.milp_vs_unconstrained_order_accuracy_gain_rate`

These keys bind to `cycle-2431-benchmark.json` with `production_validation=not_measured`.
