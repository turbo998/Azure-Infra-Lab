# Azure AI Agent Infrastructure Playbook: 6 Runtimes & 12 Production Scenarios Benchmark Report (7-Card 4:5 Visual Deck — English Edition)

> 🌐 **Language / 语言切换**: **[🇬🇧 English Version (test-report.en.md)](test-report.en.md)** | **[🇨🇳 中文版 (test-report.md)](test-report.md)** | **[📘 Playbook English (`README.en.md`)](README.en.md)** | **[📘 Playbook 中文版 (`README.md`)](README.md)** | **[🖼️ 7-Card HTML Deck (CSP Locked)](cards.html)**

**Provenance:** `anonymized_reported + deterministic_architecture_verifier (independently_reproduced=false)`, synthesized from first-party Microsoft Azure AI Infrastructure reference materials (`Agent Runtime Customer Pitch`, `AKSClaw Multi-Tenant Kubernetes`, `Agent Infra Playbook`, `E2B on Azure CheckRide v2 / Deep Dive v0.2`, and anonymized `Selection Logic` methodology) together with the local deterministic capacity and physics verifier [`simulator/agent_infra_sizer.py`](simulator/agent_infra_sizer.py) (**298 Chapters, 291 Bicep/Terraform/YAML Blueprints, 290 Quantitative Simulators, 299/299 Unit Tests Passing**). All customer PII and confidential financial rows were physically stripped prior to ingestion.

Structured data and offline-verifiable artifacts:
- [7-Card 4:5 Visual Benchmark HTML (CSP-Locked Self-Contained)](cards.html)
- [Full Sealed Benchmark & Sizing Payload (`report.json`)](report.json)
- [12 Production Scenario Routing Verifications (`evidence/test-scenarios.csv`)](evidence/test-scenarios.csv)
- [6 Generational Hardware & Boundary Perturbation Checks (`evidence/test-robustness.csv`)](evidence/test-robustness.csv)
- [6 Sandbox Startup & Snapshot Restore Latency Tiers (`evidence/test-batch-latency.csv`)](evidence/test-batch-latency.csv)

---

## Card 1 (`1 / 7` · `HANDS-ON · AZURE AI AGENT INFRASTRUCTURE BENCHMARK`): Overview & Selection Workbench

**Headline Finding:** **6 Azure Agent Runtimes, 108ms MicroVM restore** — Six complementary Azure Agent runtimes span managed simplicity to hypervisor-level control, with E2B on `Standard_D96as_v7` achieving **108 ms** Base MicroVM restore and **132 ms** Code-Interpreter V1 startup.

| Workbench Decision Field | Task Type | Core Evaluation Question | Evaluated Output | Confidence / Score | Action Band | Distribution Breakdown |
|---|---|---|---|---:|---|---|
| `e2b_turin_v7_speedup` | `choice` | Does Azure `Standard_D96as_v7` (5th-Gen AMD EPYC Turin + Azure Boost) outperform `D96s_v6` and `D96as_v6` on E2B sandbox startup? | `108 ms Base / 132 ms Code-Interpreter V1` | `0.926` (92.6%) | `Act automatically` | `D96as_v7` 108ms/132ms, `D96s_v6` 116ms/159ms, `D96as_v6` 239ms/255ms |
| `aksclaw_security_enforcement` | `choice` | Are all 5 multi-tenant K8s agent security boundaries (`AKSClaw`) enforced at the platform layer without trusting the prompt? | `5 / 5 platform hard boundaries (100.0%)` | `1.000` (100.0%) | `Act automatically` | IMDS block (`169.254.169.254`), Egress allowlist, Credential injection proxy, Entra Agent ID, Unified AI Gateway |
| `playbook_delivery_gate` | `score` | When a customer requires deep infrastructure control beyond managed hosting but lacks an engineering team, can they be routed back to Foundry Hosted Agents? | `0% shortcut allowed (Hold for CSU / Partner)` | `0.750` (75.0%) | `Send to a human` | 9/12 positive routing scenarios pass; 3/12 anti-patterns deterministically blocked |

---

## Card 2 (`2 / 7` · `SCENARIO: MANUS × E2B 100K+ VIRTUAL COMPUTERS & AKSCLAW FLEET`): Single-Case Deep Dive

**Headline Finding:** **261 D96as_v7 nodes serve 100K sandboxes at 108ms** — A single Azure VMSS Flexible scale set with 261 `Standard_D96as_v7` client nodes (`278` total VMs) sustains 100,000 concurrent 512 MiB Firecracker MicroVMs with 108 ms startup.

| Decision Field | Task Type | Deep-Dive Verification Question | Verified Output | Confidence / Score | Action Band | Distribution Breakdown |
|---|---|---|---|---:|---|---|
| `vmss_100k_capacity_fit` | `choice` | Can 100,000 concurrent E2B sandboxes fit within a single Azure VMSS Flexible scale set (1,000 VM limit)? | `Yes · 261 Client Nodes (26.1% of limit)` | `0.850` (85.0%) | `Act automatically` | 384 GiB × 85% HugePages × 60% CPU autoscale threshold = 384 steady-state sandboxes/node |
| `apim_appgw_dual_hop_isolation` | `noul` | Can `AppGW WAF v2` (dual frontend IP) + `APIM rate-limit-by-key` isolate 100K+ dynamic sandbox subdomains and stream WebSockets? | `Yes (100% per-Host isolation)` | `P(true) = 1.0` | `Act automatically` | `counter-key="@(context.Request.Headers.GetValueOrDefault("Host"))"` |
| `upstream_e2b_production_readiness` | `score` | Can stock upstream open-source E2B API Server scale horizontally across instances and survive host reboots without state loss? | `1 / 4 HA criteria met (25.0%)` | `0.250` (25.0%) | `Confirm` | Upstream stores node state in single-process RAM and lacks orphan VM GC on reboot; requires state externalization |

---

## Card 3 (`3 / 7` · `WHAT I TESTED`): Full 12-Scenario Evaluation Matrix Across 6 Archetypes

| Scenario & Archetype | Architecture Evaluation Question | Model Answer (Reported %) | Expected Met? | Action | Evidence Anchor |
|---|---|---|---:|---|---|
| `S01 · 01 Customer-Facing Agent` | 30K+ monthly sessions, ~75% autonomous resolution over approved banking APIs with shared context | `Foundry + ACA/AKS + Cosmos DB (100%)` | Yes | `Auto` | Pitch Slide 15 (Commerzbank case) |
| `S02 · 01 Customer-Facing Agent` | Executes untrusted LLM-generated Python scripts and file parsing with low wait time | `ACA Apps + Dynamic Sessions (100%)` | Yes | `Auto` | Pitch Slides 7-8 (ACA Dynamic Sessions) |
| `S03 · 03 Digital-Native AI Product` | Requires custom OCI image, persistent workspace files, and explicit pause/resume across user tasks | `ACA Sandboxes Preview + HorizonDB (92%)` | Yes | `Confirm` | Pitch Slides 7, 9, 11 (Preview region/SLA check required) |
| `S04 · 03 Digital-Native AI Product` | Requires <150ms Firecracker MicroVM restore, per-Host session rate limiting, and WebSocket desktop/terminal streaming | `E2B on VMSS D96as_v7 108ms/132ms (100%)` | Yes | `Auto` | E2B CheckRide Slides 13-20 (Measured 108ms Base / 132ms Code-Interpreter) |
| `S05 · 02 Enterprise Agent Platform` | Per-engineer persistent agent, BYO Harness (Copilot/Hermes/OpenClaw), IcM auto-triage, Follow-the-Sun handoff | `AKSClaw 5-Boundary Runtime on AKS (100%)` | Yes | `Auto` | AKSClaw Slides 3-17 (Skills, Sandbox, Security, Identity, AI Gateway, Governance) |
| `S06 · 05 Multi-Agent Workflow` | Multi-agent review + mandatory human approval wait + deterministic retry/recovery independent of compute pod lifecycle | `Durable Functions + ACA Apps + DB (100%)` | Yes | `Auto` | Pitch Slides 6, 7, 12 & Playbook Slide 10 |
| `S07 · 05 Multi-Agent Workflow` | LangGraph Triage Agent -> GH Copilot SDK Coding Agent (Shell/MCP) -> Foundry Compliance Agent | `MAF + GH Copilot SDK + Foundry (100%)` | Yes | `Auto` | Pitch Slide 13 (MAF + GitHub Copilot SDK loop) |
| `S08 · 04 Agent Factory` | To-B standard internal agents needing SAP/Salesforce/Slack/M365 integration with minimal infra management | `Foundry Hosted Agents + MCP Toolboxes (100%)` | Yes | `Auto` | Playbook Slide 7 & Pitch Slides 6, 14 |
| `S09 · 06 Regulated Industry Agent` | Customer demands deep infra control beyond managed hosting, but has NO dedicated development/ops team | `Direct Foundry fallback rejected; CSU/Partner gate triggered (0% shortcut)` `✕` | No | `Human` | Playbook Slide 7 Notes (Do not route unmet control requirement to Foundry due to missing devs) |
| `S10 · 02 Enterprise Agent Platform` | Can stock open-source E2B API process scale horizontally across nodes without state loss on reboot? | `Single-process in-memory node state lost on reboot (25%)` `✕` | No | `Confirm` | e2b infra deep dive v0.2 Slide 34 (E2B Architecture Weakness) |
| `S11 · 06 Regulated Industry Agent` | Does deploying an Agent container to ACA/AKS automatically enable full Entra Agent ID governance & block user token inheritance? | `Not automatic; requires explicit Agent ID + Gateway key custody (33%)` `✕` | No | `Confirm` | Pitch Slide 16 & AKSClaw Slides 14-16 |
| `S12 · 04 Agent Factory` | Does failing the $10,000/mo Jun-Aug Foundry Models gate automatically disqualify an account from Strong ACR / P1? | `No; non-model Specific or General+3 Foundations still qualify (100%)` | Yes | `Auto` | Playbook Slide 13 & Selection Logic (Signal vs Amount rule) |

---

## Card 4 (`4 / 7` · `UNDER THE HOOD`): APIM Dynamic Host Rate-Limiting & AKSClaw 5 Hard Boundaries

```xml
<!-- 1. E2B on Azure: APIM Per-Sandbox Dynamic Subdomain Rate Limit (<port>-<sandboxId>.domain.com) -->
<inbound>
  <base />
  <rate-limit-by-key calls="300" renewal-period="60"
    counter-key="@(context.Request.Headers.GetValueOrDefault(&quot;Host&quot;, &quot;unknown&quot;))"
    increment-condition="@(context.Response.StatusCode &gt;= 200 &amp;&amp; context.Response.StatusCode &lt; 400)" />
  <set-backend-service base-url="http://10.240.0.10:8080" /> <!-- Callback to AppGW Private Frontend -->
</inbound>
```

` ↓ Combined with AKSClaw Kata Pod VM Hardware Virtualization + Entra Agent ID + Unified AI Gateway ↓ `

```yaml
# 2. AKSClaw Kata Pod VM + NetworkPolicy + AI Gateway Contract (Zero LLM API Key in Agent Pod)
runtimeClassName: kata-mshv-vm-isolation   # Dedicated Hypervisor guest kernel isolation
serviceAccountName: entra-agent-id-alice   # Blueprint + Human Sponsor dual identity binding
env:
  - name: OPENAI_BASE_URL
    value: "http://ai-gateway.platform.svc.cluster.local/v1" # Prefix-Cache affinity + RPM/TPM hard circuit breaker
# Zero API keys inside container; NetworkPolicy blocks 169.254.169.254 IMDS -> <answer>
```

---

## Card 5 (`5 / 7` · `ROBUSTNESS CHECK`): Generational Silicon, State Reclamation & Security Boundary Perturbations

| Evaluation Dimension | Paired Comparison (Original vs Perturbed / Upgraded) | Baseline % | Perturbed / Upgraded % | Delta (pts) | Primary Finding Holds? |
|---|---|---:|---:|---:|---|
| `E2B Sandbox Cold Start: AMD Turin v7 vs Intel v6 (Code-Interpreter V1)` | D96s_v6 Intel (159 ms -> 62.9% speed index) vs D96as_v7 AMD Turin (132 ms -> 75.8% speed index) | `62.9` | `75.8` | `+12.9` | Yes |
| `E2B Sandbox Cold Start: AMD Genoa v6 vs AMD Turin v7 (Base MicroVM)` | D96as_v6 Genoa (239 ms -> 41.8% speed index) vs D96as_v7 Turin (108 ms -> 92.6% speed index) | `41.8` | `92.6` | `+50.8` | Yes |
| `State Persistence Across Idle Reclamation (Dynamic Sessions vs Sandboxes)` | ACA Dynamic Sessions (0% workspace retained after idle reclamation) vs ACA Sandboxes Preview + HorizonDB (100% snapshot + ACID state retained) | `0.0` | `100.0` | `+100.0` | Yes |
| `Multi-Tenant Security Controls: In-Agent Prompt Rules vs Platform Hard Boundaries` | Agent-Side Soft Config (0% immune to prompt injection / --yolo bypass) vs AKSClaw Platform Hard Controls (100% IMDS block + Egress + AI Gateway) | `0.0` | `100.0` | `+100.0` | Yes |
| `VMSS Autoscaling Direction Asymmetry (CPU Scale-Out vs HugePages Scale-In)` | Scale-Out @ 60% CPU (100% automated reactive horizontal expansion) vs Scale-In (0% blind termination; 100% gated by HugePages drain & live migration) | `100.0` | `100.0` | `0.0` | Yes |
| `Propensity Screening Gate: Historical $1,000 vs Adopted $10,000 Foundry Models Rule` | Raw Relevant ACR Dollar Retention (100% preserved in both releases) vs Non-Model Strong ACR Route Eligibility (100% preserved when model gate <$10K) | `100.0` | `100.0` | `0.0` | Yes |

---

## Card 6 (`6 / 7` · `LATENCY & STARTUP SCALING`): Sandbox Startup & Snapshot Restore Latency Comparison

| Latency Comparison Tier | Optimized Path Latency (`#2563EB`) | Baseline Path Latency (`#CBD5E1`) | Provenance & Notes |
|---|---|---|---|
| `E2B Base Sandbox Restore (D96as_v7 Turin vs D96as_v6 Genoa)` | **108 ms (AMD v7 Turin + UFFD)** | 239 ms (AMD v6 Genoa) | Measured in E2B_CheckRide_Reordered_v2.pdf Slide 19 |
| `E2B Base Sandbox Restore (D96as_v7 Turin vs D96s_v6 Intel)` | **108 ms (AMD v7 Turin)** | 116 ms (Intel v6 Emerald Rapids) | Measured in E2B_CheckRide_Reordered_v2.pdf Slide 19 |
| `E2B Code-Interpreter V1 Startup (D96as_v7 Turin vs D96as_v6 Genoa)` | **132 ms (AMD v7 Turin + Jupyter/envd)** | 255 ms (AMD v6 Genoa) | Measured in E2B_CheckRide_Reordered_v2.pdf Slide 19 |
| `E2B Code-Interpreter V1 Startup (D96as_v7 Turin vs D96s_v6 Intel)` | **132 ms (AMD v7 Turin)** | 159 ms (Intel v6 Emerald Rapids) | Measured in E2B_CheckRide_Reordered_v2.pdf Slide 19 |
| `ACA Dynamic Sessions Allocation (Pre-Warmed Pool vs Cold Container)` | **~210 ms (Pre-Warmed Hyper-V Pool)** | ~2,200 ms (Unwarmed Container Cold Start) | Architecture reference model (Pitch Slide 8 pre-warmed pool) |
| `ACA Sandboxes Workspace Recovery (Memory/Disk Snapshot vs Full Rebuild)` | **~320 ms (Snapshot Resume)** | ~1,650 ms (Cold OCI + Volume Init) | Architecture reference model (Pitch Slide 9 snapshot restore) |

---

## Card 7 (`7 / 7` · `MY TAKE`): Good Fit vs Architectural Anti-Patterns (Not For)

- **✅ Good Fit (Strongly Recommended)**:
  1. **Foundry Hosted Agents**: Standard To-B internal assistants reusing 1,400+ MCP connectors and Entra Agent ID with zero cluster operations.
  2. **Azure Functions + Durable Functions**: Long-running HITL approvals, cross-system sagas, and zero-cost scale-to-zero event waits.
  3. **ACA Dynamic Sessions / ACA Sandboxes (Preview)**: Sub-second untrusted code execution (`~210 ms` Hyper-V pre-warmed pool) or stateful coding/browser workspaces requiring explicit `pause/resume` snapshots.
  4. **AKS + Kata (`AKSClaw`)**: Multi-tenant enterprise agent platforms & SRE fleets combining shared read-only skill registries, dedicated RWO state volumes, and 5 non-bypassable platform hard boundaries.
  5. **E2B on Azure VMSS (`Standard_D96as_v7`)**: 100,000+ concurrent cloud virtual computers (`Manus` pattern) with `108 ms` Base / `132 ms` Code-Interpreter V1 snapshot restore.
- **⛔ Not For (Strict Guardrails)**:
  1. **Never** route a customer who requires deep infrastructure control back to Foundry Hosted Agents simply because they lack a dev team — engage CSU/Partner delivery first.
  2. **Never** store durable business state solely on ACA Dynamic Sessions local scratch disks (wiped on idle reclamation; externalize to `HorizonDB` or `Cosmos DB`).
  3. **Never** scale in E2B VMSS nodes based on host CPU/RAM metrics alone (Firecracker pre-allocates `HugePages`; require active sandbox drain/migration before node termination).
  4. **Never** mount static LLM API keys inside agent containers or allow agents to inherit raw user OBO login tokens.
