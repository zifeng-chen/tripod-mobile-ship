# Android · 工程搭建与构建

## 1. 骨架

```
android/
├── app/
│   ├── build.gradle            applicationId / versionCode / signingConfigs
│   └── src/main/
│       ├── AndroidManifest.xml 权限、Activity 声明、启动 Theme
│       ├── java/<包名>/        Activity 一层一个文件 + Ui/ 工具类
│       └── res/                 layout / values / values-night / drawable
├── build.gradle                仓库级，锁 AGP 版本
└── gradle.properties
```

约定：
- 页面 = Activity，二级页独立 Activity（不要塞 Fragment 套娃）
- 公共 UI 收在 `widget/`（卡片内边距、行高、圆角、颜色都从这里取）
- 所有颜色/尺寸走 `res/values`，Java 里不写字面量

## 2. 环境

| 项 | 值 | 坑 |
|---|---|---|
| JDK | 17 | 用系统默认 JDK 常报 AGP 不兼容，显式 `JAVA_HOME` |
| Gradle | 8.7 | 与 AGP 版本绑定，升级要一起升 |
| compileSdk / targetSdk | 按商店要求 | targetSdk 太低会被拒 |

```bash
JAVA_HOME=~/.workbuddy/binaries/jdk/jdk-17.0.20.1+1 ./gradlew assembleRelease
```

## 3. Manifest 要点

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

- 权限能少不多；`QUERY_ALL_PACKAGES`、`READ_PHONE_STATE` 这类会被重点审
- 启动页用 `windowBackground` 主题，别做成空白页
- `android:usesCleartextTraffic` 若要开，必须有正当理由（内网设备管理就是正当的）
- `android:exported` 显式写，targetSdk 31+ 强制

## 4. 签名

`app/build.gradle`：

```gradle
signingConfigs {
    release {
        storeFile file("../keystore/release.jks")
        storePassword System.getenv("KS_PWD")
        keyAlias "app"
        keyPassword System.getenv("KS_PWD")
    }
}
```

- keystore 不进仓库，口令走环境变量
- **keystore 丢了就无法覆盖升级**，单独备份
- 上传商店用 `assembleRelease` 的 apk 或 `bundleRelease` 的 aab（看商店要求）

## 5. 演示模式

Manifest 里加一个入口 Activity 或在登录页放「先看看演示」按钮；
进入后把数据源切到本地 `assets/demo.json`，所有写操作弹「演示环境只读」。

## 6. 自查

```bash
./gradlew lint                      # 静态检查
./gradlew assembleRelease           # 出包
apksigner verify --print-certs app-release.apk   # 验签
aapt dump badging app-release.apk | head -5      # 包名/版本
```
