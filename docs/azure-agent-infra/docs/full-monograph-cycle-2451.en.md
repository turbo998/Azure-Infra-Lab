# Cycle #2451 Monograph Addendum: Manufacturing ISA-95 Zero-Trust OT Agent Bridge (en)

- Round/Cycle: `1046 / 2451`
- Date: `2026-11-16 (BJT)`
- Topic: `manufacturing-ot-agent-isa95-zero-trust-bridge-faq-r1046`
- Data labels: `measured / synthetic / anonymized_reported`

## Chapter 460 · Daily breakthroughs and production meaning

Official/release-note-first evidence for this round:

1. **APIM AI Gateway + Unified Model API**  
   - Learn: <https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview>  
   - Changelog: <https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md>
2. **ACA Dynamic Sessions**  
   - Docs: <https://learn.microsoft.com/en-us/azure/container-apps/sessions>
3. **Sandbox upstream cadence**  
   - Firecracker/Kata/Wasmtime/E2B release streams (captured in `evidence/cycle-2451-sources.json`)

The practical takeaway for manufacturing infra: gateway policy and session sandboxing are now part of the core control plane, not optional side components.

## Chapter 461 · Layered decoupled reference architecture (ISA-95 + Zero Trust)

### 1. Control-plane layering

- **L4/L5 (Enterprise/Business)**: planning, work-order policy, KPI control.
- **L3 (MES/Ops)**: production orchestration and quality traceability.
- **L2/L1 (SCADA/PLC)**: equipment state and control commands.

Agents run in L4/L5-L3 domains. Any write operation toward L2/L1 must pass a zero-trust bridge; direct writes are blocked by policy.

### 2. Admission contract

Every tool call carries:
- `zone_level`
- `asset_scope`
- `command_class`
- `approval_state`
- `policy_version`

Missing or mismatched fields trigger `ot-bridge-policy-violation` and are blocked with audit emission.

### 3. Runtime flow

1. Agent intent is sent through APIM.  
2. ISA-95 policy gate validates zone and command type.  
3. Zero-trust OT bridge maps only approved commands to plant interfaces.  
4. All allow/block events are written to ADX for forensic replay.

## Chapter 462 · Quantified results from reproducible benchmark assets

From `evidence/cycle-2451-*.csv/json`:

- **Cold start / restore**
  - E2B Firecracker: P50 `118ms` / P95 `211ms` (`anonymized_reported`)
  - ACA warm pool allocation: P50 `257ms` / P95 `398ms` (`anonymized_reported`)
  - AKS + Kata Pod VM cold start: P50 `920ms` / P95 `1420ms` (`anonymized_reported`)
- **Throughput paths**
  - APIM unified model routing: P50 `1372 rps` / P95 `1178 rps` (`synthetic`)
  - MCP tool orchestration path: P50 `484 rps` / P95 `422 rps` (`synthetic`)
- **Policy interception** (`measured`)
  - `ot-bridge-policy-violation saturation gate`: `172/184 = 93.48%`
  - `isa95-zone-fence integrity guard`: `161/168 = 95.83%`
- **Per-session cost** (20-minute sessions)
  - E2B: `$0.00552/session` (`synthetic`)
  - AKS Kata: `$0.01044/session` (`synthetic`)
  - ACA Sessions: `$0.01100/session` (`synthetic`)

## Chapter 463 · Failure modes and tuning handbook

### Failure mode A: policy-version drift

Symptom: bridge and control-plane evaluate different `policy_version` snapshots.  
Mitigation: enforce version as hard gate, run dual-eval during rollout, and auto-rollback when mismatch exceeds threshold.

### Failure mode B: write-command storms during alarm spikes

Symptom: burst retries saturate bridge queue and increase unsafe race conditions.  
Mitigation: token-bucket admission by `command_class`, idempotency keys, and priority queue for safety-critical commands.

### Failure mode C: timeout replay across regions

Symptom: upstream retries duplicate writes after transient timeouts.  
Mitigation: bridge-side idempotency window plus result cache replay.

## Chapter 464 · Competitor comparison and selection conclusion

| Platform | Isolation boundary | Cold start | Cost | Ops complexity | Manufacturing OT fit |
|---|---|---:|---:|---:|---|
| Azure APIM + ACA + OT Bridge | Unified policy + session + audit | Medium | Medium | Medium | **High** |
| AWS AgentCore + Firecracker | Strong runtime isolation | Medium-low | Medium | Medium-high | Medium-high |
| GCP Agent Engine + Cloud Run | High managed abstraction | Medium | Medium | Medium | Medium |
| E2B/Modal/Cloudflare sandbox stack | Fast and flexible | Low | Low-Med | Medium | Medium (governance must be self-built) |

Conclusion: for manufacturing, prefer policy-and-audit-first control planes; speed-only direct-write patterns are operationally risky.

## Chapter 465 · Five-step rollout (Good fit vs Not for)

1. Build ISA-95 asset and zone inventory.
2. Define command classes and approval workflow (default deny for writes).
3. Enforce policy gate at APIM and bridge layer.
4. Wire ADX audit dashboards with block-rate and false-block SLOs.
5. Run weekly replay tests before policy promotion.

**Good fit**: enterprises needing IT/OT collaboration with strict traceability.  
**Not for**: teams without sustained approval/audit operations capability.
