# Energy Smart Grid DER Dispatch, VPP, and NERC-CIP Agent Infrastructure FAQ (Cycle 2437)

## 1) Executive summary
This cycle defines utility-scale architecture for renewable ramp forecasting, VPP dispatch, and market bidding under strict NERC-CIP control boundaries. Cloud agents optimize DER decisions, while deterministic AC-OPF physics gates and ESP/DMZ segmentation prevent unsafe control actions.

## 2) Q1 / Q2 / Q3
Q1: How do we keep NERC-CIP BES boundaries intact while running cloud advisory agents?  
A1: Keep cloud lanes advisory-only, enforce ESP/DMZ segmentation, and route all high-impact actuation through controlled gateways.
Q2: How do probabilistic weather ensembles work with deterministic physics constraints?  
A2: Use ensemble forecasts to generate candidate dispatch sets, then require AC-OPF verification before execution.
Q3: How do we dispatch to 500k DER endpoints with bounded latency?  
A3: Partition fan-out channels with bounded retries, queue controls, and deterministic setpoint validation.

## 3) End-to-end flow (weather/PMU -> forecast -> AC-OPF gate -> OpenADR dispatch)
```mermaid
flowchart LR
    A[Weather + PMU + AMI stream] --> B[ADX and forecast GPU lane]
    B --> C[VPP bidding and dispatch planner]
    C --> D[Pandapower AC-OPF physics gate]
    D --> E[OpenADR/DMZ setpoint actuation]
    E --> F[Audit replay and compliance controls]
```

## 4) Decision matrix: cloud VPP advisory + DMZ vs edge microgrid vs legacy SCADA rule-only
| Option | Curtailment control | Compliance posture | Dispatch scalability | Ops complexity | Best fit |
|---|---:|---:|---:|---:|---|
| Cloud VPP advisory + DMZ | High | Highest | Highest | High | utility-scale DER fleets |
| Substation-edge microgrid | Medium-High | High | Medium | Medium-High | localized resilience islands |
| Legacy SCADA rule-only | Medium | Medium | Medium | Low | conservative incremental modernization |

## 5) Smart grid production checklist (daily breakthroughs included)
- Enforce advisory-only cloud actuation across NERC-CIP ESP boundaries.  
- Keep AC-OPF thermal/voltage/frequency verifier mandatory before DER setpoint publication.  
- Use partitioned OpenADR fan-out controls for bounded dispatch latency at fleet scale.  
- Track curtailment, bidding, and outage restoration outcomes with replayable evidence.

## 6) Good fit vs Not for with percentage contract bindings
Good fit: utility operators needing large-scale DER optimization under strict compliance controls.  
Not for: architectures that bypass physics gates or CIP boundaries for dispatch speed.

Percentage contract bindings:
- `percentage_contract.renewable_curtailment_reduction_rate`
- `percentage_contract.acopf_thermal_voltage_violation_block_rate`
- `percentage_contract.openadr_dispatch_sla_rate`
- `percentage_contract.per_der_month_tco_reduction_rate`

These keys bind to `cycle-2437-benchmark.json` with `production_validation=not_measured`.
