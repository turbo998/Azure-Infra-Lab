# Cycle #2457 核心工程专著：APIM PTU↔PAYGO Spillover 与 Cache Affinity（zh-CN）

- Round/Cycle: `1052 / 2457`
- 日期：`2026-11-16 (BJT)`
- 主题：`apim-ai-gateway-ptu-paygo-spillover-cache-affinity-faq-r1052`
- 标签：`measured / synthetic / anonymized_reported`

## Chapter 460 · 当日突破与网关工程意义

本轮依据 APIM AI Gateway、ACA Sessions 与 runtime 发布证据。  
核心工程命题：在 PTU 饱和下实现可控溢出，而非无约束 PAYGO 放大。

## Chapter 461 · 参考架构分层

### 1) 流量治理层

token-bucket + circuit breaker 约束突刺流量并触发降级策略。

### 2) 执行路由层

PTU 主通道承载常态流量，PAYGO 通道承担短时溢出，采用滞回恢复避免抖动。

### 3) 缓存亲和层

prompt-cache affinity 将语义相近请求聚到热分片，提高命中并压降推理成本。

## Chapter 462 · 可复现实验结果

`evidence/cycle-2457-*`：
- 延迟：E2B P50 `118ms`，ACA warm P50 `257ms`，Kata P50 `920ms`
- 吞吐：APIM routing P50 `1372 rps`
- 拦截：`ptu-paygo-spillover-policy-violation` `172/184=93.48%`；`cache-affinity-routing-fence` `161/168=95.83%`
- 成本：E2B `$0.00552/session`，Kata `$0.01044/session`，ACA `$0.01100/session`

## Chapter 463 · 失效模式

### A. 溢出风暴导致成本突刺

PTU 饱和后过量切 PAYGO。  
治理：溢出比例上限 + 恢复滞回窗口。

### B. 缓存击穿导致延迟放大

热点 prompt 未被亲和路由命中。  
治理：按租户/模板分片并预热高频键空间。

### C. 级联降级触发可用性抖动

单点 breaker 配置过激，导致全链路抖动。  
治理：分层 breaker 与局部回退策略。

## Chapter 464 · 对比与结论

| 策略 | 稳定性 | 成本可控 | 复杂度 |
|---|---:|---:|---:|
| PTU-only 硬限流 | 中 | 高 | 低 |
| PAYGO-first | 低 | 低 | 低 |
| PTU+PAYGO 自适应 + cache affinity | **高** | **高** | 中高 |

结论：企业级多模型网关应采用 PTU 优先的自适应溢出设计，并以缓存亲和提升性价比。

## Chapter 465 · 五步落地

1. 建 PTU 容量基线与 PAYGO 预算。  
2. 部署 token-bucket 与 breaker 阈值。  
3. 开启 cache affinity 分片与预热。  
4. 实施 spillover-policy-version 灰度与回滚。  
5. 周期复盘延迟、溢出率、成本、失败率。

**Good fit**：多模型高并发企业网关。  
**Not for**：缺乏实时可观测与自动回滚能力团队。
