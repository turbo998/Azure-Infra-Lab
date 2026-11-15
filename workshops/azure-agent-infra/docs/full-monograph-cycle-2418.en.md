# Cycle 2418 Monograph: IDP Golden Paths and Agent Vending

## A. Objective and scope
- Scope: Platform CoE supporting 50+ AI product squads.
- Objective: standardize Foundry/APIM/Entra onboarding with compliant defaults in minutes.

## B. Core constraints
1. Every environment must pass policy-as-code guardrails.
2. No-public-endpoint, content safety, and FinOps tags are mandatory.
3. Sandbox lifecycle reclaim is required to prevent cost drift.

## C. Metric snapshot
- Under-30-min compliant provisioning: 96.4%
- Policy non-compliance block rate: 98.7%
- Platform leverage: 26 squads/engineer
- Orphan sandbox TTL savings: 82.4%

## D. Selection trade-offs
- Ticket-driven delivery does not scale for high parallelism.
- Module-first is transitional; full self-service vending is the target.
- Guardrails should be embedded in templates and gates, not retrofitted.

## E. Five-step rollout
1. Standardize AVM + azd templates and version policy.
2. Wire ADE + Dev Box environment vending.
3. Self-service Foundry/APIM/Entra provisioning.
4. Enforce DINE/Deny guardrails with promotion gates.
5. Operate TTL reclaim and drift remediation loops.

## F. Evidence and labels
See `evidence/cycle-2418-sources.json` and `evidence/cycle-2418-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
