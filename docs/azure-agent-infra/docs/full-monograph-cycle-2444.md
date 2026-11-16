# Cycle #2444 专著增补（AKS Kata Pod-VM & eBPF 密度护栏）

- Cycle：2444  
- Window (BJT)：2026-11-16 23:00 ~ 2026-11-17 05:15  
- Topic：AKS Kata Pod-VM 高密度沙箱 + eBPF 退化监测 + APIM 准入联动  
- Exclusion：不含半导体/ALD 题材

## Chapter 460 · 密度模型从“经验值”升级为可复算方程

### 1) 节点容量方程（SKU 级）

对于 AKS Kata 节点，密度上限按以下模型估算：

```text
effective_mem = node_mem - kube_reserved - system_reserved - safety_headroom
per_podvm   = app_request + kata_vm_fixed + io_cache
max_density = floor(effective_mem / per_podvm)
target_density = max_density * utilization_guard
```

在 D32ds_v5（128GiB）示例中：
- kube/system 预留：14GiB
- safety_headroom：10GiB（碎片化、回收延迟、突发缓存）
- effective_mem：104GiB
- per_podvm：1.30GiB（0.75 app + 0.35 Kata 固定 + 0.20 cache）
- 理论上限：80
- 生产目标（guard=0.72）：57

这说明“理论上可塞 80”与“生产稳定可运行 57”之间存在显著安全差，必须显式建模。

### 2) 典型失效模式（Failure Modes）

1. **Page cache surge**：日志/对象下载突增导致 cache 吃满，Pod-VM reclaim 抖动放大。  
2. **Conntrack explosion**：短连接突刺导致连接跟踪表膨胀，SYN/ACK 重传率上升。  
3. **Cgroup reclaim lag**：内存回收滞后，表现为“free memory 仍在但延迟雪崩”。  
4. **Burst admission mismatch**：网关突发准入与节点真实回收能力不匹配，触发级联排队。

## Chapter 461 · eBPF 护栏与 APIM 准入闭环

### eBPF 观测三元组

- `skb_drop_reason`（丢包原因分布）
- `tcp_retrans`（重传率）
- `dns_lookup_latency`（服务发现抖动）

将三元组写入 ADX 后，计算 `density_guard_state`：
- `green`：继续准入
- `amber`：缩减 burst quota
- `red`：仅高优先级租户与关键工具调用

APIM policy 读取 guard state 后执行准入分层，实现“网络退化 -> 准入收敛 -> 负载回稳”自动闭环。

## Chapter 462 · 调优优先级与收益排序

| 调优动作 | 对延迟收益 | 对吞吐影响 | 对成本影响 | 推荐顺序 |
|---|---:|---:|---:|---|
| 降低单 Pod 配额 | 高 | 中负向 | 低 | 1 |
| 开启 eBPF 自适应限流 | 高 | 低负向 | 低 | 2 |
| 增加 warm pool | 中 | 正向 | 中正向 | 3 |
| 扩节点池 | 中 | 高正向 | 高正向 | 4 |

结论：优先做**准入/配额层优化**，再做容量扩张，避免“靠扩容掩盖治理缺失”。

## Chapter 463 · 与证据包的绑定关系

- Benchmark contract: `evidence/cycle-2444-benchmark.json`
- Latency: `evidence/cycle-2444-latency.csv`
- Throughput: `evidence/cycle-2444-throughput.csv`
- Policy intercept: `evidence/cycle-2444-policy.csv`
- Cost: `evidence/cycle-2444-cost.csv`

所有指标保持 `measured` / `synthetic` / `anonymized_reported` 标签，不使用未标注数据。

## Summary 903

Round 1039 的修正要点不是“换一个模板标题”，而是把 AKS Kata 沙箱密度问题落到可计算公式、可观测失效模式与可执行调优序列。  
在生产里，**密度护栏是治理问题，不是纯扩容问题**：只有把 eBPF 信号接入 APIM 准入，才能同时守住隔离、延迟与成本。
