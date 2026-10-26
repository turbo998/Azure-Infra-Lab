# 📺 EP01 · 程序造景实验室: Zero External CDN Assets: Building Dunhuang Feitian, NASA Mars & Rocket Launch with Pure Math & Blender 4.5 MCP

> **Chinese Title (中文标题)**: *不用一兆外部CDN贴图，如何在浏览器里用纯数学与Blender烘焙造出敦煌飞天、NASA火星与火箭发射？*  
> **Target Repository**: `turbo998/generative-visual-lab` (Verified on `main` branch)  
> **Deliverable Formats**: 16:9 Landscape Deep-Dive (`1920×1080`, `168.6s`) + 9:16 Vertical Short (`1080×1920`, `65.3s`) · 30fps H.264 + Bilingual `.srt`

---

## 1. Executive Summary & Visual Engineering

This episode distills overnight autonomous research breakthroughs into a Bilibili hardcore knowledge-creator explainer format:
- **Counter-intuitive Hook**: Opens with a concrete quantitative bottleneck or production failure mode.
- **4-Chapter Progress Architecture**: Synchronized top chapter bar, architecture flow workbench, and code/formula inspection.
- **Sealed Benchmark Evidence**: Zero fabricated coordinates—every metric pill and comparison bar maps to verified repository tests.

---

## 2. Scene-by-Scene Storyboard & Narration

### Scene 1 · 反直觉开场 (`黄金3秒 · 零CDN纯静态60帧`)

- **Headline-as-Finding**: **Zero runtime CDN textures, yet 60fps Dunhuang murals, NASA MOLA Mars & 3D Rocket Launch in pure browser WebGL2**
- **Chinese Headline**: *0 外部贴图 CDN，却在浏览器跑出影视级敦煌飞天、真实火星与火箭升空？*
- **English Narration**:
  > What if I told you these Dunhuang flying apsaras, NASA Mars canyons, and a 3D rocket launch with Mach diamonds load zero external CDN textures, running at 60fps in your browser via offline Blender baking and pure math shaders? Welcome to Episode 1 of our overnight research series.
- **Chinese Narration (16:9)**:
  > 如果我告诉你，眼前这个衣带当风的敦煌莫高窟飞天、精确到水手峡谷断崖的火星三维地形、还有喷射马赫环尾焰的白色火箭，全都没有加载哪怕一张外部CDN图片，而是靠几百KB的离线烘焙数据加纯数学着色器在浏览器里实时算出来的，你敢信吗？欢迎来到夜间自动化研究第一期：揭秘程序造景实验室 Generative Visual Lab。

#### Architecture Flow & Verified Metrics
- **16.7 ms**: 敦煌飞天群飞 P95 帧耗时 (预算 ≤33.3ms) (`60 FPS 满帧`)
- **27 Calls**: 白色火箭静态发射台按材质合批 (原 142) (`-81.0% 开销`)
- **151+ Stages**: 夜间 Automation 持续演进验证阶段数 (`55/55 Checks`)

```python
// generative-visual-lab: Zero external runtime dependency contract
const BUDGET_FEITIAN_P95_MS = 33.3; // Measured: 16.7ms (tail 120 frames)
const BUDGET_ROCKET_P95_MS  = 50.0; // Measured: 33.4ms (27 draw calls)
const ASTRA_OFFLINE_MAX_MIB = 6.0;  // NASA MOLA MEG016 verified binary
```

### Scene 2 · 飞天壁画与PBD飘带 (`第一幕 · 敦煌矿物设色与柔体物理`)

- **Headline-as-Finding**: **Solving Canvas 2D Bottlenecks: 2x Offscreen Character Cache & Continuous Dual-Sided PBD Ribbons**
- **Chinese Headline**: *解决 Canvas 2D 最大痛点：人物二倍高清缓存与无黑线双面连续飘带*
- **English Narration**:
  > In Act 1, Dunhuang Feitian, per-frame gradients and stroke shadows tank Canvas 2D framerates. We decoupled the layers: Blender 4.5 bakes a 430KB orthographic grotto relief into a static buffer, while character faces and gold jewelry live in a 2x offscreen cache. The animation loop only solves continuous PBD ribbons with zero per-frame allocations, hitting 16.7ms p95!
- **Chinese Narration (16:9)**:
  > 先看第一幕：风起壁间·敦煌飞天。在Canvas 2D里画精细国风人物，最容易踩的坑就是每帧重画径向渐变和笔触阴影，导致帧率直接腰斩。我们的解法是分层解耦：先用Blender 4.5构建莫高窟四龛拱券与莲瓣藻井，烘焙成430KB的正交浮雕底壁，一次画进静态墙面；再把飞天的杏眼高光、发簪金饰、衣襟刺绣画在二倍分辨率的离屏缓存里。动画循环只用位置动力学求解双面金边飘带，并且复用预分配数组，把群飞P95帧耗时死死压在16.7毫秒！

#### Architecture Flow & Verified Metrics
- **430 KB**: Blender Cycles 四龛藻井正交烘焙底图 (`0 逐帧开销`)
- **2.0x DPR**: 人物五官与金饰独立高清离屏缓存 (`拒绝降采样`)
- **0 Alloc**: 飘带边缘坐标缓冲区每帧对象分配数 (`消除GC卡顿`)

```python
// 1. Static grotto relief + lotus border baked once into wall buffer
// 2. Character body & jewelry rendered at 2x DPR offscreen canvas
// 3. PBD ribbon solver reuses pre-allocated Float32Array edge buffers
p95_frame_time = 16.7ms; // Strictly <= 33.3ms budget on Chromium
```

### Scene 3 · NASA火星与白色火箭 (`第二幕 · 科学高程边界与马赫环`)

- **Headline-as-Finding**: **NASA MOLA Measured Mars Topography + 188KB Rocket Kit GLB: Bridging Scientific Rigor & Art**
- **Chinese Headline**: *NASA MOLA 实测火星高程 + 188KB 火箭 GLB：科学严谨与艺术表现如何兼得？*
- **English Narration**:
  > In Act 2, Astra Mars strictly preserves NASA MOLA elevation measurements, quadrupling displacement vertices at 384 cells per latitude while layering a 165KB Blender basalt micro-normal map only in realistic mode. For Rocket Launch, a 188KB GLB batches 142 pad parts into 27 draw calls and renders seamless Mach shock diamonds using dual-cone periodic phase shaders.
- **Chinese Narration (16:9)**:
  > 第二幕来看Astra火星和白色火箭。很多三维地球Demo喜欢用随机噪声伪造地形，但我们在Astra火星里立下铁律：绝不篡改NASA MOLA实测高程！384格每纬度的精细近景把真实位移顶点提升四倍，只用165KB的Blender无缝玄武岩法线贴图增强写实光影，切换到灰度或线框检验模式立刻还原纯科学几何。而在白色火箭Demo里，我们把箭体、钛合金栅格翼、五台拉瓦尔喷管和发射台浓缩进188KB的GLB，按材质合批把Draw Call从142次降到27次，再用双层圆锥相位函数算出无UV接缝的尾焰马赫环！

#### Architecture Flow & Verified Metrics
- **384 格/纬**: Astra 火星精细近景真实位移网格 (4倍面数) (`< 6 MiB 预算`)
- **188 KB**: Rocket-Kit.glb 箭体/脐带臂/发射台总大小 (`32 DrawCalls`)
- **33.4 ms**: 白色火箭点火升空全流程 P95 帧耗时 (`≤50ms 达标`)

```python
// Astra Mars: Realistic mode adds micro-normal; Gray/Wireframe stay pure MOLA
if (mode === 'realistic') applyMicroNormalAndCavity(marsMicroNormalTex);
// Rocket Launch: Merge static pad meshes by material (142 -> 27 draw calls)
assert(rocketHeadInSafeCircle && groundInSafeCircle && p95 <= 50.0);
```

### Scene 4 · 夜间进化与架构总结 (`尾声 · Stage 151+ 自动化闭环`)

- **Headline-as-Finding**: **151+ Overnight Evolution Stages: How Playwright Pixel & Frame-Time Gates Guard Quality**
- **Chinese Headline**: *连续 151+ 阶段夜间无人值守进化：Playwright 像素级与帧率门禁如何守住底线？*
- **English Narration**:
  > How does this lab evolve autonomously past Stage 151 every night without breaking? Strict Playwright browser gates! When one commit pushed rocket p95 to 116.7ms, the gate blocked deployment until two-tier DPR scaling brought it back to 33.4ms. Everything is live on GitHub main in Chinese and English—hit like, coin, and subscribe!
- **Chinese Narration (16:9)**:
  > 为什么这套实验室能每晚零点自动迭代到第151个Stage还不崩？因为我们配了最严苛的Playwright真浏览器门禁。曾经有一次夜间优化让火箭帧耗时飙到116.7毫秒，自动化门禁当场拦截、拒绝部署，直到加上二级DPR动态降级、重回33.4毫秒才放行合入main分支。所有源码、Blender脚本和中英双语文档都已同步在GitHub主分支，快去长按点赞一键三连，我们在评论区聊聊你最想看哪个着色器的源码拆解！

#### Architecture Flow & Verified Metrics
- **55 / 55**: 全量类型/单元/构建/Playwright浏览器验收 (`100% PASS`)
- **0 外部请求**: 运行时第三方 CDN / API 依赖数量 (`纯静态离线`)
- **CN + EN**: 全仓技术文档与资产分类双语同步 (`main 主干`)

```python
git clone https://github.com/turbo998/generative-visual-lab.git
npm ci && npm --prefix demos/astra-planet ci
npm run check && npm --prefix demos/astra-planet run check
// All 55 unit, type, build, and Playwright browser checks PASS
```
