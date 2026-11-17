# Round 1123 · Cycle 2528  
## Global Standard vs DataZone vs Regional PTU：企业多区域韧性、BCDR 与数据驻留选型 FAQ

## 1) 执行摘要（给架构委员会的结论）
- 若目标是**全球弹性配额与最小容量规划摩擦**，优先 Global Standard / Global Provisioned（PTU），但必须同时设计状态层多区域。
- 若目标是**地理处理边界合规（EU/US）**，优先 DataZone Standard / DataZone Provisioned，辅以区域化日志与审计分区。
- 若目标是**强可控 99.99% 多活与可验证切换**，优先“Regional PTU 多活 + APIM + Cosmos DB 多写 + AI Search 跨区副本”。
- 若目标是**受监管行业降本容灾**，优先“Regional PTU 主站 + PAYGO 温备”，并将演练节奏产品化。

## 2) 适用范围与边界
- 仅覆盖企业级 Agent 平台：LLM 推理层、工具调用层、会话状态层、检索层、治理层。
- 不覆盖内核/驱动/NIC/RDMA 等底层硬件调优话题。
- 关注对象：CIO/CTO、平台架构师、合规与风险团队、FinOps 团队。

## 3) 决策前提与经典误区
- 经典误区：仅对 LLM 端点做跨区故障转移，但把 Cosmos DB 或 AI Search 留在单区，导致“模型可用、业务不可用”。
- 正确做法：把故障域定义为“端到端事务路径”，包含 APIM 路由、会话状态、检索索引、审计日志与审批队列。
- 合规前提：跨法域业务必须先确定“处理驻留边界”再谈吞吐扩展。

## 4) 当日热点与可验证来源（抓取时间：2026-11-18 UTC）
1. Azure API Management AI Gateway 概览与统一模型入口（official）  
   来源：https://learn.microsoft.com/en-us/azure/api-management/ai-gateway-overview  
2. APIM 服务演进变更记录（official release/changelog）  
   来源：https://github.com/Azure/API-Management/blob/main/changelogs/api-management-service.md  
3. Azure Container Apps Dynamic Sessions（official）  
   来源：https://learn.microsoft.com/en-us/azure/container-apps/sessions  
4. Dynamic Sessions GA 公告（official blog）  
   来源：https://techcommunity.microsoft.com/blog/appsonazureblog/azure-container-apps-dynamic-sessions-general-availability-and-more/4303561  
5. Firecracker / Kata / Wasmtime / E2B 上游发布（official releases）  
   - https://github.com/firecracker-microvm/firecracker/releases  
   - https://github.com/kata-containers/kata-containers/releases  
   - https://github.com/bytecodealliance/wasmtime/releases  
   - https://github.com/e2b-dev/e2b/releases  

## 5) 四种方案定义（对齐企业语义）
- **A. Global Standard / Global Provisioned（PTU）**：以全局弹性和统一入口为先，弱化区域显式控制。
- **B. DataZone Standard / DataZone Provisioned**：以地理处理边界为先，面向 EU/US 数据主权诉求。
- **C. Regional PTU Active-Active**：多区域对等承载，APIM 健康探测与断路路由，状态层同步设计。
- **D. Regional PTU Active-Passive + PAYGO Warm Standby**：主站稳定吞吐，备站温热兜底，优先成本弹性比。

## 6) 12 维度选型矩阵（核心对比）
| 维度 | A Global | B DataZone | C Regional 多活 | D 主备温备 |
|---|---|---|---|---|
| 1. 推理数据驻留边界 | 弹性优先，边界可见性中 | EU/US 边界明确 | 区域显式可控最高 | 主区严格、备区策略可控 |
| 2. 静态数据驻留（存储） | 需额外架构约束 | 与 DataZone 一致性更好 | 由每区存储策略决定 | 主区强，备区按法规裁剪 |
| 3. TPM 突发与模型可得性 | 全局池优势明显 | 地理池次优 | 取决于每区 PTU 配额 | 主区强、备区受 PAYGO 上限 |
| 4. P99 延迟确定性 | 跨区路径可能抖动 | 区域内更稳 | 最佳（就近 + 区域兜底） | 主区稳，切换期抖动 |
| 5. 区域故障 RTO/RPO | 低 RTO，RPO 依赖状态层 | 低 RTO，RPO 依赖状态层 | 可做到低 RTO/低 RPO | RTO 中等、RPO 取决复制策略 |
| 6. 会话/索引故障切换 | 需额外设计 | 需额外设计 | 方案内原生考虑 | 依赖演练与回切手册 |
| 7. APIM 断路与 TTFT 路由 | 推荐 | 推荐 | 强依赖（核心能力） | 强依赖（切换阀门） |
| 8. PTU 成本乘数 | 低到中 | 中 | 高（多区常驻） | 中到低 |
| 9. 合规适配（GDPR/FINMA） | 中 | 高（EU/US） | 高（可细粒度） | 高（可主权隔离） |
| 10. 演练复杂度 | 中 | 中 | 高 | 中 |
| 11. 最佳工作负载 | 全球泛化助手 | 地理主权业务 | 7x24 高价值交易 | 受监管成本敏感业务 |
| 12. 不适用反模式 | 需严格驻留审计场景 | 需全球统一最低成本场景 | 预算/团队不足组织 | 不能接受切换窗口的极致实时业务 |

## 7) 行业架构 A：欧洲私人银行双法域投顾 Agent
### 场景目标
- 瑞士客户：严格驻留 `Switzerland North`，本地 CMK、本地审计。
- EEA 客户：走 `DataZone EU`，满足 GDPR 地理处理边界。

### 端到端参考架构（双法域）
1. Front Door + APIM（按客户法域与合同标签路由）。
2. 瑞士流量：Regional PTU（CH）+ 瑞士本地 Key Vault CMK + 区域化日志工作区。
3. EEA 流量：DataZone EU 模型池 + EU 区域存储/检索。
4. Purview + 审计总线：输出“可验证驻留报告”，禁止跨法域提示词/遥测泄漏。

### 关键控制点
- APIM policy：按 `client_jurisdiction` 强制路由。
- DLP：阻断跨域数据复制与跨区调试导出。
- 证据：驻留审计报表按月签名归档。

## 8) 行业架构 B：全球跨境支付反欺诈与拒付处置多活 Agent
### 场景目标
- US/EU/APAC 三地 7x24 多活，SLA 99.99%。
- TTFT 超阈值（>2.5s）或 429/503 自动转移。

### 端到端参考架构（全球多活）
1. Azure Front Door（地理就近接入）。
2. 三地 APIM Gateway（熔断、限流、健康探测、TTFT 采样）。
3. 区域 PTU 对等承载 + PAYGO 突发吸收。
4. Cosmos DB 多写冲突解析 + AI Search 跨区索引同步。
5. Chaos Studio 月度区域中断演练并输出回归报告。

### 关键控制点
- 交易链路与模型链路统一回放 ID（便于稽核）。
- 拒付争议处理要求“解释 + 证据引用 + 审计可重放”。

## 9) APIM 路由与断路策略建议
- 主策略：优先同法域同区域模型部署。
- 降级策略：同法域次优区域 > 同主权边界共享池 > 人工兜底。
- 禁止策略：未经批准跨法域回落。
- 探测指标：TTFT、429/503 比率、P99、队列深度、策略拦截率。

## 10) 状态层与检索层的多区域一致性设计
- Cosmos DB：账户级多区域写入，冲突采用“业务优先字段 + 向量时钟”。
- AI Search：主从索引复制，故障期允许只读降级并标注结果新鲜度。
- Thread State：将 Agent 会话快照与工具执行日志分离存储，降低回放耦合。

## 11) 基准口径（measured / synthetic / anonymized_reported）
- 冷启动/热恢复：`P50/P95`（ms），按区域分组。
- 并发吞吐：按“路由链路 + 状态写入 + 检索查询”分项统计。
- 策略拦截率：违规请求拦截比例（含跨法域与越权访问）。
- 单会话成本：按 PTU 预留摊销 + 网关 + 状态层 + 观测成本计。
- 标签要求：每个数值必须附 `source_label` 与 `source_ref`。

## 12) 1M 调用 TCO 经验模型（用于财务评审）
- A Global：容量利用率高但需补齐合规模块成本。
- B DataZone：合规收益高，容量利用率受地理池限制。
- C Regional 多活：可用性最好但成本乘数最高。
- D 主备温备：成本友好，需用演练降低切换损耗。

## 13) 五步落地路线（Good fit vs Not for）
1. 先做法域与业务分层：定义不可跨越的数据边界。  
2. 再做端到端故障域建模：把模型/状态/检索一起设计。  
3. 建立 APIM 策略包：TTFT、错误码、合规标签联动路由。  
4. 以演练驱动上线：每月区域故障演练 + 回归评分。  
5. 引入 FinOps 看板：每 1M 调用成本与可用性并列治理。  

**Good fit**：跨区域业务且受监管的金融、支付、医药与公共部门。  
**Not for**：单区域、低关键性、无合规压力且预算极紧的轻量 PoC。

## 14) 交付清单（本轮）
- FAQ：本文件与英文镜像（15 节）。
- SVG：`assets/42-cycle-2528-daily-breakthroughs.svg`。
- H5：`workbench-cycle-2528.html` + selector 新入口 `#2528`。
- 7-card：`benchmark-cards.html` 与 `benchmark-cards.en.html`（4:5，CSP 自包含）。
- 证据：`evidence/cycle-2528-*.{json,csv}`。

## 15) 运行与验收口令
```bash
python workshops/azure-agent-infra/simulator/cycle_1123_pipeline.py --write
python workshops/azure-agent-infra/simulator/cycle_1123_pipeline.py --check
pytest workshops/azure-agent-infra/simulator -q
```
- 验收要求：`sections 1..15`、`max_suffix_repeat == 1`、workshops/docs 字节一致、测试全绿。
