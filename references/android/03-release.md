# Android · 打包与上架

## 1. 出包

```bash
JAVA_HOME=<jdk17> ./gradlew clean assembleRelease
# 产物：app/build/outputs/apk/release/app-release.apk
```

```bash
# 验签 + 核对包名版本
apksigner verify --print-certs app-release.apk
aapt dump badging app-release.apk | head -3
```

三条都要看：`versionCode` 比线上大、`applicationId` 正确、签名是 release keystore。

## 2. 上架材料

| 项 | 注意 |
|---|---|
| 应用包 | apk 或 aab（按商店；Google Play 只收 aab） |
| 图标 | 512×512 商店图标 + 自适应图标（前景/背景分层） |
| 截图 | 覆盖主要页面，至少 2 张；有平板就补 |
| 隐私政策 | 独立可访问 URL，与应用内一致 |
| 数据安全表单 | 逐个权限/数据项勾选，与实际一致 |
| 内容分级 | 按实际内容填，别勾"儿童" |
| 测试账号 | 必须给；演示模式写清入口 |

## 3. 国内商店差异

- 华为/小米/OPPO/vivo 各自要软著或承诺函，**包名必须一致**
- 部分商店要求 64 位、targetSdk 下限、隐私弹窗二次确认
- 同一版本号一旦提交过就不能复用（被拒后要升 versionCode）

## 4. 自动发版

```bash
python scripts/release.py --ipk    # 同步 apk → 生成安装包 → commit/push → tag → GitHub Release
```

- 资产上传走 `uploads.github.com`（`api.github.com` 的资产接口 404）
- 改 Release 正文用数字 `id` 走 PATCH，正文手写，别用自动 commit 列表
- push 含 `.github/workflows/*` 需要 `workflow` scope，装出来的 `gho_` token 没有 → 用 classic PAT
- 安装包里的 APK 按 **mtime** 从 `dist/` 挑，先复制再发，否则容易发旧包

## 5. 常见坑

| 症状 | 原因 | 改法 |
|---|---|---|
| 构建报 AGP 版本不兼容 | JDK 太新/太旧 | 显式 `JAVA_HOME` 指向 17 |
| 装不上（`INSTALL_FAILED_UPDATE_INCOMPATIBLE`） | 签名不一致 | 用同一 keystore |
| 覆盖升级失败 | versionCode 没升 | 单调递增 |
| 深色模式颜色不更新 | 自绘 View 缓存了画笔色 | `onConfigurationChanged` 里重建 |
| 卡片内容贴边 | CardView 内边距为 0 | 内容容器补 14~16dp |
| 商店驳回"隐私政策缺失" | 只在网页有不等于应用内有 | 应用内也要能打开 |
