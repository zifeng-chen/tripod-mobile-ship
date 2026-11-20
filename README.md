# tripod-mobile-ship

三端原生 App（Android / iOS / HarmonyOS）**从搭建到上架**的方法论，打包成一个 Claude / WorkBuddy Skill。

不是教程，是踩过坑之后的硬规则：什么必须三端一起改、图标为什么不能用 Canvas 画、
鸿蒙 `.app` 为什么在服务器上打不出来、审核驳回的五类高频问题怎么解。

## 装法

```bash
# 用户级（所有项目可用）
git clone https://github.com/<you>/tripod-mobile-ship.git ~/.workbuddy/skills/tripod-mobile-ship

# 项目级（跟着仓库走）
git clone https://github.com/<you>/tripod-mobile-ship.git .workbuddy/skills/tripod-mobile-ship
```

WorkBuddy 会自动扫描 `~/.workbuddy/skills/` 与 `<project>/.workbuddy/skills/`，
SKILL.md 的 frontmatter 里 `name` 必须与目录名一致。

## 结构

```
SKILL.md                    总纲：十条铁律 + 平台索引
references/
├── common/                 三端共用
│   ├── project-structure.md   仓库骨架、包名、版本六处同步、演示模式、跨机开发
│   ├── design-tokens.md       色板/间距/圆角/字号、组件形状、对比度红线
│   └── review-playbook.md     提审自查、五类高频驳回、材料清单
├── android/                Java + Activity + XML（01 搭建 / 02 UI / 03 上架）
├── ios/                    SwiftUI（01 搭建 / 02 UI / 03 上架）
├── harmony/                ArkTS（01 搭建 / 02 UI / 03 上架 / 04 踩坑）
└── cross-platform.md       三端差异对照（以 Android 为基准）
scripts/
├── contrast_audit.py           逐控件量 WCAG 对比度（截图 + uitest dumpLayout）
└── record_demo_harmony.sh      鸿蒙演示录屏（设备无 screenrecord 时连拍合成）
```

## 覆盖范围

| 阶段 | 内容 |
|---|---|
| 搭建 | 三端同仓骨架、统一包名、版本号单点定义与六处同步、演示模式、跨机（Windows 写码 / Mac 出包） |
| 界面 | 设计令牌、卡片/按钮/图标/弹层规范、热区与对比度硬线、三端状态管理差异 |
| 发版 | Android 签名出包、iOS 归档导出、鸿蒙发布证书与 `.app` 打包（含 `PackageApp` 失败的绕法） |
| 上架 | 华为 AGC 全套 CLI 命令与 version state 机、App Store 审核要点、GitHub Release |
| 过审 | 对比度/图标锯齿/主体一致性/APP 备案/演示录屏五类驳回的定位与改法 |

## 几条最值钱的结论

- **图标一律用矢量资源**，不要代码自绘。审核工具按控件类型量对比度——透明画布会被取到同一个白（1.03），小尺寸自绘细线还会触发锯齿阈值（>90）。
- **按钮一律胶囊**（圆角 = 高度/2），宽高相等就成了正圆。行内操作胶囊最小宽 78。
- **主体信息用实名**。应用内写花名，与开发者后台不一致 → 直接驳回。
- **鸿蒙 `assembleApp` 在服务器上必然失败**：`app_packing_tool` 写死往 `/private/tempHapDir` 解压。自己 zip + `hap-sign-tool` 签名可绕。
- **AGC 网页改过版本信息会清空隐私协议绑定**，重新提交前必须复查，否则报 `PrivacyPolicy is necessary`。

## License

MIT
