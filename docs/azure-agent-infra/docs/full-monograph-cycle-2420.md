# Cycle 2420 深度专论：跨组织 A2A 联邦与外部 Agent 网关

## A. 目标与边界
- 场景：OEM、供应商、渠道商、服务商之间的 Agent 协作。
- 目标：构建可发现、可协作、可审计、可问责的跨企业 Agent 交互体系。

## B. 核心约束
1. 外部伙伴输入默认不可信，必须隔离与扫描。
2. 跨租户调用必须身份可证与限流隔离。
3. 报价/订单等关键工件必须具备不可抵赖证据链。

## C. 指标摘要
- 跨组织注入阻断率：96.7%
- 异步 A2A 完成可靠性：98.1%
- DLP 出站泄露防护率：97.2%

## D. 选型权衡
- 内部 MCP 适合内网工具编排，不适合外部伙伴直连。
- REST/EDI 稳定但灵活性不足，A2A 更适合复杂协作任务。
- A2A 联邦引入更高治理复杂度，但带来业务协同与审计收益。

## E. 五步落地
1. 建立 agent card 目录与能力版本治理。
2. APIM DMZ 落地 mTLS + 跨租户 token exchange。
3. 外部输入统一进入隔离与 prompt shield 流水线。
4. 引入 Purview DLP 出站策略与审计回放。
5. 交易工件签名与法务证据映射自动归档。

## F. 证据与标签
详见 `evidence/cycle-2420-sources.json` 与 `evidence/cycle-2420-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
