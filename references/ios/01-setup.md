# iOS · 工程搭建与构建

## 1. 骨架

```
ios/
├── gen_project.py          生成 xcodeproj（BUNDLE_ID / 版本 / 源文件清单都在这里）
├── IStorePilot/
│   ├── App.swift           入口
│   ├── Core/               网络、存储、会话
│   ├── UI/                 设计令牌、通用组件（Comp.swift）
│   ├── Views/              一页一个文件
│   ├── Resources/          图标、字体
│   └── Info.plist
└── IStorePilot.xcodeproj   生成物，不手改
```

**pbxproj 一律由脚本生成**：手改的后果是下次生成被覆盖，且 diff 无法阅读。
`gen_project.py` 至少负责：BUNDLE_ID、MARKETING_VERSION、CURRENT_PROJECT_VERSION、源文件列表。

## 2. 环境

- Xcode 最新稳定版；命令行构建用 `xcodebuild`
- 签名：`DEVELOPMENT_TEAM` + 描述文件（开发/发布分开）
- 模拟器调试不需要证书，`xcodebuild -sdk iphonesimulator` 即可

```bash
xcodebuild -project IStorePilot.xcodeproj -scheme IStorePilot \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/App.xcarchive archive
```

## 3. Info.plist 要点

- `NSAppTransportSecurity`：内网 HTTP 需要 `NSAllowsLocalNetworking = true`
  （**不要**开 `NSAllowsArbitraryLoads`，审核会问）
- 权限用途文案（相机/本地网络）必须具体，写清"用来做什么"
- 本地网络访问在 iOS 14+ 会弹窗，首次请求前要能说明原因

## 4. 版本

版本在 `gen_project.py` 里定义，重跑脚本写入 pbxproj：

```python
MARKETING_VERSION = "0.4.3"
CURRENT_PROJECT_VERSION = 47
```

改完必须确认：

```bash
grep -A1 MARKETING_VERSION IStorePilot.xcodeproj/project.pbxproj | head -4
```

## 5. 演示模式

审核必须能在没有设备的情况下看到界面：
在登录页放「先看看演示」，进入后切本地数据源；写操作提示只读。
App Store 审核员会直接点这条路径，**入口文案要直白**。

## 6. 自查

```bash
xcodebuild -showBuildSettings | grep -E "PRODUCT_BUNDLE_IDENTIFIER|MARKETING_VERSION"
xcrun altool --validate-app -f App.ipa -t ios --apiKey … --apiIssuer …
```
