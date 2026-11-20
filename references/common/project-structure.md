# 仓库与工程骨架（三端共通）

## 目录

```
repo/
├── android/        Java + Activity + XML 布局（applicationId = 统一包名）
├── ios/            SwiftUI；xcodeproj 由 gen_project.py 生成，别手改 pbxproj
├── harmony/        ArkTS + DevEco；版本在 AppScope/app.json5
├── agent/          跑在设备/服务器上的后端（Python 单文件足够）
├── deploy/         安装脚本、ipk/deb 打包
├── scripts/        体检、发版、跨机同步
├── docs/           规范、接口、发布流程
├── design/         图标源（SVG）、令牌 JSON
└── CHANGELOG.md    按版本分段的用户可读变更
```

`dist/` 进 gitignore。

## 包名/包标识

三端**完全一致**，例如 `com.example.app`。

| 端 | 位置 | 改法 |
|---|---|---|
| Android | `app/build.gradle` 的 `applicationId` | 直接改 |
| iOS | `gen_project.py` 里的 `BUNDLE_ID` | 改脚本后重跑生成工程 |
| 鸿蒙 | `AppScope/app.json5` 的 `bundleName` | 直接改 |

## 版本号：一处定义，六处同步

典型六处：鸿蒙 `AppScope/app.json5` + 两个 `oh-package.json5` + `android/app/build.gradle`
+ iOS `gen_project.py`（版本和 BUILD）+ `agent/VERSION`。

```bash
python scripts/bump_version.py --next     # 0.4.2(46) → 0.4.3(47)，六处一起写
python scripts/check_version.py           # 任一不一致 → 非 0 退出，CI 拦住
```

规则：

- 语义版本 `X.Y.Z`，第三位满 10 进位（`0.4.9 → 0.5.0`），不出现 `0.4.10`
- `versionCode` 单调递增，永不回退
- **改动多就切版本**，别塞进已发布版本的说明
- iOS 改完版本必须重跑 `gen_project.py`，pbxproj 才会更新

## 演示模式（提审必需）

审核员没有你的设备/账号。两种做法选一或都做：

1. **录制回放**：真机录一遍 GET 响应（脱敏落盘），服务端按路径回放，写操作一律 501
2. **内置假数据**：应用内带 `demo.json`，进演示切本地数据源

硬要求：

- 写操作返回「演示环境只读」，绝不执行
- 登录/首页有显眼入口（「没有设备？先看看演示」）
- 界面上常驻「演示模式」标识，避免误认成真实数据

## 跨机开发（Windows 写码、Mac 出包）

写一个单文件 `scripts/mac.py`（paramiko）：`run / put / get / sync / ping / find`。

- 认证优先 SSH 密钥，其次环境变量口令
- `sync` 递归上传但**跳过签名配置**（`build-profile.json5` 等含密文，传过去会冲掉签名）
- 用 mtime+size 判断跳过
- `find` 扫同网段 22 端口并用 SSH `hostname` 认机器（DHCP 换 IP 时比猜快）

> Git Bash 会把 `/` 开头参数改写成 `C:/Program Files/...`，远程绝对路径必须加
> `MSYS_NO_PATHCONV=1`。
