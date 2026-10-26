# 📺 EP04 · 智能体支付安全工程：当 AI 替你刷卡买单，怎么防重放与越权？UCP 与 AP2 商业协议安全拆解

> **英文标题 (English Title)**: *Securing Autonomous AI Shopping: UCP & AP2 Protocol Guardrails Explained*  
> **关联仓库 (Repository)**: `turbo998/agentic-commerce-lab` (`main` 分支实时同步)  
> **视频规格 (Video Specs)**: 16:9 横屏深度版 (`1920×1080`, `146.2s`) + 9:16 竖屏精华版 (`1080×1920`, `72.6s`) · 30fps H.264 + 双语字幕 (`.srt`)

---

## 1. 节目定位与 B 站知识区视觉风格 (Production Style)

本期视频融合了 **回形针 PaperClip / 硬件茶谈 / 何同学 / 差评君** 的硬核技术科普叙事结构：
- **黄金 3 秒反直觉开场**：直击工程痛点与反常识实验现象；
- **顶部动态章节进度条**：4 幕结构化拆解，实时高亮当前推理/架构阶段；
- **左屏架构工作台 + 真实实验证据**：嵌入仓库真实渲染图、压测曲线、核心代码与数学公式；
- **右屏定量评测卡片**：基于真实测量数据展示 KPI 指标、对比柱状图与架构师敲黑板结论；
- **高能弹幕与中英双语字幕**：内置中文语音合成解说、环境合成器背景混音与 `.srt` 时间轴字幕。

---

## 2. 分幕分镜脚本与解说词 (Scene-by-Scene Storyboard & Bilingual Script)

### 第 1 幕 · 01 AI代购风险 (`HOOK · 如果购物 Agent 被诱导多刷了 10 次卡，谁来背锅？`)

- **核心结论标题 (Headline-as-Finding)**: **从聊天助手到自主交易：UCP 与 AP2 智能体商业协议的攻防生死线**
- **英文副标题 (Subhead)**: *Autonomous Agent Checkout Risks · Replay, Schema Drift & Mandate Hijacking*
- **16:9 完整解说词 (Full Narration ZH)**:
  > 让 AI 帮你写周报写错了最多挨顿骂，但让 AI 替你自动比价、下单、绑卡支付，一旦出 Bug 就是真金白银的资损。Google 与行业联盟推出的 UCP 统一商业协议，以及 AP2 智能体支付协议，正在定义下一代 AI 电商标准。但标准刚落地，攻击面也随之而来：回调重放、分页死循环、授权凭据篡改。我们的 Agentic Commerce 实验室在第一百七十七阶段，把这些高危漏洞全部变成了确定性防线。
- **9:16 竖屏速览解说词 (Short Narration ZH)**:
  > 让 AI 帮你写周报写错了最多挨顿骂，但让 AI 替你自动比价、下单、绑卡支付，一旦出 Bug 就是真金白银的资损。Google 与行业联盟推出的 UCP 统一商业协议，以及 AP2 智能体支付协议，正在定义下一代 AI 电商标准。
- **英文对照解说 (English Narration)**:
  > When AI agents gain checkout and payment authority, protocol guardrails prevent financial loss.

#### 核心架构流节点 (Architecture Flow Nodes)
1. **用户授权意图** — Intent Mandate · 预算与品类约束
2. **UCP 商品与结账** — 目录检索、购物车构建与价格锁定
3. **AP2 支付凭据** — Cart Mandate · 加密签名与防篡改
4. **177阶确定性护栏** — 拦截重放、Schema漂移与游标投毒

#### 定量实测指标 (Verified Metrics)
- **Stage 177** (协议演进阶段) — `UCP + AP2 + ACP 深度对齐`
- **UCP #974/#897** (覆盖上游议题) — `含 #939 / #774 / AP2 #290`
- **100% 拦截** (基准评测通过) — `7-Card 4:5 标准基准报告`

#### 核心代码与公式验证 (Code & Formula Snippet)
```python
THREAT_MATRIX = {
  'UCP-974': 'Checkout state transition replay & idempotency bypass',
  'UCP-897': 'Catalog cursor trail-head window exhaustion attack',
  'AP2-290': 'Cryptographic payment mandate scope & ceiling drift'
}
```

- **💡 架构师敲黑板 (Key Takeaway)**: 当 AI Agent 获得直接下单与支付权限，协议层安全护栏决定了商业落地的生死
- **💬 精选高能弹幕 (Danmaku)**: AI 自动剁手时代真的来了，但安全太重要了 / Stage 177！这协议追踪速度比官方还快 / 金融级 Agent 必须得有确定性状态机！

### 第 2 幕 · 02 UCP协议防线 (`UCP GUARD · 拆解 UCP #974 / #897 / #939 / #774 四重协议防线`)

- **核心结论标题 (Headline-as-Finding)**: **拒绝无限游标与状态跳跃：UCP 结账流水线的毫秒级契约校验**
- **英文副标题 (Subhead)**: *Deterministic UCP Checkout · Cursor Window Bounds & Strict Idempotency*
- **16:9 完整解说词 (Full Narration ZH)**:
  > 我们直接看 UCP 协议层的四个真实上游议题。针对 UCP 九七四和八九七，攻击者往往利用分页目录的游标窗口或结账会话的版本号不一致，制造脏读与重复提交。我们在护栏引擎中引入了严格的 Trail-Head 滑动窗口边界校验与幂等键指纹绑定：任何偏离单调递增序列的游标、或者未携带有效状态哈希的结账变更请求，在零点一毫秒内就会被状态机直接熔断。
- **9:16 竖屏速览解说词 (Short Narration ZH)**:
  > 我们直接看 UCP 协议层的四个真实上游议题。针对 UCP 九七四和八九七，攻击者往往利用分页目录的游标窗口或结账会话的版本号不一致，制造脏读与重复提交。
- **英文对照解说 (English Narration)**:
  > Enforcing trail-head cursor window bounds and cryptographic idempotency for UCP #974 & #897.

#### 核心架构流节点 (Architecture Flow Nodes)
1. **UCP #897 游标窗口** — Trail-Head Window 单调性与跨度限制
2. **UCP #974 结账幂等** — 绑定 Payload Hash 与版本序列号
3. **UCP #939/#774** — 履约地址、税费重算与 Schema 严格对齐
4. **Deterministic Gate** — 违规请求 0.08ms 确定性拒绝

#### 定量实测指标 (Verified Metrics)
- **100%** (游标越界拦截率) — `零死循环 / 零内存溢出`
- **< 0.1 ms** (幂等冲突检测) — `SHA-256 规范化载荷指纹`
- **0 未知字段** (契约漂移容忍度) — `Strict Schema 强类型模式`

#### 核心代码与公式验证 (Code & Formula Snippet)
```python
def verify_ucp_cursor_window(cursor_seq: int, trail_head: int, max_span: int = 64):
    if cursor_seq < trail_head or (cursor_seq - trail_head) > max_span:
        raise UcpProtocolError('UCP_897_TRAIL_HEAD_WINDOW_VIOLATION')
    return True
```

- **💡 架构师敲黑板 (Key Takeaway)**: 针对 UCP #974/#897/#939/#774，引入滑动窗口游标边界与强幂等状态哈希校验
- **💬 精选高能弹幕 (Danmaku)**: 把 GitHub 上游 Issue 直接做成防线代码，太硬核了 / 0.08ms 校验，完全不影响结算延迟 / Prompt 防不住协议层重放，必须上状态机！

### 第 3 幕 · 03 AP2授权凭据 (`AP2 MANDATE · AP2 #290 支付授权凭据与防篡改签名链`)

- **核心结论标题 (Headline-as-Finding)**: **人机权责怎么切分？用 AP2 双层加密凭据锁死每一分钱的去向**
- **英文副标题 (Subhead)**: *AP2 Payment Mandates · Intent Mandate vs Cart Mandate Cryptographic Binding*
- **16:9 完整解说词 (Full Narration ZH)**:
  > 再看支付环节的 AP2 二九零议题。在多智能体协作购物时，主控 Agent 往往把选购任务委托给子 Agent。如果子 Agent 被商家页面的隐藏提示词劫持，把五百元的耳机换成了五千元的礼品卡怎么办？AP2 的核心设计是双层授权凭据：第一层 Intent Mandate 锁死预算上限、币种与商户白名单；第二层 Cart Mandate 对最终商品明细、税费和过期时间窗口做哈希签名，任何一分钱的改动都会导致验签直接失败。
- **9:16 竖屏速览解说词 (Short Narration ZH)**:
  > 再看支付环节的 AP2 二九零议题。在多智能体协作购物时，主控 Agent 往往把选购任务委托给子 Agent。
- **英文对照解说 (English Narration)**:
  > AP2 dual mandates cryptographically bind budget ceilings, merchant allowlists, and cart line items.

#### 核心架构流节点 (Architecture Flow Nodes)
1. **Intent Mandate** — 用户签名：上限 ¥500 + 指定类目 + TTL
2. **Sub-Agent 选购** — 不可突破主凭据的 Scope 与窗口边界
3. **Cart Mandate** — 精确绑定 SKU、单价、税费与商户 ID
4. **AP2 #290 验证器** — 签名链 + 窗口期 + 总额不变量核验

#### 定量实测指标 (Verified Metrics)
- **Intent → Cart** (双层凭据绑定) — `加密哈希链防中途篡改`
- **100% 熔断** (超预算拦截) — `分币级精度 + 币种强一致`
- **Strict TTL** (时间窗口防护) — `过期凭据与重放 Token 自动作废`

#### 核心代码与公式验证 (Code & Formula Snippet)
```python
if cart.currency != intent.currency or cart.total_minor > intent.max_amount_minor:
    return Verdict(allow=False, code='AP2_290_MANDATE_CEILING_EXCEEDED')
if not verify_detached_jws(cart.digest(), mandate.signature, user_pubkey):
    return Verdict(allow=False, code='AP2_SIGNATURE_MISMATCH')
```

- **💡 架构师敲黑板 (Key Takeaway)**: AP2 双层凭据（Intent + Cart Mandate）通过加密签名锁死预算上限、商户与商品明细
- **💬 精选高能弹幕 (Danmaku)**: Intent Mandate 和 Cart Mandate 的双层设计太巧妙了 / 哪怕网页里有 Prompt Injection 也改不了签名金额！ / 这就是未来 Visa / Mastercard AI 支付的底座啊

### 第 4 幕 · 04 7卡基准验证 (`BENCHMARK · 7-Card 4:5 视觉评测报告与双语开源交付`)

- **核心结论标题 (Headline-as-Finding)**: **从理论到实测：生成 7 卡标准评测报告并同步 GitHub 主线**
- **英文副标题 (Subhead)**: *7-Card 4:5 Benchmark Deck · Option-Order Reversal & Batch Latency Verified*
- **16:9 完整解说词 (Full Narration ZH)**:
  > 为了确保每一条护栏都经得起生产环境考验，我们严格按照七卡四比五视觉评测标准，对 Stage 一七六到一七七的全部测试集进行了正反序扰动测试与高并发延迟压测。结果显示，在正反序扰动下判定一致性达到百分之百，单批吞吐延迟保持在亚毫秒级别。所有护栏代码、七卡评测报告与中英双语文档，均已合并推送至 agentic-commerce-lab 主分支。
- **9:16 竖屏速览解说词 (Short Narration ZH)**:
  > 为了确保每一条护栏都经得起生产环境考验，我们严格按照七卡四比五视觉评测标准，对 Stage 一七六到一七七的全部测试集进行了正反序扰动测试与高并发延迟压测。结果显示，在正反序扰动下判定一致性达到百分之百，单批吞吐延迟保持在亚毫秒级别。
- **英文对照解说 (English Narration)**:
  > Verified via 7-Card 4:5 benchmark deck: 100% perturbation consistency and sub-ms latency on main.

#### 核心架构流节点 (Architecture Flow Nodes)
1. **Card 1-3 矩阵评测** — 全场景覆盖 UCP #974/#897 与 AP2 #290
2. **Card 4 协议追踪** — 输入载荷 ↓ 状态机 ↓ 确定性裁决
3. **Card 5-6 鲁棒与延迟** — 0 pts 扰动漂移 · 批量压测对比
4. **Card 7 生产就绪** — 中英双语归档至 main 分支

#### 定量实测指标 (Verified Metrics)
- **0.0 pts** (正反序扰动漂移) — `100% 确定性不变量裁决`
- **7-Card 4:5** (报告视觉标准) — `零外部依赖 CSP 自包含 HTML`
- **main 同步** (Git 主线状态) — `cc3e50d 持续集成全绿`

#### 核心代码与公式验证 (Code & Formula Snippet)
```python
{
  "stage": 177, "total_cases": 48, "passed": 48,
  "perturbation_drift_pts": 0.0, "p99_latency_ms": 0.14,
  "provenance": "measured", "branch": "main"
}
```

- **💡 架构师敲黑板 (Key Takeaway)**: 通过 7-Card 4:5 基准评测验证：100% 扰动一致性、亚毫秒级延迟，全量同步主线
- **💬 精选高能弹幕 (Danmaku)**: 7卡报告颜值与含金量拉满！ / 0.0 pts 扰动漂移，确定性工程的胜利 / 关注 UP 主，追更全网最硬核的 Agent 协议研究！
