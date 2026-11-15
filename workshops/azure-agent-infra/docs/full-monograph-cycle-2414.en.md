# Cycle 2414 Monograph: Capital Markets MNPI/WORM and Quant Agent Infrastructure

## A. Scope and objective
- Scope: sell-side research, buy-side portfolio analytics, underwriting and risk collaboration.
- Objective: deliver publishable agent-driven research under MNPI isolation, deterministic numerical verification, and regulatory retention controls.

## B. Core constraints
1. Cross desk/deal-room retrieval must be deny-by-default and auditable.
2. Critical financial outputs must be recomputed and signed by deterministic Python verifier.
3. Pre-release evidence must be persisted in WORM storage and ledger anchors.

## C. Key metrics
- MNPI cross-desk leak block rate: 99.6%
- Deterministic quant exactness: 99.4%
- Earnings ingestion-to-signal latency P95: 0.86s
- WORM/ledger verification success: 99.2%

## D. Cost and governance trade-offs
- Sell-side tier is cost-efficient for broad coverage workflows.
- Buy-side quant tier balances latency and numerical precision.
- Regulated-institution tier is best for high-stakes publication pipelines.

## E. Five-step rollout
1. Define desk/deal-room identity and retrieval boundaries.
2. Integrate deterministic Python verifier and signature chain.
3. Deploy Event Hubs + ADX low-jitter signal pipeline.
4. Enable WORM legal hold and retention locks.
5. Run weekly regulator replay and evidence integrity drills.

## F. Evidence and labels
See `evidence/cycle-2414-sources.json` and `evidence/cycle-2414-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
