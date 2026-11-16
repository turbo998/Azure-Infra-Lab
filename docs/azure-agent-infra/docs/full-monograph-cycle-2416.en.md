# Cycle 2416 Monograph: Production Trajectory Curation and Post-Training Flywheel

## A. Objective and scope
- Scope: continuously convert production reasoning traces into trainable assets.
- Objective: increase domain-task quality while reducing long-run inference cost.

## B. Core constraints
1. Unscrubbed or non-consented samples must not enter training.
2. Reward design must include deterministic verifier scoring.
3. Promotion must pass forgetting and safety regression gates.

## C. Key metrics
- Distilled accuracy gain: 12.9%
- Monthly token cost reduction: 29.0%
- Forgetting guardrail pass rate: 96.9%
- LoRA SFT TTFT P95: 1.21s

## D. Method trade-offs
- SFT offers strongest cost-efficiency for structured tasks.
- DPO improves preference alignment.
- RFT yields higher policy gains with higher governance complexity.

## E. Five-step rollout
1. Build OTel trajectory ingestion with quality partitioning.
2. Deploy Purview/Presidio scrubbing and consent gates.
3. Implement hard-negative mining plus reward scoring.
4. Run SFT/DPO/RFT shadow evaluation and canary promotion.
5. Continuously monitor forgetting regression and tenant opt-out impacts.

## F. Evidence and labels
See `evidence/cycle-2416-sources.json` and `evidence/cycle-2416-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
