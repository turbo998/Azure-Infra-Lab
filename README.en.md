# Azure Infra Lab (`turbo998/Azure-Infra-Lab`) — English Edition

> 🌐 **Language / 语言版本切换**: **[🇬🇧 English Homepage (README.en.md)](README.en.md)** | **[🇨🇳 中文主页 (README.md)](README.md)** | **[📘 Azure Agent Infra Playbook (English)](workshops/azure-agent-infra/README.en.md)** | **[📘 Azure Agent Infra Playbook (中文)](workshops/azure-agent-infra/README.md)** | **[🎬 FabCon & SQLCon 2026 Video Hub H5](https://turbo998.github.io/Azure-Infra-Lab/workshops/fabcon-sqlcon-2026/index.html?lang=en)**

> **📌 Executive Overview Summary**
> - **AI Agent Infrastructure on Azure (`AKSClaw × E2B`)**: Defines a 6-Layer Agent Infra Reference Architecture (`Build · Run · Ground · Govern`), empirical **100K Sandbox Scale Benchmarks** (**`80 ms` Firecracker microVM cold start / `108 ms` UFFD restore** on 5th-Gen AMD EPYC Turin `Standard_D96as_v7` vs **`1,420 ms` Kata VM cold boot**, **`~$148K/mo` optimized TCO** across 261 client nodes at 100K sandboxes, and Nomad heartbeat drain resilience), a **Runtime & Storage Decision Matrix** (ACA Dynamic Sessions vs AKS + Kata vs E2B vs Daytona; Azure Files NFS v4.1 vs Managed Lustre vs Blob FUSE2), and a **298-Chapter Semiconductor/AI Factory & Agent Infrastructure Encyclopedia** ([`docs/full-monograph-archive.en.md`](workshops/azure-agent-infra/docs/full-monograph-archive.en.md)).
> - **Data & AI / FabCon & SQLCon Barcelona 2026 Video Hub**: Interactive bilingual briefing with 5 official Microsoft 1080p/720p demo videos, 6 strategic pillars, and an 18-item GA/Preview release matrix.
> - **Compute / Azure VM Modernization & FinOps**: Trilingual partner workshop (`zh-CN` / `zh-TW` / `en`), 6 synthetic assessment cases, and browser-local TCO calculator.

### Core Architecture Diagrams

![Azure AI Agent Infra 6-Layer Reference Architecture](workshops/azure-agent-infra/assets/svg/01-six-layer-architecture.svg)

![100K Concurrent Sandbox Topology & 5-Step Execution Flow](workshops/azure-agent-infra/assets/svg/08-100k-sandbox-topology.svg)

Public Azure infrastructure engineering playbooks, interactive H5 simulators, and partner workshops:

1. **[AI Agent Infrastructure on Azure Playbook & Interactive Simulator (`AKSClaw × E2B on Azure` · Bilingual EN/中文)](workshops/azure-agent-infra/README.en.md)**:
   - **298 Chapters · 291 Production IaC Blueprints · 290 Deterministic Physics Simulators · 299/299 Unit Tests Passing**
   - **Live GitHub Pages (Bilingual `EN / 中文` Toggle)**:
     - [Interactive Playbook Atlas (`index.html`)](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/index.html)
     - [Live Dual-Track Simulator (`demo.html`)](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/demo.html)
     - [Decision Engine, 100K Sandbox Sizer & 290 Domain Simulators (`selector.html`)](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/selector.html)
     - [7-Card 4:5 Benchmark Deck (`cards.html`)](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/cards.html)
   - **Documentation**: [English Playbook (`README.en.md`)](workshops/azure-agent-infra/README.en.md) · [中文 Playbook (`README.md`)](workshops/azure-agent-infra/README.md) · [Full 298-Chapter Archive (`docs/full-monograph-archive.md`)](workshops/azure-agent-infra/docs/full-monograph-archive.md) · [English 7-Card Report (`test-report.en.md`)](workshops/azure-agent-infra/test-report.en.md) · [中文 7-Card 报告 (`test-report.md`)](workshops/azure-agent-infra/test-report.md)
2. **[Data & AI / FabCon & SQLCon Barcelona 2026 Executive Briefing & Interactive Video Hub (Bilingual EN/中文)](workshops/fabcon-sqlcon-2026/README.en.md)**:
   - **5 Embedded Official Microsoft CDN 1080p/720p Product Demo Videos · 6 Strategic Pillars · 18-Capability GA/Preview Filterable Matrix · 8 Companion Deep-Dive Blogs**
   - **Live GitHub Pages (Bilingual `EN / 中文` Toggle)**:
     - [Interactive Video Briefing H5 — English (`index.html?lang=en`)](https://turbo998.github.io/Azure-Infra-Lab/workshops/fabcon-sqlcon-2026/index.html?lang=en)
     - [交互式双语视频简报 H5 — 中文 (`index.html`)](https://turbo998.github.io/Azure-Infra-Lab/workshops/fabcon-sqlcon-2026/index.html)
   - **Documentation**: [English Full Briefing (`README.en.md`)](workshops/fabcon-sqlcon-2026/README.en.md) · [中文完整简报 (`README.zh-CN.md`)](workshops/fabcon-sqlcon-2026/README.zh-CN.md) · [Bilingual Overview (`README.md`)](workshops/fabcon-sqlcon-2026/README.md)
3. **[Compute / Azure VM Modernization & FinOps Partner Workshop](workshops/azure-vm-modernization/README.md)** — Trilingual course (`zh-CN` / `zh-TW` / `en`), six synthetic cases, browser-local calculator, and standalone exports.
