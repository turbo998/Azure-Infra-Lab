# Cycle 2415 深度专论：传统 ERP/SAP/主机混合集成 Agent 架构

## A. 业务目标
- 场景：订单、采购、库存、账务等核心记录在棕地系统中的 Agent 协同。
- 目标：在不破坏既有授权与审计体系前提下，实现可控自动化。

## B. 关键架构约束
1. 共享服务账号写核心数据属于高风险反模式。
2. 所有写路径必须先 TESTRUN 干跑再进入 commit。
3. 连接池保护必须前置在网关与编排层。

## C. 指标摘要
- 主体透传审计覆盖率：98.8%
- TESTRUN 预检拦截率：95.2%
- 连接池保护成功率：96.1%
- Logic Apps 主路径可靠率：99.1%

## D. 选型权衡
- Direct RFC 延迟更低，但治理复杂度更高。
- Logic Apps 最适合多系统混合集成主路径。
- RPA 仅用于尾部无 API 系统，不可替代主路径。

## E. 五步落地
1. API 资产治理与 MCP 门面契约化。
2. Entra 到 SAP 用户主体透传配置。
3. BAPI TESTRUN 干跑与审批门禁实施。
4. 连接池限流、熔断与降级策略联动。
5. 监管抽检回放与故障演练常态化。

## F. 证据与标签
详见 `evidence/cycle-2415-sources.json` 与 `evidence/cycle-2415-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
