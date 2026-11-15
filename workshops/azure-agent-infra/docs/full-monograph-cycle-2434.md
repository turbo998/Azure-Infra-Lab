# Cycle 2434 专著增补（OTel GenAI 多 Agent 追踪）

- Cycle 编号：2434
- 时间窗口：2026-11-16 23:00 ~ 2026-11-17 05:15
- 主题：opentelemetry-genai-distributed-tracing-flamegraph-adx-agent-infra-faq-r1029

## Chapter 572 · OTel GenAI + ADX 根因分析生产基线

本章将 Azure 异步多 Agent 系统可观测性收敛为可执行基线：
1. **上下文连续性**：在 APIM、Service Bus、Durable Task、MCP 全边界强制透传 W3C `traceparent`/`baggage`。
2. **语义标准化**：统一 `gen_ai.agent.*`、`gen_ai.usage.*`、`gen_ai.tool.call.*`、`gen_ai.evaluation.*` 字段。
3. **零泄漏排障**：Collector 先脱敏，结构化 span 与加密 payload 分层存储，默认不暴露敏感内容。
4. **确定性 RCA 链路**：通过 ADX KQL 关键路径压缩与 flamegraph 分析定位 fanout 与 token-loop 退化点。
5. **成本治理闭环**：tail sampling 在保留异常全量证据的前提下压降采集与查询开销。
