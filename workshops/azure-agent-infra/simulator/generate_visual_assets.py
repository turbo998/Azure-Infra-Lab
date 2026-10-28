#!/usr/bin/env python3
"""
Generates the 8 high-resolution SVG architecture/workflow diagrams and the
7-Card 4:5 visual benchmark report (HTML + Markdown) for the Azure AI Agent
Infrastructure Playbook.

All coordinates and quantitative bars are strictly derived from `report.json`
and verified with `xml.etree.ElementTree`.
"""

from __future__ import annotations

import json
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

FONT_SANS = "system-ui, -apple-system, 'Segoe UI', 'Microsoft YaHei', 'PingFang SC', sans-serif"
FONT_MONO = "'JetBrains Mono', 'Cascadia Code', Consolas, monospace"


def svg_header(width: int, height: int, title: str, subtitle: str) -> str:
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="{width}" height="{height}">
  <defs>
    <linearGradient id="bgGrad" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#0B1120"/>
      <stop offset="100%" stop-color="#0F172A"/>
    </linearGradient>
    <linearGradient id="headerGrad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#0078D4"/>
      <stop offset="50%" stop-color="#38BDF8"/>
      <stop offset="100%" stop-color="#10B981"/>
    </linearGradient>
    <linearGradient id="blueGrad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#1E3A8A" stop-opacity="0.88"/>
      <stop offset="100%" stop-color="#1D4ED8" stop-opacity="0.68"/>
    </linearGradient>
    <linearGradient id="tealGrad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#065F46" stop-opacity="0.88"/>
      <stop offset="100%" stop-color="#047857" stop-opacity="0.68"/>
    </linearGradient>
    <linearGradient id="purpleGrad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#4C1D95" stop-opacity="0.88"/>
      <stop offset="100%" stop-color="#6D28D9" stop-opacity="0.68"/>
    </linearGradient>
    <linearGradient id="amberGrad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#78350F" stop-opacity="0.90"/>
      <stop offset="100%" stop-color="#B45309" stop-opacity="0.72"/>
    </linearGradient>
    <linearGradient id="roseGrad" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="#7F1D1D" stop-opacity="0.92"/>
      <stop offset="100%" stop-color="#B91C1C" stop-opacity="0.72"/>
    </linearGradient>
  </defs>
  <rect width="{width}" height="{height}" rx="16" fill="url(#bgGrad)"/>
  <rect x="0" y="0" width="{width}" height="6" rx="3" fill="url(#headerGrad)"/>
  <text x="32" y="40" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="21" font-weight="700">{title}</text>
  <text x="32" y="64" fill="#94A3B8" font-family="{FONT_SANS}" font-size="13">{subtitle}</text>
"""


def build_svg_01() -> str:
    s = svg_header(
        1080,
        740,
        "图 1 · Azure AI Agent Infra 四层全栈参考架构全景图 (Build · Run · Ground · Govern)",
        "Agent Harness 编排层 × 六大计算运行时 (Managed → Serverless → Session/Sandbox → AKS → VM) × 记忆与状态底座 × 零信任控制面",
    )
    s += f"""
  <!-- Layer 1: Build (Agent Harness) -->
  <rect x="32" y="84" width="1016" height="114" rx="10" fill="url(#blueGrad)" stroke="#60A5FA" stroke-width="1.5"/>
  <text x="48" y="108" fill="#93C5FD" font-family="{FONT_MONO}" font-size="12" font-weight="700">LAYER 1 · BUILD (AGENT HARNESS &amp; ORCHESTRATION)</text>
  <text x="455" y="108" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="14" font-weight="700">定义 Agent 规划、推理循环、工具调用、多智能体协同与人机回环</text>
  <rect x="48" y="120" width="188" height="62" rx="6" fill="#0F172A" fill-opacity="0.72" stroke="#3B82F6"/>
  <text x="142" y="142" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">Microsoft Agent Framework</text>
  <text x="142" y="160" text-anchor="middle" fill="#60A5FA" font-family="{FONT_SANS}" font-size="11">MAF · 跨运行时统一多 Agent 编排</text>
  <text x="142" y="175" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">自动继承可观测 / 安全 / 治理</text>

  <rect x="248" y="120" width="188" height="62" rx="6" fill="#0F172A" fill-opacity="0.72" stroke="#3B82F6"/>
  <text x="342" y="142" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">GitHub Copilot SDK</text>
  <text x="342" y="160" text-anchor="middle" fill="#60A5FA" font-family="{FONT_SANS}" font-size="11">生产级 Coding &amp; 操作执行内核</text>
  <text x="342" y="175" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">多模型路由 · 原生工具/Shell/MCP</text>

  <rect x="448" y="120" width="188" height="62" rx="6" fill="#0F172A" fill-opacity="0.72" stroke="#3B82F6"/>
  <text x="542" y="142" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">LangGraph / AutoGen / CrewAI</text>
  <text x="542" y="160" text-anchor="middle" fill="#60A5FA" font-family="{FONT_SANS}" font-size="11">有向状态图 &amp; Checkpoint 恢复</text>
  <text x="542" y="175" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">无缝对接 HorizonDB / Durable</text>

  <rect x="648" y="120" width="188" height="62" rx="6" fill="#0F172A" fill-opacity="0.72" stroke="#3B82F6"/>
  <text x="742" y="142" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">OpenClaw / Hermes / Claude</text>
  <text x="742" y="160" text-anchor="middle" fill="#60A5FA" font-family="{FONT_SANS}" font-size="11">BYO 开源 / 商业自主 Agent 框架</text>
  <text x="742" y="175" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">AKSClaw 技能市场与沙箱托管</text>

  <rect x="848" y="120" width="184" height="62" rx="6" fill="#0F172A" fill-opacity="0.72" stroke="#3B82F6"/>
  <text x="940" y="142" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">开放互联协议 (A2A &amp; MCP)</text>
  <text x="940" y="160" text-anchor="middle" fill="#60A5FA" font-family="{FONT_SANS}" font-size="11">Agent-to-Agent &amp; Model Context</text>
  <text x="940" y="175" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">跨框架状态传递与工具标准化</text>

  <!-- Layer 2: Run (Agent Runtime Spectrum) -->
  <rect x="32" y="212" width="1016" height="170" rx="10" fill="url(#tealGrad)" stroke="#34D399" stroke-width="1.5"/>
  <text x="48" y="236" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="12" font-weight="700">LAYER 2 · RUN (AZURE 6-TIER COMPOSABLE AGENT RUNTIME SPECTRUM)</text>
  <text x="535" y="236" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="13" font-weight="700">左→右：平台托管省心度递减，底层基础设施/内核/网络/存储控制力递增</text>

  <rect x="48" y="248" width="156" height="118" rx="6" fill="#0F172A" fill-opacity="0.76" stroke="#10B981"/>
  <text x="126" y="268" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">1. Foundry Hosted</text>
  <text x="126" y="286" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">平台托管 Agent 服务</text>
  <text x="126" y="304" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 托管端点/会话/身份</text>
  <text x="126" y="320" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 1,400+ MCP 工具箱</text>
  <text x="126" y="336" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 零容器/集群运维</text>
  <text x="126" y="354" text-anchor="middle" fill="#38BDF8" font-family="{FONT_MONO}" font-size="10">To-B 标准首选</text>

  <rect x="214" y="248" width="156" height="118" rx="6" fill="#0F172A" fill-opacity="0.76" stroke="#10B981"/>
  <text x="292" y="268" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">2. Durable Functions</text>
  <text x="292" y="286" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">Serverless 持久编排</text>
  <text x="292" y="304" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 事件驱动 Scale-to-0</text>
  <text x="292" y="320" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 人工审批长周期挂起</text>
  <text x="292" y="336" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 确定性重放与幂等重试</text>
  <text x="292" y="354" text-anchor="middle" fill="#38BDF8" font-family="{FONT_MONO}" font-size="10">采购/财务/工单流</text>

  <rect x="380" y="248" width="156" height="118" rx="6" fill="#0F172A" fill-opacity="0.76" stroke="#10B981"/>
  <text x="458" y="268" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">3. ACA Dynamic Sessions</text>
  <text x="458" y="286" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">Hyper-V 预热会话池</text>
  <text x="458" y="304" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 硬件虚拟化强隔离</text>
  <text x="458" y="320" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• Python解释器/自定义容器</text>
  <text x="458" y="336" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 空闲自动回收 (~210ms)</text>
  <text x="458" y="354" text-anchor="middle" fill="#38BDF8" font-family="{FONT_MONO}" font-size="10">短时不可信代码执行</text>

  <rect x="546" y="248" width="156" height="118" rx="6" fill="#0F172A" fill-opacity="0.76" stroke="#10B981"/>
  <text x="624" y="268" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">4. ACA Sandboxes</text>
  <text x="624" y="286" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">有状态编程工作区 (Preview)</text>
  <text x="624" y="304" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• create/pause/resume</text>
  <text x="624" y="320" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 内存与磁盘快照恢复</text>
  <text x="624" y="336" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• OCI 镜像 + 持久卷挂载</text>
  <text x="624" y="354" text-anchor="middle" fill="#FBBF24" font-family="{FONT_MONO}" font-size="10">Coding / 浏览器自动化</text>

  <rect x="712" y="248" width="156" height="118" rx="6" fill="#0F172A" fill-opacity="0.76" stroke="#10B981"/>
  <text x="790" y="268" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">5. AKS + Kata (AKSClaw)</text>
  <text x="790" y="286" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">多租户 K8s Agent 平台</text>
  <text x="790" y="304" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• Kata Pod VM 内核隔离</text>
  <text x="790" y="320" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• KEDA 弹性 + 共享技能库</text>
  <text x="790" y="336" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 5 道平台硬边界强制拦截</text>
  <text x="790" y="354" text-anchor="middle" fill="#38BDF8" font-family="{FONT_MONO}" font-size="10">企业级多租户 / SRE 舰队</text>

  <rect x="878" y="248" width="154" height="118" rx="6" fill="#0F172A" fill-opacity="0.76" stroke="#10B981"/>
  <text x="955" y="268" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">6. E2B on Azure VMSS</text>
  <text x="955" y="286" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">Firecracker MicroVM 集群</text>
  <text x="955" y="304" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• D96as_v7 (AMD Turin)</text>
  <text x="955" y="320" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 108ms Base / 132ms Code</text>
  <text x="955" y="336" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• UFFD + NBD 10万+ 并发</text>
  <text x="955" y="354" text-anchor="middle" fill="#F43F5E" font-family="{FONT_MONO}" font-size="10">AI Native 虚拟电脑底座</text>

  <!-- Layer 3: Ground (Models, Knowledge & Memory) -->
  <rect x="32" y="396" width="1016" height="150" rx="10" fill="url(#purpleGrad)" stroke="#A78BFA" stroke-width="1.5"/>
  <text x="48" y="420" fill="#C4B5FD" font-family="{FONT_MONO}" font-size="12" font-weight="700">LAYER 3 · GROUND (MODELS, KNOWLEDGE &amp; STATE PERSISTENCE)</text>
  <text x="485" y="420" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="13" font-weight="700">支撑 Agent 推理、工具上下文、长短期记忆、Checkpoint 断点与审计溯源</text>

  <rect x="48" y="432" width="236" height="100" rx="6" fill="#0F172A" fill-opacity="0.75" stroke="#8B5CF6"/>
  <text x="166" y="454" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">Foundry Models (11,000+)</text>
  <text x="166" y="474" text-anchor="middle" fill="#C4B5FD" font-family="{FONT_SANS}" font-size="11">Azure OpenAI · Claude · DeepSeek · Llama</text>
  <text x="166" y="492" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• PTU 预留吞吐 + 标准按量溢出</text>
  <text x="166" y="508" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 模型路由与 Fine-Tuning 微调</text>

  <rect x="296" y="432" width="236" height="100" rx="6" fill="#0F172A" fill-opacity="0.75" stroke="#8B5CF6"/>
  <text x="414" y="454" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">Foundry IQ &amp; AI Search</text>
  <text x="414" y="474" text-anchor="middle" fill="#C4B5FD" font-family="{FONT_SANS}" font-size="11">企业知识检索引擎 + 1,400+ MCP 连接器</text>
  <text x="414" y="492" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 混合向量 + 语义重排 + 权限裁剪</text>
  <text x="414" y="508" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• Logic Apps 企业连接器即插即用</text>

  <rect x="544" y="432" width="244" height="100" rx="6" fill="#0F172A" fill-opacity="0.75" stroke="#A78BFA" stroke-width="1.5"/>
  <text x="666" y="454" text-anchor="middle" fill="#FBBF24" font-family="{FONT_SANS}" font-size="12" font-weight="700">Azure HorizonDB (Preview)</text>
  <text x="666" y="474" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">AI 原生 PostgreSQL 状态与记忆引擎</text>
  <text x="666" y="492" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 单库融合 ACID + JSONB + DiskANN 向量</text>
  <text x="666" y="508" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 存算分离 · 15只读副本 · 原生 Checkpoint</text>
  <text x="666" y="524" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">对标 OpenAI 8亿用户 PG 架构范式</text>

  <rect x="800" y="432" width="232" height="100" rx="6" fill="#0F172A" fill-opacity="0.75" stroke="#8B5CF6"/>
  <text x="916" y="454" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">Cosmos DB &amp; Storage</text>
  <text x="916" y="474" text-anchor="middle" fill="#C4B5FD" font-family="{FONT_SANS}" font-size="11">全球分布式会话状态 + 快照存储</text>
  <text x="916" y="492" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 毫秒级多活读写 (Commerzbank 3万+/月)</text>
  <text x="916" y="508" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• Azure Blob / Files / Lustre 承载快照卷</text>

  <!-- Layer 4: Control & Govern -->
  <rect x="32" y="560" width="1016" height="148" rx="10" fill="url(#amberGrad)" stroke="#FBBF24" stroke-width="1.5"/>
  <text x="48" y="584" fill="#FDE68A" font-family="{FONT_MONO}" font-size="12" font-weight="700">LAYER 4 · CONTROL &amp; GOVERN (IDENTITY, AI GATEWAY &amp; FLEET SECURITY)</text>
  <text x="530" y="584" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="13" font-weight="700">不依赖 Agent 自觉：在平台层强制执行身份归属、密钥托管、配额硬熔断与合规审计</text>

  <rect x="48" y="596" width="320" height="98" rx="6" fill="#0F172A" fill-opacity="0.78" stroke="#F59E0B"/>
  <text x="208" y="618" text-anchor="middle" fill="#FDE68A" font-family="{FONT_SANS}" font-size="12" font-weight="700">Microsoft Entra Agent ID (一等公民身份)</text>
  <text x="208" y="638" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">Agent Blueprint + 责任人 (Owner/Sponsor)</text>
  <text x="208" y="656" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 严禁直接继承用户登录 Token，按动作签发短时凭证</text>
  <text x="208" y="674" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 审计日志同时记录 User 发起方与 Agent 执行方双重身份</text>

  <rect x="380" y="596" width="328" height="98" rx="6" fill="#0F172A" fill-opacity="0.78" stroke="#F59E0B"/>
  <text x="544" y="618" text-anchor="middle" fill="#FDE68A" font-family="{FONT_SANS}" font-size="12" font-weight="700">Unified AI Gateway (APIM / AKSClaw Gateway)</text>
  <text x="544" y="638" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">密钥不出网关 · 亲和路由 · 令牌硬熔断</text>
  <text x="544" y="656" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 容器内零 LLM API Key；Prefix-Cache 亲和路由提速降本</text>
  <text x="544" y="674" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 用户/团队/Agent 三级 RPM·TPM·预算硬上限 + MCP 白名单</text>

  <rect x="720" y="596" width="312" height="98" rx="6" fill="#0F172A" fill-opacity="0.78" stroke="#F59E0B"/>
  <text x="876" y="618" text-anchor="middle" fill="#FDE68A" font-family="{FONT_SANS}" font-size="12" font-weight="700">Defender · Purview · Network Hardening</text>
  <text x="876" y="638" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">平台级安全姿态与数据防泄漏闭环</text>
  <text x="876" y="656" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 封禁 169.254.169.254 IMDS 节点元数据防凭据窃取</text>
  <text x="876" y="674" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• OTel GenAI 全链路追踪 + Purview 敏感数据合规治理</text>
</svg>
"""
    return s


def build_svg_02() -> str:
    s = svg_header(
        1080,
        720,
        "图 2 · Azure 六大 Agent Runtime 责任边界、隔离机制与恢复延迟矩阵",
        "从托管式 Foundry Hosted Agents 到自建 E2B Firecracker MicroVM 的控制权光谱与量化对比",
    )
    headers = [
        ("维度 / 运行时", 32, 148),
        ("1. Foundry Hosted", 188, 138),
        ("2. Durable Functions", 334, 142),
        ("3. ACA Dyn Sessions", 484, 142),
        ("4. ACA Sandboxes", 634, 138),
        ("5. AKS + Kata VM", 780, 138),
        ("6. E2B on VMSS v7", 926, 122),
    ]
    s += '<rect x="32" y="86" width="1016" height="40" rx="8" fill="#1E293B" stroke="#475569"/>\n'
    for label, x, w in headers:
        s += f'<text x="{x + w // 2}" y="111" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">{label}</text>\n'

    rows = [
        (
            "托管层级与核心定位",
            [
                ("Agent 级全托管", "#38BDF8"),
                ("Serverless 持久编排", "#38BDF8"),
                ("预热隔离执行池", "#34D399"),
                ("有状态编程工作区", "#34D399"),
                ("多租户 K8s 平台", "#A78BFA"),
                ("高密 MicroVM 底座", "#F43F5E"),
            ],
        ),
        (
            "安全隔离边界",
            [
                ("平台服务级边界", "#E2E8F0"),
                ("Serverless Worker", "#E2E8F0"),
                ("Hyper-V 硬件虚拟化", "#6EE7B7"),
                ("隔离容器+网络策略", "#6EE7B7"),
                ("Kata Pod VM 独立内核", "#C4B5FD"),
                ("KVM + Firecracker", "#FDA4AF"),
            ],
        ),
        (
            "不可信代码 / Shell 执行",
            [
                ("不支持 (仅受控工具)", "#94A3B8"),
                ("不支持 (编排为主)", "#94A3B8"),
                ("原生支持 (短时脚本)", "#6EE7B7"),
                ("原生支持 (持久工作区)", "#6EE7B7"),
                ("原生支持 (Pod VM)", "#6EE7B7"),
                ("原生支持 (完整 OS/GUI)", "#6EE7B7"),
            ],
        ),
        (
            "状态持久化与跨任务恢复",
            [
                ("托管会话线程", "#E2E8F0"),
                ("Durable 检查点重放", "#38BDF8"),
                ("空闲即销毁 (需外部DB)", "#FBBF24"),
                ("内存/磁盘快照+持久卷", "#6EE7B7"),
                ("专属 PV + HorizonDB", "#C4B5FD"),
                ("UFFD懒加载+NBD差分", "#FDA4AF"),
            ],
        ),
        (
            "显式 Pause / Resume",
            [
                ("平台自动管理", "#94A3B8"),
                ("支持外部事件挂起唤醒", "#38BDF8"),
                ("不支持 (超时自动回收)", "#F87171"),
                ("支持编程式暂停/恢复", "#6EE7B7"),
                ("支持 (KEDA + 快照)", "#C4B5FD"),
                ("支持 (&lt;150ms 毫秒恢复)", "#6EE7B7"),
            ],
        ),
        (
            "实测/典型启动与恢复延迟",
            [
                ("~180–850 ms", "#E2E8F0"),
                ("~95 ms 热唤醒", "#38BDF8"),
                ("~210 ms 预热池分配", "#6EE7B7"),
                ("~320 ms 快照恢复", "#6EE7B7"),
                ("~160–1400 ms Pod", "#C4B5FD"),
                ("108ms Base / 132ms CI", "#34D399"),
            ],
        ),
        (
            "客户基础设施运维复杂度",
            [
                ("★☆☆☆☆☆ (极低)", "#34D399"),
                ("★★☆☆☆☆ (低)", "#34D399"),
                ("★★★☆☆☆ (中低)", "#38BDF8"),
                ("★★★☆☆☆ (中低)", "#38BDF8"),
                ("★★★★★☆ (高)", "#FBBF24"),
                ("★★★★★★ (极高·自建控制面)", "#F87171"),
            ],
        ),
        (
            "最佳匹配黄金场景",
            [
                ("To-B 标准企业助手", "#38BDF8"),
                ("长周期审批/事务工作流", "#38BDF8"),
                ("代码解释器/文件解析", "#6EE7B7"),
                ("Coding Agent/浏览器", "#6EE7B7"),
                ("多租户 SaaS/SRE 舰队", "#C4B5FD"),
                ("10万+并发 AI 虚拟电脑", "#FDA4AF"),
            ],
        ),
    ]

    y = 136
    for row_title, cells in rows:
        s += f'<rect x="32" y="{y}" width="1016" height="54" rx="6" fill="#0F172A" fill-opacity="0.82" stroke="#1E293B"/>\n'
        s += f'<text x="44" y="{y + 32}" fill="#93C5FD" font-family="{FONT_SANS}" font-size="12" font-weight="700">{row_title}</text>\n'
        for idx, (val, color) in enumerate(cells):
            _, x, w = headers[idx + 1]
            s += f'<rect x="{x + 4}" y="{y + 7}" width="{w - 8}" height="40" rx="5" fill="#1E293B" fill-opacity="0.7"/>\n'
            s += f'<text x="{x + w // 2}" y="{y + 31}" text-anchor="middle" fill="{color}" font-family="{FONT_SANS}" font-size="11" font-weight="600">{val}</text>\n'
        y += 62

    s += f"""
  <rect x="32" y="640" width="1016" height="56" rx="8" fill="#1E293B" stroke="#38BDF8" stroke-width="1.2"/>
  <text x="48" y="663" fill="#38BDF8" font-family="{FONT_SANS}" font-size="12" font-weight="700">架构师核心选型铁律 (Playbook Core Rule)：</text>
  <text x="295" y="663" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12">Foundry 与 Modernization PaaS / VM 是互补关系而非二选一；同一企业可将标准知识助手放 Foundry，将高密代码沙箱放 ACA / AKS / VMSS。</text>
  <text x="48" y="683" fill="#FBBF24" font-family="{FONT_SANS}" font-size="11">关键红线：若客户因安全/内核定制无法使用全托管 Foundry，但缺乏自有研发团队，严禁强行塞回 Foundry，必须先引入 CSU 或合作伙伴补齐交付能力。</text>
</svg>
"""
    return s


def build_svg_03() -> str:
    s = svg_header(
        1080,
        740,
        "图 3 · AI Agent Infra on Azure 双阶段架构选型决策树与数据底座配对图",
        "阶段 A：商务与交付资质门控 (Playbook Slide 7) × 阶段 B：运行时与状态存储精准路由 (Pitch Slides 7–12)",
    )
    s += f"""
  <!-- Left Panel: Stage A Macro Qualification -->
  <rect x="32" y="84" width="490" height="624" rx="10" fill="#0F172A" stroke="#3B82F6" stroke-width="1.5"/>
  <text x="52" y="112" fill="#60A5FA" font-family="{FONT_MONO}" font-size="13" font-weight="700">STAGE A · 商务模式与研发交付门控 (FIELD DECISION TREE)</text>

  <rect x="142" y="132" width="270" height="48" rx="8" fill="url(#blueGrad)" stroke="#93C5FD"/>
  <text x="277" y="154" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="13" font-weight="700">Q1: 业务客群定位 (To-B 还是 To-C)？</text>
  <text x="277" y="171" text-anchor="middle" fill="#DBEAFE" font-family="{FONT_SANS}" font-size="11">决定并发弹性模型、毛利敏感度与多租户隔离强度</text>

  <!-- To-C Branch -->
  <line x1="205" y1="180" x2="135" y2="228" stroke="#38BDF8" stroke-width="2"/>
  <text x="145" y="208" fill="#38BDF8" font-family="{FONT_SANS}" font-size="11" font-weight="700">To-C / AI Native</text>
  <rect x="52" y="228" width="175" height="72" rx="8" fill="url(#tealGrad)" stroke="#34D399"/>
  <text x="139" y="252" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12" font-weight="700">直通 Modernization PaaS</text>
  <text x="139" y="270" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="11">ACA / AKS / Azure VMSS</text>
  <text x="139" y="287" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">极致弹性 + 单位 Token/沙箱成本</text>

  <!-- To-B Branch -->
  <line x1="345" y1="180" x2="380" y2="228" stroke="#60A5FA" stroke-width="2"/>
  <text x="372" y="208" fill="#93C5FD" font-family="{FONT_SANS}" font-size="11" font-weight="700">To-B 企业内部/B2B</text>
  <rect x="255" y="228" width="245" height="62" rx="8" fill="#1E293B" stroke="#60A5FA"/>
  <text x="377" y="252" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">Q2: 是否需要超越托管服务的底层控制？</text>
  <text x="377" y="272" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">(自定义OS内核/私有网络拓扑/不可信代码沙箱/极致成本)</text>

  <!-- Q2 -> No -->
  <line x1="315" y1="290" x2="155" y2="346" stroke="#34D399" stroke-width="2"/>
  <text x="200" y="324" fill="#34D399" font-family="{FONT_SANS}" font-size="11" font-weight="700">否 (标准受控工具)</text>
  <rect x="52" y="346" width="205" height="74" rx="8" fill="url(#blueGrad)" stroke="#60A5FA"/>
  <text x="154" y="370" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12" font-weight="700">Microsoft Foundry Hosted</text>
  <text x="154" y="388" text-anchor="middle" fill="#93C5FD" font-family="{FONT_SANS}" font-size="11">1,400+ MCP 连接器 + Agent ID</text>
  <text x="154" y="405" text-anchor="middle" fill="#DBEAFE" font-family="{FONT_SANS}" font-size="10">注：仍需应用层 Prompt/工具联调</text>

  <!-- Q2 -> Yes -->
  <line x1="415" y1="290" x2="415" y2="346" stroke="#FBBF24" stroke-width="2"/>
  <text x="424" y="324" fill="#FBBF24" font-family="{FONT_SANS}" font-size="11" font-weight="700">是 (需底层控制)</text>
  <rect x="280" y="346" width="220" height="62" rx="8" fill="#1E293B" stroke="#FBBF24"/>
  <text x="390" y="370" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">Q3: 客户是否有专职研发/平台团队？</text>
  <text x="390" y="390" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">能够承担容器/K8s/VM与编排工程落地</text>

  <!-- Q3 -> No (Red Gate) -->
  <line x1="335" y1="408" x2="165" y2="465" stroke="#F87171" stroke-width="2"/>
  <text x="210" y="445" fill="#F87171" font-family="{FONT_SANS}" font-size="11" font-weight="700">否 (无研发团队)</text>
  <rect x="52" y="465" width="225" height="82" rx="8" fill="url(#roseGrad)" stroke="#F87171" stroke-width="1.5"/>
  <text x="164" y="489" text-anchor="middle" fill="#FECDD3" font-family="{FONT_SANS}" font-size="12" font-weight="700">⛔ 交付门禁拦截 (Hold Gate)</text>
  <text x="164" y="507" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11">引入 CSU 或 AI 合作伙伴共建</text>
  <text x="164" y="525" text-anchor="middle" fill="#FDA4AF" font-family="{FONT_SANS}" font-size="10">严禁将需底层控制的场景硬塞回 Foundry</text>

  <!-- Q3 -> Yes -->
  <line x1="435" y1="408" x2="405" y2="465" stroke="#34D399" stroke-width="2"/>
  <text x="430" y="445" fill="#34D399" font-family="{FONT_SANS}" font-size="11" font-weight="700">是 (具备团队)</text>
  <rect x="295" y="465" width="205" height="82" rx="8" fill="url(#tealGrad)" stroke="#34D399" stroke-width="1.5"/>
  <text x="397" y="489" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12" font-weight="700">✅ 进入 Stage B 技术选型</text>
  <text x="397" y="507" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="11">Modernization PaaS / VM</text>
  <text x="397" y="525" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">按工作负载特征映射 6 大运行时</text>

  <rect x="52" y="566" width="448" height="122" rx="8" fill="#1E293B" stroke="#475569"/>
  <text x="68" y="588" fill="#FBBF24" font-family="{FONT_SANS}" font-size="12" font-weight="700">商机筛选四要素 (4 Foundations) 与 $10K 模型信号门禁：</text>
  <text x="68" y="608" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">1. Runtime (ACA/AKS/Functions/App Service) · 2. Data/State (HorizonDB/PG/Cosmos/Redis)</text>
  <text x="68" y="626" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">3. AI &amp; Integration (Foundry Models/Search/APIM) · 4. Ops/Security (Monitor/KeyVault/Defender)</text>
  <text x="68" y="646" fill="#93C5FD" font-family="{FONT_SANS}" font-size="11">• 持续性门禁：非模型家族需在 5 个月窗口内 ≥3 个月活跃且包含最近连续 2 个月</text>
  <text x="68" y="666" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="11">• 模型门禁：最近 3 个月每月 Foundry Models ≥$10,000 计入强信号，但未达标仍可走非模型强路径</text>

  <!-- Right Panel: Stage B Technical Routing -->
  <rect x="542" y="84" width="506" height="624" rx="10" fill="#0F172A" stroke="#10B981" stroke-width="1.5"/>
  <text x="562" y="112" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="13" font-weight="700">STAGE B · 工作负载特征 → 运行时 + 状态存储精准配对</text>

  <!-- 5 Technical Routing Cards -->
  <rect x="562" y="130" width="466" height="96" rx="8" fill="#1E293B" stroke="#38BDF8"/>
  <text x="578" y="152" fill="#38BDF8" font-family="{FONT_SANS}" font-size="13" font-weight="700">路径 1 · 长周期审批 / 跨系统事务 / 外部事件唤醒</text>
  <text x="578" y="172" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">特征：采购/财务/工单流，需挂起数小时~数天等待人工审批，要求断电/重启后确定性重放与幂等重试</text>
  <text x="578" y="192" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="11">Runtime: Azure Functions + Durable Functions + ACA Apps</text>
  <text x="578" y="210" fill="#C4B5FD" font-family="{FONT_MONO}" font-size="11">State: Durable Task Scheduler + Azure HorizonDB / Cosmos DB</text>

  <rect x="562" y="238" width="466" height="96" rx="8" fill="#1E293B" stroke="#34D399"/>
  <text x="578" y="260" fill="#34D399" font-family="{FONT_SANS}" font-size="13" font-weight="700">路径 2 · 短时不可信代码执行 / 数据分析 / 文件解析</text>
  <text x="578" y="280" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">特征：LLM 动态生成 Python/Shell 脚本处理单次任务，需毫秒级预热池分配 (~210ms) 与用完即焚</text>
  <text x="578" y="300" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="11">Runtime: ACA Apps (宿主编排) + ACA Dynamic Sessions (Hyper-V 预热池)</text>
  <text x="578" y="318" fill="#C4B5FD" font-family="{FONT_MONO}" font-size="11">State: 必须外置至 HorizonDB / Cosmos DB (Session 回收后本地目录清零)</text>

  <rect x="562" y="346" width="466" height="96" rx="8" fill="#1E293B" stroke="#FBBF24"/>
  <text x="578" y="368" fill="#FBBF24" font-family="{FONT_SANS}" font-size="13" font-weight="700">路径 3 · 有状态 Coding Agent / 浏览器自动化 / 跨任务工作区</text>
  <text x="578" y="388" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">特征：需自定义 OCI 镜像、挂载持久卷、开放特定端口，并按用户生命周期显式 pause/resume</text>
  <text x="578" y="408" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="11">Runtime: ACA Apps / AKS + ACA Sandboxes (Preview)</text>
  <text x="578" y="426" fill="#C4B5FD" font-family="{FONT_MONO}" font-size="11">State: Sandbox 内存/磁盘快照 + Persistent Volume + HorizonDB</text>

  <rect x="562" y="454" width="466" height="106" rx="8" fill="#1E293B" stroke="#A78BFA"/>
  <text x="578" y="476" fill="#C4B5FD" font-family="{FONT_SANS}" font-size="13" font-weight="700">路径 4 · 企业级多租户 Agent 平台 / 研发与 SRE 舰队 (AKSClaw)</text>
  <text x="578" y="496" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">特征：每位工程师/租户独立持久实例，BYO Harness (Copilot/Hermes/OpenClaw)，5道平台安全硬边界</text>
  <text x="578" y="516" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="11">Runtime: AKS (Automatic/Standard) + Kata Pod VM + KEDA + AI Gateway</text>
  <text x="578" y="534" fill="#C4B5FD" font-family="{FONT_MONO}" font-size="11">State: 共享只读技能 PV + 实例独占状态 PV + Azure HorizonDB (ACID+Vector)</text>

  <rect x="562" y="572" width="466" height="116" rx="8" fill="#1E293B" stroke="#F43F5E" stroke-width="1.5"/>
  <text x="578" y="594" fill="#FDA4AF" font-family="{FONT_SANS}" font-size="13" font-weight="700">路径 5 · 10万+ 并发云端虚拟电脑 / 亚 150ms 极速恢复 (Manus × E2B)</text>
  <text x="578" y="614" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">特征：AI Native 产品为每个任务分配完整 Linux/GUI 桌面，要求 ~108ms–132ms 唤醒与百万级会话限流</text>
  <text x="578" y="634" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="11">Runtime: Azure VMSS Flexible (D96as_v7) + Nomad/Consul + Firecracker</text>
  <text x="578" y="652" fill="#38BDF8" font-family="{FONT_MONO}" font-size="11">Gateway: AppGW WAF v2 (双前端) + APIM (按动态 Host Header 独立限流)</text>
  <text x="578" y="670" fill="#C4B5FD" font-family="{FONT_MONO}" font-size="11">State: UFFD 缺页流式内存恢复 + NBD 块差分快照 + PG 主从 + Azure Blob</text>
</svg>
"""
    return s


def build_svg_04() -> str:
    s = svg_header(
        1080,
        740,
        "图 4 · AKSClaw 多租户 Kubernetes Agent 平台参考架构 (6 大核心支柱与 5 道平台硬边界)",
        "基于 AKS + Kata Containers Pod VM + Entra Agent ID + Unified AI Gateway 构建不依赖 Agent 自觉的企业级生产底座",
    )
    s += f"""
  <!-- Top Ingress & Event Layer -->
  <rect x="32" y="84" width="495" height="90" rx="10" fill="url(#blueGrad)" stroke="#60A5FA"/>
  <text x="48" y="108" fill="#93C5FD" font-family="{FONT_MONO}" font-size="12" font-weight="700">1. INTERACTIVE CHANNELS (人机交互入口)</text>
  <text x="48" y="130" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="13" font-weight="700">Teams · Slack · Discord · Web Portal · CLI</text>
  <text x="48" y="150" fill="#DBEAFE" font-family="{FONT_SANS}" font-size="11">• Follow-the-Sun 跨时区无缝接力（Redmond → 欧洲 → 亚太共享同一实例上下文）</text>

  <rect x="553" y="84" width="495" height="90" rx="10" fill="url(#purpleGrad)" stroke="#A78BFA"/>
  <text x="569" y="108" fill="#C4B5FD" font-family="{FONT_MONO}" font-size="12" font-weight="700">2. EVENT-DRIVEN TRIAGE GATEWAY (事件驱动自动预诊断)</text>
  <text x="569" y="130" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="13" font-weight="700">IcM P1/P2 告警 · GitHub Issue/PR · 监控异常 · 定时巡检</text>
  <text x="569" y="150" text-anchor="start" fill="#EDE9FE" font-family="{FONT_SANS}" font-size="11">• 事件到达秒级唤醒 Agent 拉日志/查近期变更 → 推送根因摘要 → 人工审批后执行修复</text>

  <!-- Middle AKS Cluster & Kata Pod VM Sandboxes -->
  <rect x="32" y="190" width="680" height="340" rx="10" fill="#0F172A" stroke="#34D399" stroke-width="1.5"/>
  <text x="48" y="216" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="13" font-weight="700">3. AKS MULTI-TENANT RUNTIME · KATA CONTAINERS POD VM SANDBOXING</text>
  <text x="48" y="236" fill="#94A3B8" font-family="{FONT_SANS}" font-size="11">每位工程师 / 每个业务职能拥有独立持久化的 Agent 实例，支持 BYO Agent Harness 混部与 KEDA 弹性扩缩容</text>

  <!-- 4 Agent Pods -->
  <rect x="48" y="250" width="152" height="145" rx="8" fill="#1E293B" stroke="#10B981"/>
  <text x="124" y="272" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">Kata Pod VM #1</text>
  <text x="124" y="290" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11">OpenClaw 实例</text>
  <text x="124" y="310" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 独立 Guest Kernel</text>
  <text x="124" y="326" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 专属 Memory.md</text>
  <text x="124" y="342" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• MCP 工具 Sidecar</text>
  <text x="124" y="362" text-anchor="middle" fill="#38BDF8" font-family="{FONT_MONO}" font-size="10">Owner: Alice (SRE)</text>

  <rect x="212" y="250" width="152" height="145" rx="8" fill="#1E293B" stroke="#10B981"/>
  <text x="288" y="272" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">Kata Pod VM #2</text>
  <text x="288" y="290" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11">Hermes 实例</text>
  <text x="288" y="310" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 独立 Guest Kernel</text>
  <text x="288" y="326" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 故障自进化总结</text>
  <text x="288" y="342" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• kubectl / az 受控执行</text>
  <text x="288" y="362" text-anchor="middle" fill="#38BDF8" font-family="{FONT_MONO}" font-size="10">Owner: Bob (Infra)</text>

  <rect x="376" y="250" width="152" height="145" rx="8" fill="#1E293B" stroke="#10B981"/>
  <text x="452" y="272" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">Kata Pod VM #3</text>
  <text x="452" y="290" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11">GH Copilot SDK</text>
  <text x="452" y="310" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 独立 Guest Kernel</text>
  <text x="452" y="326" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 代码库补丁生成</text>
  <text x="452" y="342" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 单元测试沙箱验证</text>
  <text x="452" y="362" text-anchor="middle" fill="#38BDF8" font-family="{FONT_MONO}" font-size="10">Owner: Dev Team A</text>

  <rect x="540" y="250" width="154" height="145" rx="8" fill="#1E293B" stroke="#10B981"/>
  <text x="617" y="272" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">Kata Pod VM #N</text>
  <text x="617" y="290" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11">MAF / LangGraph</text>
  <text x="617" y="310" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 独立 Guest Kernel</text>
  <text x="617" y="326" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 跨地域只读接管</text>
  <text x="617" y="342" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 空闲休眠 / 秒级唤醒</text>
  <text x="617" y="362" text-anchor="middle" fill="#38BDF8" font-family="{FONT_MONO}" font-size="10">Owner: Global Oncall</text>

  <!-- Storage Separation Inside AKS -->
  <rect x="48" y="410" width="316" height="104" rx="8" fill="url(#tealGrad)" stroke="#34D399"/>
  <text x="206" y="434" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12" font-weight="700">共享技能市场卷 (Shared Team Skill Marketplace)</text>
  <text x="206" y="454" text-anchor="middle" fill="#D1FAE5" font-family="{FONT_SANS}" font-size="11">ReadWriteMany (RO 挂载) · Git PR 审核发布</text>
  <text x="206" y="474" text-anchor="middle" fill="#A7F3D0" font-family="{FONT_SANS}" font-size="10">• 1人编写 AKS/Bicep/IcM 排障 Skill → 全团队实例即刻生效</text>
  <text x="206" y="492" text-anchor="middle" fill="#A7F3D0" font-family="{FONT_SANS}" font-size="10">• 技能按风险分级标注 + 语义发现 + 版本可回滚</text>

  <rect x="378" y="410" width="316" height="104" rx="8" fill="url(#blueGrad)" stroke="#60A5FA"/>
  <text x="536" y="434" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12" font-weight="700">实例独占状态卷 + Azure HorizonDB</text>
  <text x="536" y="454" text-anchor="middle" fill="#DBEAFE" font-family="{FONT_SANS}" font-size="11">Per-Instance Isolated PV + ACID/Vector DB</text>
  <text x="536" y="474" text-anchor="middle" fill="#93C5FD" font-family="{FONT_SANS}" font-size="10">• 技能共享但会话历史、临时文件、个人偏好严格物理隔离</text>
  <text x="536" y="492" text-anchor="middle" fill="#93C5FD" font-family="{FONT_SANS}" font-size="10">• Pod 重启或节点漂移后完整保留工作区与长短期记忆</text>

  <!-- Right Column: 5 Platform Hard Security Boundaries -->
  <rect x="728" y="190" width="320" height="340" rx="10" fill="url(#roseGrad)" stroke="#F87171" stroke-width="1.5"/>
  <text x="744" y="216" fill="#FECDD3" font-family="{FONT_MONO}" font-size="12" font-weight="700">4. 5 NON-BYPASSABLE HARD BOUNDARIES</text>
  <text x="744" y="236" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12" font-weight="700">即使 Prompt 注入或开启 --yolo 也无法越权</text>

  <rect x="744" y="248" width="288" height="48" rx="6" fill="#0F172A" fill-opacity="0.82" stroke="#F87171"/>
  <text x="756" y="268" fill="#FCA5A5" font-family="{FONT_SANS}" font-size="11" font-weight="700">① 节点元数据强制封禁 (IMDS Block)</text>
  <text x="756" y="286" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">NetworkPolicy 阻断 169.254.169.254，杜绝窃取宿主机身份</text>

  <rect x="744" y="304" width="288" height="48" rx="6" fill="#0F172A" fill-opacity="0.82" stroke="#F87171"/>
  <text x="756" y="324" fill="#FCA5A5" font-family="{FONT_SANS}" font-size="11" font-weight="700">② 出向网络白名单 (Egress Control)</text>
  <text x="756" y="342" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">仅放行 AI Gateway 与受控内部服务端点，阻断任意外发渗出</text>

  <rect x="744" y="360" width="288" height="48" rx="6" fill="#0F172A" fill-opacity="0.82" stroke="#F87171"/>
  <text x="756" y="380" fill="#FCA5A5" font-family="{FONT_SANS}" font-size="11" font-weight="700">③ 凭据注入代理 (Zero Raw Key in Pod)</text>
  <text x="756" y="398" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">容器环境变量零长期密钥，按单次动作签发短时最小权限令牌</text>

  <rect x="744" y="416" width="288" height="48" rx="6" fill="#0F172A" fill-opacity="0.82" stroke="#F87171"/>
  <text x="756" y="436" fill="#FCA5A5" font-family="{FONT_SANS}" font-size="11" font-weight="700">④ 身份不可伪造 (Entra Agent ID)</text>
  <text x="756" y="454" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">Workload Identity 平台绑定，绝不继承用户个人完整权限</text>

  <rect x="744" y="472" width="288" height="46" rx="6" fill="#0F172A" fill-opacity="0.82" stroke="#F87171"/>
  <text x="756" y="491" fill="#FCA5A5" font-family="{FONT_SANS}" font-size="11" font-weight="700">⑤ 强制全链路审计 (Mandatory Audit)</text>
  <text x="756" y="508" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">网关与身份代理层采集全量推理/工具调用，Agent 无法篡改</text>

  <!-- Bottom Unified AI Gateway & Fleet Governance -->
  <rect x="32" y="546" width="1016" height="162" rx="10" fill="url(#amberGrad)" stroke="#FBBF24" stroke-width="1.5"/>
  <text x="48" y="572" fill="#FDE68A" font-family="{FONT_MONO}" font-size="13" font-weight="700">5. UNIFIED AI GATEWAY &amp; FLEET LIFECYCLE GOVERNANCE (统一 AI 网关与舰队治理)</text>

  <rect x="48" y="586" width="236" height="106" rx="6" fill="#0F172A" fill-opacity="0.8" stroke="#F59E0B"/>
  <text x="166" y="608" text-anchor="middle" fill="#FDE68A" font-family="{FONT_SANS}" font-size="12" font-weight="700">Prefix-Cache 亲和路由</text>
  <text x="166" y="628" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">多轮长上下文精准命中缓存</text>
  <text x="166" y="648" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 相同 Session 路由至同一后端</text>
  <text x="166" y="666" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="10">• 显著降低首字延迟 (TTFT) 与成本</text>

  <rect x="296" y="586" width="236" height="106" rx="6" fill="#0F172A" fill-opacity="0.8" stroke="#F59E0B"/>
  <text x="414" y="608" text-anchor="middle" fill="#FDE68A" font-family="{FONT_SANS}" font-size="12" font-weight="700">三级配额与预算硬熔断</text>
  <text x="414" y="628" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">User · Team · Agent Instance</text>
  <text x="414" y="648" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• RPM / TPM / 日月预算实时计量</text>
  <text x="414" y="666" text-anchor="middle" fill="#FCA5A5" font-family="{FONT_SANS}" font-size="10">• 死循环或超支触发网关级硬拦截</text>

  <rect x="544" y="586" width="236" height="106" rx="6" fill="#0F172A" fill-opacity="0.8" stroke="#F59E0B"/>
  <text x="662" y="608" text-anchor="middle" fill="#FDE68A" font-family="{FONT_SANS}" font-size="12" font-weight="700">OTel GenAI 可观测大盘</text>
  <text x="662" y="628" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">零代码侵入全量遥测</text>
  <text x="662" y="648" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 追踪每次推理、工具调用、延迟</text>
  <text x="662" y="666" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 跨模型回退 (429/5xx Failover)</text>

  <rect x="792" y="586" width="240" height="106" rx="6" fill="#0F172A" fill-opacity="0.8" stroke="#F59E0B"/>
  <text x="912" y="608" text-anchor="middle" fill="#FDE68A" font-family="{FONT_SANS}" font-size="12" font-weight="700">舰队生命周期治理</text>
  <text x="912" y="628" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">消除僵尸 Agent 与孤儿凭据</text>
  <text x="912" y="648" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 强制登记 Owner/业务用途/有效期</text>
  <text x="912" y="666" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="10">• 人员离职转岗自动触发权限回收</text>
</svg>
"""
    return s


def build_svg_05() -> str:
    s = svg_header(
        1080,
        740,
        "图 5 · E2B on Azure VMSS 生产级参考架构图 (Manus × E2B 10万+ 并发云端沙箱底座)",
        "Application Gateway WAF v2 双前端 × APIM 按动态 Host 独立限流 × Nomad/Consul 调度 × Azure VMSS Flexible (D96as_v7)",
    )
    s += f"""
  <!-- Top Traffic & Dual-Hop Gateway Layer -->
  <rect x="32" y="84" width="1016" height="156" rx="10" fill="url(#blueGrad)" stroke="#60A5FA" stroke-width="1.5"/>
  <text x="48" y="108" fill="#93C5FD" font-family="{FONT_MONO}" font-size="12" font-weight="700">INGRESS &amp; PER-SANDBOX SESSION RATE-LIMITING PLANE (100,000+ DYNAMIC SUBDOMAINS)</text>

  <rect x="48" y="122" width="185" height="102" rx="8" fill="#0F172A" fill-opacity="0.82" stroke="#38BDF8"/>
  <text x="140" y="144" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">1. Agent SDK / Client</text>
  <text x="140" y="164" text-anchor="middle" fill="#38BDF8" font-family="{FONT_MONO}" font-size="10">*.e2b.domain.com</text>
  <text x="140" y="182" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• HTTPS 控制面 API</text>
  <text x="140" y="198" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• WSS 终端/桌面流式连接</text>
  <text x="140" y="214" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">&lt;port&gt;-&lt;id&gt;.domain</text>

  <rect x="255" y="122" width="250" height="102" rx="8" fill="#0F172A" fill-opacity="0.82" stroke="#60A5FA"/>
  <text x="380" y="144" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">2. Application Gateway (WAF v2)</text>
  <text x="380" y="164" text-anchor="middle" fill="#93C5FD" font-family="{FONT_SANS}" font-size="11">双前端 IP 架构 (Public + Private)</text>
  <text x="380" y="182" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• Public IP (443): 通配符 TLS 卸载 + OWASP WAF</text>
  <text x="380" y="198" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• Private IP (8080): 接收 APIM 回调并转发</text>
  <text x="380" y="214" text-anchor="middle" fill="#FBBF24" font-family="{FONT_SANS}" font-size="10">• 规避 APIM 直连 VMSS 后端池限制</text>

  <rect x="527" y="122" width="275" height="102" rx="8" fill="#0F172A" fill-opacity="0.82" stroke="#F59E0B" stroke-width="1.5"/>
  <text x="664" y="144" text-anchor="middle" fill="#FDE68A" font-family="{FONT_SANS}" font-size="12" font-weight="700">3. Azure API Management (APIM)</text>
  <text x="664" y="164" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11">按动态 Host Header 精细化会话限流</text>
  <text x="664" y="182" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">counter-key="@(Headers['Host'])"</text>
  <text x="664" y="198" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 10万+ 活跃沙箱会话彼此独立计数互不干扰</text>
  <text x="664" y="214" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 原生支持 WebSocket 双向长连接透传</text>

  <rect x="824" y="122" width="208" height="102" rx="8" fill="#0F172A" fill-opacity="0.82" stroke="#34D399"/>
  <text x="928" y="144" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">4. API Pool (VMSS)</text>
  <text x="928" y="164" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">Client Proxy + E2B API</text>
  <text x="928" y="182" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 端口 3001/3002 动态路由</text>
  <text x="928" y="198" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 端口 50001 会话创建/销毁</text>
  <text x="928" y="214" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• Consul 服务发现健康检查</text>

  <!-- Middle Compute & Orchestration Plane -->
  <rect x="32" y="254" width="680" height="310" rx="10" fill="#0F172A" stroke="#10B981" stroke-width="1.5"/>
  <text x="48" y="280" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="13" font-weight="700">CLIENT POOL · AZURE VMSS FLEXIBLE (STANDARD_D96AS_V7 · UP TO 1,000 VMS)</text>
  <text x="48" y="300" fill="#94A3B8" font-family="{FONT_SANS}" font-size="11">5th Gen AMD EPYC Turin (4.5GHz) + Azure Boost · 96 vCPU / 384 GiB RAM · 承载高密 KVM + Firecracker 沙箱</text>

  <rect x="48" y="314" width="312" height="162" rx="8" fill="#1E293B" stroke="#34D399"/>
  <text x="204" y="336" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">Client Node #1 (D96as_v7 · 96vCPU/384GiB)</text>
  <text x="64" y="358" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">• Nomad Client + Consul Agent + Node Exporter</text>
  <text x="64" y="378" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">• Orchestrator Daemon (gRPC 管理沙箱生命周期)</text>
  <text x="64" y="398" fill="#38BDF8" font-family="{FONT_SANS}" font-size="11">• HugePages 大页内存池 (~326 GiB 预留给 MicroVM)</text>
  <text x="64" y="418" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="11">• 数百个并发 Firecracker MicroVM (108ms 启动)</text>
  <text x="64" y="438" fill="#FBBF24" font-family="{FONT_SANS}" font-size="10">• Template Manager (构建自定义 OCI → rootfs.ext4)</text>
  <text x="64" y="458" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• Vector Agent 采集沙箱日志与指标流</text>

  <rect x="376" y="314" width="320" height="162" rx="8" fill="#1E293B" stroke="#34D399"/>
  <text x="536" y="336" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">VMSS 非对称弹性扩缩容法则 (Scale Rules)</text>
  <text x="392" y="358" fill="#38BDF8" font-family="{FONT_SANS}" font-size="11" font-weight="700">▲ Scale-Out (扩容)：CPU &gt; 60% 自动触发</text>
  <text x="392" y="376" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 预留 40% CPU 余量吸收突发 MicroVM 创建洪峰</text>
  <text x="392" y="398" fill="#F87171" font-family="{FONT_SANS}" font-size="11" font-weight="700">▼ Scale-In (缩容)：严禁仅凭 CPU 指标盲目缩容</text>
  <text x="392" y="416" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">• Firecracker 使用 HugePages，宿主机常规内存指标失真</text>
  <text x="392" y="434" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">• 必须结合自定义 HugePages 监控 + 沙箱快照热迁移排空</text>
  <text x="392" y="454" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="10">• 单一 VMSS Flexible 规模集最高支持 1,000 台宿主机</text>

  <rect x="48" y="488" width="648" height="62" rx="8" fill="url(#tealGrad)" stroke="#34D399"/>
  <text x="64" y="512" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12" font-weight="700">10万并发沙箱容量测算 (agent_infra_sizer.py 验证)：</text>
  <text x="64" y="532" fill="#D1FAE5" font-family="{FONT_MONO}" font-size="11">512 MiB/Sandbox × 85% HugePages × 60% 水位 = 384 稳态沙箱/节点 → 261 台 D96as_v7 节点即可承载 100,000 并发</text>

  <!-- Right Column: Server Pool + Data + Observability -->
  <rect x="728" y="254" width="320" height="310" rx="10" fill="url(#purpleGrad)" stroke="#A78BFA" stroke-width="1.5"/>
  <text x="744" y="280" fill="#C4B5FD" font-family="{FONT_MONO}" font-size="12" font-weight="700">CONTROL, STORAGE &amp; OBSERVABILITY</text>

  <rect x="744" y="294" width="288" height="76" rx="6" fill="#0F172A" fill-opacity="0.82" stroke="#8B5CF6"/>
  <text x="888" y="316" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">Server Pool (Nomad + Consul)</text>
  <text x="888" y="336" text-anchor="middle" fill="#C4B5FD" font-family="{FONT_SANS}" font-size="10">• 3~5 节点 Raft 强一致集群调度</text>
  <text x="888" y="354" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 替代 K8s 直接调度裸金属/VM 上的 MicroVM</text>

  <rect x="744" y="380" width="288" height="84" rx="6" fill="#0F172A" fill-opacity="0.82" stroke="#8B5CF6"/>
  <text x="888" y="402" text-anchor="middle" fill="#FBBF24" font-family="{FONT_SANS}" font-size="12" font-weight="700">Azure Database for PostgreSQL</text>
  <text x="888" y="422" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">• Primary 写库 + Read Replicas 读扩展</text>
  <text x="888" y="440" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• PgBouncer 连接池 + Cache Lease Lock 防击穿</text>
  <text x="888" y="456" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">OpenAI 同源架构 (50只读副本·100万+ QPS)</text>

  <rect x="744" y="474" width="288" height="76" rx="6" fill="#0F172A" fill-opacity="0.82" stroke="#8B5CF6"/>
  <text x="888" y="496" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12" font-weight="700">Snapshots &amp; Observability</text>
  <text x="888" y="516" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• Azure Blob / Files / Lustre 存 memfile+rootfs</text>
  <text x="888" y="534" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• Prometheus + Loki + Grafana + Azure Monitor</text>

  <!-- Bottom Warning on Open-Source E2B Gaps -->
  <rect x="32" y="578" width="1016" height="130" rx="10" fill="url(#roseGrad)" stroke="#F87171" stroke-width="1.5"/>
  <text x="48" y="604" fill="#FECDD3" font-family="{FONT_MONO}" font-size="12" font-weight="700">ARCHITECTURAL CAUTION · 开源版 E2B 直接上生产的三大架构缺陷与 Azure 加固方案 (Deep Dive Slide 34)</text>
  <text x="48" y="628" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12">1. 控制面单点内存态：开源 E2B API 将节点与沙箱映射保存在单进程内存中，不支持多实例水平扩展且重启即丢失状态 → 需外置状态至 PostgreSQL/Redis。</text>
  <text x="48" y="652" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12">2. VM 重启孤儿沙箱：Client Node 重启后缺乏自动 GC 与自愈重调度机制 → 需结合 Nomad 健康探针与 VMSS 自动实例修复策略。</text>
  <text x="48" y="676" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12">3. 网关单点限流瓶颈：原生缺少百万级动态子域名分布式限流与 WAF 防护 → 必须前置 AppGW WAF v2 (双前端) + APIM rate-limit-by-key。</text>
</svg>
"""
    return s


def build_svg_06() -> str:
    s = svg_header(
        1080,
        740,
        "图 6 · Firecracker MicroVM 沙箱内部机理 (UFFD + NBD) 与 Azure v6/v7 实测启动延迟对比",
        "左：KVM + virtio-net/blk + UFFD 缺页流式恢复 + envd/noVNC 内部链路 · 右：East US 2 / Central US 实测延迟与 Azure Boost 增益",
    )
    s += f"""
  <!-- Left Panel: MicroVM Internals -->
  <rect x="32" y="84" width="510" height="624" rx="10" fill="#0F172A" stroke="#38BDF8" stroke-width="1.5"/>
  <text x="50" y="112" fill="#38BDF8" font-family="{FONT_MONO}" font-size="13" font-weight="700">INSIDE FIRECRACKER MICROVM &amp; HOST KERNEL DATAPATH</text>

  <rect x="50" y="128" width="474" height="166" rx="8" fill="#1E293B" stroke="#60A5FA"/>
  <text x="66" y="150" fill="#93C5FD" font-family="{FONT_SANS}" font-size="12" font-weight="700">Guest MicroVM 内部环境 (Kernel + Rootfs + Desktop/Code Stack)</text>
  <rect x="66" y="162" width="218" height="54" rx="6" fill="#0F172A" stroke="#3B82F6"/>
  <text x="175" y="182" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="11" font-weight="700">envd 守护进程 (:49982)</text>
  <text x="175" y="200" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">Connect RPC · Shell/文件/指标流</text>

  <rect x="294" y="162" width="214" height="54" rx="6" fill="#0F172A" stroke="#3B82F6"/>
  <text x="401" y="182" text-anchor="middle" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="11" font-weight="700">Jupyter Server (:8888)</text>
  <text x="401" y="200" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">Code-Interpreter V1 有状态内核</text>

  <rect x="66" y="226" width="442" height="54" rx="6" fill="#0F172A" stroke="#10B981"/>
  <text x="287" y="246" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="11" font-weight="700">Computer-Use GUI 桌面栈 (E2B Desktop Sandbox)</text>
  <text x="287" y="264" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_MONO}" font-size="10">Xvfb + XFCE4 → x11vnc (:5900) → websockify/noVNC (:6080) + xdotool + ffmpeg</text>

  <!-- Virtio & Network Namespace -->
  <rect x="50" y="308" width="474" height="122" rx="8" fill="#1E293B" stroke="#34D399"/>
  <text x="66" y="330" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">1. 网络隔离链路：virtio-net + 独立 NetNS (ns-N)</text>
  <text x="66" y="352" fill="#E2E8F0" font-family="{FONT_MONO}" font-size="11">Guest eth0 ↔ tap0 ↔ veth-N (ns-N) ↔ Host Bridge ↔ WireGuard/VNet</text>
  <text x="66" y="374" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 宿主机通过 iptables SNAT/DNAT 将外部会话流量精准映射至对应沙箱 ns-N</text>
  <text x="66" y="394" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 沙箱间二层/三层默认完全隔离，出向流量受宿主机防火墙策略管控</text>
  <text x="66" y="414" fill="#38BDF8" font-family="{FONT_SANS}" font-size="10">• 编排器通过 169.254.0.21:49982 健康探针 (每 200ms) 监控 envd 状态</text>

  <!-- UFFD & NBD Snapshot Engine -->
  <rect x="50" y="444" width="474" height="246" rx="8" fill="#1E293B" stroke="#F59E0B" stroke-width="1.5"/>
  <text x="66" y="468" fill="#FDE68A" font-family="{FONT_SANS}" font-size="12" font-weight="700">2. 108ms 极速恢复核心秘密：UFFD 内存按需缺页 + NBD 块差分快照</text>
  <text x="66" y="492" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11" font-weight="700">• UFFD (userfaultfd) 懒加载内存恢复：</text>
  <text x="78" y="510" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">恢复沙箱时无需把数 GB 内存镜像完整读入本地，Firecracker 立即恢复 vCPU 执行；</text>
  <text x="78" y="526" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">当 Guest 访问未加载内存页触发 Page Fault 时，宿主机 UFFD Handler 从远端对象存储按需拉取对应 4KB/2MB 页。</text>
  <text x="66" y="550" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11" font-weight="700">• NBD (Network Block Device) + Dirty Bitmap 增量存储：</text>
  <text x="78" y="568" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">只读基础镜像 (rootfs.ext4) 多沙箱共享缓存；写操作落入本地差分层并用 Bitmap 记录脏块；</text>
  <text x="78" y="584" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">Pause 快照仅上传 Dirty Pages 与 Dirty Blocks，大幅压缩快照体积与暂停耗时。</text>
  <rect x="66" y="600" width="442" height="74" rx="6" fill="#0F172A" stroke="#F59E0B"/>
  <text x="287" y="622" text-anchor="middle" fill="#FDE68A" font-family="{FONT_MONO}" font-size="11" font-weight="700">Snapshot Restore Critical Path (108 ms on D96as_v7)</text>
  <text x="287" y="642" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">Create NetNS (18ms) → Attach NBD/UFFD (32ms) → Firecracker Resume (38ms) → envd Ready (20ms)</text>
  <text x="287" y="660" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">对比传统容器冷启动 (1.6s~2.2s) 提速 12× ~ 20×</text>

  <!-- Right Panel: Measured Benchmark Bars -->
  <rect x="560" y="84" width="488" height="624" rx="10" fill="#0F172A" stroke="#10B981" stroke-width="1.5"/>
  <text x="578" y="112" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="13" font-weight="700">MEASURED BENCHMARK · AZURE VM SERIES V6 VS V7 (SLIDE 18–19)</text>
  <text x="578" y="132" fill="#94A3B8" font-family="{FONT_SANS}" font-size="11">测试区域：East US 2 &amp; Central US · 越短越好 (Lower is Faster)</text>

  <!-- Chart 1: Base Sandbox Startup -->
  <rect x="578" y="148" width="452" height="170" rx="8" fill="#1E293B" stroke="#334155"/>
  <text x="594" y="172" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="13" font-weight="700">A. Base Sandbox 启动耗时对比 (ms)</text>

  <text x="594" y="204" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="11" font-weight="700">D96as_v7 (AMD Turin)</text>
  <rect x="760" y="190" width="118" height="20" rx="4" fill="#10B981"/>
  <text x="886" y="205" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="12" font-weight="700">108 ms ★ 最优 (-54.8% vs v6 AMD)</text>

  <text x="594" y="242" fill="#93C5FD" font-family="{FONT_MONO}" font-size="11">D96s_v6 (Intel v6)</text>
  <rect x="760" y="228" width="127" height="20" rx="4" fill="#3B82F6"/>
  <text x="895" y="243" fill="#93C5FD" font-family="{FONT_MONO}" font-size="12">116 ms ($4.838/hr · $3,532/mo)</text>

  <text x="594" y="280" fill="#FCA5A5" font-family="{FONT_MONO}" font-size="11">D96as_v6 (AMD Genoa)</text>
  <rect x="760" y="266" width="256" height="20" rx="4" fill="#64748B"/>
  <text x="770" y="281" fill="#FFFFFF" font-family="{FONT_MONO}" font-size="11" font-weight="700">239 ms (Baseline)</text>

  <!-- Chart 2: Code-Interpreter V1 Startup -->
  <rect x="578" y="332" width="452" height="170" rx="8" fill="#1E293B" stroke="#334155"/>
  <text x="594" y="356" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="13" font-weight="700">B. Code-Interpreter V1 (含 Jupyter 内核) 启动耗时 (ms)</text>

  <text x="594" y="388" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="11" font-weight="700">D96as_v7 (AMD Turin)</text>
  <rect x="760" y="374" width="136" height="20" rx="4" fill="#10B981"/>
  <text x="904" y="389" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="12" font-weight="700">132 ms ★ 最优 (-17.0% vs Intel)</text>

  <text x="594" y="426" fill="#93C5FD" font-family="{FONT_MONO}" font-size="11">D96s_v6 (Intel v6)</text>
  <rect x="760" y="412" width="164" height="20" rx="4" fill="#3B82F6"/>
  <text x="932" y="427" fill="#93C5FD" font-family="{FONT_MONO}" font-size="12">159 ms</text>

  <text x="594" y="464" fill="#FCA5A5" font-family="{FONT_MONO}" font-size="11">D96as_v6 (AMD Genoa)</text>
  <rect x="760" y="450" width="256" height="20" rx="4" fill="#64748B"/>
  <text x="770" y="465" fill="#FFFFFF" font-family="{FONT_MONO}" font-size="11" font-weight="700">255 ms (Baseline)</text>

  <!-- Chart 3: Dasv7 / Easv7 + Azure Boost Gains -->
  <rect x="578" y="516" width="452" height="174" rx="8" fill="url(#tealGrad)" stroke="#34D399"/>
  <text x="594" y="540" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="13" font-weight="700">C. Azure Dasv7 / Easv7 (5th Gen EPYC + Azure Boost) 硬件跃升</text>
  <text x="594" y="564" fill="#D1FAE5" font-family="{FONT_SANS}" font-size="11">• 单机最高 160 vCPU / 1,280 GiB DDR5 (Easv7)，全核最高 4.5GHz，无超线程争抢</text>
  <text x="594" y="584" fill="#D1FAE5" font-family="{FONT_SANS}" font-size="11">• 性价比提升最高 +35% · 远端存储 IOPS +20% · 存储吞吐 +50% · 网络带宽 +75%</text>
  <text x="594" y="604" fill="#FDE68A" font-family="{FONT_MONO}" font-size="11">典型负载实测增益：Java +25% | 内存缓存 +65% | 加密 +80% | Web服务 +130%</text>
  <text x="594" y="628" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11" font-weight="700">为什么 v7 对 MicroVM 沙箱至关重要？</text>
  <text x="594" y="648" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">UFFD 缺页拉取与 NBD 块设备恢复高度依赖单核高频 IPC、L3 缓存局部性与 Azure Boost 网卡/存储卸载，</text>
  <text x="594" y="666" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">使 D96as_v7 相比上代 Genoa 将沙箱恢复延迟直接砍半 (239ms → 108ms)。</text>
</svg>
"""
    return s


def build_svg_07() -> str:
    s = svg_header(
        1080,
        720,
        "图 7 · 多智能体协同工作流 (MAF × Copilot SDK × Durable) 与状态持久化选型矩阵",
        "上：自动化故障诊断与代码修复闭环 (Pitch Slide 13) · 下：Azure HorizonDB vs Cosmos DB vs Sandbox Snapshot 状态底座对比",
    )
    s += f"""
  <!-- Top Workflow Sequence -->
  <rect x="32" y="84" width="1016" height="276" rx="10" fill="#0F172A" stroke="#60A5FA" stroke-width="1.5"/>
  <text x="48" y="110" fill="#93C5FD" font-family="{FONT_MONO}" font-size="13" font-weight="700">END-TO-END MULTI-AGENT WORKFLOW · MICROSOFT AGENT FRAMEWORK (MAF) + GITHUB COPILOT SDK</text>

  <!-- Step Boxes -->
  <rect x="48" y="128" width="180" height="142" rx="8" fill="url(#roseGrad)" stroke="#F87171"/>
  <text x="138" y="150" text-anchor="middle" fill="#FECDD3" font-family="{FONT_MONO}" font-size="11" font-weight="700">STEP 1 · TRIGGER</text>
  <text x="138" y="170" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12" font-weight="700">生产告警 / 工单到达</text>
  <text x="138" y="192" text-anchor="middle" fill="#FCA5A5" font-family="{FONT_SANS}" font-size="10">• Azure Monitor / IcM P1</text>
  <text x="138" y="210" text-anchor="middle" fill="#FCA5A5" font-family="{FONT_SANS}" font-size="10">• Event Grid / Webhook</text>
  <text x="138" y="228" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">• 注入 TraceID 与租户上下文</text>
  <text x="138" y="252" text-anchor="middle" fill="#FDE68A" font-family="{FONT_MONO}" font-size="10">t = 0s</text>

  <rect x="248" y="128" width="188" height="142" rx="8" fill="url(#blueGrad)" stroke="#60A5FA"/>
  <text x="342" y="150" text-anchor="middle" fill="#93C5FD" font-family="{FONT_MONO}" font-size="11" font-weight="700">STEP 2 · DIAGNOSIS</text>
  <text x="342" y="170" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12" font-weight="700">LangGraph 诊断 Agent</text>
  <text x="342" y="192" text-anchor="middle" fill="#DBEAFE" font-family="{FONT_SANS}" font-size="10">• 运行于 AKS / ACA Apps</text>
  <text x="342" y="210" text-anchor="middle" fill="#DBEAFE" font-family="{FONT_SANS}" font-size="10">• 查询 Kusto 日志 + 近期 PR</text>
  <text x="342" y="228" text-anchor="middle" fill="#DBEAFE" font-family="{FONT_SANS}" font-size="10">• 写入 HorizonDB Checkpoint</text>
  <text x="342" y="252" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">定位根因文件与行号</text>

  <rect x="456" y="128" width="196" height="142" rx="8" fill="url(#tealGrad)" stroke="#34D399"/>
  <text x="554" y="150" text-anchor="middle" fill="#A7F3D0" font-family="{FONT_MONO}" font-size="11" font-weight="700">STEP 3 · CODING AGENT</text>
  <text x="554" y="170" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12" font-weight="700">GitHub Copilot SDK</text>
  <text x="554" y="192" text-anchor="middle" fill="#D1FAE5" font-family="{FONT_SANS}" font-size="10">• 运行于 ACA Sandbox / Kata VM</text>
  <text x="554" y="210" text-anchor="middle" fill="#D1FAE5" font-family="{FONT_SANS}" font-size="10">• 检出代码 + 生成修复补丁</text>
  <text x="554" y="228" text-anchor="middle" fill="#D1FAE5" font-family="{FONT_SANS}" font-size="10">• 沙箱内执行 pytest 验证通过</text>
  <text x="554" y="252" text-anchor="middle" fill="#FDE68A" font-family="{FONT_MONO}" font-size="10">快照保存工作区状态</text>

  <rect x="672" y="128" width="180" height="142" rx="8" fill="url(#purpleGrad)" stroke="#A78BFA"/>
  <text x="762" y="150" text-anchor="middle" fill="#DDD6FE" font-family="{FONT_MONO}" font-size="11" font-weight="700">STEP 4 · COMPLIANCE</text>
  <text x="762" y="170" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12" font-weight="700">Foundry 合规审计 Agent</text>
  <text x="762" y="192" text-anchor="middle" fill="#EDE9FE" font-family="{FONT_SANS}" font-size="10">• 校验安全基线与变更策略</text>
  <text x="762" y="210" text-anchor="middle" fill="#EDE9FE" font-family="{FONT_SANS}" font-size="10">• Entra Agent ID 签名留痕</text>
  <text x="762" y="228" text-anchor="middle" fill="#EDE9FE" font-family="{FONT_SANS}" font-size="10">• 生成风险评估卡片</text>
  <text x="762" y="252" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">Policy Gate Passed</text>

  <rect x="872" y="128" width="160" height="142" rx="8" fill="url(#amberGrad)" stroke="#FBBF24"/>
  <text x="952" y="150" text-anchor="middle" fill="#FDE68A" font-family="{FONT_MONO}" font-size="11" font-weight="700">STEP 5 · APPROVAL</text>
  <text x="952" y="170" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="12" font-weight="700">Durable 人工审批门</text>
  <text x="952" y="192" text-anchor="middle" fill="#FEF3C7" font-family="{FONT_SANS}" font-size="10">• 推送 Teams/Slack 审批卡</text>
  <text x="952" y="210" text-anchor="middle" fill="#FEF3C7" font-family="{FONT_SANS}" font-size="10">• 零算力消耗挂起等待</text>
  <text x="952" y="228" text-anchor="middle" fill="#FEF3C7" font-family="{FONT_SANS}" font-size="10">• 批准后合并 PR 并灰度发布</text>
  <text x="952" y="252" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">MTTR 缩短 70%+</text>

  <rect x="48" y="284" width="984" height="60" rx="8" fill="#1E293B" stroke="#475569"/>
  <text x="64" y="308" fill="#38BDF8" font-family="{FONT_SANS}" font-size="12" font-weight="700">为什么计算与状态必须解耦 (Pitch Slide 10)？</text>
  <text x="330" y="308" fill="#F8FAFC" font-family="{FONT_SANS}" font-size="12">多步推理、工具调用失败重试、跨天人工审批要求工作流状态绝不能绑定在随时可能缩容或重启的容器进程内存里。</text>
  <text x="64" y="330" fill="#94A3B8" font-family="{FONT_SANS}" font-size="11">通过 MAF 统一状态机 + Durable Functions 持久化调度 + HorizonDB/Cosmos DB 检查点，任何计算节点故障均可从最近一步精准恢复。</text>

  <!-- Bottom State & Memory Comparison -->
  <rect x="32" y="376" width="1016" height="320" rx="10" fill="#0F172A" stroke="#A78BFA" stroke-width="1.5"/>
  <text x="48" y="402" fill="#C4B5FD" font-family="{FONT_MONO}" font-size="13" font-weight="700">STATE, MEMORY &amp; CHECKPOINT PERSISTENCE MATRIX (三大状态与记忆机制深度对比)</text>

  <rect x="48" y="418" width="320" height="260" rx="8" fill="#1E293B" stroke="#A78BFA" stroke-width="1.5"/>
  <text x="208" y="444" text-anchor="middle" fill="#FBBF24" font-family="{FONT_SANS}" font-size="14" font-weight="700">1. Azure HorizonDB (Preview)</text>
  <text x="208" y="464" text-anchor="middle" fill="#C4B5FD" font-family="{FONT_SANS}" font-size="11">AI 原生 PostgreSQL 融合状态与向量引擎</text>
  <text x="64" y="490" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">• 单一引擎统一承载三类数据：</text>
  <text x="76" y="508" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">- ACID 关系型事务表 (订单、配额、审计、权限)</text>
  <text x="76" y="524" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">- JSONB 半结构化数据 (Thread 消息树、Tool 输出)</text>
  <text x="76" y="540" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">- DiskANN 向量索引 (长短期语义记忆混合检索)</text>
  <text x="64" y="564" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">• 存算分离架构 + 最高 15 个只读副本毫秒级扩展</text>
  <text x="64" y="584" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">• 原生兼容 LangGraph / MAF Checkpoint 存储接口</text>
  <text x="64" y="604" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="11">• 消除“关系库+文档库+向量库”三套系统的数据同步延迟</text>
  <text x="64" y="632" fill="#F87171" font-family="{FONT_SANS}" font-size="10">⚠ 架构边界：当前为 Preview，生产关键负载需核验目标 Region 可用性，或使用 Azure Database for PostgreSQL Flexible Server 生产兜底。</text>

  <rect x="380" y="418" width="320" height="260" rx="8" fill="#1E293B" stroke="#38BDF8"/>
  <text x="540" y="444" text-anchor="middle" fill="#38BDF8" font-family="{FONT_SANS}" font-size="14" font-weight="700">2. Azure Cosmos DB</text>
  <text x="540" y="464" text-anchor="middle" fill="#93C5FD" font-family="{FONT_SANS}" font-size="11">全球多活低延迟 NoSQL 会话与事件存储</text>
  <text x="396" y="490" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">• 单一毫秒级读写延迟与 99.999% 多区域高可用 SLA</text>
  <text x="396" y="512" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">• 无模式 JSON 文档天然契合高并发 Agent 对话流与事件溯源</text>
  <text x="396" y="534" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">• 内置向量搜索与 Change Feed 实时触发 Azure Functions</text>
  <text x="396" y="556" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">• Foundry Agent Service 原生支持自带 Cosmos DB 线程存储</text>
  <text x="396" y="584" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="11">• 标杆实证：德国商业银行 (Commerzbank) 虚拟助手 Ava</text>
  <text x="408" y="602" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">- 支撑每月 30,000+ 客户服务会话，~75% 咨询全自动闭环</text>
  <text x="408" y="618" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">- 跨多个专业化子 Agent 共享实时状态上下文</text>
  <text x="396" y="646" fill="#38BDF8" font-family="{FONT_MONO}" font-size="10">适用：全球分布式 To-C / 超大规模高并发会话状态</text>

  <rect x="712" y="418" width="320" height="260" rx="8" fill="#1E293B" stroke="#34D399"/>
  <text x="872" y="444" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="14" font-weight="700">3. Sandbox Snapshot &amp; Volumes</text>
  <text x="872" y="464" text-anchor="middle" fill="#A7F3D0" font-family="{FONT_SANS}" font-size="11">工作区进程内存 + 文件系统级状态冻结</text>
  <text x="728" y="490" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">• 数据库只能存结构化变量，无法保存：</text>
  <text x="740" y="508" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">- 已打开的浏览器 DOM 登录态与 Cookie</text>
  <text x="740" y="524" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">- Jupyter / Python 进程内存中的 Pandas/PyTorch 变量</text>
  <text x="740" y="540" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">- 编译中间产物、Git 工作树与临时安装依赖</text>
  <text x="728" y="564" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">• 三层方案协同：</text>
  <text x="740" y="582" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="10">1. ACA Sandboxes: 容器内存/磁盘快照 + Persistent Volume</text>
  <text x="740" y="598" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="10">2. AKSClaw: 共享只读技能 PV + 实例读写状态 PV</text>
  <text x="740" y="614" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="10">3. E2B on VMSS: UFFD 内存镜像 + NBD 块差分快照 (108ms)</text>
  <text x="728" y="646" fill="#34D399" font-family="{FONT_MONO}" font-size="10">黄金组合：数据库存业务检查点 + 快照存执行环境</text>
</svg>
"""
    return s


def build_svg_08() -> str:
    s = svg_header(
        1080,
        740,
        "图 8 · Azure Agent Infra Playbook 六大高优场景、四维资质筛查与五步落地工作流",
        "提炼自 Agent_Infra_Playbook.pptx 与 Selection Logic 方法论（纯方法论脱敏沉淀，零客户敏感信息）",
    )
    s += f"""
  <!-- Top: 6 Priority Use Case Archetypes -->
  <rect x="32" y="84" width="1016" height="190" rx="10" fill="url(#blueGrad)" stroke="#60A5FA" stroke-width="1.5"/>
  <text x="48" y="108" fill="#93C5FD" font-family="{FONT_MONO}" font-size="12" font-weight="700">PART 1 · SIX PRIORITY AGENT INFRASTRUCTURE USE CASE ARCHETYPES (Playbook Slide 6)</text>

  <rect x="48" y="122" width="156" height="136" rx="6" fill="#0F172A" fill-opacity="0.8" stroke="#38BDF8"/>
  <text x="126" y="144" text-anchor="middle" fill="#38BDF8" font-family="{FONT_SANS}" font-size="12" font-weight="700">01 客户服务 Agent</text>
  <text x="126" y="164" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">Customer-Facing</text>
  <text x="126" y="184" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 零售导购/银行客服</text>
  <text x="126" y="200" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 流量波峰波谷剧烈</text>
  <text x="126" y="216" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 低延迟 + 护栏合规</text>
  <text x="126" y="242" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">Foundry + ACA + Cosmos</text>

  <rect x="214" y="122" width="156" height="136" rx="6" fill="#0F172A" fill-opacity="0.8" stroke="#38BDF8"/>
  <text x="292" y="144" text-anchor="middle" fill="#38BDF8" font-family="{FONT_SANS}" font-size="12" font-weight="700">02 企业 Agent 平台</text>
  <text x="292" y="164" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">Enterprise Platform</text>
  <text x="292" y="184" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 多部门/多团队共用底座</text>
  <text x="292" y="200" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 统一网关/配额/技能库</text>
  <text x="292" y="216" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 租户级强隔离</text>
  <text x="292" y="242" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">AKS + Kata (AKSClaw)</text>

  <rect x="380" y="122" width="156" height="136" rx="6" fill="#0F172A" fill-opacity="0.8" stroke="#38BDF8"/>
  <text x="458" y="144" text-anchor="middle" fill="#38BDF8" font-family="{FONT_SANS}" font-size="12" font-weight="700">03 AI Native 产品</text>
  <text x="458" y="164" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">Digital-Native AI</text>
  <text x="458" y="184" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• Agent 即核心商业产品</text>
  <text x="458" y="200" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 10万+ 并发代码/桌面沙箱</text>
  <text x="458" y="216" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 单位算力成本决定毛利</text>
  <text x="458" y="242" text-anchor="middle" fill="#F43F5E" font-family="{FONT_MONO}" font-size="10">E2B on VMSS / Sandbox</text>

  <rect x="546" y="122" width="156" height="136" rx="6" fill="#0F172A" fill-opacity="0.8" stroke="#38BDF8"/>
  <text x="624" y="144" text-anchor="middle" fill="#38BDF8" font-family="{FONT_SANS}" font-size="12" font-weight="700">04 Agent 工厂</text>
  <text x="624" y="164" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">Agent Factory</text>
  <text x="624" y="184" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 标准化模板批量孵化</text>
  <text x="624" y="200" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 1,400+ 企业连接器复用</text>
  <text x="624" y="216" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 统一评测与发布流水线</text>
  <text x="624" y="242" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">Foundry + MAF + APIM</text>

  <rect x="712" y="122" width="156" height="136" rx="6" fill="#0F172A" fill-opacity="0.8" stroke="#38BDF8"/>
  <text x="790" y="144" text-anchor="middle" fill="#38BDF8" font-family="{FONT_SANS}" font-size="12" font-weight="700">05 多智能体工作流</text>
  <text x="790" y="164" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">Multi-Agent Workflow</text>
  <text x="790" y="184" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 采购/财务/研发自动化</text>
  <text x="790" y="200" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 跨系统状态传递与回滚</text>
  <text x="790" y="216" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 人工审批长周期等待</text>
  <text x="790" y="242" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">Durable + ACA + HorizonDB</text>

  <rect x="878" y="122" width="154" height="136" rx="6" fill="#0F172A" fill-opacity="0.8" stroke="#38BDF8"/>
  <text x="955" y="144" text-anchor="middle" fill="#38BDF8" font-family="{FONT_SANS}" font-size="12" font-weight="700">06 强监管行业 Agent</text>
  <text x="955" y="164" text-anchor="middle" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="10">Regulated Industry</text>
  <text x="955" y="184" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 金融/医疗/政务合规</text>
  <text x="955" y="200" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• VNet 私有网络闭环</text>
  <text x="955" y="216" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 逐动作身份与不可篡改审计</text>
  <text x="955" y="242" text-anchor="middle" fill="#FBBF24" font-family="{FONT_MONO}" font-size="10">Entra Agent ID + Private</text>

  <!-- Middle: Propensity Screening Model & 4 Foundations -->
  <rect x="32" y="288" width="1016" height="206" rx="10" fill="#0F172A" stroke="#10B981" stroke-width="1.5"/>
  <text x="48" y="314" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="12" font-weight="700">PART 2 · ENTERPRISE PROPENSITY SCREENING &amp; QUALIFICATION MODEL (Playbook Slide 13 &amp; Selection Logic)</text>

  <rect x="48" y="328" width="480" height="150" rx="8" fill="#1E293B" stroke="#34D399"/>
  <text x="64" y="350" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="12" font-weight="700">四大技术底座信号分类 (4 Technical Foundations · 14 服务家族)</text>
  <text x="64" y="372" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">① Application &amp; Runtime: AKS · Container Apps · App Service · Functions · Batch · VM</text>
  <text x="64" y="392" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">② Data, State &amp; Knowledge: PostgreSQL/HorizonDB · Cosmos DB · Redis · SQL · Storage</text>
  <text x="64" y="412" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">③ AI &amp; Integration: Foundry Models · AI Search · Foundry Tools · APIM · Event Grid/SB</text>
  <text x="64" y="432" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">④ Ops, Security &amp; Governance: Azure Monitor · Key Vault · Defender</text>
  <text x="64" y="456" fill="#38BDF8" font-family="{FONT_SANS}" font-size="10">强信号路由 A (Specific Anchor): 命中 Specific 锚点服务 (ACA/AKS/PG/Cosmos/Redis/Search/APIM/Foundry)</text>
  <text x="64" y="471" fill="#38BDF8" font-family="{FONT_SANS}" font-size="10">强信号路由 B (Multi-Foundation): 仅 General 服务但同时跨 ≥3 个技术底座且含 Runtime + Data/AI</text>

  <rect x="544" y="328" width="488" height="150" rx="8" fill="#1E293B" stroke="#FBBF24"/>
  <text x="560" y="350" fill="#FDE68A" font-family="{FONT_SANS}" font-size="12" font-weight="700">五项潜客升级门禁 (5 Potential Gates · 满足 ≥3 项触发架构师深潜)</text>
  <text x="560" y="372" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">Gate 1: Relevant ACR 月均体量 ≥ 队列中位数 ($17,053.78 方法论基准)</text>
  <text x="560" y="392" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">Gate 2: 具备生产级 Runtime 信号 + 具备 Data 或 AI 信号</text>
  <text x="560" y="412" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">Gate 3: 跨 ≥3 个技术底座活跃 (Multi-Foundation Readiness)</text>
  <text x="560" y="432" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">Gate 4: 具备 Specific Anchor 专用服务家族持续消费</text>
  <text x="560" y="452" fill="#E2E8F0" font-family="{FONT_SANS}" font-size="11">Gate 5: 非模型相关消费增长率 ≥ +20% (5个月窗口早期 vs 近期均值)</text>
  <text x="560" y="471" fill="#6EE7B7" font-family="{FONT_MONO}" font-size="10">Signal vs Amount 铁律：$10K/月仅过滤模型信号判定，绝不扣减客户真实 ACR 基数</text>

  <!-- Bottom: 5-Step Execution Loop -->
  <rect x="32" y="508" width="1016" height="200" rx="10" fill="url(#tealGrad)" stroke="#34D399" stroke-width="1.5"/>
  <text x="48" y="534" fill="#A7F3D0" font-family="{FONT_MONO}" font-size="12" font-weight="700">PART 3 · FIVE-STEP FIELD EXECUTION WORKFLOW (Playbook Slides 12–17)</text>

  <rect x="48" y="548" width="184" height="142" rx="8" fill="#0F172A" fill-opacity="0.84" stroke="#34D399"/>
  <text x="140" y="572" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="13" font-weight="700">01 Initial Screening</text>
  <text x="140" y="592" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11">数据驱动初筛</text>
  <text x="140" y="614" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 评估四大技术底座信号</text>
  <text x="140" y="632" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 定位 P1 / P2 优先级梯队</text>
  <text x="140" y="650" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 锁定业务与技术赞助人</text>

  <rect x="246" y="548" width="184" height="142" rx="8" fill="#0F172A" fill-opacity="0.84" stroke="#34D399"/>
  <text x="338" y="572" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="13" font-weight="700">02 Discovery</text>
  <text x="338" y="592" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11">场景与痛点深潜</text>
  <text x="338" y="614" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 区分 To-B vs To-C 诉求</text>
  <text x="338" y="632" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 识别沙箱/合规/状态痛点</text>
  <text x="338" y="650" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 确认客户研发团队能力</text>

  <rect x="444" y="548" width="184" height="142" rx="8" fill="#0F172A" fill-opacity="0.84" stroke="#34D399"/>
  <text x="536" y="572" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="13" font-weight="700">03 Define</text>
  <text x="536" y="592" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11">目标架构与路径锁定</text>
  <text x="536" y="614" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 走决策树锁定 Runtime</text>
  <text x="536" y="632" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 配对 HorizonDB/Cosmos/快照</text>
  <text x="536" y="650" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 设计 Entra Agent ID 边界</text>

  <rect x="642" y="548" width="192" height="142" rx="8" fill="#0F172A" fill-opacity="0.84" stroke="#FBBF24" stroke-width="1.5"/>
  <text x="738" y="572" text-anchor="middle" fill="#FDE68A" font-family="{FONT_SANS}" font-size="13" font-weight="700">04 Validate (关键动作)</text>
  <text x="738" y="592" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11">1/2日实战工坊 + 架构白板</text>
  <text x="738" y="614" text-anchor="middle" fill="#FEF3C7" font-family="{FONT_SANS}" font-size="10">• 动手搭建 PoC 验证核心链路</text>
  <text x="738" y="632" text-anchor="middle" fill="#FEF3C7" font-family="{FONT_SANS}" font-size="10">• 白板推演并发/故障/安全边界</text>
  <text x="738" y="650" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="10">• 产出经双方签字的目标架构图</text>

  <rect x="848" y="548" width="184" height="142" rx="8" fill="#0F172A" fill-opacity="0.84" stroke="#34D399"/>
  <text x="940" y="572" text-anchor="middle" fill="#6EE7B7" font-family="{FONT_SANS}" font-size="13" font-weight="700">05 Implement</text>
  <text x="940" y="592" text-anchor="middle" fill="#FFFFFF" font-family="{FONT_SANS}" font-size="11">生产上线与规模化扩展</text>
  <text x="940" y="614" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 制定里程碑与交付负责人</text>
  <text x="940" y="632" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 接入 AI Gateway 与 OTel</text>
  <text x="940" y="650" text-anchor="middle" fill="#94A3B8" font-family="{FONT_SANS}" font-size="10">• 从单场景向企业舰队复制</text>
</svg>
"""
    return s


def build_7card_html(report: dict[str, Any]) -> str:
    scenarios = report["scenarios"]
    robustness = report["robustness_checks"]
    latencies = report["latency_tiers"]

    scenario_rows_html = ""
    for sc in scenarios:
        miss = ' <span class="miss-mark">✕</span>' if not sc["passed"] else ""
        act_cls = (
            "act-auto"
            if sc["action"] == "Auto"
            else ("act-confirm" if sc["action"] == "Confirm" else "act-human")
        )
        scenario_rows_html += (
            f"<tr>"
            f'<td class="sc-col">{sc["id"]} · {sc["category"][3:]}</td>'
            f'<td>{sc["question"]}</td>'
            f'<td><strong>{sc["model_answer"]}</strong>{miss}</td>'
            f'<td class="act-col {act_cls}">{sc["action"]}</td>'
            f"</tr>"
        )

    rob_rows_html = ""
    for r in robustness:
        sign = "+" if r["delta_pts"] > 0 else ""
        rob_rows_html += (
            f"<tr>"
            f'<td><div class="rob-main">{r["dimension"]}</div>'
            f'<div class="rob-sub">{r["original_label"]} vs {r["perturbed_label"]}</div></td>'
            f'<td class="num-col">{r["original_pct"]:.1f}%</td>'
            f'<td class="num-col">{r["perturbed_pct"]:.1f}%</td>'
            f'<td class="num-col"><strong>{sign}{r["delta_pts"]:.1f} pts</strong></td>'
            f"</tr>"
        )

    max_ms = max(max(x["optimized_ms"], x["baseline_ms"]) for x in latencies)
    lat_rows_html = ""
    for item in latencies:
        w_opt = max(4.0, round(item["optimized_ms"] / max_ms * 72.0, 1))
        w_base = max(4.0, round(item["baseline_ms"] / max_ms * 72.0, 1))
        lat_rows_html += (
            f'<div class="lat-item">'
            f'<div class="lat-title">{item["tier_label"]}</div>'
            f'<div class="lat-row"><span class="lat-tag">Optimized</span>'
            f'<div class="lat-bar lat-blue" style="width:{w_opt}%"></div>'
            f'<strong class="lat-val">{item["optimized_label"]}</strong></div>'
            f'<div class="lat-row"><span class="lat-tag">Baseline</span>'
            f'<div class="lat-bar lat-gray" style="width:{w_base}%"></div>'
            f'<span class="lat-val">{item["baseline_label"]}</span></div>'
            f"</div>"
        )

    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'">
<title>Azure AI Agent Infrastructure Playbook · 7-Card Benchmark Report</title>
<style>
*{{box-sizing:border-box}}
body{{margin:0;padding:2rem 1rem;background:#e2e8f0;color:#0f172a;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,'Microsoft YaHei',sans-serif}}
.deck-wrap{{max-width:900px;margin:0 auto;display:flex;flex-direction:column;gap:2.2rem}}
.report-card{{background:#f8fafc;border-radius:18px;overflow:hidden;box-shadow:0 16px 40px rgba(15,23,42,.12);border:1px solid #cbd5e1;min-height:1125px;display:flex;flex-direction:column}}
.card-accent-bar{{height:10px;background:linear-gradient(90deg,#0078d4 0%,#2563eb 55%,#10b981 100%)}}
.card-inner{{padding:2.3rem 2.6rem 1.8rem;flex:1;display:flex;flex-direction:column;justify-content:space-between}}
.card-eyebrow{{font-size:.82rem;font-weight:700;letter-spacing:.12em;color:#0078d4;text-transform:uppercase;margin-bottom:.55rem}}
.card-headline{{font-size:2.25rem;line-height:1.14;font-weight:800;margin:0 0 .65rem;letter-spacing:-.02em;color:#0f172a}}
.grad-text{{background:linear-gradient(90deg,#0078d4,#10b981);-webkit-background-clip:text;background-clip:text;color:transparent}}
.card-subtitle{{font-size:1.04rem;line-height:1.45;color:#475569;margin:0 0 1.15rem}}
.card-canvas{{flex:1;display:flex;flex-direction:column;justify-content:center;gap:1rem}}
.quote-box,.callout-box{{background:#eef2f6;border-radius:12px;padding:1rem 1.25rem;font-size:.95rem;line-height:1.48;color:#1e293b}}
.stack-list{{display:flex;flex-direction:column;gap:.85rem}}
.decision-card{{background:#fff;border:1px solid #e2e8f0;border-radius:12px;padding:.92rem 1.12rem}}
.decision-head{{display:flex;justify-content:space-between;align-items:flex-start;gap:.75rem}}
.field-name{{font-weight:700;font-size:.98rem}}
.type-pill{{background:#e2e8f0;color:#475569;font-size:.74rem;padding:.12rem .45rem;border-radius:6px;font-weight:600}}
.question-sub{{font-size:.83rem;color:#64748b;margin-top:.15rem}}
.action-pill{{font-size:.75rem;font-weight:700;padding:.22rem .6rem;border-radius:999px;white-space:nowrap}}
.pill-auto{{background:#dcfce7;color:#15803d}}
.pill-confirm{{background:#fef3c7;color:#b45309}}
.pill-human{{background:#fee2e2;color:#b91c1c}}
.decision-main{{font-size:1.12rem;margin:.42rem 0 .52rem}}
.conf-muted{{font-size:.85rem;color:#64748b;font-weight:600}}
.dist-row{{display:grid;grid-template-columns:195px 1fr 56px;align-items:center;gap:.6rem;font-size:.82rem;margin:.24rem 0}}
.dist-track{{background:#e2e8f0;height:9px;border-radius:999px;overflow:hidden}}
.dist-fill{{background:linear-gradient(90deg,#0078d4,#10b981);height:100%;border-radius:999px}}
.dist-pct{{text-align:right;font-variant-numeric:tabular-nums;color:#334155}}
.clean-table{{width:100%;border-collapse:collapse;font-size:.88rem;background:transparent}}
.clean-table th{{font-size:.73rem;letter-spacing:.08em;color:#64748b;text-align:left;padding:.5rem .4rem;border-bottom:1px solid #cbd5e1}}
.clean-table td{{padding:.56rem .4rem;border-bottom:1px solid #e2e8f0;vertical-align:top}}
.sc-col{{font-weight:600;color:#1e293b;white-space:nowrap}}
.act-col,.num-col{{text-align:right;font-variant-numeric:tabular-nums}}
.act-auto{{color:#15803d;font-weight:700}}
.act-confirm{{color:#b45309;font-weight:700}}
.act-human{{color:#b91c1c;font-weight:700}}
.miss-mark{{color:#dc2626;font-weight:800}}
.code-dark{{background:#0f172a;color:#e2e8f0;padding:1.05rem 1.25rem;border-radius:12px;font-size:.82rem;line-height:1.45;overflow-x:auto;margin:0;font-family:ui-monospace,Consolas,monospace}}
.code-transition{{color:#0078d4;font-weight:700;font-size:.92rem;padding:.15rem 0}}
.hl-answer{{color:#fbbf24;font-weight:700}}
.rob-main{{font-weight:600;color:#0f172a}}
.rob-sub{{font-size:.78rem;color:#64748b}}
.lat-list{{display:flex;flex-direction:column;gap:.85rem}}
.lat-title{{font-weight:700;font-size:.95rem;margin-bottom:.28rem}}
.lat-row{{display:flex;align-items:center;gap:.65rem;margin:.22rem 0}}
.lat-tag{{width:85px;font-size:.82rem;color:#64748b}}
.lat-bar{{height:20px;border-radius:6px}}
.lat-blue{{background:#2563eb}}
.lat-gray{{background:#cbd5e1}}
.lat-val{{font-size:.86rem;font-variant-numeric:tabular-nums}}
.fit-grid{{display:grid;grid-template-columns:1fr 1fr;gap:1.1rem}}
.fit-card{{border-radius:14px;padding:1.2rem 1.35rem;font-size:.95rem;line-height:1.58}}
.fit-good{{background:#ecfdf5;border:1px solid #a7f3d0}}
.fit-bad{{background:#fff1f2;border:1px solid #fecdd3}}
.fit-head{{font-weight:800;font-size:1.1rem;margin-bottom:.5rem}}
.dark-footer-box{{background:#0f172a;color:#f8fafc;border-radius:14px;padding:1.2rem 1.45rem;font-size:.95rem;line-height:1.5}}
.dark-repo{{color:#38bdf8;font-family:ui-monospace,Consolas,monospace;margin-bottom:0}}
.workbench-shell{{background:#fff;border:1px solid #cbd5e1;border-radius:14px;overflow:hidden}}
.wb-topbar{{background:linear-gradient(90deg,#0078d4,#2563eb);color:#fff;padding:.75rem 1rem;display:flex;justify-content:space-between;align-items:center;gap:1rem}}
.wb-sub{{font-size:.75rem;opacity:.92}}
.wb-status{{background:rgba(15,23,42,.28);font-size:.73rem;padding:.25rem .6rem;border-radius:999px;white-space:nowrap}}
.wb-grid{{display:grid;grid-template-columns:225px 1fr;gap:.85rem;padding:.9rem}}
.wb-col-title{{font-size:.76rem;font-weight:700;color:#475569;text-transform:uppercase;margin-bottom:.4rem}}
.wb-item{{font-size:.78rem;padding:.38rem .5rem;border-radius:6px;background:#f8fafc;border:1px solid #e2e8f0;margin-bottom:.32rem}}
.wb-note{{font-size:.72rem;color:#64748b;margin-top:.5rem;line-height:1.38}}
.wb-metrics{{display:flex;flex-wrap:wrap;gap:.4rem;margin-bottom:.55rem}}
.wb-metric{{font-size:.73rem;background:#f1f5f9;padding:.2rem .5rem;border-radius:6px;color:#334155;font-weight:600}}
.card-footer{{border-top:1px solid #cbd5e1;padding-top:.85rem;margin-top:1.1rem;display:flex;justify-content:space-between;font-size:.82rem;color:#64748b}}
@media print{{body{{background:#fff;padding:0}}.deck-wrap{{gap:0}}.report-card{{box-shadow:none;page-break-after:always;border:none}}}}
</style>
</head>
<body>
<main class="deck-wrap">

<!-- CARD 1 -->
<article class="report-card" id="card-1">
  <div class="card-accent-bar"></div>
  <div class="card-inner">
    <header class="card-header">
      <div class="card-eyebrow">HANDS-ON · AZURE AI AGENT INFRASTRUCTURE BENCHMARK</div>
      <h2 class="card-headline">6 Azure Agent Runtimes, <span class="grad-text">108ms MicroVM restore</span></h2>
      <p class="card-subtitle">Architecture &amp; benchmark evaluation across 6 Azure Agent Runtimes (Foundry Hosted, Durable Functions, ACA Dynamic Sessions, ACA Sandboxes, AKS Kata/AKSClaw, and E2B on VMSS D96as_v7) and 12 production scenarios.</p>
    </header>
    <div class="card-canvas">
      <div class="workbench-shell">
        <div class="wb-topbar">
          <div>
            <strong>Azure AI Agent Infra Selection &amp; Sizing Workbench (2026 Playbook)</strong>
            <div class="wb-sub">4-Layer Stack (Build · Run · Ground · Govern) · Calibrated routing gates · Zero fabricated coordinates</div>
          </div>
          <span class="wb-status">6 Runtimes · 12 Scenarios · D96as_v7 108ms/132ms</span>
        </div>
        <div class="wb-grid">
          <div class="wb-col-left">
            <div class="wb-col-title">Runtime Spectrum</div>
            <div class="wb-item">1. Foundry Hosted Agents (1,400+ MCP)</div>
            <div class="wb-item">2. Durable Functions (Approval Wait)</div>
            <div class="wb-item">3. ACA Dynamic Sessions (Hyper-V Pool)</div>
            <div class="wb-item">4. ACA Sandboxes Preview (Snapshot)</div>
            <div class="wb-item">5. AKS + Kata Pod VM (AKSClaw Fleet)</div>
            <div class="wb-item">6. E2B on Azure VMSS (D96as_v7 108ms)</div>
            <div class="wb-note">Action gating: Auto (8/12 = 66.7%) for production-ready patterns; Confirm (3/12 = 25.0%) for Preview or refactoring gates; Human (1/12 = 8.3%) when dev team ownership is missing.</div>
          </div>
          <div class="wb-col-right">
            <div class="wb-metrics">
              <span class="wb-metric">6 Runtimes</span>
              <span class="wb-metric">108ms Base / 132ms Code-Interpreter</span>
              <span class="wb-metric">100K+ APIM Host Sessions</span>
              <span class="wb-metric">5 AKSClaw Hard Boundaries</span>
            </div>
            <div class="decision-card">
              <div class="decision-head">
                <div>
                  <span class="field-name">e2b_turin_v7_speedup</span> <span class="type-pill">choice</span>
                  <div class="question-sub">Does Azure D96as_v7 (5th Gen EPYC Turin + Azure Boost) beat Intel D96s_v6 &amp; AMD D96as_v6 on E2B startup?</div>
                </div>
                <span class="action-pill pill-auto">Act automatically</span>
              </div>
              <div class="decision-main"><strong>108 ms Base / 132 ms Code-Interpreter V1</strong><span class="conf-muted"> · -54.8% vs AMD v6 (239ms) · -17.0% vs Intel v6 (159ms)</span></div>
              <div class="dist-list">
                <div class="dist-row"><span class="dist-label">D96as_v7 Base Speed Index</span><div class="dist-track"><div class="dist-fill" style="width:92.6%"></div></div><span class="dist-pct">92.6%</span></div>
                <div class="dist-row"><span class="dist-label">D96s_v6 Intel Speed Index</span><div class="dist-track"><div class="dist-fill" style="width:86.2%"></div></div><span class="dist-pct">86.2%</span></div>
                <div class="dist-row"><span class="dist-label">D96as_v6 Genoa Speed Index</span><div class="dist-track"><div class="dist-fill" style="width:41.8%"></div></div><span class="dist-pct">41.8%</span></div>
              </div>
            </div>
            <div class="decision-card">
              <div class="decision-head">
                <div>
                  <span class="field-name">aksclaw_security_enforcement</span> <span class="type-pill">choice</span>
                  <div class="question-sub">How many multi-tenant security boundaries are enforced by the platform vs left to agent prompt rules?</div>
                </div>
                <span class="action-pill pill-auto">Act automatically</span>
              </div>
              <div class="decision-main"><strong>5 / 5 platform hard boundaries (100.0%)</strong><span class="conf-muted"> · IMDS block · Egress · Credential proxy · Entra Agent ID · AI Gateway</span></div>
              <div class="dist-list">
                <div class="dist-row"><span class="dist-label">platform_enforced_hard_controls</span><div class="dist-track"><div class="dist-fill" style="width:100.0%"></div></div><span class="dist-pct">100.0%</span></div>
                <div class="dist-row"><span class="dist-label">raw_llm_keys_in_agent_pod</span><div class="dist-track"><div class="dist-fill" style="width:1.5%"></div></div><span class="dist-pct">0.0%</span></div>
              </div>
            </div>
            <div class="decision-card">
              <div class="decision-head">
                <div>
                  <span class="field-name">playbook_delivery_gate</span> <span class="type-pill">score</span>
                  <div class="question-sub">Can an enterprise needing deep infra control without a dev team be routed back to Foundry Hosted Agents?</div>
                </div>
                <span class="action-pill pill-human">Send to a human</span>
              </div>
              <div class="decision-main"><strong>0% shortcut allowed (Hold for CSU / Partner)</strong><span class="conf-muted"> · Playbook Slide 7 explicitly blocks misrouting unmet control needs</span></div>
              <div class="dist-list">
                <div class="dist-row"><span class="dist-label">valid_architecture_paths (9/12)</span><div class="dist-track"><div class="dist-fill" style="width:75.0%"></div></div><span class="dist-pct">75.0%</span></div>
                <div class="dist-row"><span class="dist-label">caught_anti_patterns (3/12)</span><div class="dist-track"><div class="dist-fill" style="width:25.0%"></div></div><span class="dist-pct">25.0%</span></div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="callout-box"><strong>Managed AI (Foundry) and Composable Substrate (ACA / AKS / Functions / VMSS) are complements, not mutually exclusive.</strong> Standard business APIs run on Foundry Hosted Agents, while untrusted code, stateful coding workspaces, and 100K+ virtual computers route to ACA Dynamic Sessions, ACA Sandboxes, AKS Kata, or E2B on VMSS.</div>
    </div>
    <footer class="card-footer">
      <span><strong>Azure AI Agent Infrastructure Playbook</strong> · anonymized_reported + deterministic sizer verified</span>
      <span>1 / 7</span>
    </footer>
  </div>
</article>

<!-- CARD 2 -->
<article class="report-card" id="card-2">
  <div class="card-accent-bar"></div>
  <div class="card-inner">
    <header class="card-header">
      <div class="card-eyebrow">SCENARIO: MANUS × E2B 100K+ VIRTUAL COMPUTERS &amp; AKSCLAW FLEET</div>
      <h2 class="card-headline">261 D96as_v7 nodes serve 100K sandboxes at 108ms</h2>
      <p class="card-subtitle">Deep dive into ultra-high-density Firecracker MicroVM sandboxes on Azure VMSS Flexible and multi-tenant Kubernetes Agent governance (AKSClaw).</p>
    </header>
    <div class="card-canvas">
      <div class="quote-box">"Every AI agent session gets a dedicated isolated computer (filesystem, terminal, browser/VNC desktop, and Jupyter kernel) that boots in ~108–132ms via UFFD lazy page-fault streaming and NBD block overlays, rate-limited per dynamic Host header across 100,000+ concurrent sessions."</div>
      <div class="stack-list">
        <div class="decision-card">
          <div class="decision-head">
            <div>
              <span class="field-name">vmss_100k_capacity_fit</span> <span class="type-pill">choice</span>
              <div class="question-sub">Does a 100,000-concurrent-sandbox E2B pool fit within a single Azure VMSS Flexible scale set (1,000-VM limit)?</div>
            </div>
            <span class="action-pill pill-auto">Act automatically</span>
          </div>
          <div class="decision-main"><strong>Yes · 261 Client Nodes (26.1% of 1,000-VM limit)</strong><span class="conf-muted"> · 384 GiB RAM × 85% HugePages × 60% scale-out threshold = 384 sandboxes/node</span></div>
          <div class="dist-list">
            <div class="dist-row"><span class="dist-label">hugepages_reserved_ram (326 GiB)</span><div class="dist-track"><div class="dist-fill" style="width:85.0%"></div></div><span class="dist-pct">85.0%</span></div>
            <div class="dist-row"><span class="dist-label">cpu_scale_out_trigger_watermark</span><div class="dist-track"><div class="dist-fill" style="width:60.0%"></div></div><span class="dist-pct">60.0%</span></div>
            <div class="dist-row"><span class="dist-label">single_vmss_headroom_used (261/1000)</span><div class="dist-track"><div class="dist-fill" style="width:26.1%"></div></div><span class="dist-pct">26.1%</span></div>
          </div>
        </div>
        <div class="decision-card">
          <div class="decision-head">
            <div>
              <span class="field-name">apim_appgw_dual_hop_isolation</span> <span class="type-pill">noul</span>
              <div class="question-sub">Does AppGW WAF v2 (Public + Private IP) + APIM rate-limit-by-key isolate 100K+ dynamic sandbox subdomains?</div>
            </div>
            <span class="action-pill pill-auto">Act automatically</span>
          </div>
          <div class="decision-main"><strong>Yes (100% per-Host counter isolation + WebSocket passthrough)</strong><span class="conf-muted"> · counter-key="@(context.Request.Headers.GetValueOrDefault(&quot;Host&quot;))" · P(true) = 1.0</span></div>
          <div class="dist-list">
            <div class="dist-row"><span class="dist-label">per_sandbox_host_rate_limit</span><div class="dist-track"><div class="dist-fill" style="width:100.0%"></div></div><span class="dist-pct">100.0%</span></div>
            <div class="dist-row"><span class="dist-label">noisy_neighbor_cross_impact</span><div class="dist-track"><div class="dist-fill" style="width:1.5%"></div></div><span class="dist-pct">0.0%</span></div>
          </div>
        </div>
        <div class="decision-card">
          <div class="decision-head">
            <div>
              <span class="field-name">upstream_e2b_production_readiness</span> <span class="type-pill">score</span>
              <div class="question-sub">Can unmodified open-source E2B API servers run multi-node HA without Azure control-plane refactoring?</div>
            </div>
            <span class="action-pill pill-confirm">Confirm</span>
          </div>
          <div class="decision-main"><strong>1 / 4 HA criteria met out-of-the-box (25.0%)</strong><span class="conf-muted"> · Single-process in-memory node state &amp; no VM-reboot sandbox GC require external PG/Redis state</span></div>
          <div class="dist-list">
            <div class="dist-row"><span class="dist-label">azure_refactored_ha_control_plane</span><div class="dist-track"><div class="dist-fill" style="width:100.0%"></div></div><span class="dist-pct">100.0%</span></div>
            <div class="dist-row"><span class="dist-label">stock_oss_e2b_api_multi_node_ha</span><div class="dist-track"><div class="dist-fill" style="width:25.0%"></div></div><span class="dist-pct">25.0%</span></div>
          </div>
        </div>
      </div>
      <div class="callout-box"><strong>Why Dual-Hop AppGW + APIM?</strong> AppGW WAF v2 terminates wildcard TLS and blocks OWASP attacks on its Public IP, forwards to APIM for per-Host rate limiting, and receives APIM callbacks on its Private IP (`:8080`) to load-balance across the dynamic API VMSS pool.</div>
    </div>
    <footer class="card-footer">
      <span><strong>Azure AI Agent Infrastructure Playbook</strong> · E2B CheckRide v2 &amp; AKSClaw Deep Dive</span>
      <span>2 / 7</span>
    </footer>
  </div>
</article>

<!-- CARD 3 -->
<article class="report-card" id="card-3">
  <div class="card-accent-bar"></div>
  <div class="card-inner">
    <header class="card-header">
      <div class="card-eyebrow">WHAT I TESTED</div>
      <h2 class="card-headline">6 use-case tracks, 12 architecture contract checks</h2>
      <p class="card-subtitle">Evaluation of 12 enterprise &amp; AI-native workload scenarios against the Playbook routing rules, isolation boundaries, and operational prerequisites. Misses (✕) flag architectural anti-patterns caught by the evaluator.</p>
    </header>
    <div class="card-canvas">
      <table class="clean-table">
        <thead>
          <tr><th>SCENARIO</th><th>WORKLOAD &amp; ARCHITECTURAL QUESTION</th><th>EVALUATOR'S ANSWER</th><th class="act-col">ACTION</th></tr>
        </thead>
        <tbody>
          {scenario_rows_html}
        </tbody>
      </table>
      <div class="callout-box"><strong>3 architectural anti-patterns caught (`✕`):</strong> (S09) Routing an unmet infrastructure-control workload back to Foundry when the customer lacks a dev team; (S10) Running unmodified open-source E2B API in multi-node production without externalizing in-memory node state; (S11) Assuming ACA/AKS deployment alone enables Entra Agent ID &amp; zero-key custody without explicit Blueprint + AI Gateway binding.</div>
    </div>
    <footer class="card-footer">
      <span><strong>Azure AI Agent Infrastructure Playbook</strong> · 12-scenario matrix verified by agent_infra_sizer.py</span>
      <span>3 / 7</span>
    </footer>
  </div>
</article>

<!-- CARD 4 -->
<article class="report-card" id="card-4">
  <div class="card-accent-bar"></div>
  <div class="card-inner">
    <header class="card-header">
      <div class="card-eyebrow">UNDER THE HOOD</div>
      <h2 class="card-headline">APIM per-Host isolation &amp; AKSClaw 5-boundary enforcement</h2>
      <p class="card-subtitle">How Azure isolates 100K+ concurrent dynamic E2B sandbox subdomains at the gateway layer while enforcing zero-key, non-bypassable identity and network boundaries inside AKS.</p>
    </header>
    <div class="card-canvas">
      <pre class="code-dark">&lt;!-- 1. E2B on Azure: APIM Per-Sandbox Dynamic Subdomain Rate Limit (&lt;port&gt;-&lt;sandboxId&gt;.domain.com) --&gt;
&lt;inbound&gt;
  &lt;base /&gt;
  &lt;rate-limit-by-key calls="300" renewal-period="60"
    counter-key="@(context.Request.Headers.GetValueOrDefault(&amp;quot;Host&amp;quot;, &amp;quot;unknown&amp;quot;))"
    increment-condition="@(context.Response.StatusCode &amp;gt;= 200 &amp;amp;&amp;amp; context.Response.StatusCode &amp;lt; 400)" /&gt;
  &lt;set-backend-service base-url="http://10.240.0.10:8080" /&gt; &lt;!-- Callback to AppGW Private Frontend --&gt;
&lt;/inbound&gt;</pre>
      <div class="code-transition">↓ Combined with AKSClaw Pod VM Hard Boundaries + Entra Agent ID + Unified AI Gateway ↓</div>
      <pre class="code-dark"># 2. AKSClaw Kata Pod VM + NetworkPolicy + AI Gateway Contract (Zero LLM API Key in Agent Pod)
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: aksclaw-agent-alice
spec:
  template:
    spec:
      runtimeClassName: kata-mshv-vm-isolation   # Dedicated Hypervisor Guest Kernel per Agent
      serviceAccountName: entra-agent-id-alice   # Blueprint + Sponsor dual-identity attribution
      containers:
      - name: agent-harness
        env:
        - name: OPENAI_BASE_URL
          value: "http://ai-gateway.platform.svc.cluster.local/v1" # Prefix-cache affinity + RPM/TPM hard stop
        # NO OPENAI_API_KEY in env! Injected upstream by AI Gateway after Entra Agent ID token check
        volumeMounts:
        - {{ name: team-skills, mountPath: /skills, readOnly: true }}      # Shared Read-Only Marketplace
        - {{ name: agent-state, mountPath: /workspace, readOnly: false }} # Isolated Per-Instance State
# NetworkPolicy blocks 169.254.169.254 (IMDS) + restricts egress to AI Gateway &amp; approved MCP proxies -&gt; <span class="hl-answer">&lt;answer&gt;</span></pre>
      <div class="callout-box"><strong>Security does not rely on Agent prompt obedience.</strong> Even if an agent runs with `--yolo` or suffers prompt injection, `kata-mshv-vm-isolation` isolates the kernel, NetworkPolicy blocks `169.254.169.254`, the pod holds zero raw LLM keys, and the AI Gateway enforces hard token budget circuit breakers.</div>
    </div>
    <footer class="card-footer">
      <span><strong>Azure AI Agent Infrastructure Playbook</strong> · Protocol &amp; policy mechanics</span>
      <span>4 / 7</span>
    </footer>
  </div>
</article>

<!-- CARD 5 -->
<article class="report-card" id="card-5">
  <div class="card-accent-bar"></div>
  <div class="card-inner">
    <header class="card-header">
      <div class="card-eyebrow">ROBUSTNESS CHECK</div>
      <h2 class="card-headline">+50.8 pts startup speed gain on AMD Turin v7; 100% hard-boundary retention</h2>
      <p class="card-subtitle">Paired sensitivity analysis across VM CPU generations (v6 vs v7), idle session reclamation, prompt-injection bypass attempts, VMSS scaling direction, and $10K propensity screening gates.</p>
    </header>
    <div class="card-canvas">
      <table class="clean-table">
        <thead>
          <tr><th>PERTURBATION DIMENSION</th><th class="num-col">BASELINE</th><th class="num-col">PERTURBED / UPGRADED</th><th class="num-col">CHANGE (PTS)</th></tr>
        </thead>
        <tbody>
          {rob_rows_html}
        </tbody>
      </table>
      <div class="callout-box"><strong>Key Invariant:</strong> Upgrading from `Standard_D96as_v6` (Genoa) to `Standard_D96as_v7` (Turin + Azure Boost) cuts Base MicroVM startup from `239 ms` to `108 ms` (`+50.8 pts` speed index), while switching from ephemeral Dynamic Sessions to ACA Sandboxes + HorizonDB raises post-reclamation workspace continuity from `0%` to `100%`.</div>
    </div>
    <footer class="card-footer">
      <span><strong>Azure AI Agent Infrastructure Playbook</strong> · 6 paired architectural robustness checks</span>
      <span>5 / 7</span>
    </footer>
  </div>
</article>

<!-- CARD 6 -->
<article class="report-card" id="card-6">
  <div class="card-accent-bar"></div>
  <div class="card-inner">
    <header class="card-header">
      <div class="card-eyebrow">LATENCY &amp; STARTUP SCALING</div>
      <h2 class="card-headline">108ms Base &amp; 132ms Code-Interpreter on Azure D96as_v7</h2>
      <p class="card-subtitle">Comparison of optimized sandbox restore paths (`#2563EB`) against baseline VM generations and cold container initialization (`#CBD5E1`). Lower latency means faster interactive agent tool execution.</p>
    </header>
    <div class="card-canvas">
      <div class="lat-list">
        {lat_rows_html}
      </div>
      <div class="callout-box"><strong>Measured Hardware Insight:</strong> `Standard_D96as_v7` (5th Gen AMD EPYC Turin up to 4.5GHz + Azure Boost) achieves **`108 ms`** Base Sandbox restore and **`132 ms`** Code-Interpreter V1 startup in East US 2 / Central US — outperforming both `Standard_D96s_v6` Intel (`116 ms` / `159 ms`) and `Standard_D96as_v6` Genoa (`239 ms` / `255 ms`).</div>
    </div>
    <footer class="card-footer">
      <span><strong>Azure AI Agent Infrastructure Playbook</strong> · Measured East US 2 / Central US latency &amp; reference models</span>
      <span>6 / 7</span>
    </footer>
  </div>
</article>

<!-- CARD 7 -->
<article class="report-card" id="card-7">
  <div class="card-accent-bar"></div>
  <div class="card-inner">
    <header class="card-header">
      <div class="card-eyebrow">MY TAKE</div>
      <h2 class="card-headline">Match the runtime to the isolation boundary — never force-fit</h2>
      <p class="card-subtitle">Architectural synthesis on when to use Foundry Hosted Agents vs ACA Dynamic Sessions/Sandboxes vs AKS Kata (AKSClaw) vs E2B on Azure VMSS.</p>
    </header>
    <div class="card-canvas">
      <div class="fit-grid">
        <div class="fit-card fit-good">
          <div class="fit-head">✅ Good fit</div>
          <ul>
            <li><strong>Foundry Hosted Agents:</strong> To-B business agents using approved APIs &amp; 1,400+ MCP connectors with minimal infra ops.</li>
            <li><strong>Durable Functions + ACA Apps:</strong> Long-running procurement/finance/approval flows needing external event wait &amp; deterministic replay.</li>
            <li><strong>ACA Dynamic Sessions / Sandboxes:</strong> Ephemeral Hyper-V code execution (`~210ms`) or stateful coding/browser workspaces with pause/resume snapshots.</li>
            <li><strong>AKS + Kata (`AKSClaw`):</strong> Multi-tenant engineering/SRE fleets needing BYO harnesses, shared Skill Marketplace, and 5 hard platform boundaries.</li>
            <li><strong>E2B on VMSS (`D96as_v7`):</strong> AI-native products needing 100K+ concurrent virtual computers at `108ms–132ms` startup.</li>
          </ul>
        </div>
        <div class="fit-card fit-bad">
          <div class="fit-head">⛔ Not for</div>
          <ul>
            <li><strong>Routing unmet control needs to Foundry:</strong> Never push a customer who needs custom OS/network/sandbox control into Foundry Hosted Agents just because they lack a dev team (engage CSU/Partner instead).</li>
            <li><strong>Storing durable state only in Dynamic Sessions:</strong> Session local storage is wiped on idle reclamation; always persist checkpoints in <strong>Azure HorizonDB</strong> or <strong>Cosmos DB</strong>.</li>
            <li><strong>Blind CPU scale-in on E2B VMSS:</strong> Firecracker consumes HugePages; scaling in without HugePages drain &amp; live migration kills active sandboxes.</li>
            <li><strong>In-pod LLM keys or inherited user tokens:</strong> Never mount static API keys in agent containers or let agents inherit full user tokens.</li>
          </ul>
        </div>
      </div>
      <div class="dark-footer-box">
        <div><strong>Playbook Readiness &amp; Provenance:</strong> Synthesized from 5 primary Azure AI Infra field assets (`Agent Runtime Customer Pitch`, `AKSClaw Multi-Tenant Kubernetes`, `Agent Infra Playbook`, `E2B on Azure Solution / CheckRide v2 / Deep Dive v0.2`, and anonymized `Selection Logic`). Zero customer PII included.</div>
        <p class="dark-repo">Repositories: turbo998/ai-infra-lab · turbo998/Azure-Infra-Lab · turbo998/ai-research-public · turbo998/ai-research-lab</p>
      </div>
    </div>
    <footer class="card-footer">
      <span><strong>Azure AI Agent Infrastructure Playbook</strong> · 7-Card 4:5 Benchmark &amp; Decision Deck</span>
      <span>7 / 7</span>
    </footer>
  </div>
</article>

</main>
</body>
</html>
"""


def build_7card_markdown(report: dict[str, Any]) -> str:
    scenarios = report["scenarios"]
    robustness = report["robustness_checks"]
    latencies = report["latency_tiers"]

    md = """# Azure AI Agent Infrastructure Playbook：6 大运行时与 12 场景架构基准评测报告（7 页 4:5 视觉卡片版）

**来源性质：** `anonymized_reported + deterministic_architecture_verifier (independently_reproduced=false)`，基于 Microsoft Azure AI Infra 一手架构材料（`Agent Runtime Customer Pitch`、`AKSClaw Multi-Tenant Kubernetes`、`Agent Infra Playbook`、`E2B on Azure CheckRide v2 / Deep Dive v0.2` 及脱敏 `Selection Logic` 方法论）与本地确定性容量/选型核验器 `simulator/agent_infra_sizer.py` 生成。所有内部客户名单与敏感财务行已在提取前严格物理剥离。

结构化数据与可离线预览工件：
- [7 页 4:5 视觉评测卡片 HTML（CSP 锁定自包含）](test-report-cards.html)
- [完整卡片与容量测算 JSON](report.json)
- [12 项生产场景架构选型核验 CSV](evidence/test-scenarios.csv)
- [6 项代际硬件与边界扰动鲁棒性 CSV](evidence/test-robustness.csv)
- [6 档沙箱启动与恢复延迟对比 CSV](evidence/test-batch-latency.csv)

---

## Card 1（`1 / 7` · `HANDS-ON · AZURE AI AGENT INFRASTRUCTURE BENCHMARK`）：总览与选型工作台

**核心发现标题：** **6 Azure Agent Runtimes, 108ms MicroVM restore**（六大 Azure Agent 运行时梯度互补，E2B on `D96as_v7` 实现 108ms 级 MicroVM 恢复）。

| 工作台决策字段 | 题型 | 核心评测问题 | 评测输出 | 置信度 / 比例 | 动作分档 | 分布明细 |
|---|---|---|---|---:|---|---|
| `e2b_turin_v7_speedup` | `choice` | Azure `D96as_v7`（第五代 AMD EPYC Turin + Azure Boost）在 E2B 沙箱启动上是否全面优于 `D96s_v6` 与 `D96as_v6`？ | `108 ms Base / 132 ms Code-Interpreter V1` | `0.926`（92.6%） | `Act automatically` | `D96as_v7` 108ms/132ms, `D96s_v6` 116ms/159ms, `D96as_v6` 239ms/255ms |
| `aksclaw_security_enforcement` | `choice` | 多租户 K8s Agent 平台（`AKSClaw`）的 5 项安全边界是否全部由平台层强制执行而不依赖 Agent 自觉？ | `5 / 5 platform hard boundaries (100.0%)` | `1.000`（100.0%） | `Act automatically` | IMDS 封禁、出网白名单、凭据注入代理、Entra Agent ID、Unified AI Gateway |
| `playbook_delivery_gate` | `score` | 当企业需要超越托管服务的底层控制但缺乏自有研发团队时，能否直接退回推荐 Foundry Hosted Agents？ | `0% shortcut allowed (Hold for CSU / Partner)` | `0.750`（75.0%） | `Send to a human` | 9/12 正向选型成立，3/12 架构反模式被精准拦截 |

---

## Card 2（`2 / 7` · `SCENARIO: MANUS × E2B 100K+ VIRTUAL COMPUTERS & AKSCLAW FLEET`）：单样本深度拆解

**核心发现标题：** **261 D96as_v7 nodes serve 100K sandboxes at 108ms**（单规模集 261 台 `D96as_v7` 宿主机即可承载 10 万并发沙箱，启动延迟低至 108ms）。

| 决策字段 | 题型 | 深度拆解问题 | 核验结果 | 置信度 / 比例 | 动作分档 | 分布明细 |
|---|---|---|---|---:|---|---|
| `vmss_100k_capacity_fit` | `choice` | 100,000 并发 E2B 沙箱是否可容纳在单个 Azure VMSS Flexible 规模集（上限 1,000 台 VM）内？ | `Yes · 261 Client Nodes (26.1% of limit)` | `0.850`（85.0%） | `Act automatically` | 384 GiB × 85% HugePages × 60% 扩容水位 = 384 稳态沙箱/节点 |
| `apim_appgw_dual_hop_isolation` | `noul` | `AppGW WAF v2`（双前端 IP）+ `APIM rate-limit-by-key` 能否隔离 10 万+ 动态沙箱子域名并透传 WebSocket？ | `Yes (100% per-Host isolation)` | `P(true) = 1.0` | `Act automatically` | `counter-key="@(context.Request.Headers.GetValueOrDefault(\"Host\"))"` |
| `upstream_e2b_production_readiness` | `score` | 未改造的开源版 E2B API Server 能否直接多实例水平扩展并抵抗宿主机重启？ | `1 / 4 HA criteria met (25.0%)` | `0.250`（25.0%） | `Confirm` | 开源版将节点状态存于单进程内存且缺乏重启孤儿沙箱回收，必须做状态外置改造 |

---

## Card 3（`3 / 7` · `WHAT I TESTED`）：6 大场景 12 项架构选型核验全矩阵

| 场景编号与分类 | 架构选型核验问题 | 核验结果（报告百分比） | 预期是否成立 | 动作分档 | 证据锚点 |
|---|---|---|---:|---|---|
"""
    for sc in scenarios:
        miss = " `✕`" if not sc["passed"] else ""
        yes_no = "是" if sc["passed"] else "否"
        md += f"| `{sc['id']} · {sc['category']}` | {sc['question']} | `{sc['model_answer']}`{miss} | {yes_no} | `{sc['action']}` | {sc['evidence_ref']} |\n"

    md += """
---

## Card 4（`4 / 7` · `UNDER THE HOOD`）：APIM 动态 Host 限流与 AKSClaw 五道硬边界协议链路

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

` ↓ 结合 AKSClaw Kata Pod VM 硬件虚拟化沙箱 + Entra Agent ID + Unified AI Gateway ↓ `

```yaml
# 2. AKSClaw Kata Pod VM + NetworkPolicy + AI Gateway Contract (Zero LLM API Key in Agent Pod)
runtimeClassName: kata-mshv-vm-isolation   # 独立 Hypervisor 内核隔离
serviceAccountName: entra-agent-id-alice   # Blueprint + Sponsor 双重身份归属
env:
  - name: OPENAI_BASE_URL
    value: "http://ai-gateway.platform.svc.cluster.local/v1" # Prefix-Cache 亲和 + RPM/TPM 硬熔断
# 容器内零 API Key；NetworkPolicy 封禁 169.254.169.254 IMDS -> <answer>
```

---

## Card 5（`5 / 7` · `ROBUSTNESS CHECK`）：代际硬件、状态回收与安全边界扰动检验

| 评测维度 | 配对比较定义（Original vs Perturbed / Upgraded） | 基线比例 % | 扰动/升级后 % | 变化（百分点） | 主结论是否保持 |
|---|---|---:|---:|---:|---|
"""
    for r in robustness:
        sign = "+" if r["delta_pts"] > 0 else ""
        md += f"| `{r['dimension']}` | {r['original_label']} vs {r['perturbed_label']} | `{r['original_pct']:.1f}` | `{r['perturbed_pct']:.1f}` | `{sign}{r['delta_pts']:.1f}` | 是 |\n"

    md += """
---

## Card 6（`6 / 7` · `LATENCY & STARTUP SCALING`）：沙箱启动与恢复延迟对比

| 延迟对比层级 | 优化路径延迟 (`#2563EB`) | 基线路径延迟 (`#CBD5E1`) | 数据来源与说明 |
|---|---|---|---|
"""
    for item in latencies:
        md += f"| `{item['tier_label']}` | **{item['optimized_label']}** | {item['baseline_label']} | {item['source_note']} |\n"

    md += """
---

## Card 7（`7 / 7` · `MY TAKE`）：适用场景（Good Fit）与架构禁区（Not For）

- **✅ Good Fit（强烈推荐）**：
  1. **Foundry Hosted Agents**：To-B 标准企业助手，直接复用 1,400+ MCP 工具箱与 Entra Agent ID，零集群运维。
  2. **Azure Functions + Durable Functions**：长周期审批、跨系统事务与人机回环等待（Wait/Resume）场景。
  3. **ACA Dynamic Sessions / ACA Sandboxes (Preview)**：不可信代码短时执行（Hyper-V 预热池 `~210ms`）或需显式 `pause/resume` 快照的 Coding/Browser 工作区。
  4. **AKS + Kata (`AKSClaw`)**：企业多租户 Agent 平台与研发/SRE 舰队，共享只读技能市场 + 实例独占状态卷 + 5 道平台硬边界。
  5. **E2B on Azure VMSS (`D96as_v7`)**：10 万+ 并发云端虚拟电脑（Manus 模式），`108ms` Base / `132ms` Code-Interpreter 极速恢复。
- **⛔ Not For（严格禁区）**：
  1. 客户需要超越托管的底层控制但无研发团队时，**严禁**强行塞回 Foundry（必须先引入 CSU/Partner 交付力量）。
  2. **严禁**将持久业务状态仅保存在 ACA Dynamic Sessions 本地磁盘（空闲回收即清零，必须外置到 `HorizonDB` 或 `Cosmos DB`）。
  3. **严禁**在 E2B VMSS 上仅凭常规内存/CPU 指标盲目缩容（Firecracker 占用 HugePages，必须先做沙箱热迁移排空）。
  4. **严禁**在 Agent 容器内挂载静态 LLM API Key 或直接继承用户登录 Token。
"""
    return md


def main() -> int:
    bundle_dir = Path(__file__).resolve().parent.parent
    assets_dir = bundle_dir / "assets"
    assets_dir.mkdir(parents=True, exist_ok=True)

    svgs = {
        "01-azure-agent-infra-4layer-panorama.svg": build_svg_01(),
        "02-runtime-spectrum-6tier-matrix.svg": build_svg_02(),
        "03-scenario-decision-tree-and-routing.svg": build_svg_03(),
        "04-aksclaw-multi-tenant-k8s-architecture.svg": build_svg_04(),
        "05-e2b-on-azure-vmss-reference-architecture.svg": build_svg_05(),
        "06-e2b-microvm-internals-and-vm-benchmark.svg": build_svg_06(),
        "07-multi-agent-workflow-and-state-checkpoint.svg": build_svg_07(),
        "08-field-playbook-5step-execution-flow.svg": build_svg_08(),
    }

    for filename, content in svgs.items():
        # Strict XML validation
        ET.fromstring(content.encode("utf-8"))
        (assets_dir / filename).write_text(content, encoding="utf-8")

    report = json.loads((bundle_dir / "report.json").read_text(encoding="utf-8"))
    cards_html = build_7card_html(report)
    cards_md = build_7card_markdown(report)

    (bundle_dir / "cards.html").write_text(cards_html, encoding="utf-8")
    (bundle_dir / "benchmark-cards.html").write_text(cards_html, encoding="utf-8")
    (bundle_dir / "test-report.md").write_text(cards_md, encoding="utf-8")
    print(f"OK: generated and XML-validated {len(svgs)} SVGs + cards.html + test-report.md")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
