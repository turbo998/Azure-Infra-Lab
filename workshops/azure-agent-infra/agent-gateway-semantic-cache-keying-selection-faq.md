# Agent 网关语义缓存键选型 FAQ（原始 Prompt 哈希 vs 规范化语义键）

## 1) 核心结论（先给负责人）
- **多租户生产默认采用“规范化语义键 + 策略版本号”**，不建议仅用原始 Prompt 哈希。
- **纯哈希键在高变体输入下命中率不稳定**，容易放大回源压力与尾延迟。
- **缓存键治理必须与租户命名空间、碰撞检测、TTL/配额联动**，否则命中收益不可持续。

## 2) Q1 / Q2 / Q3（术语先通俗解释）
- **原始 Prompt 哈希**：对用户输入直接哈希，键构造简单但对微小文本变体非常敏感。
- **规范化语义键**：先归一化输入（模板、参数槽位、策略版本），再生成稳定键。

### Q1：为什么纯哈希键在生产里不稳？
第一性原理：等价语义但文本不同会产生不同键，造成“伪未命中”，在流量抖动下放大回源与成本。

### Q2：什么时候可以接受纯哈希键？
单租户、输入模板严格固定、命中率目标不高且可容忍回源峰值时，可作为短期过渡。

### Q3：语义键最小安全闭环是什么？
输入归一化 -> 语义键生成 -> 租户命名空间隔离 -> 命中/回源记录 -> TTL/配额调节 -> 碰撞审计。

## 3) Mermaid（语义缓存键治理闭环）
```mermaid
flowchart LR
  I[Prompt/Input] --> N[Normalizer]
  N --> K[Semantic Key Builder]
  K --> T[Tenant Namespace Fence]
  T --> C[Cache Lookup]
  C --> M[Hit/Miss Ledger]
  M --> P[TTL + Quota Policy Loop]
```

## 4) 决策矩阵
| 维度 | 原始 Prompt 哈希 | 规范化语义键 |
|---|---|---|
| 实现复杂度 | 低 | 中-高 |
| 命中率稳定性 | 低-中 | 高 |
| 回源放大控制 | 低 | 高 |
| 多租户隔离治理 | 中 | 高 |
| 生产默认建议 | 短期过渡 | 多租户长期运行 |

## 5) 数据证据与可复算算例（含 n/分母/来源）
> 本节百分比为 `synthetic_assumed` 假设算例（hypothetical），用于机制比较；生产机制认证仍为 `not_measured`。  
> 合同字段见：`workshops/azure-agent-infra/evidence/cycle-426-benchmark.json` 的 `percentage_contract`。

- 指标 A（未命中率，原始哈希键）  
  - 定义：`n_miss_raw_hash / n_sessions_observed`  
  - 值：`256/2000 = 12.8%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.raw_hash_cache_miss_rate`
- 指标 B（未命中率，规范化语义键）  
  - 定义：`n_miss_normalized / n_sessions_observed`  
  - 值：`62/2000 = 3.1%`（`synthetic_assumed`）  
  - 路径：`percentage_contract.normalized_key_cache_miss_rate`
- 指标 C（命中收益，百分点）  
  - 定义：`(n_hit_normalized - n_hit_raw_hash) / n_sessions_observed`  
  - 值：`(1704-1480)/2000 = 11.2` 个百分点（`synthetic_assumed`）  
  - 路径：`percentage_contract.cache_hit_gain_pts`

## 6) 生产 Checklist（上线前必须打勾）
- [ ] 语义键策略含版本、灰度与回滚路径  
- [ ] 租户命名空间隔离与配额门禁在网关层生效  
- [ ] 缓存碰撞检测与命中/回源账本可审计可追溯  
- [ ] 指标口径标注 `synthetic_assumed` 与分母/单位，生产机制认证保持 `not_measured`  
