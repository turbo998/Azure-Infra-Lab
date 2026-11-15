# Cycle 2421 Monograph: GreenOps and Agent-Fleet Energy Optimization

## A. Objective and scope
- Scope: multi-region GPU agent fleets balancing latency, cost, and carbon disclosure.
- Objective: operationalize carbon-aware scheduling and algorithmic efficiency as auditable task-level controls.

## B. Core constraints
1. Interactive workloads must preserve latency SLOs.
2. Deferrable workloads should prioritize low-carbon regions/time windows.
3. Every optimization action must map to traceable `$` and `gCO2e` outcomes.

## C. Metric snapshot
- gCO2e reduction per 10K tasks: 34.6%
- Idle GPU waste elimination: 78.3%
- Joint `$` + `gCO2e` reduction: 22.8%

## D. Selection trade-offs
- Power capping alone may hurt UX while leaving optimization headroom untapped.
- Scheduling alone misses model-level efficiency gains.
- Coordinated scheduling + power + algorithm optimization delivers stable dual-objective gains.

## E. Five-step rollout
1. Build per-task carbon-intensity and energy telemetry.
2. Implement interactive vs async scheduling classes.
3. Deploy TDP capping + MIG + scale-to-zero controls.
4. Apply quantization + KV cache + cascade routing.
5. Operate joint FinOps/CarbonOps dashboards and audit workflows.

## F. Evidence and labels
See `evidence/cycle-2421-sources.json` and `evidence/cycle-2421-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
