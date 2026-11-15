# Cycle 2419 Monograph: Real-Time Fraud/Risk Dual-Speed Triage

## A. Objective and scope
- Scope: payment authorization, fraud, AML, and account-takeover defense.
- Objective: keep authorization p99 below 50ms while improving capture quality and investigation depth.

## B. Core constraints
1. Hot-path authorization cannot rely on high-variance blocking inference.
2. Grey-zone investigations must preserve SAR explainability and auditability.
3. Step-up and clawback strategies require measurable economics.

## C. Metric snapshot
- Inline p99 under-50ms compliance: 96.9%
- False-positive friction reduction: 31.2%
- SAR investigation time savings: 48.7%

## D. Selection trade-offs
- Rules-only hot path has low latency but limited capture ceiling.
- Inline ML + micro-SLM gives balanced speed and quality.
- Async investigation swarm increases complexity but improves deep-case handling and compliance output.

## E. Five-step rollout
1. Define strict hot-path latency budgets and fallback controls.
2. Wire Event Hubs/Fabric streams and Redis feature windows.
3. Deploy ONNX/TensorRT + micro-SLM hybrid inline scoring.
4. Build async investigation swarms for link analysis and SAR drafting.
5. Continuously optimize thresholds across capture, friction, and throughput.

## F. Evidence and labels
See `evidence/cycle-2419-sources.json` and `evidence/cycle-2419-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
