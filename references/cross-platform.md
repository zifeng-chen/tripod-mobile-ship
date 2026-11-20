# 三端差异对照（以 Android 为基准）

定位"哪端偏了"时先看这张表。确认是平台惯例就当差异保留，别当 bug 修。

## 能力/结构

| 维度 | Android | iOS | HarmonyOS |
|---|---|---|---|
| 技术栈 | Java + Activity + XML 布局 | SwiftUI（`App.swift` + `Views/`） | ArkTS 声明式（`pages/` + `ui/`） |
| 工程文件 | `build.gradle` 文本 | `project.pbxproj`（**脚本生成**） | `build-profile.json5` + `module.json5` |
| 包标识 | `applicationId` | `BUNDLE_ID`（gen_project.py） | `bundleName`（app.json5） |
| 版本位置 | `build.gradle` | `gen_project.py` → pbxproj | `AppScope/app.json5` |
| 状态管理 | ViewModel / 单例 | `@State` / `@Observable` | **V2：`@Local/@Param/@Event/@Monitor`**（别用 V1） |
| 二级页 | 独立 Activity | `NavigationStack` 推入 | 自绘返回栏 + `UI.backTick` |
| 安全区 | `WindowInsets` | `safeAreaInset` | `UI.safeTop`（冷启动要补量） |
| 深色模式 | `values-night` | Asset Catalog | `resources/dark` |

## 交互/视觉

| 项 | Android | iOS | HarmonyOS |
|---|---|---|---|
| 禁用态 | `alpha 0.5` | `.disabled()` 会连文字一起调暗 | `.enabled(false)` + 手动透明度 |
| 卡片内边距 | `Card` 左右可能是 0，自己补 | 默认 16 | 自己控制 |
| 长按复制 | `textIsSelectable` | `.textSelection(.enabled)` | `copyOption(CopyOptions.LocalDevice)` |
| 底部导航 | `BottomNavigationView` | `TabView` | 自绘 `NavBar`（`UI.tab` 0~3） |
| 弹层 | `BottomSheet` | `.sheet` | `bindSheet`（**一个组件只能挂一个**） |
| 图标着色 | `app:tint` | `.renderingMode(.template)` | `Image + colorFilter(SRC_IN)` |
| 列表项重建 | `notifyItemChanged` | 自动 | `ForEach` 的 key 必须含变化字段 |

## 常见"假差异"

- 行高不同：三端 line-height 默认值不同，统一用令牌里的字号 + 固定行高
- 圆角看着不一样：Android 用 dp、iOS 用 pt，数值相同即可，别按像素调
- 阴影浓淡：iOS 默认有、Android 要显式设；本项目约定**卡片一律无阴影**
- 返回手势：iOS 边缘手势、Android 系统返回键、鸿蒙系统返回 + 自绘返回栏，三者都要能用

## 复跑核对

```bash
# 三端页面清单对比（人工维护一份映射表，改版时逐条勾）
diff <(grep -h "class .*Activity" android/**/*.java | sort) \
     <(grep -h "struct .*View" ios/**/*.swift | sort)
```

更实用的做法：把「页面 → 入口 → 关键字段」列成表，每次改版勾一遍，缺哪个补哪个。
