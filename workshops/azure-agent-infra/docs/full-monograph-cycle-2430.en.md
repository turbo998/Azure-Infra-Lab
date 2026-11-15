# Cycle 2430 Monograph: SOC Triage, Threat Hunting, and SOAR Containment Agent Infrastructure

## A. Objective and scope
- Scope: enterprise SOC Tier-1/Tier-2 workflows, sandbox analysis, and safe containment automation.
- Objective: reduce alert fatigue, accelerate investigation, and prevent unsafe containment on crown-jewel assets.

## B. Core constraints
1. All untrusted logs must be sanitized before agent reasoning.
2. Investigation and containment identities must remain separated.
3. Crown-jewel assets require tiered approval gates before containment actions.

## C. Metric snapshot
- Prompt-injection log block rate: 97.4%
- Crown-jewel false-positive containment prevention rate: 98.2%
- Critical incident MTTR improvement rate: 42.6%
- Per-incident SIEM and token cost reduction rate: 31.8%

## D. Selection trade-offs
- Security Copilot OOB is fastest for immediate SOC uplift.
- Custom Foundry SOC agents maximize orchestration flexibility.
- Hybrid mode balances speed, control, and long-term governance.

## E. Five-step rollout
1. Deploy untrusted log sanitization at every alert ingestion boundary.
2. Separate investigation and containment identities with least privilege.
3. Add sandbox detonation for suspicious artifacts before containment.
4. Enforce crown-jewel risk-tier approval gates in SOAR playbooks.
5. Continuously replay and audit containment evidence and outcomes.

## F. Evidence and labels
See `evidence/cycle-2430-sources.json` and `evidence/cycle-2430-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
