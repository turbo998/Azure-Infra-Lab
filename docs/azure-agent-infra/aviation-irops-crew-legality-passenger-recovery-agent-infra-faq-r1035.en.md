# Aviation IROPS Recovery, Crew Legality & Passenger Re-Accommodation Agent Infra FAQ (Round 1035 / Cycle 2440)

## 1) Executive Summary
This cycle targets severe-weather hub disruptions with deterministic legality-safe recovery. The architecture combines real-time flight-state streams, multi-agent orchestration, CP-SAT legality verification, idempotent seat-lock commit, and omnichannel passenger action delivery.

## 2) Q1 / Q2 / Q3
Q1: Why does pure LLM planning fail airline IROPS recovery?  
A1: Crew legality, MEL, gate exclusivity, and cascading network constraints are combinatorial and require deterministic optimization verification.

Q2: How to survive 50x traffic spikes while preserving booking integrity?  
A2: Use APIM priority queues plus Cosmos optimistic concurrency seat-lock idempotency against upstream PSS/NDC rate limits.

Q3: How to reduce cascading delay amplification across hub operations?  
A3: Build a real-time disruption cascade graph and run coupled fleet/crew/passenger optimization with hard legality gates.

## 3) End-to-end architecture flow
```mermaid
flowchart LR
  A[Weather / ground-stop event] --> B[Event Hubs + ADX cascade graph]
  B --> C[Fleet/Crew/Pax agents]
  C --> D[CP-SAT legality verifier]
  D --> E[PSS/NDC seat commit with Cosmos lock]
  E --> F[ACS omnichannel rebooking push]
```

## 4) Decision matrix
| Option | Recovery speed | Legality assurance | Burst resilience | Ops complexity | Best use |
|---|---:|---:|---:|---:|---|
| Legacy sequential OCC manual recovery | Low | Medium | Low | Medium | Small disruptions |
| Pure LLM advisory | Medium | Low | Medium | Low | Triage-only advisory |
| Hybrid agent + CP-SAT joint recovery | High | Highest | High | High | Large hub IROPS events |

## 5) Airline IROPS production checklist
- Ingest ACARS/ADS-B/METAR/NOTAM with replayable event lineage.
- Enforce FAA Part 117 / EASA FTL / MEL / gate exclusivity as hard constraints.
- Apply Cosmos optimistic concurrency seat-lock and idempotent commit keys.
- Use APIM priority queues to protect legacy PSS/NDC partner rate limits.
- Fan-out rebooking actions via ACS with SLA and fallback channels.
- Continuously monitor legality blocks, burst completion, and look-to-book protection.

## 6) Good fit vs Not for and percentage contract binding
Good fit: airline OCC programs requiring legality-safe high-burst disruption recovery.  
Not for: advisory-only pilots that cannot enforce deterministic legality and inventory constraints.

Percentage-contract keys (bound to `evidence/cycle-2440-benchmark.json`, `production_validation=not_measured`):
- `percentage_contract.full_schedule_recovery_time_improvement_rate`
- `percentage_contract.crew_mel_compliance_rate`
- `percentage_contract.passenger_rebooking_burst_sla_rate`
- `percentage_contract.pss_ndc_look_to_book_protection_rate`
