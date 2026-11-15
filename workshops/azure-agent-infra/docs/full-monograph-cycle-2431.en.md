# Cycle 2431 Monograph: Retail Store-Edge Vision, Demand Sensing, and Replenishment Agent Infrastructure

## A. Objective and scope
- Scope: 5,000-store omnichannel demand sensing and replenishment operations.
- Objective: lower WAN pressure, improve OOS recovery, reduce spoilage, and increase replenishment accuracy.

## B. Core constraints
1. Shelf vision inference must survive store WAN brownouts at the edge.
2. Replenishment decisions must pass deterministic MILP constraints.
3. ERP purchase-order guardrails must gate every autonomous order action.

## C. Metric snapshot
- Store WAN egress reduction rate: 87.6%
- OOS detection to restock latency improvement rate: 46.9%
- Perishable spoilage reduction rate: 28.4%
- MILP vs unconstrained order accuracy gain rate: 41.7%

## D. Selection trade-offs
- Edge-first architecture best protects WAN and local continuity.
- Cloud-centralized vision simplifies operations but stresses bandwidth.
- Hybrid tiered architecture balances resilience and operational complexity.

## E. Five-step rollout
1. Enable Arc edge inference with offline continuity controls.
2. Fuse POS, ecommerce, and local demand signals in Fabric streams.
3. Apply MILP safety-stock and cross-store constraints for replenishment.
4. Enforce SAP and D365 PO guardrails for budget and anomaly checks.
5. Continuously measure OOS recovery, spoilage, and order-accuracy outcomes.

## F. Evidence and labels
See `evidence/cycle-2431-sources.json` and `evidence/cycle-2431-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
