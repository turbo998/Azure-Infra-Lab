# Cycle 2418 深度专论：IDP Golden Paths 与 Agent Vending

## A. 目标与边界
- 场景：Platform CoE 支撑 50+ AI 业务团队并行交付。
- 目标：把 Foundry/APIM/Entra 与安全基线的开通标准化到分钟级。

## B. 核心约束
1. 所有环境必须通过 Policy-as-Code 守门。
2. 零公网端点、Content Safety、FinOps 标签为强制项。
3. 沙箱环境必须可回收，避免成本失控。

## C. 指标摘要
- 30 分钟内合规开通率：96.4%
- 非合规策略阻断率：98.7%
- 平台杠杆：26 squads/engineer
- 孤儿沙箱 TTL 节省：82.4%

## D. 选型权衡
- Ticket 驱动不适合高并发业务团队。
- 模块化是过渡形态，最终应走向自助 vending。
- Guardrail 应内建在模板与门禁，而不是事后补救。

## E. 五步落地
1. 固化 AVM + azd 模板与版本策略。
2. 对接 ADE + Dev Box 的环境供应链。
3. 自助开通 Foundry/APIM/Entra identity。
4. 启用 DINE/Deny 守门并落地 promotion gate。
5. 启动 TTL 回收和漂移修复的运营闭环。

## F. 证据与标签
详见 `evidence/cycle-2418-sources.json` 与 `evidence/cycle-2418-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
