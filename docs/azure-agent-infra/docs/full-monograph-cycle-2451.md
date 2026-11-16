# Cycle #2451 制造业专著增补：ISA-95 零信任 OT Agent Bridge（zh-CN）

- Round/Cycle: `1046 / 2451`
- 日期：`2026-11-16 (BJT)`
- 主题：`manufacturing-ot-agent-isa95-zero-trust-bridge-faq-r1046`
- 数据标签：`measured / synthetic / anonymized_reported`

## Chapter 460 · 今日突破与生产含义

当日热点采用官方/发布源优先：

1. **APIM AI Gateway + Unified Model API**  
   - Learn: <https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview>  
   - Changelog: <https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md>
2. **ACA Dynamic Sessions**  
   - Docs: <https://learn.microsoft.com/en-us/azure/container-apps/sessions>
3. **Sandbox 上游发布节奏**  
   - Firecracker/Kata/Wasmtime/E2B release 流（见 `evidence/cycle-2451-sources.json`）

对制造业 Agent 基础设施的直接影响是：  
网关策略与会话沙箱不再是“外围组件”，而是 IT/OT 融合架构的主控制面。

## Chapter 461 · 分层解耦参考架构（ISA-95 + Zero Trust）

### 1. 控制面分层

- **L4/L5（Enterprise/Business）**：计划、工单、质量策略与运营 KPI。  
- **L3（MES/Manufacturing Ops）**：工序、排产、质量追溯。  
- **L2/L1（SCADA/PLC）**：设备状态与控制命令。  

Agent 运行在 L4/L5-L3 侧，所有写命令必须经由零信任桥接层，不允许直穿 L2/L1。

### 2. 网关准入契约

每次工具调用至少携带：
- `zone_level`
- `asset_scope`
- `command_class`
- `approval_state`
- `policy_version`

若任一字段缺失或与当前策略不一致，按 `ot-bridge-policy-violation` 直接阻断并记审计。

### 3. 生产流量路径

1. Agent 经 APIM 发起读/写意图。  
2. ISA-95 策略门完成 zone 级准入与写命令类型检查。  
3. Zero-trust bridge 仅对允许命令进行协议映射和下发。  
4. 全量 allow/block 事件回流 ADX，形成可追溯审计时间线。

## Chapter 462 · 定量结果（来自本轮可复现实验）

基于 `evidence/cycle-2451-*.csv/json`：

- **冷启动/恢复**  
  - E2B Firecracker：P50 `118ms` / P95 `211ms`（`anonymized_reported`）  
  - ACA Session warm pool：P50 `257ms` / P95 `398ms`（`anonymized_reported`）  
  - AKS + Kata Pod VM 冷启：P50 `920ms` / P95 `1420ms`（`anonymized_reported`）
- **吞吐路径**  
  - APIM unified model routing：P50 `1372 rps` / P95 `1178 rps`（`synthetic`）  
  - MCP tool orchestration：P50 `484 rps` / P95 `422 rps`（`synthetic`）
- **策略阻断**（`measured`）  
  - `ot-bridge-policy-violation saturation gate`: `172/184 = 93.48%`  
  - `isa95-zone-fence integrity guard`: `161/168 = 95.83%`
- **单会话成本**（20 分钟）  
  - E2B：`$0.00552/session`（`synthetic`）  
  - AKS Kata：`$0.01044/session`（`synthetic`）  
  - ACA Sessions：`$0.01100/session`（`synthetic`）

## Chapter 463 · 失效模式与调优手册

### 失效模式 A：策略版本漂移

表现：控制面与桥接层 `policy_version` 不一致，导致写命令误放行或误阻断。  
处置：将 `policy_version` 作为强约束字段，灰度发布期间执行双写比对并设置自动回滚阈值。

### 失效模式 B：高峰告警导致写命令风暴

表现：单分钟大量重试触发桥接拥塞。  
处置：对高风险 `command_class` 启用队列令牌桶 + 幂等 key + 优先级队列，保证安全命令先行。

### 失效模式 C：跨区网络抖动带来的超时重放

表现：调用超时后被上层误判失败并重试，造成重复写命令。  
处置：桥接层强制幂等窗口 + 结果缓存回填，阻断重复执行。

## Chapter 464 · 竞对对比与选型结论

| 平台路径 | 隔离边界 | 冷启动 | 成本 | 运维复杂度 | 适配制造 OT |
|---|---|---:|---:|---:|---|
| Azure APIM + ACA + OT Bridge | 策略 + 会话 + 审计一体 | 中 | 中 | 中 | **高** |
| AWS AgentCore + Firecracker | 运行时隔离强 | 中低 | 中 | 中高 | 中高 |
| GCP Agent Engine + Cloud Run | 托管度高 | 中 | 中 | 中 | 中 |
| E2B/Modal/Cloudflare Sandbox | 启动快、灵活 | 低 | 低-中 | 中 | 中（需自建治理） |

结论：制造业场景优先“策略审计先行”的 Azure 控制面组合，避免“快但不可审计”的直连捷径。

## Chapter 465 · 五步落地（Good fit vs Not for）

1. 建 ISA-95 资产与 zone 台账。  
2. 定义命令类别与审批策略（写命令默认 deny）。  
3. 在 APIM 与桥接层同时落地 policy gate。  
4. 接入 ADX 审计看板，设 block-rate 与误阻断 SLO。  
5. 每周运行回放测试，校验策略升级不会破坏产线。

**Good fit**：需要 IT/OT 协同且合规可追溯的制造企业。  
**Not for**：无法承接审批流与审计运营的轻治理团队。
