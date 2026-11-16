# Cycle 2417 深度专论：MCP/Agent 供应链签名与准入防护

## A. 目标与边界
- 场景：第三方 MCP server、LoRA 适配器、容器镜像持续接入。
- 目标：保障来源可信、部署可控、运行可追踪。

## B. 核心约束
1. 未签名或 provenance 缺失工件不得进入集群。
2. 高危 CVE 必须在准入阶段阻断。
3. 补丁后必须重签名并重新准入验证。

## C. 指标摘要
- 篡改/未签名阻断率：99.5%
- 准入额外延迟 P95：96ms
- Copa 补丁耗时：22min
- 供应链守门通过率：98.2%

## D. 选型权衡
- L2（Ratify+Gatekeeper）是多数生产系统拐点。
- L3 在高监管环境更稳健，但运营复杂度更高。
- 动态未 pin 拉包需强制淘汰。

## E. 五步落地
1. 统一 digest pin 与签名策略。
2. 发布 SBOM/AI-BOM 并绑定 OCI referrers。
3. 部署 Ratify + Gatekeeper 准入策略。
4. 引入 Copa 快速补丁与重签名流水线。
5. 建立 Defender 漂移告警与隔离回滚剧本。

## F. 证据与标签
详见 `evidence/cycle-2417-sources.json` 与 `evidence/cycle-2417-benchmark.json`，标签为 `measured/synthetic/anonymized_reported`。
