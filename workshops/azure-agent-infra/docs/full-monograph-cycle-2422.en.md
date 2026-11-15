# Cycle 2422 Monograph: Million-Player NPC and LiveOps Agent Architecture

## A. Objective and scope
- Scope: NPC interaction and world-event orchestration for large online games.
- Objective: preserve low latency and low COGS while maintaining narrative quality and exploit resistance.

## B. Core constraints
1. Interaction-layer TTFT must remain within UX limits.
2. Economy mutations must be validated by authoritative server rules.
3. Launch-day 10x CCU requires prewarm and degradation playbooks.

## C. Metric snapshot
- Sub-180ms TTFT compliance: 96.2%
- Economy exploit block rate: 99.1%
- COGS reduction vs single model: 39.7%

## D. Selection trade-offs
- Single-tier frontier inference yields quality but unsustainable latency and cost.
- Three-tier cascade better balances interactivity, economics, and narrative depth.
- Authoritative state isolation is mandatory for exploit resilience.

## E. Five-step rollout
1. Define three-tier inference responsibilities and degradation policies.
2. Design Agones elastic pools and warm capacity plans.
3. Map intent tokens to deterministic rule-engine validation.
4. Optimize Cosmos partitioning and hotspot control.
5. Run launch-day stress tests and exploit replay drills.

## F. Evidence and labels
See `evidence/cycle-2422-sources.json` and `evidence/cycle-2422-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
