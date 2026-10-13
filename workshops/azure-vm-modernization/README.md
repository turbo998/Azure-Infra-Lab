# Azure VM 伙伴 Workshop 与本地评估工作台

## 打开与使用

解压后直接双击 `workshop.html` 或 `calculator.html`，使用较新的 Edge/Chrome 浏览器。两份页面均自包含，**不需要服务器、登录、联网或 Azure 权限**。保留这两个文件在同一目录，方便互相跳转。

## 同页三语、样例与 Demo

Workshop、计算器和 `demo.html` 都在页首提供 **简体 / 繁體 / English** 按钮，原地切换，不跳转到另一个语言页面，不清空客户数据、分析结果、已选答案或课程进度。界面、字段说明、校验提示、分析建议及导出报告使用当前语言；客户输入的名称、文件名、列名、价格依据和原始值不自动翻译。ARM 字段、SKU、地区码、日期、币种、购买方式枚举和计算结果保持一致。

语言只保留在当前页面 URL，不写浏览器存储；页内跨工具链接携带语言。HTML/CSV 报告按导出时的语言生成，脱敏口径不变。

- 双击 `demo.html`，选择语言，点击“开始自动演示”：自动载入六个模拟案例与价格并分析，无需手动导入。
- `sample-data\zh-CN\`、`sample-data\zh-TW\`、`sample-data\en\` 分别提供 CSV/XLSX 用量样例、CSV/XLSX 模拟价格、字段说明、独立示例报告和预期结果 JSON。
- 计算器也可直接下载当前语言的样例 CSV。样例均为虚构数据，`priceKind=demo`；客户价格模式会拒绝模拟金额。
- `screenshots\` 包含真实离线浏览器演示的三语桌面、手机、分析结果及报告截图；截图不是设计稿。

建议演示：案例 A 的有条件缩容 → B 的 RI/临时盘 → C 的 EA 上限 → D 的单公告排除 → E 的 HPC 专项 → F 的指标缺失。金额不是实际 Azure 报价。

- `workshop.html`：7 个模块、销售/售前/服务交付联合课程、互动案例、6 道测验、讲师模式及打印讲义。首章三个角色标题统一为 Sales role、Presales role、Service role，并同步简体/繁体标题。
- `calculator.html`：CSV/XLSX 本地导入、映射、补充、校验、规则分析、D/E 候选与报告。
- `templates\`：VM、价格 CSV/XLSX 模板与字段说明。
- `sample-data\`：6 个教学案例、模拟价格、手算核对用预期 JSON，以及可独立打开的教学示例报告。
- `source\`：TypeScript/React 源码、规则/目录、构建配置、测试与 lockfile。
- `third-party-licenses\` 和 `THIRD_PARTY_NOTICES.txt`：第三方许可。

### 快速体验

1. 打开 Workshop，按章节完成适用范围、计费与迁移讨论。
2. 打开计算器，点击“加载教学案例”，然后“分析配置与影响”。
3. 展开案例 A/F/B/C，分别观察完整指标、缺少内存/网络、RI+临时盘、EA 价格上限的差异。
4. 切换“客户价格依据”模式再分析：模拟价格会被拒绝，不会变成客户合同价。
5. 下载 HTML 报告，双击独立打开；通过“打印 / 保存 PDF”输出 PDF。

教学单价、客户名称和数据全部为模拟，**不是 Azure 实际报价**。

## 导入客户数据

建议从标准模板开始。最少必填：`id`、`sku`、`region`、`count`。

- 一行是一台 VM 或明确的同配置聚合组。逐台 `count=1`；聚合组必须有唯一标识。
- 原始账单多行不是多台 VM；请先按稳定资源标识、期间、SKU 和计费口径汇总。所有重复标识行都会被拒绝，不采用“保留第一行”的静默策略。
- 默认识别 ResourceId、VmSize、ResourceLocation、InstanceCount、CostInBillingCurrency 等常见列；可以手工修改列映射。
- 不把账单 `Quantity` 自动映射为实例数，也不把平均 CPU 当作 P95。
- 可选择包含数据记录的工作表；空表及仅有表头的表不参与分析。补充资料必须为单数据工作表，通过稳定标识关联；重复、冲突和无法关联都会报错。
- 单条记录可在页面中编辑；不会改写源文件。可下载补充后的标准 CSV。

### 关键字段口径

| 字段 | 口径 |
| --- | --- |
| `cloud` | Commercial / China / Government / Sovereign / Unknown；缺失则 Unknown，不自动默认为商业云 |
| `sku` | ARM 名称，如 Standard_D8s_v3、旧代际 Standard_DS3_v2；不能只填“D 系列” |
| `region` | ARM 区域码；可归一化 West Europe、EU West 等少量已知别名，未知区域不推断为无影响 |
| `hoursTotal` | 所有实例的实例小时总量；不能再乘 `count` |
| `hoursPerVM` | 每实例小时；与 `hoursTotal` 互斥 |
| `usageUnit` | 提供小时用量时明确填 `1 Hour`；不接受每核小时或未知计量单位 |
| `periodStart` / `periodEnd` | YYYY-MM-DD，开始包含、结束不包含；小时不得超过期间最大可能值 |
| `vcpus` / `memoryGiB` | 每实例源规格；已核验目录中存在的 SKU 若与手填规格冲突会报错 |
| `cpuP95` / `memoryP99` | 0–100 的百分比，不是 0–1 比例，也不是平均值；Excel 格式化百分比会转换 |
| `networkP95Mbps` | 发送网络 P95 的 Mbps，非 MB/s、流量总量或利用率百分比 |
| `peakCovered` | yes/no，确认观察窗覆盖实际业务峰值；未知不等于 no 或 yes |
| `tempGiB` | 每实例所需临时盘；明确不依赖填 0，留空未知 |
| `diskIOPS` / `diskMBps` | 远程磁盘所需 IOPS 与 MB/s；目录使用保守的非突发 Premium SSD 上限 |
| `architecture` / `specialRequirements` | x64；none 表示已确认无专项要求，认证/托管/特殊计算填 manual |
| `currentCost` | 源期间仅 VM 计算成本，不得混入磁盘、软件许可、网络或税费 |
| `currency` / `costBasis` | 三位币种码；Actual / Amortized，各组不混算也不自动换汇 |
| `currentRate` | PAYG/有效小时费率；RI 情景基准模式此列填 PAYG 基础费率 |
| `riRate` / `riCoverage` / `riEnd` | 已覆盖小时费率、0–100 覆盖比例、到期日；RI 基准情景只支持 Amortized 口径 |
| `residualCommitmentCost` | 迁移后同比较用量期间的剩余承诺成本，不是承诺总年费 |
| `eaCapRate` / `eaRenewal` | 源 SKU 的 EA PAYG 价格上限与 enrollment 续约日，不沿用给新 SKU |
| `priceKind` / `priceSource` | customer / retail / demo；来源/类型缺失时金额视为依据不足 |
| `rateBasis` | baseline（情景前基准）或 effective（已生效费率） |
| `rateFrom` / `rateTo` | 费率有效开始/结束，结束不包含；客户模式需有效开始日 |
| `priceIncludesUpdate` | 已含调整填 yes；客户有效价格必须明确 yes，不再次套涨幅 |
| `futureStorageCost` | 相同用量、评估日的客户存储成本；须有 effective/已含调整/有效日及来源依据 |

其他字段见 `templates\字段说明.csv`。yes/no、true/false、是/否可用于布尔字段；数值不含货币符号或千位符。

UTF-8 CSV、XLSX 在浏览器本地解析；XLS、加密工作簿、公式单元格不支持。Excel 公式请复制为值后导入，以免采用陈旧缓存。保护上限：压缩文件 20 MiB、每表 20,000 行/250 列、XLSX 解压后 100 MiB。不支持 ZIP64；不是无限容量工具。

## 两种价格模式

### 培训情景

依据用户提供的邮件材料，使用明确显示的价格情景和精确排除清单，计算旧代际约 25% 与七区域 8–17% 的影响。**尚未找到足够公开公告佐证这些具体日期、比例和完整商务处理规则**，因此不作为已公开确认的官方政策或客户报价。

v1/v2 情景与区域 VM 情景遵守排除关系，不叠加。指定 v7 排除仅限清单内的系列。存储父产品名不足以判断 Files Transaction-Optimized 或 ANF Cross Region Replication 时标为待核验。

### 客户价格依据

不用邮件涨幅，优先采用导入的、匹配评估日的价格快照。价格模板必须包含：

`sku, region, cloud, os, currency, purchase, unit, rate, from, to, basis, includesUpdate, source, kind`

`unit=1 Hour`，`basis=effective`，`includesUpdate=yes`。客户需要先把合同及实际购买安排归一化为**同计算范围/币种/口径的有效小时费率**。价格重叠时不自动任选；到期或购买方式不匹配时留空金额。

源 SKU 可从行内费率取值，目标 SKU 需要对应价格快照。目标计算比较采用 PAYG；不会自动将源 RI/SP 折扣继承给目标。跨系列覆盖和剩余承诺需单独核验，缺少同期间剩余承诺成本时不给可兑现差额。

Retail 类型可作零售参考，但会明确“非合同净价”。公开 Retail Prices API 仅提供商业云范围；非 USD 价格也属于预算参考，不能代替合同价。快照有来源与有效日期，需用户自行更新；离线页面不主动联网取价。

## 建议与金额边界

- 具体候选目录有 56 个经公开规格核验的 D/E Intel v5/v6/v7 SKU，覆盖 2–64 vCPU，含 v5 临时盘变体；不声称涵盖所有 Azure VM。
- 对邮件涉及的旧系列进行精确识别与风险提示。GPU/HPC/FPGA/B 系列特性、Arm、托管服务和认证设备不强行套 D/E 替代。
- 默认 30 天且覆盖业务峰值、CPU P95、内存 P99、网络、临时盘和磁盘/网卡约束齐全后，才投影缩容候选。阈值可调整；来源参考 Advisor，但不复刻其机器学习与采样。
- 指标缺失时保留不低于源 CPU/内存容量的候选或要求补数据，不生成“安全缩容”结论。CPU 投影不假设跨代加速百分比。
- 所有候选都标有区域/可用区、配额、实时容量、应用性能和回退验证；目录中有规格不等于客户可部署。
- v6/v7 缺少 Gen2/NVMe/MANA 前提时提示镜像平台升级，不能盲目原地 resize；v5 目标同样需核对加速网络与临时盘。
- **分析日期只选费率，源用量保持不变。** 报告是固定用量 run-rate 比较，不是跨价格生效日、RI 到期或 EA 续约的真实账单预测，也不输出伪精确的全年账单。
- “条件计算费差额”可能为负，且不是总账单节省。缺少目标价、承诺信息、币种或成本口径时不把未知填为零。
- 不同云/币种/Actual–Amortized 分组展示。总额只包含已知子集，附覆盖数量；不自动汇率转换。
- VM 计算与关联存储分别展示，不对所有存储统一涨价，不自动转换磁盘类型。

## 报告与隐私

HTML 报告是自包含文件，下载后可离线独立打开；浏览器打印即可保存 PDF。CSV 是建议明细，不是账单导入文件。

默认报告省略 VM/客户名称、资源/订阅标识、文件名与价格依据原始标题，使用 VM-001 等编号；SKU、区域、数量和技术结论仍然保留，外发前请审查。CSV 公式前缀会转义；HTML 中所有导入内容均转义，不作为代码执行。

数据不上传、不默认缓存到 localStorage/IndexedDB、不保存到后端。页面状态只在当前打开的页面中存在；刷新、关闭或清除会丢失未导出数据。两个页面不通过 URL 自动传递客户数据。官方资料链接仅在用户主动点击时联网。

本交付不包含原始邮件、内部客户清单、内部仪表板、Seismic、SharePoint 或回放链接。

## 维护与构建

资料核验版本：2026-10-12。公开来源链接、精确情景清单与 SKU 参数在 `source\src\data.ts`；分析逻辑在 `engine.ts`；字段/校验在 `model.ts` 与 `import.ts`。

Windows PowerShell，Node.js 20.19+ 或 22.12+：

```powershell
Set-Location '.\source'
npm ci
npm test
npm run build
npm run fixtures
npm run browser-test
npm run demo-test
```

构建将两份 HTML 发布到交付根目录。运行页面时无需 Node.js。浏览器验证默认使用已安装的 Edge，其他环境可设置 `BROWSER_EXE` 为浏览器完整路径。

公开生命周期/现代化信息与具体系列退役日期逐条使用 Microsoft Learn 来源。任何新定价通知应先核验适用产品、地区、云、协议、排除项和生效日，再更新规则及相应测试，不只修改页面文字。
