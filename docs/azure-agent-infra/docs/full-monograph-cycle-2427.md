# Cycle 2427 深度专论：地理观测与天气韧性物流 Agent 基础设施

## A. 目标与边界
- 场景：灾损理赔分拣、管线/电网走廊巡检、天气扰动下物流路由。
- 目标：在 PB 级影像数据下提升空间判定精度并控制带宽与时延成本。

## B. 核心约束
1. 空间关系判断必须落到 PostGIS/H3 确定性执行层。
2. 栅格读取默认窗口化，禁止无界整景下载。
3. 路由重算必须使用可复现求解器并保留约束证据。

## C. 指标摘要
- COG range-read 出口流量节省：89.4%
- PostGIS+H3 空间精度：97.9%
- 理赔分拣时效提升：58.6%
- 路线 SLA 保持率：96.1%

## D. 选型权衡
- PostGIS 在事务型空间判定中精度和可控性最好。
- ADX 更适合超大规模时序地理告警分析。
- Sedona 适用于离线批处理与大规模回溯计算。

## E. 五步落地
1. 统一 STAC 元数据规范与 tile window 策略。
2. 构建 PostGIS + H3 空间索引与查询模板。
3. 将 GeoFM 检测输出标准化为可连接的空间对象。
4. 融合 Aurora 风险图层并触发 OR-Tools 重路由。
5. 建立理赔与调度输出的证据链追踪机制。

## F. 证据与标签
详见 `evidence/cycle-2427-sources.json` 与 `evidence/cycle-2427-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
