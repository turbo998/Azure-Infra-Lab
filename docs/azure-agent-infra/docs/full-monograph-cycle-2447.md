# Cycle #2447 专著增补（SBOM Attestation 供应链门禁）

- Cycle：2447  
- Window (BJT)：2026-11-16 23:00 ~ 2026-11-17 05:15  
- Topic：企业 Agent 运行前供应链可信门禁（SBOM + 签名证明 + 准入阻断）  
- Exclusion：不含半导体/ALD 题材

## Chapter 463 · 从“扫描报告”到“运行时门禁”

仅有构建时漏洞扫描并不能保证运行时安全：  
- 运行时依赖可能在镜像拉取后漂移。  
- 插件与连接器可能动态加载。  
- 租户差异化策略可能导致同一工件在不同租户风险等级不同。

因此需要把 SBOM/attestation 校验放到请求准入路径，而不是发布环节结束就视为完成。

## Chapter 464 · 准入策略与阈值设计

### 推荐阻断表达式

```text
block_if =
  (critical_vuln_count > 0)
  OR (attestation_missing = true)
  OR (sbom_drift_ratio > drift_threshold)
```

其中：
- `sbom_drift_ratio = changed_packages / total_packages`
- `drift_threshold` 建议按租户风险级别分层（如 0.5%、1.0%、2.0%）

## Chapter 465 · 失效模式与补救动作

| 失效模式 | 表现 | 主动作 | 补救 |
|---|---|---|---|
| 无证明工件放行 | 运行时才发现来源不可追溯 | APIM 硬阻断 | 触发紧急回滚 |
| 误拦截激增 | 发布窗口大量 4xx | 降级到只读策略 + 人工复核 | 调整 drift 阈值 |
| 证明链断裂 | digest 与签名映射不一致 | 停止发布批次 | 重新签名并重建索引 |

## Chapter 466 · 审计与业务指标联动

建议将安全指标和业务指标同看：
- `unauthorized_artifact_block_rate`
- `false_positive_block_rate`
- `mttr_for_vuln_patch`
- `p95_admission_latency`

避免“安全通过但交付不可用”或“交付顺畅但供应链裸奔”两种极端。

## Summary 925

Round 1042 的核心贡献是把供应链治理从静态文档要求，转化为可执行的运行时门禁机制。  
对于企业 Agent Infra，SBOM 与 attestation 不是审计附属物，而是进入生产流量前的硬条件。
