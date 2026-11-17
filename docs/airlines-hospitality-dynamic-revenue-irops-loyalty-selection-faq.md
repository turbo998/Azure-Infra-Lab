# ✈️ 航空、酒店与商旅集团“NDC 动态收益管理 (Offer/Order) + 航班不正常延误 (IROPS) 旅客安置 + 常旅客联名积分防欺诈与联合归因”架构选型指南（架构师速查版）

> **完整版深度选型指南与 7-Card 评测报告**：请参阅 [`../workshops/data-lab/comparisons/fabric-airlines-hospitality-dynamic-revenue-irops-loyalty-faq.md`](../workshops/data-lab/comparisons/fabric-airlines-hospitality-dynamic-revenue-irops-loyalty-faq.md)  
> **架构全景 SVG**：[`../workshops/data-lab/assets/svg/169-fabric-airlines-hospitality-dynamic-revenue-irops-loyalty-faq.svg`](../workshops/data-lab/assets/svg/169-fabric-airlines-hospitality-dynamic-revenue-irops-loyalty-faq.svg)  
> **English Version**: [`airlines-hospitality-dynamic-revenue-irops-loyalty-selection-faq.en.md`](airlines-hospitality-dynamic-revenue-irops-loyalty-selection-faq.en.md)

## 一句话选型结论

面向运营 **850 架客机 + 4,200 家酒店、1.1 亿常旅客会员、11,950 名收益/场站/客服人员、995K EPS NDC/ACARS/PMS 流与 `5.12 亿` (`512M = 2^9 \times 10^6`) 支付意愿及房态向量** 的航旅酒店集团，**Microsoft Fabric (`Eventhouse KQL + H3 + Activator` + `512M SSD DiskANN` + `FLAML/NL2DAX` + `Foundry IQ`)** 将端到端航班延误（IROPS）主动改签锁房、NDC 连续定价与积分反盗刷闭环从 `1,380–2,610ms` 压缩至 **`30ms` 整十闭环**，并将月度总 TCO 从 `$339,400/月` 降至 **`$14,400/月`（创纪录省 `95.8%`，月省 `$325.0K` 整十万美元大关！）**，守护 **`$55.45M`** 收益与服务 SLA。
