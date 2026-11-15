# Cycle 2420 Monograph: Cross-Org A2A Federation and External Agent Gateway

## A. Objective and scope
- Scope: collaboration among OEMs, suppliers, channels, and service partners.
- Objective: provide discoverable, secure, auditable, and non-repudiable cross-enterprise agent interactions.

## B. Core constraints
1. External partner payloads are untrusted by default and must be quarantined.
2. Cross-tenant calls require verifiable identity and quota isolation.
3. Critical quote/order artifacts must carry non-repudiation evidence.

## C. Metric snapshot
- Cross-org injection block rate: 96.7%
- Async A2A completion reliability: 98.1%
- DLP outbound leak prevention: 97.2%

## D. Selection trade-offs
- Internal MCP fits internal tool orchestration, not direct partner exposure.
- REST/EDI is stable but less adaptive; federated A2A supports richer workflows.
- A2A federation increases governance complexity but unlocks collaborative throughput.

## E. Five-step rollout
1. Build agent-card registry and capability-version governance.
2. Deploy APIM DMZ with mTLS and cross-tenant token exchange.
3. Route external payloads through quarantine and prompt shields.
4. Enforce Purview DLP outbound policy with audit replay.
5. Archive signed transaction artifacts with legal evidence mapping.

## F. Evidence and labels
See `evidence/cycle-2420-sources.json` and `evidence/cycle-2420-benchmark.json` with `measured/synthetic/anonymized_reported` labels.
