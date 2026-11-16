# Cycle 2423 Monograph: Enterprise Contact-Center Voice Agents with PCI Isolation

## A. Objective and scope
- Scope: enterprise contact-center workloads at 10,000 concurrent calls (IVR plus human agents).
- Objective: balance voice UX, operator productivity, and payment compliance at production scale.

## B. Core constraints
1. Mouth-to-ear latency and barge-in quality must remain stable under concurrency spikes.
2. Warm transfer must preserve critical conversation context without drift.
3. PCI payment windows must isolate media so cardholder data never enters models.

## C. Metric snapshot
- Mouth-to-ear P95 SLA compliance: 94.8%
- Barge-in interruption accuracy: 93.6%
- AHT reduction with live whisper assist: 28.4%

## D. Selection trade-offs
- Native S2S: lowest latency for high-concurrency self-service lanes.
- STT-LLM-TTS cascade: stronger audit and stage-level policy controls.
- Human whisper-only: strongest control, highest latency and cost, for sensitive flows.

## E. Five-step rollout
1. Define routing policy between S2S and cascaded speech paths.
2. Baseline ACS media-channel concurrency and burst capacity.
3. Implement warm-transfer context contract with fallback handling.
4. Enforce DTMF masking and recording pause/resume for payment windows.
5. Jointly validate latency, containment, AHT, and PCI control metrics.

## F. Evidence and labels
See `evidence/cycle-2423-sources.json` and `evidence/cycle-2423-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
