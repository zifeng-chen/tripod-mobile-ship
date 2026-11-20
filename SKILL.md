---
name: tripod-mobile-ship
description: 三端原生 App（Android / iOS / HarmonyOS）从项目搭建、UI 规范到打包上架的完整方法论。Android（Java+Activity）、iOS（SwiftUI）、鸿蒙（ArkTS）各有独立文档，另有共通工程约定与三端差异对照。当需要新建或维护三端同源项目、统一设计令牌、处理平台差异、构建签名发版、华为 AGC 提审、或应对审核驳回（对比度/图标/隐私/备案/演示录屏）时使用。
agent_created: true
---

# 三端 App：从搭建到上架

同一套产品逻辑，三份原生实现，共享一份设计令牌、一份接口契约、一条发布流水线。
**每个平台的细节单独成文**，按任务去读对应目录，不要一次全读。

## 平台入口

| 端 | 技术栈 | 文档 |
|---|---|---|
| Android | Java + Activity + XML | `references/android/`（01 搭建 · 02 UI · 03 上架） |
| iOS | SwiftUI | `references/ios/`（01 搭建 · 02 UI · 03 上架） |
| HarmonyOS | ArkTS（状态管理 V2） | `references/harmony/`（01 搭建 · 02 UI · 03 上架 · 04 踩坑） |

## 共通文档

| 文档 | 什么时候读 |
|---|---|
| `references/common/project-structure.md` | 建仓库、定包名、版本号同步、演示模式、跨机开发 |
| `references/common/design-tokens.md` | 定色板/间距/圆角/字号、组件形状、对比度红线 |
| `references/common/review-playbook.md` | 提审前自查、五类高频驳回、材料清单 |
| `references/cross-platform.md` | 三端行为不一致，要定位"哪端偏了" |

## 十条铁律

1. **三端同步**：界面或功能改动三端一起改，提交信息写清"三端"。
2. **版本号单点**：一处定义、脚本写六处、提审前校验；不一致不许发。
3. **设计令牌镜像**：颜色/尺寸只从令牌取，页面里不出现裸色值和裸圆角。
4. **图标用矢量资源**，不要代码自绘——审核按控件类型量对比度和锯齿。
5. **按钮一律胶囊**：圆角 = 高度/2，且宽度明显大于高度；行内胶囊最小宽 78。
6. **热区不小于 44**（iOS 44pt / Android 48dp / 鸿蒙 44vp），量的是控件自身矩形。
7. **深浅色两套值**都走 token；自绘组件切主题要能重取色。
8. **必须有演示模式**：审核员没有你的设备，写操作只读、入口显眼。
9. **发布前跑体检**：样式检查、死代码、版本一致性、包签名类型、对比度抽查。
10. **市场材料与包同版本**：截图、录屏、版本说明跟着 versionCode 走。

## 典型任务 → 从哪里开始

| 任务 | 先读 |
|---|---|
| 新建三端项目 | `common/project-structure.md` → 对应平台的 `01-setup.md` |
| 定 UI 规范 / 写组件库 | `common/design-tokens.md` → 平台 `02-ui.md` |
| 出包 / 签名 / 发版 | 平台 `03-release.md` |
| 华为提审 / 被驳回 | `harmony/03-release.md` + `common/review-playbook.md` |
| 三端表现不一致 | `cross-platform.md` |
| 编译或运行报错 | `harmony/04-pitfalls.md`，或平台 `03-release.md` 末尾的坑表 |
| 要录演示视频 | `scripts/record_demo_harmony.sh` + `common/review-playbook.md` |

## 脚本

```bash
# 逐控件量对比度（截图 + uitest dumpLayout 配对，放在同目录）
python scripts/contrast_audit.py <目录>

# 鸿蒙演示录屏（设备没有 screenrecord 时用连拍合成）
bash scripts/record_demo_harmony.sh <包名> <步骤文件> <输出.mp4>
```

## 判断"三端哪个对"

以 **Android 为基准**（实现最早、约束最少），把差异列成表逐条核实：
入口位置、字段顺序、空态文案、单位换算、禁用态、返回行为。
确认是平台惯例就当差异保留，别当 bug 修。
