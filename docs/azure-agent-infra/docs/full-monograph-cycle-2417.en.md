# Cycle 2417 Monograph: MCP/Agent Supply-Chain Signing and Admission Defense

## A. Objective and scope
- Scope: continuous onboarding of third-party MCP servers, LoRA adapters, and container artifacts.
- Objective: enforce trusted origin, controlled deployment, and runtime traceability.

## B. Core constraints
1. Unsigned or provenance-missing artifacts must never reach cluster runtime.
2. Critical CVEs must be blocked during admission.
3. Patched artifacts require re-sign and re-verification before rollout.

## C. Metric snapshot
- Unsigned/tampered block rate: 99.5%
- Admission overhead P95: 96ms
- Copa patch lead time: 22 min
- Supply-chain guardrail pass: 98.2%

## D. Selection trade-offs
- L2 (Ratify + Gatekeeper) is the practical production inflection point.
- L3 is stronger for high-regulation operations with added complexity.
- Unpinned runtime package pulls should be eliminated.

## E. Five-step rollout
1. Standardize digest pinning and signing policy.
2. Publish SBOM/AI-BOM and bind via OCI referrers.
3. Enforce Ratify + Gatekeeper admission policy.
4. Operate Copa fast patch with re-sign pipeline.
5. Run Defender drift alert plus quarantine/rollback runbooks.

## F. Evidence and labels
See `evidence/cycle-2417-sources.json` and `evidence/cycle-2417-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
