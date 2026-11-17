# Round 1123 · Cycle 2528  
## Global Standard vs DataZone vs Regional PTU: Enterprise Multi-Region Resilience, BCDR, and Data-Residency Selection FAQ

## 1) Executive decision brief
- Choose **Global Standard / Global Provisioned (PTU)** when your top priority is global elasticity with minimal capacity-planning friction, and you can still engineer multi-region state services.
- Choose **DataZone Standard / DataZone Provisioned** when geographic processing boundaries (EU/US) are a hard compliance requirement.
- Choose **Regional PTU Active-Active + APIM + multi-region state/search** when you need explicit control and verifiable 99.99% class availability.
- Choose **Regional PTU Active-Passive + PAYGO warm standby** when regulated DR is mandatory but cost efficiency is equally critical.

## 2) Scope and non-goals
- Focus: enterprise Agent platforms across model inference, tool gateway, thread state, retrieval, and governance.
- Out of scope: kernel/driver/NIC/RDMA internals and low-level hardware telemetry.
- Primary audience: platform architects, compliance/risk teams, and FinOps owners.

## 3) Decision prerequisites and common pitfall
- Classic failure pattern: failing over stateless LLM endpoints while leaving Cosmos DB or AI Search stranded in a single region.
- Correct pattern: define fault domains as full transaction paths (APIM route + model endpoint + thread state + retrieval index + audit log).
- Compliance-first sequencing: establish legal residency boundaries before throughput optimization.

## 4) Daily breakthroughs with verifiable sources (fetched: 2026-11-18 UTC)
1. APIM AI Gateway and unified model ingress (official)  
   https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
2. APIM service changelog (official release notes)  
   https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md  
3. ACA Dynamic Sessions (official docs)  
   https://learn.microsoft.com/en-us/azure/container-apps/sessions  
4. Dynamic Sessions GA announcement (official Apps on Azure blog)  
   https://techcommunity.microsoft.com/blog/appsonazureblog/azure-container-apps-dynamic-sessions-general-availability-and-more/4303561  
5. Upstream runtime evidence (official releases)  
   - https://github.com/firecracker-microvm/firecracker/releases  
   - https://github.com/kata-containers/kata-containers/releases  
   - https://github.com/bytecodealliance/wasmtime/releases  
   - https://github.com/e2b-dev/e2b/releases  

## 5) Four architecture options in enterprise terms
- **A. Global Standard / Global Provisioned (PTU)**: optimize for global quota elasticity and simplified endpoint posture.
- **B. DataZone Standard / DataZone Provisioned**: optimize for geographic processing boundaries and sovereignty controls.
- **C. Regional PTU Active-Active**: optimize for deterministic regional control, low failover RTO, and explicit state replication.
- **D. Regional PTU Active-Passive + PAYGO Warm Standby**: optimize for cost-aware regulated DR with pre-warmed fallback.

## 6) 12-dimension side-by-side matrix
| Dimension | A Global | B DataZone | C Regional Active-Active | D Active-Passive Warm Standby |
|---|---|---|---|---|
| 1. In-transit/in-use residency boundary | Medium explicitness | High (geo-bound) | Very high (region-explicit) | High in primary, policy-defined in standby |
| 2. At-rest data residency | Needs extra guardrails | Strong geo alignment | Fully design-controlled | Strong in primary, controlled in DR |
| 3. Burst TPM/model availability | Excellent global pool | Strong but geo-bound | Region-by-region capacity planning | Strong primary + bounded standby burst |
| 4. P99 latency determinism | Good but can vary across routes | Better intra-geo consistency | Best with local routing | Stable primary, variance during failover |
| 5. Regional outage RTO/RPO | Low RTO, state-layer dependent RPO | Low RTO, state-layer dependent RPO | Lowest RTO/RPO with full design | Moderate RTO, replication-defined RPO |
| 6. Thread/Search failover synchronization | External design required | External design required | First-class design concern | Runbook and drills are decisive |
| 7. APIM circuit-break + TTFT routing | Recommended | Recommended | Mandatory | Mandatory |
| 8. PTU reservation cost multiplier | Low to medium | Medium | High | Medium to low |
| 9. Compliance fit (GDPR/FINMA/sovereignty) | Medium | High | High | High |
| 10. Game-day operational complexity | Medium | Medium | High | Medium |
| 11. Best-fit workload | Global generalized assistants | Geo-sovereign assistants | Mission-critical 24x7 platforms | Regulated cost-sensitive workloads |
| 12. Anti-pattern (`When NOT to choose`) | Hard residency audit use cases | Lowest-cost global homogenization goals | Limited budget/platform team | Ultra-real-time workloads with zero switchover tolerance |

## 7) Industry reference architecture A  
### European Private Banking dual-jurisdiction sovereign advisory Agent
- Swiss portfolios are strictly routed to `Switzerland North` Regional PTU with local CMK and local audit workspace.
- EEA portfolios are routed to `DataZone EU` for GDPR-aligned processing boundary.
- APIM policy enforces `client_jurisdiction` routing and blocks cross-jurisdiction fallback.
- Purview-backed signed residency evidence is exported for regulator audits.

## 8) Industry reference architecture B  
### Global 24x7 cross-border payment fraud and chargeback Active-Active Agent
- Azure Front Door + regional APIM gateways across US/EU/APAC.
- TTFT-aware failover (`>2.5s` or `429/503`) shifts traffic automatically to healthy regional pools.
- Cosmos DB multi-region writes with deterministic conflict policy.
- AI Search cross-region index strategy supports read-degraded continuity.
- Monthly Chaos Studio region-outage drills validate RTO/RPO assumptions.

## 9) APIM routing and circuit-break policy baseline
- Primary route: same jurisdiction + nearest compliant region.
- Secondary route: same sovereignty boundary, alternative region.
- Tertiary route: approved warm standby path with explicit compliance tag.
- Hard deny: unauthorized cross-jurisdiction fallback.
- Probes: TTFT, 429/503 ratio, P99, queue depth, policy interception rate.

## 10) Stateful thread and retrieval replication design
- Cosmos DB: multi-region write with business-priority conflict resolver.
- AI Search: replicated indexes with freshness annotation during degraded mode.
- Agent state model: decouple thread snapshots from tool execution logs to simplify replay and resilience tests.

## 11) Benchmark methodology labels (`measured` / `synthetic` / `anonymized_reported`)
- Cold start / warm restore: `P50/P95` latency by region.
- Throughput: separate path metrics for gateway, state write, and retrieval query.
- Policy interception: rate of blocked non-compliant or out-of-scope requests.
- Per-session cost: PTU amortization + gateway + state + observability components.
- Every metric must include `source_label` and `source_ref`.

## 12) 1M-invocation TCO interpretation
- A Global: high utilization efficiency; requires added compliance control layers.
- B DataZone: strong regulatory fit; lower pooling efficiency than global.
- C Regional Active-Active: strongest resilience profile; highest steady-state multiplier.
- D Active-Passive: favorable cost-to-compliance balance; requires disciplined drill cadence.

## 13) Five-step rollout guide (Good fit vs Not for)
1. Classify legal boundaries and workload criticality tiers.  
2. Model end-to-end fault domains including state and retrieval.  
3. Implement APIM policy package for TTFT/error/compliance-tag aware routing.  
4. Productize regional game-day drills with regression scoring.  
5. Operate a FinOps dashboard balancing cost per 1M calls against SLO adherence.  

**Good fit**: regulated global finance/payments/public-sector workloads with strict residency and high availability requirements.  
**Not for**: single-region low-criticality PoCs with no residency constraints and minimal platform budget.

## 14) Deliverables in this cycle
- Bilingual FAQ (this file + zh-CN counterpart), 15 sections in strict order.
- SVG one-pager: `assets/42-cycle-2528-daily-breakthroughs.svg`.
- H5 workbench: `workbench-cycle-2528.html` and selector entry `#2528`.
- 7-card outputs: `benchmark-cards.html` and `benchmark-cards.en.html` (4:5, self-contained CSP).
- Evidence bundle: `evidence/cycle-2528-*.{json,csv}`.

## 15) Runbook and acceptance commands
```bash
python workshops/azure-agent-infra/simulator/cycle_1123_pipeline.py --write
python workshops/azure-agent-infra/simulator/cycle_1123_pipeline.py --check
pytest workshops/azure-agent-infra/simulator -q
```
- Acceptance gates: `sections 1..15`, `max_suffix_repeat == 1`, workshops/docs byte parity, and full test pass.
