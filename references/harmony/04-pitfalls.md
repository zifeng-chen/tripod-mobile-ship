# HarmonyOS · 踩坑速查

按"症状 → 原因 → 改法"记。

## ArkTS 编译期

| 症状 | 原因 | 改法 |
|---|---|---|
| `Object literal must correspond to some explicitly declared class` | 不允许无类型对象字面量 | 声明 `interface` 或 `Record<string, string>` |
| 用 `any`/`unknown` 报错 | ArkTS 禁用 | 联合类型 / 泛型 |
| 结构体赋值字段缺失报错 | 严格类型 | 补默认值或 `?` |
| 导入 `.ets` 路径报错 | 必须相对路径且带后缀规则 | 按工程约定写全 |

## 组件与状态

| 症状 | 原因 | 改法 |
|---|---|---|
| `@Builder` 改了数据不刷新 | 按值传参 | 传对象引用或改 `@Component` |
| `ForEach` 项变了不重绘 | key 用了固定值 | key 带会变的字段 |
| 一个组件挂两个 `bindSheet` 只有一个生效 | 鸿蒙只认最后一个 | 合并成一个 sheet，用状态区分 |
| `CardHeader` 把旁边的 Text 挤没 | 组件自带 `width('100%')` | 外层包 Row / 给 Text 加 `layoutWeight(1)` |
| 图标只画出第一段 | `Path` 拼多段 M 只渲染首个 | 用 `Image` 资源 |
| 二级页返回后数据丢 | 页面卸载 | 跨页状态放 `UI` 单例 |
| 冷启动安全区为 0 | 入口还没量到 | `EntryAbility` 里也量一次写入全局 |
| 切换主题自绘组件不变色 | 颜色被缓存 | 切主题时清缓存重建 |

## 构建与设备

| 症状 | 原因 | 改法 |
|---|---|---|
| `command not found: hvigorw` | PATH 没加 DevEco tools | export 三个 bin + `DEVECO_SDK_HOME` |
| 产物版本还是旧的 | 增量构建没认 `app.json5` | `hvigorw clean` 再编 |
| `assembleApp` 报 `Compress failed` | 打包工具要写 `/private/tempHapDir` | 自己 zip + `hap-sign-tool`（见 03-release） |
| `hdc` 报 `need connect-key` | 多 target | 加 `-t <target>` |
| 设备端脚本里 `for i in $(seq…)` 不生效 | 脚本 PATH 不含 /bin | 全用绝对路径 `/bin/uitest`、`/bin/snapshot_display` |
| `snapshot_display` 帧冻住 / 点击丢失 | 宿主机并发发 hdc 命令 | 把连拍和点击放进**同一个设备端脚本** |
| 模拟器起不来报 `can not read uuid file` | 实例指向的镜像目录不存在 | 换一个已下载镜像的实例启动 |

## 审核相关

| 症状 | 原因 | 改法 |
|---|---|---|
| 改了代码，装上界面没变 | ① `assembleHap` 判 UP-TO-DATE 没重签；② `hdc install -r` 覆盖失败但报成功 | 先 `bm dump -n <包>` 核对 versionName；固化流程：`bm uninstall` → `install`（覆盖安装不可靠，直接卸载重装最稳） |
| 系统启动窗口一闪是白屏 | `startWindowBackground` 指到浅色 `app_bg`，图标还是带底色的方图 | 底色换成品牌深色（单独定义 `start_bg`，base/dark 同值），图标用**透明底**的白色字形；页内启动页复用同一张图，交接不跳色 |
| 启动页卡死、只能杀进程 | boot 里 `await` 的某一步（preferences / 网络探测）不返回，`splash=false` 永远执行不到 | 加看门狗：`setTimeout(() => { if (this.splash) { this.splash = false } }, 4000)`；iOS 同理在 `SplashView` 里 4 秒后 `finishOnce()`，并用 `finished` 标志防重复收尾 |
| 对比度 1.03（Text） | 透明画布图标被当文本取色 | 图标改矢量资源 |
| Canvas 锯齿 94.67 | 自绘细线边缘不干净 | 同上 |
| 提审报 `SelfTestVideos json format is incorrect` | 传了数组 | 传字符串 `"{\"objectIds\":[…]}"` |
| `app state can not be modified` | 版本在审 | 先 `cancel-review` |
| `cancel-review` 报 `Version status is incorrect` | 已经是草稿/驳回态 | 直接改，不用撤 |
| 提交后隐私政策又"缺" | 网页改版本信息清空了绑定 | 重新绑 `privacyAgreementId` |
