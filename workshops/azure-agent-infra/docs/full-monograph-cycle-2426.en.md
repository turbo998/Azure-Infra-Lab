# Cycle 2426 Monograph: Scientific Discovery HPC Simulator-in-the-Loop Agent Infrastructure

## A. Objective and scope
- Scope: materials discovery, battery/coolant formulation, small-molecule design, and semiconductor EDA R&D.
- Objective: improve valid-candidate discovery throughput with physically trustworthy verification under controlled compute spend.

## B. Core constraints
1. Candidate lineage, checkpoints, and simulation outcomes must be fully traceable.
2. Physically invalid candidates must be rejected before promotion.
3. Long-horizon resume reliability must be treated as a first-class production SLO.

## C. Metric snapshot
- GPU-hour reduction vs brute-force: 96.8%
- AMLFS checkpoint throughput uplift: 214.0%
- Invalid candidate rejection rate: 95.7%
- Slurm long-horizon resume reliability: 98.2%

## D. Selection trade-offs
- Kueue is strong for containerized multi-queue exploration.
- Slurm InfiniBand remains strongest for MPI-heavy deterministic verification.
- Multi-fidelity funnels cut cost substantially but demand stricter state and data governance.

## E. Five-step rollout
1. Establish unified lineage IDs for candidates and experiment runs.
2. Run surrogate pre-screening before expensive HPC verification.
3. Implement AMLFS checkpoint strategy with preemption recovery drills.
4. Place physical-validity gates before promotion decisions.
5. Close the loop with active-learning feedback into surrogate retraining.

## F. Evidence and labels
See `evidence/cycle-2426-sources.json` and `evidence/cycle-2426-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
