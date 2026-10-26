# 📺 EP01 · 程序造景实验室：不用一兆外部CDN贴图，如何在浏览器里用纯数学与Blender烘焙造出敦煌飞天、NASA火星与火箭发射？

> **英文标题 (English Title)**: *Zero External CDN Assets: Building Dunhuang Feitian, NASA Mars & Rocket Launch with Pure Math & Blender 4.5 MCP*  
> **关联仓库 (Repository)**: `turbo998/generative-visual-lab` (`main` 分支实时同步)  
> **视频规格 (Video Specs)**: 16:9 横屏深度版 (`1920×1080`, `168.6s`) + 9:16 竖屏精华版 (`1080×1920`, `65.3s`) · 30fps H.264 + 双语字幕 (`.srt`)

---

## 1. 节目定位与 B 站知识区视觉风格 (Production Style)

本期视频融合了 **回形针 PaperClip / 硬件茶谈 / 何同学 / 差评君** 的硬核技术科普叙事结构：
- **黄金 3 秒反直觉开场**：直击工程痛点与反常识实验现象；
- **顶部动态章节进度条**：4 幕结构化拆解，实时高亮当前推理/架构阶段；
- **左屏架构工作台 + 真实实验证据**：嵌入仓库真实渲染图、压测曲线、核心代码与数学公式；
- **右屏定量评测卡片**：基于真实测量数据展示 KPI 指标、对比柱状图与架构师敲黑板结论；
- **高能弹幕与中英双语字幕**：内置中文语音合成解说、环境合成器背景混音与 `.srt` 时间轴字幕。

---

## 2. 分幕分镜脚本与解说词 (Scene-by-Scene Storyboard & Bilingual Script)

### 第 1 幕 · 反直觉开场 (`黄金3秒 · 零CDN纯静态60帧`)

- **核心结论标题 (Headline-as-Finding)**: **0 外部贴图 CDN，却在浏览器跑出影视级敦煌飞天、真实火星与火箭升空？**
- **英文副标题 (Subhead)**: *Zero runtime CDN textures, yet 60fps Dunhuang murals, NASA MOLA Mars & 3D Rocket Launch in pure browser WebGL2*
- **16:9 完整解说词 (Full Narration ZH)**:
  > 如果我告诉你，眼前这个衣带当风的敦煌莫高窟飞天、精确到水手峡谷断崖的火星三维地形、还有喷射马赫环尾焰的白色火箭，全都没有加载哪怕一张外部CDN图片，而是靠几百KB的离线烘焙数据加纯数学着色器在浏览器里实时算出来的，你敢信吗？欢迎来到夜间自动化研究第一期：揭秘程序造景实验室 Generative Visual Lab。
- **9:16 竖屏速览解说词 (Short Narration ZH)**:
  > 零外部CDN贴图，怎么在浏览器里实时跑出60帧的敦煌飞天、真实NASA火星和火箭发射？核心秘诀只有八个字：离线烘焙，实时数学！
- **英文对照解说 (English Narration)**:
  > What if I told you these Dunhuang flying apsaras, NASA Mars canyons, and a 3D rocket launch with Mach diamonds load zero external CDN textures, running at 60fps in your browser via offline Blender baking and pure math shaders? Welcome to Episode 1 of our overnight research series.

#### 核心架构流节点 (Architecture Flow Nodes)
1. **离线几何与光线追踪烘焙** — Blender 4.5 LTS MCP 生成高精度网格与 Cycles 法线/凹腔贴图
2. **运行时零外部依赖加载** — 总包严控 < 6 MiB 离线预算，无任何外部纹理 API 或 CDN 请求
3. **动态分辨率与合批渲染** — 飞天 2x 局部缓存 + 火箭 27 Draw Calls 静态合批 + 火星 384 格位移
4. **Playwright 100% 帧率门禁** — 每次夜间提交强制校验 p95 <= 33.3ms (飞天) / <= 50ms (火箭)

#### 定量实测指标 (Verified Metrics)
- **16.7 ms** (敦煌飞天群飞 P95 帧耗时 (预算 ≤33.3ms)) — `60 FPS 满帧`
- **27 Calls** (白色火箭静态发射台按材质合批 (原 142)) — `-81.0% 开销`
- **151+ Stages** (夜间 Automation 持续演进验证阶段数) — `55/55 Checks`

#### 核心代码与公式验证 (Code & Formula Snippet)
```python
// generative-visual-lab: Zero external runtime dependency contract
const BUDGET_FEITIAN_P95_MS = 33.3; // Measured: 16.7ms (tail 120 frames)
const BUDGET_ROCKET_P95_MS  = 50.0; // Measured: 33.4ms (27 draw calls)
const ASTRA_OFFLINE_MAX_MIB = 6.0;  // NASA MOLA MEG016 verified binary
```

- **💡 架构师敲黑板 (Key Takeaway)**: 把昂贵的全局光照留在构建期 Blender Cycles 离线烘焙，把灵动的物理动力学交给浏览器实时数学求解。
- **💬 精选高能弹幕 (Danmaku)**: 卧槽，这居然是纯浏览器算出来的？！ / 把公屏打在硬核上！零外部CDN太顶了 / Blender MCP + WebGL2 完美双剑合璧

### 第 2 幕 · 飞天壁画与PBD飘带 (`第一幕 · 敦煌矿物设色与柔体物理`)

- **核心结论标题 (Headline-as-Finding)**: **解决 Canvas 2D 最大痛点：人物二倍高清缓存与无黑线双面连续飘带**
- **英文副标题 (Subhead)**: *Solving Canvas 2D Bottlenecks: 2x Offscreen Character Cache & Continuous Dual-Sided PBD Ribbons*
- **16:9 完整解说词 (Full Narration ZH)**:
  > 先看第一幕：风起壁间·敦煌飞天。在Canvas 2D里画精细国风人物，最容易踩的坑就是每帧重画径向渐变和笔触阴影，导致帧率直接腰斩。我们的解法是分层解耦：先用Blender 4.5构建莫高窟四龛拱券与莲瓣藻井，烘焙成430KB的正交浮雕底壁，一次画进静态墙面；再把飞天的杏眼高光、发簪金饰、衣襟刺绣画在二倍分辨率的离屏缓存里。动画循环只用位置动力学求解双面金边飘带，并且复用预分配数组，把群飞P95帧耗时死死压在16.7毫秒！
- **9:16 竖屏速览解说词 (Short Narration ZH)**:
  > 第一招：分层缓存！用Blender烘焙430KB莫高窟藻井底壁，飞天五官金饰放进二倍离屏缓存，动画循环只算零内存分配的双面飘带，群飞P95仅16.7毫秒！
- **英文对照解说 (English Narration)**:
  > In Act 1, Dunhuang Feitian, per-frame gradients and stroke shadows tank Canvas 2D framerates. We decoupled the layers: Blender 4.5 bakes a 430KB orthographic grotto relief into a static buffer, while character faces and gold jewelry live in a 2x offscreen cache. The animation loop only solves continuous PBD ribbons with zero per-frame allocations, hitting 16.7ms p95!

#### 核心架构流节点 (Architecture Flow Nodes)
1. **莫高窟四龛正交烘焙底壁** — Blender Cycles 烘焙 430KB grotto-relief-bake.png 一次绘入静态层
2. **二倍离屏人物缓存 (2x Cache)** — 五官、杏眼高光、金饰、衣纹仅在初始化重绘，节能降档绝不糊脸
3. **连续曲线双面 PBD 飘带** — 消除逐节黑线纸链感，复用边缘坐标缓冲实现每帧 0 内存分配
4. **竖屏 1000×1350 自适应构图** — 手机端双排壁面放大人物比例，触点与执灯轨迹全自动重映射

#### 定量实测指标 (Verified Metrics)
- **430 KB** (Blender Cycles 四龛藻井正交烘焙底图) — `0 逐帧开销`
- **2.0x DPR** (人物五官与金饰独立高清离屏缓存) — `拒绝降采样`
- **0 Alloc** (飘带边缘坐标缓冲区每帧对象分配数) — `消除GC卡顿`

#### 核心代码与公式验证 (Code & Formula Snippet)
```python
// 1. Static grotto relief + lotus border baked once into wall buffer
// 2. Character body & jewelry rendered at 2x DPR offscreen canvas
// 3. PBD ribbon solver reuses pre-allocated Float32Array edge buffers
p95_frame_time = 16.7ms; // Strictly <= 33.3ms budget on Chromium
```

- **💡 架构师敲黑板 (Key Takeaway)**: 初版逐笔触阴影会让帧率暴跌；将壁龛浮雕与人物五官分离到静态缓存，动态循环只算飘带约束，帧耗时直接砍半到16.7毫秒。
- **💬 精选高能弹幕 (Danmaku)**: 原来以前Canvas卡顿是因为每帧重建渐变和阴影！ / 人物2倍缓存太聪明了，降分辨率也不糊脸 / 敦煌石青石绿朱砂配色绝美！

### 第 3 幕 · NASA火星与白色火箭 (`第二幕 · 科学高程边界与马赫环`)

- **核心结论标题 (Headline-as-Finding)**: **NASA MOLA 实测火星高程 + 188KB 火箭 GLB：科学严谨与艺术表现如何兼得？**
- **英文副标题 (Subhead)**: *NASA MOLA Measured Mars Topography + 188KB Rocket Kit GLB: Bridging Scientific Rigor & Art*
- **16:9 完整解说词 (Full Narration ZH)**:
  > 第二幕来看Astra火星和白色火箭。很多三维地球Demo喜欢用随机噪声伪造地形，但我们在Astra火星里立下铁律：绝不篡改NASA MOLA实测高程！384格每纬度的精细近景把真实位移顶点提升四倍，只用165KB的Blender无缝玄武岩法线贴图增强写实光影，切换到灰度或线框检验模式立刻还原纯科学几何。而在白色火箭Demo里，我们把箭体、钛合金栅格翼、五台拉瓦尔喷管和发射台浓缩进188KB的GLB，按材质合批把Draw Call从142次降到27次，再用双层圆锥相位函数算出无UV接缝的尾焰马赫环！
- **9:16 竖屏速览解说词 (Short Narration ZH)**:
  > 在Astra火星里，我们严守NASA MOLA实测高程，叠加165KB玄武岩微法线；在白色火箭里，188KB的GLB把142个部件合批到27次调用，双层圆锥直接算出逼真尾焰马赫环！
- **英文对照解说 (English Narration)**:
  > In Act 2, Astra Mars strictly preserves NASA MOLA elevation measurements, quadrupling displacement vertices at 384 cells per latitude while layering a 165KB Blender basalt micro-normal map only in realistic mode. For Rocket Launch, a 188KB GLB batches 142 pad parts into 27 draw calls and renders seamless Mach shock diamonds using dual-cone periodic phase shaders.

#### 核心架构流节点 (Architecture Flow Nodes)
1. **NASA MOLA 实测高程红线** — 严格保留 MEG016 原始高程统计，384格/纬精细网格提升4倍几何顶点
2. **165KB 无缝玄武岩微法线贴图** — G/B通道存切线斜率、R存凹腔遮蔽，检验模式下100%还原纯科学几何
3. **188KB 三层级火箭 GLB 资产** — 相切卵形鼻锥+钛合金栅格翼+5台拉瓦尔喷管，142个部件合批至27 DrawCalls
4. **无粒子尾焰马赫环与三维天球** — 两层圆锥周期相位扰动消除UV接缝，无需昂贵流体粒子即可呈现炽白马赫结

#### 定量实测指标 (Verified Metrics)
- **384 格/纬** (Astra 火星精细近景真实位移网格 (4倍面数)) — `< 6 MiB 预算`
- **188 KB** (Rocket-Kit.glb 箭体/脐带臂/发射台总大小) — `32 DrawCalls`
- **33.4 ms** (白色火箭点火升空全流程 P95 帧耗时) — `≤50ms 达标`

#### 核心代码与公式验证 (Code & Formula Snippet)
```python
// Astra Mars: Realistic mode adds micro-normal; Gray/Wireframe stay pure MOLA
if (mode === 'realistic') applyMicroNormalAndCavity(marsMicroNormalTex);
// Rocket Launch: Merge static pad meshes by material (142 -> 27 draw calls)
assert(rocketHeadInSafeCircle && groundInSafeCircle && p95 <= 50.0);
```

- **💡 架构师敲黑板 (Key Takeaway)**: 绝不用程序随机噪波伪造NASA科学测量数据！我们在保留MOLA实测高程的同时，仅在写实模式叠加165KB微法线，并支持一键导出标准GLB。
- **💬 精选高能弹幕 (Danmaku)**: 科学归科学，艺术归艺术，这边界感太严谨了！ / 142个draw call合并到27个，WebGL优化教科书 / 两层圆锥加相位扰动做出马赫环，神仙写法！

### 第 4 幕 · 夜间进化与架构总结 (`尾声 · Stage 151+ 自动化闭环`)

- **核心结论标题 (Headline-as-Finding)**: **连续 151+ 阶段夜间无人值守进化：Playwright 像素级与帧率门禁如何守住底线？**
- **英文副标题 (Subhead)**: *151+ Overnight Evolution Stages: How Playwright Pixel & Frame-Time Gates Guard Quality*
- **16:9 完整解说词 (Full Narration ZH)**:
  > 为什么这套实验室能每晚零点自动迭代到第151个Stage还不崩？因为我们配了最严苛的Playwright真浏览器门禁。曾经有一次夜间优化让火箭帧耗时飙到116.7毫秒，自动化门禁当场拦截、拒绝部署，直到加上二级DPR动态降级、重回33.4毫秒才放行合入main分支。所有源码、Blender脚本和中英双语文档都已同步在GitHub主分支，快去长按点赞一键三连，我们在评论区聊聊你最想看哪个着色器的源码拆解！
- **9:16 竖屏速览解说词 (Short Narration ZH)**:
  > 连续151个Stage夜间自动进化不翻车，全靠55项Playwright真浏览器门禁！帧率超标当场拦截，全部源码与双语文档已开源至GitHub main，记得一键三连！
- **英文对照解说 (English Narration)**:
  > How does this lab evolve autonomously past Stage 151 every night without breaking? Strict Playwright browser gates! When one commit pushed rocket p95 to 116.7ms, the gate blocked deployment until two-tier DPR scaling brought it back to 33.4ms. Everything is live on GitHub main in Chinese and English—hit like, coin, and subscribe!

#### 核心架构流节点 (Architecture Flow Nodes)
1. **每晚 00:00 自动唤醒迭代** — 扫描前沿 WebGL/Opus 动画谱系，提取可复用着色器与动力学技法
2. **双轨回归门禁 (Local vs CI)** — 区分本机硬件预算 (33.3ms/50ms) 与共享 Linux CI 软件渲染回归线
3. **确定性暂停态截图取证** — 消除慢截图期间时钟滑移，断言火箭头部与地面100%处于圆框安全区
4. **中英双语直推 GitHub main** — 55/55 项检查全绿后自动归档六大类资产并同步 origin/main

#### 定量实测指标 (Verified Metrics)
- **55 / 55** (全量类型/单元/构建/Playwright浏览器验收) — `100% PASS`
- **0 外部请求** (运行时第三方 CDN / API 依赖数量) — `纯静态离线`
- **CN + EN** (全仓技术文档与资产分类双语同步) — `main 主干`

#### 核心代码与公式验证 (Code & Formula Snippet)
```python
git clone https://github.com/turbo998/generative-visual-lab.git
npm ci && npm --prefix demos/astra-planet ci
npm run check && npm --prefix demos/astra-planet run check
// All 55 unit, type, build, and Playwright browser checks PASS
```

- **💡 架构师敲黑板 (Key Takeaway)**: 没有自动化性能门禁的视觉调优只是自嗨。曾有一次提交让火箭帧耗时退化到116.7ms，门禁当场拦截未予发布，直到引入二级DPR自适应才放行上主干。
- **💬 精选高能弹幕 (Danmaku)**: 116.7ms直接拦截不发布，这工程纪律太硬核了！ / 一键三连！这才是真正的AI+图形学工程化 / 已Star仓库，去GitHub Pages亲自玩一把！
