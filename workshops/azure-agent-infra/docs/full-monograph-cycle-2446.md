# Cycle #2446 专著增补（OBO Token Vault 与 HSM Envelope 轮换）

- Cycle：2446  
- Window (BJT)：2026-11-16 23:00 ~ 2026-11-17 05:15  
- Topic：企业 Agent 的 OBO 令牌治理、密钥轮换与租户追溯闭环  
- Exclusion：不含半导体/ALD 题材

## Chapter 462 · OBO 令牌失控的真实根因

在多 Agent DAG 中，最容易被忽略的是“令牌复制链路”而非模型调用本身：
1. Planner 把 bearer token 透传给 Worker。  
2. Worker 再透传给 Tool adapter。  
3. 日志/重试队列意外持久化 token 明文。  

因此，治理核心不是“加密一个变量”，而是把明文令牌从运行链路中消除，只允许引用（token_ref）流动。

## Chapter 463 · 双版本 HSM Envelope 轮换机制

### 轮换状态机

1. **Prepare**：创建 `key_vN+1`，Vault 开始支持双读。  
2. **Shift-Write**：新写入全部改为 `key_vN+1`。  
3. **Reencrypt**：后台重加密旧密文。  
4. **Retire**：确认覆盖率达标后停用 `key_vN`。

### 关键约束

`exposure_window = token_ttl + cache_ttl + retry_backoff_max`

若 exposure_window 超阈值，必须强制缩短 token TTL 或禁止跨 hop 缓存。

## Chapter 464 · 失效模式与防线

| 失效模式 | 表现 | 防线 |
|---|---|---|
| 明文泄漏 | 审计日志出现 raw token | token_ref-only + 日志脱敏 |
| 轮换中断 | 新旧密钥读取冲突 | 双读窗口 + 幂等重加密任务 |
| 租户串扰 | A 租户 token 访问 B 工具 | tenant-scoped token namespace + policy gate |
| 吊销不生效 | revoke 后仍可调用 | token introspection cache TTL 收敛 |

## Chapter 465 · 证据包与审计绑定

- Benchmark contract: `evidence/cycle-2446-benchmark.json`
- Latency: `evidence/cycle-2446-latency.csv`
- Throughput: `evidence/cycle-2446-throughput.csv`
- Policy: `evidence/cycle-2446-policy.csv`
- Cost: `evidence/cycle-2446-cost.csv`

审计主键建议：`tenant_id`, `token_ref`, `key_version`, `policy_version`, `request_id`。

## Summary 918

Round 1041 的核心增量是把“身份与密钥治理”从通用安全建议，落地为可执行状态机和可观测约束。  
对企业级 Agent 平台而言，OBO + Vault + HSM 轮换闭环是规模化上线的硬门槛，而不是上线后的补丁项。
