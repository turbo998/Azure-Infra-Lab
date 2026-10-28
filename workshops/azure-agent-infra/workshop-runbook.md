# Azure AI Agent Infrastructure — Step 04 Validate: Customer Workshop & Architecture Design Session Runbook (Bilingual EN / 中文)

> 🌐 **Language / 语言导航**: **[📘 Playbook 中文版 (`README.zh-CN.md`)](README.zh-CN.md)** | **[📘 Playbook English (`README.en.md`)](README.en.md)** | **[📊 7-Card Report (ZH)](test-report.md)** | **[📊 7-Card Report (EN)](test-report.en.md)**
>
> **Purpose**: Actionable field delivery guide for **Step 04 Validate (1/2-Day or 1-Day Hands-On Workshop + Target Architecture Whiteboard Session)** from the *Agent Infra Playbook* (`Agent_Infra_Playbook.pptx`, Slides 14–18).
> **定位**：面向架构师与现场交付团队的 **Step 04 Validate（半天/全天动手工作坊 + 目标架构白板共创）** 落地执行手册（覆盖 284 章行业模型、277 套 IaC 蓝图与 276 项定量仿真器，285/285 项单测全绿）。

---

## 1. Executive Objective of Step 04 Validate

In the 5-step Azure Agent Infra Playbook (`Initial Screening → Discovery → Define → Validate → Implement`), **Step 04 Validate** is the primary conversion inflection point:
- **Morning (Hands-On Lab, 2.5 hrs)**: Customer platform and AI engineers deploy a working slice of the target runtime (`ACA Dynamic Sessions / Sandboxes`, `AKSClaw Kata VM`, or `E2B on Azure VMSS`) connected to a durable state store (`Azure HorizonDB` or `Cosmos DB`).
- **Afternoon (Target Architecture Whiteboard, 2.0 hrs)**: Jointly finalize the production **Target Architecture Diagram**, **5 Hard Security Boundaries**, **Capacity & Cost Sizing Table**, and **4-Week Production Cutover Plan**.

---

## 2. Half-Day / Full-Day Workshop Agenda

| Time Block | Duration | Module | Deliverable |
|---|---:|---|---|
| **09:30 – 10:00** | 30 min | **Module 1: 4-Layer Panorama & 6-Tier Runtime Spectrum** | Walk through [SVG 01](assets/01-azure-agent-infra-4layer-panorama.svg) & [SVG 02](assets/02-runtime-spectrum-6tier-matrix.svg); align on why Agent Infra requires sandbox isolation + state checkpointing |
| **10:00 – 10:45** | 45 min | **Module 2: Two-Stage Decision Tree & Delivery Gate Check** | Run [Interactive Selector (`h5/selector.html`)](h5/selector.html) against customer's actual concurrency, isolation, and dev-team readiness |
| **10:45 – 12:00** | 75 min | **Module 3: Hands-On Lab Track (Select Track A, B, or C below)** | Execute `python demo/run_live_demo.py --self-test` and deploy the corresponding blueprint from [`blueprints/`](blueprints) |
| **13:30 – 14:30** | 60 min | **Module 4: Zero-Trust Control Plane & 5 Hard Boundaries Stress Test** | Run red-team attack simulations in [`h5/demo.html`](h5/demo.html); verify IMDS block (`169.254.169.254/32`), Egress Lockdown, Keyless Pod, and AI Gateway Token Circuit Breaker |
| **14:30 – 15:30** | 60 min | **Module 5: State Persistence & Capacity Sizing Whiteboard** | Size VMSS/AKS nodes and `Azure HorizonDB + PgBouncer` WAL retention using Tool 2 & Tool 4 in [`h5/selector.html`](h5/selector.html) |
| **15:30 – 16:00** | 30 min | **Module 6: Sign-Off on Target Architecture & Step 05 Milestones** | Agree on PoC exit criteria, CSU/Partner assignment, and target production launch date |

---

## 3. Three Selectable Hands-On Lab Tracks

### Track A: Managed PaaS Sandbox Track (`ACA Apps + ACA Dynamic Sessions / ACA Sandboxes`)
- **Best For**: Enterprise To-B teams needing sub-second isolated code execution (`~210ms` pre-warmed Hyper-V pool) or stateful coding workspaces without operating Kubernetes or Firecracker clusters.
- **Blueprint Used**: [`blueprints/aca-dynamic-sessions-pool.bicep`](blueprints/aca-dynamic-sessions-pool.bicep) + [`blueprints/horizondb-langgraph-checkpointer.py`](blueprints/horizondb-langgraph-checkpointer.py)
- **Verification Criteria**:
  1. `sessionNetworkConfiguration.status == 'EgressDisabled'` verified;
  2. Untrusted Python payload executes in `< 250ms` from ready pool;
  3. Conversation checkpoint persisted in HorizonDB via PgBouncer (`:6432`) in `< 15ms`.

### Track B: Multi-Tenant Kubernetes Fleet Track (`AKS + Kata Pod VM / AKSClaw`)
- **Best For**: Platform engineering teams running 50–1,000+ persistent Dev/SRE/Analyst agents (`OpenClaw` / `Hermes` / `LangGraph`) sharing a team skill registry (`/skills` ReadOnlyMany) with isolated per-instance workspaces (`/workspace` ReadWriteOnce).
- **Blueprint Used**: [`blueprints/aksclaw-kata-fleet.yaml`](blueprints/aksclaw-kata-fleet.yaml) + [`blueprints/entra-agent-id-ai-gateway-policy.xml`](blueprints/entra-agent-id-ai-gateway-policy.xml)
- **Verification Criteria**:
  1. Pod scheduled with `runtimeClassName: kata-vm-isolation` (`Standard_D64s_v6` hosts `109` sandboxes/node at `85.16%` memory efficiency);
  2. `curl http://169.254.169.254/metadata/identity/oauth2/token` times out (`100%` dropped by NetworkPolicy);
  3. `env` inside container contains zero raw API keys; all model calls pass through Unified AI Gateway with `x-ms-audit-dual-attribution`.

### Track C: 100K-Scale Firecracker MicroVM Cloud Computer Track (`E2B on Azure VMSS Flexible`)
- **Best For**: Digital-native To-C AI products (`Manus`-style autonomous virtual computers) requiring `10,000–100,000+` concurrent sandboxes and `108ms` Base / `132ms` Code-Interpreter resume latency.
- **Blueprint Used**: [`blueprints/e2b-vmss-d96as-v7.bicep`](blueprints/e2b-vmss-d96as-v7.bicep) + [`blueprints/e2b-apim-per-host-policy.xml`](blueprints/e2b-apim-per-host-policy.xml)
- **Verification Criteria**:
  1. `Standard_D96as_v7` VMSS Flexible deployed with `enableAcceleration: true` and `nr_hugepages=174080` (`340 GiB` HugePages);
  2. Double-hop ingress (`AppGW WAF v2` Public+Private frontend → `APIM` per-Host `rate-limit-by-key` → `Nomad Client Pool`) verified with `*.e2b.<domain>` wildcard TLS;
  3. Firecracker UFFD + NBD snapshot resume verified at `< 150ms` p50 under `50x` concurrent burst.

---

## 4. Production Cutover Readiness Checklist (Step 04 → Step 05 Exit Gate)

| Category | Check Item | Target Metric / Invariant | Status |
|---|---|---|---|
| **Delivery Governance** | Dedicated customer engineering team or signed CSU/Partner delivery plan | Required whenever `needs_infra_control_beyond_managed == true` | `[ ]` |
| **Compute Isolation** | Untrusted code or `--yolo` autonomous loop runs inside hardware virtualization | Hyper-V (`ACA`), Kata Pod VM (`AKS`), or KVM/Firecracker (`E2B`) | `[ ]` |
| **IMDS Protection** | Host metadata endpoint `169.254.169.254/32` blocked from all agent sandboxes | `100%` packet drop in NetworkPolicy / iptables | `[ ]` |
| **Credential Hygiene** | Zero raw LLM API keys or database connection strings inside sandbox env | `OPENAI_BASE_URL` points to internal AI Gateway (`Keyless Pod`) | `[ ]` |
| **Token Budget Guard** | Per-Agent / Per-Team TPM & Daily USD hard circuit breaker active at gateway | Automatic `HTTP 429` before runaway loop exhausts subscription quota | `[ ]` |
| **State & Retention** | Durable checkpointer (`HorizonDB + PgBouncer` or `Cosmos DB`) + 30-day TTL | PgBouncer handoff `~5ms`; 30-day ZSTD hot retention `< 128 TB` | `[ ]` |
