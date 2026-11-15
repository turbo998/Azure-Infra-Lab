# Automotive SDV In-Cabin Voice, MQTT Fleet Diagnostics, and OTA Agent Infra FAQ (Cycle 2435)

## 1) Executive summary
This cycle defines a production architecture for million-vehicle SDV operations: edge in-cabin SLM handles dead-zone intents, cloud agent handoff manages complex reasoning, Event Grid MQTT v5 sustains persistent mTLS sessions, and strict ISO 26262 / UNECE R155 air-gaps prevent any LLM write path into safety-critical ADAS/powertrain domains.

## 2) Q1 / Q2 / Q3
Q1: How do we keep cockpit voice continuity through dead-zones and cell handoffs?  
A1: Route simple intents to embedded NPU SLM locally and hand off complex intents to cloud when connectivity returns.
Q2: How do we guarantee safety-domain isolation?  
A2: Enforce hard gateway separation with deterministic deny rules for any agent-originated write command into drive-by-wire and ADAS CAN-FD buses.
Q3: How does MQTT scale to 1M+ vehicles without reconnect storms?  
A3: Use MQTT v5 session expiry, backpressure, token freshness checks, and controlled retry windows.

## 3) SDV flow (cockpit edge routing -> cloud diagnostics -> OTA action gate)
```mermaid
flowchart LR
    A[Cockpit Mic and CAN signals] --> B[Embedded NPU Intent Router]
    B --> C[5G/LTE mTLS MQTT and WebRTC lane]
    C --> D[Cloud Foundry EV and Diagnostics Agents]
    D --> E[Dealership Scheduler and OTA Triage Gate]
    E --> F[Safety Firewall and Audit Replay]
```

## 4) Decision matrix: edge-only SLM vs cloud-only voice vs hybrid split
| Option | Dead-zone continuity | Safety isolation | Fleet scalability | Ops complexity | Best fit |
|---|---:|---:|---:|---:|---|
| Edge-only SLM | Highest | High | Medium | Medium | limited command set, low cloud dependency |
| Cloud-only voice | Low | Medium | High | Low-Medium | non-critical infotainment-only paths |
| Hybrid speculative split | High | Highest | Highest | High | production SDV with diagnostics and OTA governance |

## 5) Automotive SDV production checklist (daily breakthroughs included)
- Implement hybrid edge/cloud routing with deterministic offline fallback.  
- Enforce ISO 26262 and UNECE R155 isolation between IVI and safety domains.  
- Scale MQTT broker with mTLS, session expiry, and reconnect backpressure controls.  
- Correlate DTC telemetry in ADX and gate OTA actions through owner-approved workflows.  
- Daily breakthroughs (fetched on 2026-11-16, official/release-first):  
  - Event Grid MQTT scaling and session controls (`measured`).  
  - Azure Maps route optimization for EV workflows (`measured`).  
  - Safety-domain hard block enforcement and fleet diagnostics replay evidence (`measured` + `anonymized_reported`).

## 6) Good fit vs Not for with percentage contract bindings
Good fit:  
1. OEMs and mobility platforms requiring dead-zone continuity and fleet-scale diagnostics governance.  
2. Programs needing strict safety-domain firewalling and replayable audit evidence.

Not for:  
1. Architectures that let LLM/agent write directly into ADAS/powertrain control lanes.  
2. MQTT designs without session-expiry/backpressure controls under reconnect surges.

Percentage contract bindings:
- `percentage_contract.voice_latency_improvement_hybrid_vs_cloud_rate`
- `percentage_contract.safety_domain_unauthorized_command_block_rate`
- `percentage_contract.predictive_dtc_recall_rate`
- `percentage_contract.per_vehicle_month_tco_reduction_hybrid_rate`

These keys bind to `cycle-2435-benchmark.json` with `production_validation=not_measured`.
