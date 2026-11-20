# iOS · 打包与上架

## 1. 出包

```bash
# 1) 归档
xcodebuild -project IStorePilot.xcodeproj -scheme IStorePilot \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath build/App.xcarchive archive

# 2) 导出 ipa（ExportOptions.plist 里写 method=app-store / ad-hoc）
xcodebuild -exportArchive -archivePath build/App.xcarchive \
  -exportPath build/ipa -exportOptionsPlist ExportOptions.plist
```

证书与描述文件：

- 发布证书（Apple Distribution）+ App Store 描述文件
- 团队 ID 写进 `ExportOptions.plist` 的 `teamID`
- 上传：`xcrun altool --upload-app` 或 Transporter / Xcode Organizer

## 2. App Store Connect

| 项 | 注意 |
|---|---|
| Bundle ID | 与 `gen_project.py` 一致；一旦上架不可改 |
| 版本号 | 与 pbxproj 一致；BUILD 必须比上一版大 |
| 隐私清单 | `PrivacyInfo.xcprivacy`（2024 起必填，声明 API 使用与数据收集） |
| 截图 | 6.7" / 6.1" 必传；iPad 若声明支持也必须给 |
| 演示账号 | 必须有；演示模式写清进入路径 |
| 出口合规 | 用到加密要选对（HTTPS 属豁免） |

## 3. 审核要点（App Store 特有）

- **2.1 崩溃/占位**：不能有空白页、TODO 文案
- **4.2 最低功能**：纯网页套壳会被拒——本项目是原生实现，在介绍里说明
- **5.1.1 隐私**：权限弹窗文案必须说明用途；首次启动前不能提前请求
- **登录必须可用**：没有账号体系就要能直接用；有账号就要给测试号
- 引导用户去外部支付的文案会被拒（无内购时不要提"购买"）

## 4. 常见坑

| 症状 | 原因 | 改法 |
|---|---|---|
| 上传报 `ITMS-90087` | 内含不支持的架构 | 去掉 x86_64 切片 |
| `Invalid Bundle` | Info.plist 缺 `CFBundleIcons` | 补齐图标资源 |
| 审核说"无法登录" | 没给测试账号/演示模式 | 提供演示入口 + 测试号 |
| 深色模式文字看不清 | 硬编码 `.black` | 走 Asset 颜色 |
| 按钮禁用后白字变灰 | `.disabled()` 整体调暗 | 见 02-ui.md |
| 内网 HTTP 请求失败 | ATS 拦截 | 只开 `NSAllowsLocalNetworking` |

## 5. 发版节奏

1. TestFlight 内测（自己 + 少量用户）
2. 提交审核（备注写清演示路径与测试账号）
3. 审核通过后手动发布或定时发布
4. 版本说明与 CHANGELOG 同步
