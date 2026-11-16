# Cycle 2415 Monograph: Legacy ERP/SAP/Mainframe Hybrid Agent Integration

## A. Business objective
- Scope: agent collaboration over core records (orders, procurement, inventory, accounting) across brownfield systems.
- Objective: enable controlled automation without breaking authorization and audit boundaries.

## B. Core constraints
1. Shared privileged service-account mutation is a high-risk anti-pattern.
2. Every mutating path must pass TESTRUN before commit.
3. Connection-pool protection must be enforced at gateway and orchestration layers.

## C. Metric snapshot
- Principal propagation audit coverage: 98.8%
- TESTRUN precommit catch rate: 95.2%
- Backend connection-pool protection: 96.1%
- Logic Apps primary-path reliability: 99.1%

## D. Selection trade-offs
- Direct RFC can be lower latency with higher governance burden.
- Logic Apps is strongest for hybrid multi-system primary paths.
- RPA is for no-API tails only, not a primary replacement.

## E. Five-step rollout
1. Govern API assets and MCP facade contracts.
2. Configure Entra-to-SAP user principal propagation.
3. Enforce BAPI TESTRUN and approval gates.
4. Apply throttling, circuit-breakers, and degradation policies.
5. Run regular regulator replay and incident drills.

## F. Evidence and labels
See `evidence/cycle-2415-sources.json` and `evidence/cycle-2415-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
