# Cycle 2430 专著：SOC 分级分流、威胁狩猎与 SOAR 处置 Agent 基础设施

## A. 目标与范围
- 范围：企业 SOC T1/T2 流程、隔离沙箱分析、可控自动化处置。
- 目标：降低告警疲劳、加速调查闭环、避免 Crown-Jewel 资产误处置。

## B. 核心约束
1. 不可信日志必须先净化后入模推理。
2. 调查身份与处置身份必须分层隔离。
3. Crown-Jewel 资产处置动作必须通过分级审批门控。

## C. 指标快照
- 日志提示注入拦截率：97.4%
- Crown-Jewel 误处置预防率：98.2%
- 严重事件 MTTR 改善率：42.6%
- 单事件 SIEM/Token 成本下降率：31.8%

## D. 选型权衡
- Security Copilot OOB 适合快速见效。
- Foundry 自定义 Agent 适合深度编排与定制治理。
- 混合模式兼顾短期收益与长期可控性。

## E. 五步落地
1. 在告警入口部署不可信日志净化层。
2. 将调查与处置身份彻底分离并执行最小权限。
3. 对可疑工件先做隔离沙箱引爆再决策处置。
4. 在 SOAR 中引入 Crown-Jewel 分级审批门控。
5. 持续回放审计链，闭环处置正确率与成本指标。

## F. 证据与标签
参见 `evidence/cycle-2430-sources.json` 与 `evidence/cycle-2430-benchmark.json`，包含 `measured/synthetic/anonymized_reported` 标签。
