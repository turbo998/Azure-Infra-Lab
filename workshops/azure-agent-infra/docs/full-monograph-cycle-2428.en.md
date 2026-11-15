# Cycle 2428 Monograph: Sovereign Cross-Border Residency and Signed Exchange Agent Infrastructure

## A. Objective and scope
- Scope: regulated B2B agent collaboration under cross-region and cross-organization constraints.
- Objective: preserve residency, prevent uncontrolled egress, and maintain cryptographic non-repudiation.

## B. Core constraints
1. Raw context must stay in-region.
2. Cross-border transfer must be signature-based artifact exchange only.
3. Every decision must be audit-replayable (policy + identity + signature).

## C. Metric snapshot
- Residency policy violation block rate: 96.8%
- Cross-border token denial rate: 93.7%
- Signed artifact non-repudiation rate: 99.2%
- P0 data egress incident reduction rate: 84.4%

## D. Selection trade-offs
- In-region federation remains the default for sensitive workflows.
- Signed artifact exchange is the practical cross-border production lane.
- Direct plaintext context sharing is excluded for regulated workloads.

## E. Five-step rollout
1. Define sovereign zones and policy metadata contracts.
2. Bind APIM routes to residency and intent policies.
3. Enforce short-lived workload identity with revocation checks.
4. Sign outbound artifacts with HSM-backed keys and verify at ingress.
5. Run audit replay drills for denial events and cross-border exchanges.

## F. Evidence and labels
See `evidence/cycle-2428-sources.json` and `evidence/cycle-2428-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
