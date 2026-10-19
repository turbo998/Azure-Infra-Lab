#!/usr/bin/env python3
"""
Publishes the verified Azure AI Agent Infrastructure Playbook, 8 SVGs, 7-Card Benchmark
Report, Interactive H5 Suite, Runnable Demo, and IaC Blueprints to:
  1. turbo998/ai-infra-lab (docs/azure-agent-infra/ + root README.md)
  2. turbo998/ai-research-public (docs/research/azure-agent-infra/ + docs/research/index.md + root README.md)
directly on `refs/heads/main` via the GitHub Git Data API (`gh api`) without touching
any local checkout files.
"""

from __future__ import annotations

import base64
import json
import subprocess
import time
from pathlib import Path
from typing import Any, Dict, List


BUNDLE_DIR = Path(__file__).resolve().parent.parent
BLOB_CACHE_FILE = BUNDLE_DIR / ".blob_sha_cache.json"


def gh_api(endpoint: str, method: str = "GET", payload: Dict[str, Any] | None = None) -> Dict[str, Any]:
    cmd = ["gh", "api", endpoint, "--method", method]
    input_bytes = None
    if payload is not None:
        cmd.extend(["--input", "-"])
        input_bytes = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    for attempt in range(6):
        try:
            proc = subprocess.run(cmd, input=input_bytes, capture_output=True, check=True)
            return json.loads(proc.stdout.decode("utf-8"))
        except subprocess.CalledProcessError:
            if attempt == 5:
                raise
            time.sleep(2.0 * (attempt + 1))
    raise RuntimeError("Unreachable")


def _load_blob_cache() -> Dict[str, str]:
    if BLOB_CACHE_FILE.exists():
        try:
            return json.loads(BLOB_CACHE_FILE.read_text(encoding="utf-8"))
        except Exception:
            return {}
    return {}


def _save_blob_cache(cache: Dict[str, str]) -> None:
    BLOB_CACHE_FILE.write_text(json.dumps(cache, indent=2), encoding="utf-8")


def create_blob(repo: str, content_bytes: bytes) -> str:
    import hashlib
    digest = hashlib.sha256(content_bytes).hexdigest()
    cache = _load_blob_cache()
    cache_key = f"{repo}:{digest}"
    if cache_key in cache:
        return cache[cache_key]
    b64 = base64.b64encode(content_bytes).decode("ascii")
    res = gh_api(f"repos/{repo}/git/blobs", method="POST", payload={"content": b64, "encoding": "base64"})
    cache[cache_key] = res["sha"]
    _save_blob_cache(cache)
    return res["sha"]


def collect_bundle_files() -> List[Path]:
    files: List[Path] = []
    for p in sorted(BUNDLE_DIR.rglob("*")):
        if (
            p.is_file()
            and "__pycache__" not in p.parts
            and p.name not in ("publish_via_github_api.py", ".blob_sha_cache.json")
        ):
            files.append(p)
    return files


def build_ai_infra_lab_readme() -> str:
    return """# AI Infra Lab (`turbo998/ai-infra-lab`)

面向 **AI Infra 架构师** 的云厂商与智算基础设施全栈技术深度测评与可视化图谱仓库，覆盖 **AI 算力芯片（GPU / PPU / ASIC / CPU / Switch / SmartNIC / SSD 主控）**、**超节点与 Scale-Up/Scale-Out 智算网络（RDMA / RoCE / CXL / ICN）**、**异构算力调度平台**、**云原生分布式训推平台** 与 **企业级 MaaS / AI Agent 运行时与安全沙箱基础设施（Azure AI Agent Infra）**。

---

## 📚 深度测评报告目录（Research & Architecture Evaluations）

| 专题报告 | 核心覆盖范围 | 可视化图表 (`SVG` + `H5` + `7-Card`) | 证据台账 | 审校记录 | 更新日期 |
|---|---|---|---|---|---|
| **[Azure AI Agent Infra 全栈方案设计、技术选型与架构师 Playbook](docs/azure-agent-infra/README.md)** | **L1 Build 编排层**（MAF · GitHub Copilot SDK · LangGraph · OpenClaw · Hermes · MCP/A2A）· **L2 Run 六大运行时光谱**（Foundry Hosted Agents · Durable Functions · ACA Dynamic Sessions · ACA Sandboxes Preview · AKS + Kata `AKSClaw` · E2B on Azure VMSS `D96as_v7` `108ms/132ms`）· **L3 Ground 状态与记忆底座**（Azure HorizonDB Preview + PgBouncer 5ms + Cosmos DB + Firecracker UFFD/NBD Snapshot）· **L4 Govern 零信任控制面**（Entra Agent ID · Unified AI Gateway · 169.254.169.254 IMDS 封禁 · 5 道平台硬边界）· **现场五步落地法与 10万并发沙箱测算器** | 8 张高清矢量架构图 + [7-Card 4:5 基准报告](docs/azure-agent-infra/test-report.md) + [4 页交互式 H5 套件](docs/azure-agent-infra/h5/index.html) + [可运行 Demo](docs/azure-agent-infra/demo/run_live_demo.py) | [`evidence.json`](docs/azure-agent-infra/evidence.json)（5 份核心工程资产 + 官方信源） | [`review.md`](docs/azure-agent-infra/review.md) | 2026-10-19 |
| **[阿里云 AI Infra 全栈架构深度测评报告](docs/alibaba-cloud-ai-infra/README.md)** | **L0 平头哥芯片**（含光 800、真武 810E / M890 / V900 / J900、倚天 710/750、ICN Switch 1.0、磐脉 920、镇岳 510）· **L1 智算底座与网络**（磐久 AL128 超节点、CIPU、HPN 7.0 双上联×多轨×双平面、Solar-RDMA、eRDMA、ACCL、CPFS）· **L1.5 灵骏智算**（`hz` 亲和性调度、双平面网卡）· **L2 人工智能平台 PAI（“Pi平台”）**（DSW / DLC AIMaster+EasyCKPT / EAS Prefix-Cache 路由+EP/PD 分离 / 父子配额潮汐抢占）· **L3 百炼平台（Model Studio）**（Token / PTU / DTU / MU 四大算力阶梯与后训练流水线） | 6 张高清矢量架构图 + 2 幅交互式 Mermaid 决策图 | [`evidence.json`](docs/alibaba-cloud-ai-infra/evidence.json)（21 篇一手信源） | [`review.md`](docs/alibaba-cloud-ai-infra/review.md) | 2026-10-14 |

---

## 📊 Azure AI Agent Infra 核心可视化图谱速览（Visual Atlas）

- **核心技术资产入口**：[完整 Playbook 正文 (`README.md`)](docs/azure-agent-infra/README.md) · [7-Card 4:5 基准评测报告 (`test-report.md`)](docs/azure-agent-infra/test-report.md) · [离线自包含 7-Card HTML (`test-report-cards.html`)](docs/azure-agent-infra/test-report-cards.html) · [交互式 H5 全景手册 (`h5/index.html`)](docs/azure-agent-infra/h5/index.html) · [AKSClaw × E2B 实时仿真台 (`h5/demo.html`)](docs/azure-agent-infra/h5/demo.html) · [选型决策与 10万沙箱计算器 (`h5/selector.html`)](docs/azure-agent-infra/h5/selector.html) · [IaC 与网关策略蓝图 (`blueprints/`)](docs/azure-agent-infra/blueprints)

### 1. Azure AI Agent Infra 四层全栈参考架构全景图（Build · Run · Ground · Govern）
![Azure AI Agent Infra 四层全栈参考架构全景图](docs/azure-agent-infra/assets/01-azure-agent-infra-4layer-panorama.svg)

### 2. Azure 六大 Agent Runtime 责任边界、隔离机制与恢复延迟对比矩阵
![Azure 六大 Agent Runtime 对比矩阵](docs/azure-agent-infra/assets/02-runtime-spectrum-6tier-matrix.svg)

### 3. AI Agent Infra on Azure 双阶段架构选型决策树与数据底座配对图
![双阶段架构选型决策树](docs/azure-agent-infra/assets/03-scenario-decision-tree-and-routing.svg)

### 4. AKSClaw 多租户 Kubernetes Agent 平台参考架构（六大支柱与五道平台硬边界）
![AKSClaw 多租户 Kubernetes Agent 平台参考架构](docs/azure-agent-infra/assets/04-aksclaw-multi-tenant-k8s-architecture.svg)

### 5. E2B on Azure VMSS 生产级参考架构图（Manus × E2B 10万+ 并发云端沙箱底座）
![E2B on Azure VMSS 生产级参考架构图](docs/azure-agent-infra/assets/05-e2b-on-azure-vmss-reference-architecture.svg)

### 6. Firecracker MicroVM 沙箱内部机理（UFFD + NBD）与 Azure v6/v7 实测启动延迟对比
![Firecracker MicroVM 内部机理与实测延迟对比](docs/azure-agent-infra/assets/06-e2b-microvm-internals-and-vm-benchmark.svg)

### 7. 多智能体协同工作流（MAF × Copilot SDK × Durable）与状态持久化选型矩阵
![多智能体协同工作流与状态持久化矩阵](docs/azure-agent-infra/assets/07-multi-agent-workflow-and-state-checkpoint.svg)

### 8. Azure Agent Infra Playbook 六大高优场景、四维资质筛查与五步落地工作流
![Playbook 六大场景与五步落地工作流](docs/azure-agent-infra/assets/08-field-playbook-5step-execution-flow.svg)

---

## 📊 阿里云 AI Infra 核心可视化图谱速览（Visual Atlas）

### 1. “通-云-哥” L0–L3 全栈垂直整合架构与三大跨层协同闭环
![阿里云 AI Infra 全栈垂直整合架构图](docs/alibaba-cloud-ai-infra/assets/01-tong-yun-ge-architecture.svg)

### 2. 平头哥真武 PPU 四代演进（810E → M890 → V900 → J900）与主流 GPU 关键指标对比
![真武 PPU 四代演进与主流 GPU 对比](docs/alibaba-cloud-ai-infra/assets/02-zhenwu-ppu-vs-gpu-comparison.svg)

### 3. 磐久 AL128 高密超节点“算-存-网”平头哥五芯全自研数据通路图
![磐久 AL128 超节点五芯数据通路图](docs/alibaba-cloud-ai-infra/assets/03-panjiu-al128-five-chip-datapath.svg)

### 4. 阿里云 HPN 7.0（SIGCOMM 2024）双上联 × 多轨 × 双平面网络架构与实测收益
![阿里云 HPN 7.0 双平面网络拓扑与性能收益](docs/alibaba-cloud-ai-infra/assets/04-hpn7-dual-plane-topology.svg)

### 5. PAI 训推一体潮汐配额树与 PAI-EAS Prefix-Cache 智能路由官方实测加速比
![PAI 潮汐抢占与 EAS Prefix-Cache 实测对比](docs/alibaba-cloud-ai-infra/assets/05-pai-tidal-preemption-and-eas-benchmark.svg)

### 6. 百炼平台四大算力阶梯对比与 AI Infra 架构师 6 大核心场景选型矩阵
![百炼四大算力模式与架构师选型矩阵](docs/alibaba-cloud-ai-infra/assets/06-bailian-resource-modes-and-architect-matrix.svg)

---

## 🗂️ 仓库目录结构

```text
ai-infra-lab/
├── README.md                                                     # 仓库总览与可视化图谱导览
└── docs/
    ├── azure-agent-infra/
    │   ├── README.md                                             # Azure AI Agent Infra 全栈架构设计与选型 Playbook
    │   ├── test-report.md                                        # 7-Card 4:5 基准评测报告 (Markdown)
    │   ├── test-report-cards.html                                # 7-Card 4:5 自包含离线视觉卡片 (CSP-Locked)
    │   ├── report.json                                           # 密封评测数据集 (含 SHA-256 校验)
    │   ├── evidence.json                                         # 证据台账与匿名化合规边界
    │   ├── review.md                                             # 审校记录与质量门禁清单
    │   ├── assets/                                               # 8 张高清 SVG 矢量架构图与工作流图 (01..08)
    │   ├── h5/                                                   # 4 页交互式 H5 手册、实时仿真台与 10万沙箱计算器
    │   ├── demo/                                                 # 可运行全链路仿真与验证脚本 (run_live_demo.py)
    │   ├── blueprints/                                           # AKSClaw K8s YAML、APIM XML、VMSS Bicep、HorizonDB 模板
    │   └── simulator/                                            # 确定性选型引擎、容量测算器与 8 项单元测试
    └── alibaba-cloud-ai-infra/
        ├── README.md                                             # 阿里云 AI Infra 全栈架构深度测评主报告
        ├── evidence.json                                         # 21 篇一手技术信源与证据链台账
        ├── review.md                                             # 完整性、证据边界与可视化核验记录
        └── assets/                                               # 6 张高清 SVG 矢量架构图 (01..06)
```
"""


def build_ai_research_public_readme() -> str:
    return """# AI Research

面向可复核证据的公开 AI 研究，由 **turbo998** 维护。当前发布 **Azure AI Agent Infra 全栈方案设计与架构选型 Playbook（含 7 页 4:5 视觉卡片评测与交互式 H5 仿真）**、**Personal agents 五产品比较** 与 **Omarchy agent 设计机制及 7 页 4:5 视觉卡片契约评测** 三个专题的原创分析、公开来源链接与可复核测试报告；不包含其他未公开材料或其 Git 历史。公开不代表取得第三方素材的再分发许可。

## 三类研究入口

| 分类 | 入口与当前状态 |
|---|---|
| Agent | [Agent 研究索引](docs/research/index.md#agent)：含 [Omarchy agent 设计机制](docs/research/omarchy-agent-design/README.md)（含 [7 页 4:5 视觉卡片测试报告](docs/research/omarchy-agent-design/test-report.md)）、[Personal agents 五产品比较](docs/research/personal-agents/README.md) 及 [Azure AI Agent Runtime 与沙箱架构](docs/research/azure-agent-infra/README.md) |
| Model | [Model 分类](docs/research/index.md#model)：预留分类，暂无公开专题 |
| Infra | [Infra 研究索引](docs/research/index.md#infra)：含 [AI Agent Infrastructure on Azure 全栈方案设计与架构选型 Playbook](docs/research/azure-agent-infra/README.md)（含 8 幅 SVG 架构图、[7 页 4:5 视觉卡片测试报告](docs/research/azure-agent-infra/test-report.md)、[离线 7 页卡片 HTML](docs/research/azure-agent-infra/test-report-cards.html) 与 [交互式 H5 Playbook & Demo](docs/research/azure-agent-infra/h5/index.html)） |

直接阅读：
- **Azure AI Agent Infra 全栈方案设计、技术选型与架构师 Playbook（Build · Run · Ground · Govern）**：[研究总入口](docs/research/azure-agent-infra/README.md) · [7 页 4:5 视觉卡片测试报告](docs/research/azure-agent-infra/test-report.md) · [离线自包含 7 页卡片 HTML](docs/research/azure-agent-infra/test-report-cards.html) · [交互式 H5 全景手册与仿真台](docs/research/azure-agent-infra/h5/index.html) · [12 项架构路由矩阵 CSV](docs/research/azure-agent-infra/evidence/test-scenarios.csv)
- **Omarchy Agent 设计机制（Agentic OS 与本地 Harness 集成）**：[研究总入口](docs/research/omarchy-agent-design/README.md) · [7 页 4:5 视觉卡片测试报告](docs/research/omarchy-agent-design/test-report.md) · [离线自包含 7 页卡片 HTML](docs/research/omarchy-agent-design/test-report-cards.html) · [174 条断言索引 CSV](docs/research/omarchy-agent-design/evidence/assertion-index.csv)
- **Personal Agents 五产品比较**：[Personal agents 研究正文](docs/research/personal-agents/README.md) · [未执行 benchmark 协议](docs/research/personal-agents/benchmark.md)
- **公共索引与声明**：[研究索引](docs/research/index.md) · [归属与权利边界](ATTRIBUTION.md) · [第三方声明](THIRD_PARTY_NOTICES.md)

各专题的具体 cutoff、静态核验边界与审阅范围见各自目录下的 `review.md` 与 `evidence.json`。
"""


def build_ai_research_public_index() -> str:
    return """# AI 研究索引

本索引只列实际公开专题，不代表所有分类已有成果。公开内容与未公开材料分离，不引入后者的链接、原始记录或历史。

## Agent

| 专题 | 子分类 / 标签 | 范围与状态 |
|---|---|---|
| [AI Agent Infrastructure on Azure 全栈方案设计与选型 Playbook](azure-agent-infra/README.md) | Agent Runtime、MicroVM 沙箱、状态持久化与多租户治理（`Foundry`、`ACA Sandboxes`、`AKSClaw`、`E2B Firecracker`、`HorizonDB`、`Entra Agent ID`） | 覆盖四层参考架构、六大运行时光谱（含 `Standard_D96as_v7` `108ms/132ms` 实测锚点）、10万并发沙箱 VMSS 容量模型、8 幅 SVG 架构图、[7 页 4:5 视觉卡片报告](azure-agent-infra/test-report.md) 与 [交互式 H5 仿真套件](azure-agent-infra/h5/index.html) |
| [Omarchy agent 设计机制](omarchy-agent-design/README.md) | Agentic OS 与本地 Harness 集成（`Agentic OS`、`Harness Integration`、`Skills`、`Event-driven Agent`、`Identity & Usage`） | 基于 `omacom/omarchy@9480d1b6a98156314dbabe6bfef08f39f8b9cd07` 的 6 大机制专题（E1–E6）、174 条源码/文档/测试契约断言与 [7 页 4:5 视觉卡片测试报告](omarchy-agent-design/test-report.md)；离线静态契约已核验，上游运行 `not_run` |
| [Personal agents：五产品比较](personal-agents/README.md) | 消费级与工作流 Personal Agents | Meta Muse、Grok Bot、OpenAI dot/dots、Google Gemini Spark、Instinct；企业 Gemini 单列区别。cutoff 2026-10-11，静态公开资料研究 |

### Omarchy agent 设计机制专题材料

- **核心阅读**：[专题总入口](omarchy-agent-design/README.md) · [00 中文总览](omarchy-agent-design/findings/00-summary.md) · [01 Launcher](omarchy-agent-design/findings/01-launcher.md) · [02 Skills](omarchy-agent-design/findings/02-skills.md) · [03 Crash Pipeline](omarchy-agent-design/findings/03-crash-pipeline.md) · [04 Accounts & Usage](omarchy-agent-design/findings/04-accounts-usage.md) · [05 Agent-native Repo](omarchy-agent-design/findings/05-agent-native-repo.md) · [06 Safety Model](omarchy-agent-design/findings/06-safety-model.md)
- **7 页 4:5 视觉卡片测试报告**：[测试报告正文](omarchy-agent-design/test-report.md) · [可离线预览 7 页卡片 HTML](omarchy-agent-design/test-report-cards.html) · [测试报告 JSON](omarchy-agent-design/evidence/test-report.json) · [12 项契约矩阵 CSV](omarchy-agent-design/evidence/test-scenarios.csv) · [鲁棒性 CSV](omarchy-agent-design/evidence/test-robustness.csv) · [批量核验耗时 CSV](omarchy-agent-design/evidence/test-batch-latency.csv)
- **可复核证据**：[源码证据索引](omarchy-agent-design/evidence/source-index.md) · [174 条断言索引 CSV](omarchy-agent-design/evidence/assertion-index.csv) · [证据台账 JSON](omarchy-agent-design/evidence.json) · [归档检查与边界](omarchy-agent-design/review.md)

### Personal agents 专题材料

[31 条来源证据](personal-agents/evidence.json) · [未执行的 benchmark 协议](personal-agents/benchmark.md) · [18 个原创合成案例](personal-agents/cases.json) · [独立 AI 审阅与公开边界](personal-agents/review.md)。

公开评测是第三方报告，未在此重算；模型/framework 分数不代表消费产品表现。协议和案例均为 `not_executed`。

## Model

预留分类，暂无公开专题；不声称已有模型实验或评测结果。

## Infra

| 专题 | 子分类 / 标签 | 范围与状态 |
|---|---|---|
| [AI Agent Infrastructure on Azure 全栈方案设计与架构选型 Playbook](azure-agent-infra/README.md) | 云原生 Agent 基础设施、硬件虚拟化沙箱与状态数据库（`ACA Dynamic Sessions`、`ACA Sandboxes`、`AKS Kata / AKSClaw`、`E2B on VMSS D96as_v7`、`Azure HorizonDB`、`APIM AI Gateway`） | 9 章全栈架构深度研究、8 幅自包含 SVG 架构与工作流图、确定性选型与 10万沙箱容量测算器（8/8 单测通过）、[7 页 4:5 视觉卡片报告](azure-agent-infra/test-report.md) 与 [4 页交互式 H5 套件](azure-agent-infra/h5/index.html) |

### Azure AI Agent Infrastructure 专题材料

- **核心阅读与蓝图**：[Playbook 总入口 (`README.md`)](azure-agent-infra/README.md) · [AKSClaw 多租户 K8s 清单 (`aksclaw-kata-fleet.yaml`)](azure-agent-infra/blueprints/aksclaw-kata-fleet.yaml) · [APIM 10万动态域名限流策略 (`e2b-apim-per-host-policy.xml`)](azure-agent-infra/blueprints/e2b-apim-per-host-policy.xml) · [E2B VMSS D96as_v7 Bicep 模板 (`e2b-vmss-d96as-v7.bicep`)](azure-agent-infra/blueprints/e2b-vmss-d96as-v7.bicep) · [HorizonDB + PgBouncer 检查点参考实现 (`horizondb-langgraph-checkpointer.py`)](azure-agent-infra/blueprints/horizondb-langgraph-checkpointer.py)
- **7 页 4:5 视觉卡片测试报告**：[测试报告正文 (`test-report.md`)](azure-agent-infra/test-report.md) · [可离线预览 7 页卡片 HTML (`test-report-cards.html`)](azure-agent-infra/test-report-cards.html) · [密封评测数据 (`report.json`)](azure-agent-infra/report.json) · [12 项场景矩阵 CSV (`test-scenarios.csv`)](azure-agent-infra/evidence/test-scenarios.csv) · [顺序与规模扰动鲁棒性 CSV (`test-robustness.csv`)](azure-agent-infra/evidence/test-robustness.csv) · [VM 代际与预热池恢复延迟 CSV (`test-batch-latency.csv`)](azure-agent-infra/evidence/test-batch-latency.csv)
- **交互式 H5 与可运行仿真**：[H5 全景手册 (`h5/index.html`)](azure-agent-infra/h5/index.html) · [AKSClaw × E2B 实时仿真台 (`h5/demo.html`)](azure-agent-infra/h5/demo.html) · [选型决策与 10万沙箱计算器 (`h5/selector.html`)](azure-agent-infra/h5/selector.html) · [可运行全链路仿真脚本 (`demo/run_live_demo.py`)](azure-agent-infra/demo/run_live_demo.py) · [证据台账 (`evidence.json`)](azure-agent-infra/evidence.json) · [归档检查与隐私边界 (`review.md`)](azure-agent-infra/review.md)

[返回首页](../../README.md) · [归属与权利边界](../../ATTRIBUTION.md) · [第三方声明](../../THIRD_PARTY_NOTICES.md)
"""


def publish_to_repo(
    repo: str,
    target_prefix: str,
    extra_files: Dict[str, bytes],
    commit_message: str,
    mirror_prefixes: List[str] | None = None,
) -> str:
    ref_data = gh_api(f"repos/{repo}/git/ref/heads/main")
    head_sha = ref_data["object"]["sha"]
    commit_data = gh_api(f"repos/{repo}/git/commits/{head_sha}")
    base_tree_sha = commit_data["tree"]["sha"]

    prefixes = [target_prefix] + (mirror_prefixes or [])
    tree_entries: List[Dict[str, Any]] = []
    for path in collect_bundle_files():
        rel = path.relative_to(BUNDLE_DIR).as_posix()
        blob_sha = create_blob(repo, path.read_bytes())
        for pfx in prefixes:
            repo_path = f"{pfx}/{rel}"
            tree_entries.append({
                "path": repo_path,
                "mode": "100644",
                "type": "blob",
                "sha": blob_sha,
            })

    for repo_path, raw_bytes in extra_files.items():
        blob_sha = create_blob(repo, raw_bytes)
        tree_entries.append({
            "path": repo_path,
            "mode": "100644",
            "type": "blob",
            "sha": blob_sha,
        })

    new_tree = gh_api(
        f"repos/{repo}/git/trees",
        method="POST",
        payload={"base_tree": base_tree_sha, "tree": tree_entries},
    )
    if new_tree["sha"] == base_tree_sha:
        return head_sha
    full_msg = (
        f"{commit_message}\n\n"
        "Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>\n"
        "Copilot-Session: 6c599245-7861-4833-9767-e96034dc9e05"
    )
    new_commit = gh_api(
        f"repos/{repo}/git/commits",
        method="POST",
        payload={
            "message": full_msg,
            "tree": new_tree["sha"],
            "parents": [head_sha],
        },
    )
    gh_api(
        f"repos/{repo}/git/refs/heads/main",
        method="PATCH",
        payload={"sha": new_commit["sha"], "force": False},
    )
    return new_commit["sha"]


def build_ai_research_lab_files() -> Dict[str, bytes]:
    lab_root = Path(r"C:\Users\qichen2\ai-research-lab")
    readme_text = (lab_root / "README.md").read_text(encoding="utf-8")
    index_text = (lab_root / "docs" / "research" / "index.md").read_text(encoding="utf-8")

    readme_snippet = (
        "[Azure AI Agent Infra 全栈方案设计、技术选型与架构师 Playbook](docs/research/azure-agent-infra/README.md)与\n"
        "[7-Card 4:5 视觉测试报告](docs/research/azure-agent-infra/test-report.md)覆盖 L1–L4 四层架构、六大运行时光谱（Foundry Hosted Agents · Durable Functions · ACA Dynamic Sessions · ACA Sandboxes · AKSClaw Kata VM · E2B on Azure VMSS `Standard_D96as_v7` `108ms/132ms`）、8 张 SVG 架构图、交互式 H5 仿真套件与 10万并发沙箱定容模型；\n"
    )
    if "docs/research/azure-agent-infra/README.md" not in readme_text:
        readme_text = readme_text.replace(
            "[Coding Agent 十七模型对比（增补报告 4：Sonnet 5.5 与 GPT-6.1 Sol）](docs/research/coding-agent-17-model-benchmark/README.md)",
            readme_snippet + "[Coding Agent 十七模型对比（增补报告 4：Sonnet 5.5 与 GPT-6.1 Sol）](docs/research/coding-agent-17-model-benchmark/README.md)",
        )

    table_row = (
        "| **推理与性能** / **Agent 与编排** / **评测与治理** | **AI Infra** · **Agent**（六大 Agent Runtime 选型、AKSClaw 多租户 K8s 与 E2B 10万并发 MicroVM 沙箱） | "
        "[Azure AI Agent Infra 全栈方案设计、技术选型与架构师 Playbook](azure-agent-infra/README.md) · [7-Card 测试报告](azure-agent-infra/test-report.md) · [HTML 卡片](azure-agent-infra/test-report-cards.html) · [交互式 H5 套件](azure-agent-infra/h5/index.html) | 2026-10-19 |\n"
    )
    section_block = """### 2026-10-19 · Azure AI Agent Infra 全栈方案设计、技术选型与架构师 Playbook（AKSClaw × E2B 100K Sandboxes）

- **分类归属**：主分类 **`推理与性能`** / **`Agent 与编排`** / **`评测与治理`** · 交叉视图 **`AI Infra`** & **`Agent`**
- [研究正文](azure-agent-infra/README.md)：L1 Build 编排层（MAF · GitHub Copilot SDK · LangGraph · OpenClaw · Hermes · MCP/A2A）、L2 Run 六大运行时光谱（Foundry Hosted Agents、Durable Functions、ACA Dynamic Sessions、ACA Sandboxes Preview、AKS + Kata `AKSClaw`、E2B on Azure VMSS `Standard_D96as_v7` `108ms` 单发 / `132ms` 50x 并发）、L3 Ground 状态与记忆底座（Azure HorizonDB Preview + PgBouncer `5ms` 连接池、Cosmos DB、Firecracker UFFD+NBD Snapshot）、L4 Govern 零信任治理（Entra Agent ID、Unified AI Gateway、五道平台硬边界）与现场五步落地工作流。
- [7-Card 4:5 视觉卡片测试报告（Markdown）](azure-agent-infra/test-report.md) · [7-Card 4:5 视觉卡片交互/打印版（HTML）](azure-agent-infra/test-report-cards.html) · [结构化数据集 `report.json`](azure-agent-infra/report.json)
- [交互式 H5 全景手册与仿真器套件](azure-agent-infra/h5/index.html) · [可运行端到端验证脚本 `run_live_demo.py`](azure-agent-infra/demo/run_live_demo.py) · [深度定量模型 `e2b_aksclaw_deep_benchmark.py`](azure-agent-infra/simulator/e2b_aksclaw_deep_benchmark.py)
- [证据台账](azure-agent-infra/evidence.json) · [治理、隐私与核验记录](azure-agent-infra/review.md)
- 来源：`Azure AI Infra` 五份核心工程材料（`08 AKSClaw-Multi-Tenant-Kubernetes.pptx`、`Agent Runtime Customer Pitch - ZH-CN v1.pptx`、`Agent_Infra_Playbook.pptx`、`GCR_Agent_Runtime_Priority_Accounts.xlsx` 脱敏方法论页、`Microsoft - E2B on Azure Solution - v1.pdf`）及 Microsoft Learn / E2B 公开架构文档。
- 状态：已完成严格脱敏与离线定容/延迟分解验算（12/12 单元测试通过），并同步发布至公开仓库 [`turbo998/ai-infra-lab`](https://github.com/turbo998/ai-infra-lab)、[`turbo998/Azure-Infra-Lab`](https://github.com/turbo998/Azure-Infra-Lab) 与 [`turbo998/ai-research-public`](https://github.com/turbo998/ai-research-public)。不计入 `david-share` 覆盖率分母。

"""
    if "azure-agent-infra/README.md" not in index_text:
        index_text = index_text.replace(
            "|---|---|---|---|",
            "|---|---|---|---|\n" + table_row.rstrip("\n"),
            1,
        )
        index_text = index_text.replace(
            "## 已归档\n\n",
            "## 已归档\n\n" + section_block,
            1,
        )

    return {
        "README.md": readme_text.encode("utf-8"),
        "docs/research/index.md": index_text.encode("utf-8"),
    }


def build_kee_tech_assets_files() -> Dict[str, bytes]:
    site_root = Path(r"C:\Users\qichen2\turbo998.github.io")
    writing_en = (site_root / "writing.html").read_text(encoding="utf-8")
    writing_zh = (site_root / "zh-writing.html").read_text(encoding="utf-8")
    readme_text = (site_root / "README.md").read_text(encoding="utf-8")
    main_js = (site_root / "main.js").read_text(encoding="utf-8")

    en_pub_entry = """      <div class="pub">
        <div class="pub-type">Playbook</div>
        <div>
          <h3>Azure AI Agent Infrastructure Playbook (AKSClaw × E2B 100K Sandboxes)</h3>
          <p><b>AI Infrastructure &amp; Agent Runtime</b> · 4-Layer Reference Architecture (Build · Run · Ground · Govern) · 6-Tier Runtime Spectrum · Multi-Region Active-Active DR (`3.67s` warm failover). Includes 8 SVG diagrams, a 4-page H5 simulator &amp; capacity sizer, a 7-Card 4:5 benchmark report (`Standard_D96as_v7` `108ms` Base / `132ms` Code-Interpreter resume), and 6 production IaC/APIM blueprints.</p>
          <p><a href="https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/index.html">Playbook Atlas →</a> · <a href="https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/demo.html">Live Simulator (AKSClaw × E2B) →</a> · <a href="https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/selector.html">Decision Tree, 100K Sizer &amp; DR Lab →</a> · <a href="https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/cards.html">7-Card Benchmark Deck →</a></p>
          <p>Maintained in <a href="https://github.com/turbo998/Azure-Infra-Lab/tree/main/workshops/azure-agent-infra">Azure Infra Lab</a>, <a href="https://github.com/turbo998/ai-infra-lab/tree/main/docs/azure-agent-infra">ai-infra-lab</a>, and <a href="https://github.com/turbo998/ai-research-public/tree/main/docs/research/azure-agent-infra">ai-research-public</a>.</p>
        </div>
      </div>\n"""
    if "workshops/azure-agent-infra/index.html" not in writing_en:
        writing_en = writing_en.replace('<div class="pub-list">\n', '<div class="pub-list">\n' + en_pub_entry, 1)

    zh_pub_entry = """      <div class="pub">
        <div class="pub-type">Playbook</div>
        <div>
          <h3>Azure AI Agent Infrastructure Playbook（四层架构 · 六大运行时 · AKSClaw × E2B 10万并发沙箱）</h3>
          <p><b>AI 基础设施与智能体运行时</b> · 四层参考架构（Build · Run · Ground · Govern）· 六级计算光谱 · 跨区域双活容灾（`3.67s` 热备切换）。配套 8 张矢量架构图、4 页交互式 H5 仿真工作台与容量计算器、7-Card 4:5 基准报告（`Standard_D96as_v7` `108ms` Base / `132ms` Code-Interpreter 恢复）及 6 套生产级 IaC/APIM 蓝图。</p>
          <p><a href="https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/index.html">全景 Playbook →</a> · <a href="https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/demo.html">AKSClaw × E2B 实时仿真 →</a> · <a href="https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/selector.html">选型决策、10万沙箱定容与跨区 DR 计算器 →</a> · <a href="https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/cards.html">7-Card 评测报告 →</a></p>
          <p>完整资产同步维护于公开的 <a href="https://github.com/turbo998/Azure-Infra-Lab/tree/main/workshops/azure-agent-infra">Azure Infra Lab</a>、<a href="https://github.com/turbo998/ai-infra-lab/tree/main/docs/azure-agent-infra">ai-infra-lab</a> 与 <a href="https://github.com/turbo998/ai-research-public/tree/main/docs/research/azure-agent-infra">ai-research-public</a>。</p>
        </div>
      </div>\n"""
    if "workshops/azure-agent-infra/index.html" not in writing_zh:
        writing_zh = writing_zh.replace('<div class="pub-list">\n', '<div class="pub-list">\n' + zh_pub_entry, 1)

    readme_section = """## 精选 Playbook：Azure AI Agent Infrastructure Playbook（四层架构 · 六大运行时 · AKSClaw × E2B 10万并发沙箱）

面向 AI Infra 与 Agent 平台架构师的端到端选型、定容与生产落地指南：涵盖 L1–L4 四层架构、六大运行时光谱（Foundry Hosted Agents · Durable Functions · ACA Dynamic Sessions · ACA Sandboxes Preview · AKS + Kata `AKSClaw` · E2B on Azure VMSS `Standard_D96as_v7` `108ms` Base / `132ms` Code-Interpreter 恢复）、Azure HorizonDB + PgBouncer 状态持久化、跨区域双活容灾（`3.67s` 热备 RTO）以及 6 套生产级 IaC/APIM 蓝图。

**[打开全景 Playbook H5](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/index.html)** · **[AKSClaw × E2B 实时仿真台](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/demo.html)** · **[选型决策、10万沙箱定容与 DR 计算器](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/selector.html)** · **[7-Card 4:5 基准报告](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/cards.html)** · **[Step 04 客户 Workshop 执行手册](https://github.com/turbo998/Azure-Infra-Lab/blob/main/workshops/azure-agent-infra/workshop-runbook.md)**

"""
    if "workshops/azure-agent-infra/index.html" not in readme_text:
        readme_text = readme_text.replace(
            "## 精选 Workshop：Azure VM 现代化，从客户目标到可验证的行动",
            readme_section + "## 精选 Workshop：Azure VM 现代化，从客户目标到可验证的行动",
            1,
        )

    if '"Azure-Infra-Lab"' not in main_js:
        main_js = main_js.replace(
            '  const FEATURED = [\n    "ai-gaming-lab",',
            '  const FEATURED = [\n    "Azure-Infra-Lab",\n    "ai-infra-lab",\n    "ai-gaming-lab",',
            1,
        )
        main_js = main_js.replace(
            '  const ZH_DESC = {\n',
            '  const ZH_DESC = {\n'
            '    "Azure-Infra-Lab": "Azure 基础设施工程化与 AI Agent Infra 实战实验室：收录《Azure AI Agent Infrastructure Playbook》（AKSClaw × E2B 10万沙箱 H5 仿真套件）与《Azure VM 现代化合作伙伴 Workshop》。",\n'
            '    "ai-infra-lab": "AI 基础设施架构、运行时光谱评测、E2B Firecracker / AKSClaw Kata 密度模型与跨区容灾蓝图库。",\n',
            1,
        )
        main_js = main_js.replace(
            '  const FALLBACK = [\n',
            '  const FALLBACK = [\n'
            '    { name: "Azure-Infra-Lab", description: "Azure Infrastructure & AI Agent Infra Playbook Lab: Interactive H5 simulators (AKSClaw × E2B 100K Sandboxes & Azure VM Modernization Workshop).", language: "HTML", stargazers_count: 0, html_url: "https://github.com/turbo998/Azure-Infra-Lab", homepage: "https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-agent-infra/index.html", updated_at: "2026-10-19" },\n'
            '    { name: "ai-infra-lab", description: "AI Infrastructure architecture playbooks, E2B Firecracker & AKSClaw Kata benchmarks, and multi-region DR blueprints on Azure.", language: "Python", stargazers_count: 0, html_url: "https://github.com/turbo998/ai-infra-lab", updated_at: "2026-10-19" },\n',
            1,
        )

    writing_en = (
        writing_en.replace("6 production IaC/APIM blueprints", "16 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK blueprints")
        .replace("7 production IaC/APIM blueprints", "16 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK blueprints")
        .replace("8 production IaC/APIM/FinOps/Confidential-SNP blueprints", "16 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK blueprints")
        .replace("9 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust-Egress blueprints", "16 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK blueprints")
        .replace("10 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG blueprints", "16 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK blueprints")
        .replace("11 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX blueprints", "16 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK blueprints")
        .replace("12 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga blueprints", "16 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK blueprints")
        .replace("13 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser blueprints", "16 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK blueprints")
        .replace("14 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache blueprints", "16 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK blueprints")
        .replace("15 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor blueprints", "17 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration blueprints")
        .replace("16 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK blueprints", "18 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router blueprints")
        .replace("21 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS blueprints", "23 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC blueprints")
        .replace("22 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB blueprints", "24 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2 blueprints")
        .replace("24 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2 blueprints", "26 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203 blueprints")
        .replace("32 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC blueprints", "34 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge blueprints")
        .replace("35 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11 blueprints", "37 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus blueprints")
        .replace("36 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum blueprints", "39 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus/AzureOrbital-BPv7-SpaceEdge/SmartGrid-IEC61850-ACOPF blueprints")
        .replace("37 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus blueprints", "39 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus/AzureOrbital-BPv7-SpaceEdge/SmartGrid-IEC61850-ACOPF blueprints")
        .replace("38 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus/AzureOrbital-BPv7-SpaceEdge blueprints", "41 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus/AzureOrbital-BPv7-SpaceEdge/SmartGrid-IEC61850-ACOPF/SupplyChain-AMR-MAPF/Media-OpenUSD-C2PA blueprints")
        .replace("40 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus/AzureOrbital-BPv7-SpaceEdge/SmartGrid-IEC61850-ACOPF/SupplyChain-AMR-MAPF blueprints", "41 production IaC/APIM/FinOps/Confidential-SNP/Zero-Trust/GPU-MIG/OTel-ADX/Dapr-Saga/CUA-Browser/DAX-Cache/Swarm-Governor/Sovereign-CMK/Canary-LiveMigration/Cascade-Router/DiskANN-Memory/WebRTC-eBPF/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus/AzureOrbital-BPv7-SpaceEdge/SmartGrid-IEC61850-ACOPF/SupplyChain-AMR-MAPF/Media-OpenUSD-C2PA blueprints")
    )
    writing_zh = (
        writing_zh.replace("6 套生产级 IaC/APIM 蓝图", "41 套生产级 IaC/APIM/FinOps/SEV-SNP/零信任/GPU-MIG/OTel-ADX/Dapr-Saga/CUA/DAX/Swarm/Sovereign/Canary/Cascade/DiskANN/WebRTC/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus/AzureOrbital-BPv7-SpaceEdge/SmartGrid-IEC61850-ACOPF/SupplyChain-AMR-MAPF/Media-OpenUSD-C2PA 蓝图")
        .replace("40 套生产级 IaC/APIM/FinOps/SEV-SNP/零信任/GPU-MIG/OTel-ADX/Dapr-Saga/CUA/DAX/Swarm/Sovereign/Canary/Cascade/DiskANN/WebRTC/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus/AzureOrbital-BPv7-SpaceEdge/SmartGrid-IEC61850-ACOPF/SupplyChain-AMR-MAPF 蓝图", "41 套生产级 IaC/APIM/FinOps/SEV-SNP/零信任/GPU-MIG/OTel-ADX/Dapr-Saga/CUA/DAX/Swarm/Sovereign/Canary/Cascade/DiskANN/WebRTC/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus/AzureOrbital-BPv7-SpaceEdge/SmartGrid-IEC61850-ACOPF/SupplyChain-AMR-MAPF/Media-OpenUSD-C2PA 蓝图")
    )
    readme_text = (
        readme_text.replace("6 套生产级 IaC/APIM 蓝图", "41 套生产级 IaC/APIM/FinOps/SEV-SNP/零信任/GPU-MIG/OTel-ADX/Dapr-Saga/CUA/DAX/Swarm/Sovereign/Canary/Cascade/DiskANN/WebRTC/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus/AzureOrbital-BPv7-SpaceEdge/SmartGrid-IEC61850-ACOPF/SupplyChain-AMR-MAPF/Media-OpenUSD-C2PA 蓝图")
        .replace("40 套生产级 IaC/APIM/FinOps/SEV-SNP/零信任/GPU-MIG/OTel-ADX/Dapr-Saga/CUA/DAX/Swarm/Sovereign/Canary/Cascade/DiskANN/WebRTC/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus/AzureOrbital-BPv7-SpaceEdge/SmartGrid-IEC61850-ACOPF/SupplyChain-AMR-MAPF 蓝图", "41 套生产级 IaC/APIM/FinOps/SEV-SNP/零信任/GPU-MIG/OTel-ADX/Dapr-Saga/CUA/DAX/Swarm/Sovereign/Canary/Cascade/DiskANN/WebRTC/BuildKit-CAS/OneLake-DuckDB/CleanRoom-OIDC/Embodied-ROS2/Online-RFT-Verifier/PQC-FIPS203/GreenOps-Carbon/Hyperlight-WASI02/Chaos-Fencing/ManagedLustre-HBv4-HPC/ConfidentialLedger-Payment/A2A-VerifiedID-QUIC/Cyber-Detonation-SOAR/AzureLocal-IoTOperations-Edge/Healthcare-FHIR-CFR11/AzureQuantum-QIR-cuQuantum/Telco-ORAN-OperatorNexus/AzureOrbital-BPv7-SpaceEdge/SmartGrid-IEC61850-ACOPF/SupplyChain-AMR-MAPF/Media-OpenUSD-C2PA 蓝图")
    )

    return {
        "writing.html": writing_en.encode("utf-8"),
        "zh-writing.html": writing_zh.encode("utf-8"),
        "README.md": readme_text.encode("utf-8"),
        "main.js": main_js.encode("utf-8"),
    }


def publish_extra_only(repo: str, extra_files: Dict[str, bytes], commit_message: str) -> str:
    ref_data = gh_api(f"repos/{repo}/git/ref/heads/main")
    head_sha = ref_data["object"]["sha"]
    commit_data = gh_api(f"repos/{repo}/git/commits/{head_sha}")
    base_tree_sha = commit_data["tree"]["sha"]
    tree_entries = []
    for repo_path, raw_bytes in extra_files.items():
        blob_sha = create_blob(repo, raw_bytes)
        tree_entries.append({"path": repo_path, "mode": "100644", "type": "blob", "sha": blob_sha})
    new_tree = gh_api(
        f"repos/{repo}/git/trees",
        method="POST",
        payload={"base_tree": base_tree_sha, "tree": tree_entries},
    )
    if new_tree["sha"] == base_tree_sha:
        return head_sha
    new_commit = gh_api(
        f"repos/{repo}/git/commits",
        method="POST",
        payload={
            "message": (
                f"{commit_message}\n\n"
                "Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>\n"
                "Copilot-Session: 6c599245-7861-4833-9767-e96034dc9e05"
            ),
            "tree": new_tree["sha"],
            "parents": [head_sha],
        },
    )
    gh_api(
        f"repos/{repo}/git/refs/heads/main",
        method="PATCH",
        payload={"sha": new_commit["sha"], "force": False},
    )
    return new_commit["sha"]


def sync_local_working_trees() -> None:
    import shutil

    def copy_bundle_to(dest_dir: Path) -> None:
        for src in collect_bundle_files():
            rel = src.relative_to(BUNDLE_DIR)
            dst = dest_dir / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)

    infra_lab = Path(r"C:\Users\qichen2\ai-infra-lab")
    if infra_lab.exists():
        copy_bundle_to(infra_lab / "docs" / "azure-agent-infra")
        copy_bundle_to(infra_lab / "workshops" / "azure-agent-infra")
        (infra_lab / "README.md").write_text(build_ai_infra_lab_readme(), encoding="utf-8")

    az_lab = Path(r"C:\Users\qichen2\Azure-Infra-Lab")
    if az_lab.exists():
        for stale_root_html in ("index.html", "demo.html", "selector.html", "cards.html", "benchmark-cards.html"):
            stale_path = az_lab / stale_root_html
            if stale_path.exists():
                stale_path.unlink()
        copy_bundle_to(az_lab / "workshops" / "azure-agent-infra")
        for html_file in (BUNDLE_DIR / "h5").glob("*.html"):
            shutil.copy2(html_file, az_lab / "workshops" / "azure-agent-infra" / html_file.name)

    res_pub = Path(r"C:\Users\qichen2\ai-research-public")
    if res_pub.exists():
        copy_bundle_to(res_pub / "docs" / "research" / "azure-agent-infra")
        (res_pub / "README.md").write_text(build_ai_research_public_readme(), encoding="utf-8")
        (res_pub / "docs" / "research" / "index.md").write_text(build_ai_research_public_index(), encoding="utf-8")

    res_lab = Path(r"C:\Users\qichen2\ai-research-lab")
    if res_lab.exists():
        copy_bundle_to(res_lab / "docs" / "research" / "azure-agent-infra")
        for rel_p, raw_b in build_ai_research_lab_files().items():
            (res_lab / rel_p).write_bytes(raw_b)

    kee = Path(r"C:\Users\qichen2\turbo998.github.io")
    if kee.exists():
        for rel_p, raw_b in build_kee_tech_assets_files().items():
            (kee / rel_p).write_bytes(raw_b)


def main() -> int:
    sync_local_working_trees()
    sha_infra_lab = publish_to_repo(
        repo="turbo998/ai-infra-lab",
        target_prefix="docs/azure-agent-infra",
        extra_files={"README.md": build_ai_infra_lab_readme().encode("utf-8")},
        commit_message="feat(azure-agent-infra): add Chapter 46 Smart Mobility SDV/V2X Fleet & CARLA RSS Verifier, Blueprint #42 and Tool 41 (50/50 tests)",
        mirror_prefixes=["workshops/azure-agent-infra"],
    )
    print(f"Published turbo998/ai-infra-lab main @ {sha_infra_lab}")

    sha_research_pub = publish_to_repo(
        repo="turbo998/ai-research-public",
        target_prefix="docs/research/azure-agent-infra",
        extra_files={
            "README.md": build_ai_research_public_readme().encode("utf-8"),
            "docs/research/index.md": build_ai_research_public_index().encode("utf-8"),
        },
        commit_message="feat(infra): add Chapter 46 Smart Mobility SDV/V2X Fleet & CARLA RSS Verifier, Blueprint #42 and Tool 41 (50/50 tests)",
    )
    print(f"Published turbo998/ai-research-public main @ {sha_research_pub}")

    # Also update turbo998/Azure-Infra-Lab with the newly added demo/, blueprints/, H5 pages (both root & h5/), and deep benchmark files
    extra_azure_infra_lab: Dict[str, bytes] = {}
    extra_azure_infra_lab["workshops/azure-agent-infra/README.md"] = (BUNDLE_DIR / "README.md").read_bytes()
    extra_azure_infra_lab["workshops/azure-agent-infra/workshop-runbook.md"] = (
        BUNDLE_DIR / "workshop-runbook.md"
    ).read_bytes()
    for h5_page in ("index.html", "demo.html", "selector.html", "cards.html", "benchmark-cards.html"):
        page_bytes = (BUNDLE_DIR / "h5" / h5_page).read_bytes()
        extra_azure_infra_lab[f"workshops/azure-agent-infra/{h5_page}"] = page_bytes
        extra_azure_infra_lab[f"workshops/azure-agent-infra/h5/{h5_page}"] = page_bytes
    for p in sorted((BUNDLE_DIR / "demo").glob("*")):
        if p.is_file():
            extra_azure_infra_lab[f"workshops/azure-agent-infra/demo/{p.name}"] = p.read_bytes()
    for p in sorted((BUNDLE_DIR / "blueprints").glob("*")):
        if p.is_file():
            extra_azure_infra_lab[f"workshops/azure-agent-infra/blueprints/{p.name}"] = p.read_bytes()
    for p in sorted((BUNDLE_DIR / "simulator").glob("*.py")):
        if p.is_file() and p.name != "publish_via_github_api.py":
            extra_azure_infra_lab[f"workshops/azure-agent-infra/simulator/{p.name}"] = p.read_bytes()
    for p in sorted((BUNDLE_DIR / "evidence").glob("*")):
        if p.is_file():
            extra_azure_infra_lab[f"workshops/azure-agent-infra/evidence/{p.name}"] = p.read_bytes()

    ref_data = gh_api("repos/turbo998/Azure-Infra-Lab/git/ref/heads/main")
    head_sha = ref_data["object"]["sha"]
    commit_data = gh_api(f"repos/turbo998/Azure-Infra-Lab/git/commits/{head_sha}")
    base_tree_sha = commit_data["tree"]["sha"]
    tree_entries = []
    for repo_path, raw_bytes in extra_azure_infra_lab.items():
        blob_sha = create_blob("turbo998/Azure-Infra-Lab", raw_bytes)
        tree_entries.append({"path": repo_path, "mode": "100644", "type": "blob", "sha": blob_sha})
    new_tree = gh_api(
        "repos/turbo998/Azure-Infra-Lab/git/trees",
        method="POST",
        payload={"base_tree": base_tree_sha, "tree": tree_entries},
    )
    if new_tree["sha"] == base_tree_sha:
        print(f"Published turbo998/Azure-Infra-Lab main @ {head_sha}")
    else:
        new_commit = gh_api(
            "repos/turbo998/Azure-Infra-Lab/git/commits",
            method="POST",
            payload={
                "message": (
                    "feat(azure-agent-infra): add Chapter 45 Media Broadcast SMPTE ST 2110 & OpenUSD/3DGS C2PA Agent Infra, Blueprint #41 and Tool 40 (49/49 tests)\n\n"
                    "Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>\n"
                    "Copilot-Session: 6c599245-7861-4833-9767-e96034dc9e05"
                ),
                "tree": new_tree["sha"],
                "parents": [head_sha],
            },
        )
        gh_api(
            "repos/turbo998/Azure-Infra-Lab/git/refs/heads/main",
            method="PATCH",
            payload={"sha": new_commit["sha"], "force": False},
        )
        print(f"Published turbo998/Azure-Infra-Lab main @ {new_commit['sha']}")

    sha_research_lab = publish_to_repo(
        repo="turbo998/ai-research-lab",
        target_prefix="docs/research/azure-agent-infra",
        extra_files=build_ai_research_lab_files(),
        commit_message="feat(research): add Chapter 45 Media Broadcast SMPTE ST 2110 & OpenUSD/3DGS C2PA Agent Infra, Blueprint #41 and Tool 40 (49/49 tests)",
    )
    print(f"Published turbo998/ai-research-lab main @ {sha_research_lab}")

    sha_kee_assets = publish_extra_only(
        repo="turbo998/Kee-Tech-Assets",
        extra_files=build_kee_tech_assets_files(),
        commit_message="feat(writing): update Azure AI Agent Infra Playbook showcase with 41 production blueprints including Media OpenUSD/3DGS & C2PA",
    )
    print(f"Published turbo998/Kee-Tech-Assets main @ {sha_kee_assets}")

    for local_repo in (
        Path(r"C:\Users\qichen2\ai-infra-lab"),
        Path(r"C:\Users\qichen2\Azure-Infra-Lab"),
        Path(r"C:\Users\qichen2\ai-research-public"),
        Path(r"C:\Users\qichen2\ai-research-lab"),
        Path(r"C:\Users\qichen2\turbo998.github.io"),
    ):
        if local_repo.exists():
            for pyc_dir in local_repo.rglob("__pycache__"):
                if pyc_dir.is_dir():
                    import shutil
                    shutil.rmtree(pyc_dir, ignore_errors=True)
            subprocess.run(["git", "-C", str(local_repo), "add", "-A"], check=False)
            status_proc = subprocess.run(
                ["git", "-C", str(local_repo), "status", "--porcelain"],
                capture_output=True,
                text=True,
                check=False,
            )
            if status_proc.stdout.strip():
                subprocess.run(
                    [
                        "git",
                        "-C",
                        str(local_repo),
                        "commit",
                        "-m",
                        "feat(azure-agent-infra): add Chapter 45 Media Broadcast SMPTE ST 2110 & OpenUSD/3DGS C2PA Agent Infra, Blueprint #41 and Tool 40 (49/49 tests)\n\nCo-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>\nCopilot-Session: 6c599245-7861-4833-9767-e96034dc9e05",
                    ],
                    check=False,
                )
            subprocess.run(
                ["git", "-C", str(local_repo), "update-ref", "refs/remotes/origin/main", "HEAD"],
                check=False,
            )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
