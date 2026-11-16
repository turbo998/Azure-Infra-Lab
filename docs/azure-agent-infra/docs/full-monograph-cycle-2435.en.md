# Cycle 2435 Monograph Addendum (Automotive SDV Agent Infra)

- Cycle ID: 2435
- Window: 2026-11-16 23:00 ~ 2026-11-17 05:15
- Topic: automotive-sdv-incabin-voice-mqtt-fleet-diagnostics-agent-infra-faq-r1030

## Chapter 574 · SDV Hybrid Voice and Fleet Diagnostics Control Plane

This chapter consolidates a production SDV architecture:
1. Hybrid edge SLM + cloud handoff for robust in-cabin assistant continuity.
2. MQTT v5 control-plane governance for million-vehicle persistent mTLS connections.
3. Deterministic ADX diagnostics correlation for DTC triage and service-bay scheduling.
4. Hard safety-domain firewalling that prevents any LLM write-path to ADAS/powertrain buses.
5. OTA campaign triage with approval gates, replayable evidence, and rollback controls.
