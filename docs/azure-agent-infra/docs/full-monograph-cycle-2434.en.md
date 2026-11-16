# Cycle 2434 Monograph Addendum (OTel GenAI Multi-Agent Tracing)

- Cycle ID: 2434
- Window: 2026-11-16 23:00 ~ 2026-11-17 05:15
- Topic: opentelemetry-genai-distributed-tracing-flamegraph-adx-agent-infra-faq-r1029

## Chapter 572 · OTel GenAI + ADX RCA Production Baseline

This chapter formalizes a production observability baseline for asynchronous multi-agent systems on Azure:
1. **Context continuity**: enforce W3C `traceparent` and `baggage` propagation across APIM ingress, Service Bus fanout, Durable Task workers, and MCP boundaries.
2. **Semantic normalization**: standardize `gen_ai.agent.*`, `gen_ai.usage.*`, `gen_ai.tool.call.*`, and `gen_ai.evaluation.*` across planner/worker/tool spans.
3. **PII-safe debugability**: split structural spans from encrypted prompt/completion payload vault lanes with collector-level redaction policies.
4. **Deterministic RCA path**: use ADX KQL critical-path condensation + flamegraph analytics to isolate token-loop and fanout bottlenecks.
5. **Cost governance**: tail sampling policy preserves forensic evidence while reducing ingestion and query overhead.
