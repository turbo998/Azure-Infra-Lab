# Cycle 2414 深度专论：资本市场 MNPI/WORM 与量化 Agent 基础设施

## A. 业务边界与目标
- 场景：卖方研究、买方组合研究、承销与风控协同。
- 目标：在 MNPI 隔离、确定性数值复核、监管留痕三重约束下实现可发布 Agent 研究流。

## B. 关键约束
1. 跨 Desk/Deal-Room 数据检索必须默认拒绝并可追溯。
2. 关键财务结论必须由确定性 Python 复算签名。
3. 发布前证据必须进入 WORM + 账本锚定。

## C. 核心指标
- MNPI 跨 Desk 泄漏阻断率：99.6%
- 确定性量化精确率：99.4%
- 财报入湖到信号延迟 P95：0.86s
- WORM/账本校验成功率：99.2%

## D. 成本与治理权衡
- 卖方层成本较低，适合覆盖类研究。
- 买方量化层平衡延迟和精确度。
- 高监管层最适合关键机构发布链路。

## E. 五步落地
1. 设计 Desk/Deal-Room 身份与检索边界。
2. 接入确定性 Python 复算沙盒与签名链路。
3. 建立 Event Hubs + ADX 低抖动信号通道。
4. 启用 WORM legal hold 与保留策略锁。
5. 每周执行监管抽样回放与证据完整性演练。

## F. 证据与标签
详见 `evidence/cycle-2414-sources.json` 与 `evidence/cycle-2414-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
