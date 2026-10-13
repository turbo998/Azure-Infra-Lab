# Azure Infra Lab

面向伙伴与技术团队的公开 Azure 基础设施 Workshop。当前内容聚焦 **Compute / Azure VM Modernization & FinOps**：从联合课程、六个模拟案例到浏览器本地评估与可分享报告。

Public Azure infrastructure workshops for partners and technical teams. The current lab covers **Compute / Azure VM Modernization & FinOps**, with a trilingual course, six synthetic cases, a browser-local calculator, and standalone reports.

**[立即体验 / Live Demo](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-vm-modernization/demo.html)** · **[课程 / Course](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-vm-modernization/workshop.html)** · **[计算器 / Calculator](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-vm-modernization/calculator.html)** · **[下载离线包 / Download ZIP](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-vm-modernization/Azure-VM-Partner-Workshop.zip)** · **[源码 / Source](workshops/azure-vm-modernization/source)**

## Azure VM 伙伴 Workshop / Partner Workshop

不是只有幻灯片：把生命周期与迁移讨论、用量与价格校验、候选约束和报告导出串成一个可离线使用的体验。

| 内容 / Experience | 能力 / Capabilities |
| --- | --- |
| 联合课程 / Course | 7 个模块、角色分工、互动案例、6 道测验、讲师模式与打印讲义 / Seven modules, role-based discussion, interactive cases, quizzes, presenter mode, and printable handouts |
| 同页三语 / Three languages | 简体中文、繁體中文、English 原地切换，保留课程进度、答案、数据与结果 / Switch languages on the same page without losing progress or results |
| 本地评估 / Local analysis | CSV/XLSX 导入、列映射、补充资料、校验、D/E 候选与约束分析 / Browser-local imports, mapping, enrichment, validation, and constrained candidate analysis |
| 教学案例 / Demo cases | 六个虚构案例与模拟价格，覆盖有条件缩容、RI/临时盘、EA 上限、排除项、HPC 和指标缺失 / Six synthetic cases, not customer records |
| 可分享输出 / Exports | 标准 CSV、建议明细、自包含 HTML 报告；通过浏览器打印保存 PDF / CSV exports, standalone HTML reports, and print-to-PDF |
| 离线使用 / Offline use | 解压后直接打开 HTML，无需服务器、登录、Azure 权限或联网 / Open the extracted HTML files without a server, sign-in, Azure permissions, or network access |

### 谁适合参加 / Role audiences

| 角色 / Role | Workshop 关注点 / Focus |
| --- | --- |
| Sales / 销售 | 识别现代化机会、澄清客户目标与商务假设 / Identify modernization opportunities and clarify business assumptions |
| Presales / 售前 | 核验适用范围、指标与价格依据，解释候选和约束 / Validate scope, metrics, pricing evidence, and candidate constraints |
| Service / 服务交付 | 制定验证、迁移与回退安排，交付可审查报告 / Plan validation, migration, rollback, and reviewable outputs |

## 三分钟 Demo 路线 / A short Demo journey

1. 打开 **[Demo](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-vm-modernization/demo.html)**，选择简体 / 繁體 / English，点击“开始自动演示” / “Start automatic demo”。
2. 自动载入六个模拟案例与价格并分析；依次观察 A 的有条件缩容、B 的 RI/临时盘、C 的 EA 上限、D 的排除项、E 的 HPC 专项与 F 的指标缺失。
3. 在结果页切换语言，展开候选和约束；切换“客户价格依据”模式可看到模拟价格被拒绝，而不是被当作合同净价。
4. 下载 HTML 报告并独立打开，或打印保存 PDF；需要动手练习时，使用 [三语样例](workshops/azure-vm-modernization/sample-data) 和 [CSV/XLSX 模板](workshops/azure-vm-modernization/templates)。

Start the Demo, inspect the six cases and their constraints, switch languages without resetting the analysis, then export a standalone report. Customer-pricing mode rejects synthetic demo prices.

## 实际界面 / Real screenshots

以下图片来自交付包的真实浏览器截图，使用虚构教学数据；不是设计稿或实测客户节省证明。

### Demo：从入口直接进入六案例分析

[![Simplified Chinese Demo page with language choices and the automatic six-case demonstration entry](workshops/azure-vm-modernization/screenshots/demo-zh-CN-desktop.png)](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-vm-modernization/demo.html)

*Demo entry: choose a language and launch the synthetic-case analysis.*

### Workshop：Sales / Presales / Service 联合课程

[![Workshop role cards describing the Sales, Presales, and Service audiences in Simplified Chinese](workshops/azure-vm-modernization/screenshots/workshop-zh-CN-roles.png)](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-vm-modernization/workshop.html)

*Role-based course: align commercial discovery, technical assessment, and delivery.*

### Calculator：结果、候选与约束一起看

[![Simplified Chinese calculator results for synthetic VM cases, showing analysis summaries and expandable recommendations](workshops/azure-vm-modernization/screenshots/calculator-zh-CN-results.png)](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-vm-modernization/calculator.html?demo=1&lang=zh-CN)

*Local calculator: inspect the evidence and constraints behind each recommendation.*

### Report：可独立打开与打印的报告

[![Standalone Simplified Chinese report summarizing synthetic VM analysis with anonymized identifiers and technical conclusions](workshops/azure-vm-modernization/screenshots/report-zh-CN-desktop.png)](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-vm-modernization/sample-data/zh-CN/live-demo-report.html)

*Standalone HTML report: review before sharing, or print to PDF.*

## 数据、价格与建议边界 / Important boundaries

**所有案例中的客户名称、价格和用量均为虚构教学数据，不是 Azure 官方报价，也不代表已实现的节省。** 原邮件材料涉及的具体涨幅、日期与商务处理规则仍是**未经充分公开佐证的培训情景，不是已确认的 Azure 政策**。客户评估应使用适用合同、购买安排和评估日期的有效价格依据。

**All names, prices, and usage in the examples are synthetic. Detailed price increases, dates, and commercial rules derived from the original mail remain unverified training scenarios, not confirmed Azure policy or official quotes.** Conditional compute-cost differences are not measured savings or total-bill savings.

CSV/XLSX 在浏览器本地解析，数据不上传、不默认写入 localStorage/IndexedDB，也没有保存客户数据的后端。刷新或关闭页面会丢失未导出的状态；外部资料仅在主动点击时联网。报告默认省略客户/VM 名称、资源/订阅标识、文件名与原始价格依据标题，但保留 SKU、区域等技术信息，外发前仍需审查。

Imported data stays in the browser and is not uploaded or persisted by default. Review reports before sharing. Missing prices, metrics, or commitment information remain unknown rather than being treated as zero; region/zone availability, quota, capacity, application performance, and rollback still require validation.

完整口径、容量限制、价格模式、RI/EA 约束与维护说明见 **[Workshop 使用说明 / Detailed guide](workshops/azure-vm-modernization/README.md)**。

## 离线包与源码 / Offline package and source

下载 [原始 ZIP](https://turbo998.github.io/Azure-Infra-Lab/workshops/azure-vm-modernization/Azure-VM-Partner-Workshop.zip)，解压后打开 `demo.html`、`workshop.html` 或 `calculator.html`，保留目录结构即可。运行交付页面不需要 Node.js；源码和维护命令位于 [source](workshops/azure-vm-modernization/source) 与 [使用说明](workshops/azure-vm-modernization/README.md)。

The public directory preserves all 256 original package files and the original ZIP unchanged. Its 37 PNG screenshots, language-specific samples, templates, HTML/PDF reports, source, and tests remain together.

ZIP SHA-256: `ba996b06697fcf0c926d9fdbf14ec67c5d76a2729cac291a2bd65648391332b5`

第三方声明与许可证原样保留：[THIRD_PARTY_NOTICES.txt](workshops/azure-vm-modernization/THIRD_PARTY_NOTICES.txt) · [third-party-licenses](workshops/azure-vm-modernization/third-party-licenses)。公开发布不新增或变更许可证。

Third-party notices and licenses are retained as supplied. Publication does not add or change a license.
