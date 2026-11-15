# Cycle 2413 深度专论：医疗临床 FHIR 与多模态 Agent 基础设施

## A. 场景边界与目标
- 场景：肿瘤会诊、先审后付、临床文书与影像联合分析。
- 目标：在 HIPAA/HITRUST/FDA SaMD 约束下实现可审计、可回放、可签署的多 Agent 工作流。

## B. 关键架构约束
1. PHI 必须在模型侧之前完成脱敏。
2. FHIR 写回必须遵循资源版本一致性（If-Match/versionId）。
3. CITL 签署是 EHR 写回硬门禁，不得绕过。

## C. 关键指标
- PHI 脱敏精度：97.2%
- FHIR 归因准确率：95.8%
- 未授权回写拦截率：99.7%
- 会诊链路延迟 P95：1.86s（高监管企业层）

## D. 成本与治理权衡
- 研究试点层成本最低，但拦截与归因能力较弱。
- 医院网络层在成本和合规间平衡。
- 高监管企业层最适合跨区域高风险临床生产。

## E. 生产落地五步
1. 统一 SMART-on-FHIR OBO 权限与作用域审计。
2. 在 AHDS 网关侧固化 PHI 脱敏策略。
3. 部署多 Agent 协作与冲突回退路径。
4. 强制启用 CITL 加密签署与不可抵赖日志。
5. 运行周度故障演练（冲突、拒签、写回阻断）。

## F. 证据与标签
详见 `evidence/cycle-2413-sources.json` 与 `evidence/cycle-2413-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
