# HarmonyOS · 工程搭建与构建

## 1. 骨架

```
harmony/
├── AppScope/
│   ├── app.json5            bundleName / versionCode / versionName
│   └── resources/base/media/app_icon.png
├── entry/src/main/
│   ├── module.json5         deviceTypes / requestPermissions / abilities
│   ├── ets/
│   │   ├── entryability/    EntryAbility（窗口、安全区、主题）
│   │   ├── pages/           一级页（含 Index 容器）
│   │   ├── core/            网络、存储、会话、演示数据、协议文本
│   │   └── ui/              Theme(T/Pal) · Comp(卡片/弹层) · comp/图标 · tabs/
│   └── resources/
│       ├── base/element/{color,string,float}.json
│       ├── base/media/ic_*.svg
│       └── dark/element/color.json
├── build-profile.json5      签名（只在构建机，不入库）
└── oh-package.json5
```

## 2. 环境

```bash
DEVECO=/Applications/DevEco-Studio.app/Contents
export DEVECO_SDK_HOME=$DEVECO/sdk
export PATH=$DEVECO/tools/node/bin:$DEVECO/tools/ohpm/bin:$DEVECO/tools/hvigor/bin:$PATH
```

`DEVECO_SDK_HOME` **必须显式 export**，hvigor 不会自己从 DEVECO_HOME 推导。

设备：`hdc list targets`；真机需开发者模式 + USB 调试。模拟器：
`Emulator -start 'Mate X7'`，起来后 `hdc` 里出现 `127.0.0.1:5555`（结束后 `-stop` 关掉）。

## 3. module.json5 要点

```json5
"deviceTypes": ["phone", "tablet", "2in1"],
"requestPermissions": [
  { "name": "ohos.permission.INTERNET" },
  { "name": "ohos.permission.GET_NETWORK_INFO" }
]
```

- 声明了 2in1 就必须真的适配宽屏（`DuoLayout`/侧栏），否则审核会按单形态过、用户投诉
- 明文 HTTP 需要 `network_config` 白名单，别全局放开
- 启动图用 `startWindowIcon` + `startWindowBackground`，别留白屏

## 4. 构建

```bash
hvigorw --mode module -p product=default -p buildMode=release assembleHap --no-daemon
# 产物：entry/build/default/outputs/default/entry-default-signed.hap
```

- `-p buildMode=release`（驼峰！写成 `buildmode` 会被静默忽略，产物还是 debug）
- 改了 `AppScope/app.json5` 的版本但产物没变 → 加 `hvigorw clean` 再编
- 调试安装：`hdc install -r xxx.hap`

## 5. 演示模式

`core/Demo.ets` + `resources/rawfile/demo.json`：
登录页给「没有路由器？先看看演示」，进入后 `Api` 层直接返回本地数据，
写操作返回 `{ok:false,error:"演示环境只读"}`。

## 6. 自查

```bash
hdc shell bm dump -n <bundle> | head -20     # 版本/权限
hdc shell uitest dumpLayout -p /data/local/tmp/l.json   # 控件树（含 bounds）
```
