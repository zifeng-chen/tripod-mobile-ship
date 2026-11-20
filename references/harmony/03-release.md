# HarmonyOS · 打包与上架（AGC）

## 1. 证书与 Profile（一次性）

```bash
CLI="node $HOME/.workbuddy/skills/hmos-connect-api-cli-skill/scripts/connect-api-cli.js"

$CLI provision csr-generate --alias app --pwd '<口令>' --sdk-path "$DEVECO_HOME/Contents/sdk"
$CLI provision cert-create --csr .certs/<id>/*.csr --cert-name app-release --cert-type 2   # 2=发布
$CLI provision profile-create --name app-release --type 2 --cert <certId> -a "$APPID"
```

材料三件套：`key_*.p12` + `cert_*.cer` + `profile_*.p7b`，路径写进
`build-profile.json5` 的 `signingConfigs[0].material`（口令用 CLI 加密后填）。
这份配置**只在构建机**，不要入库。

## 2. 出 `.app`（AGC 只收这个）

```bash
hvigorw -p product=default -p buildMode=release assembleApp --no-daemon
```

**坑**：`PackageApp` 会调 `app_packing_tool.jar`，它写死往 `/private/tempHapDir`
解压，普通用户建不了 → `Compress failed`。可用的绕法：

```bash
# 1) 让它跑到失败（失败前 hap 与 pac.json/pack.info 已产出）
hvigorw -p product=default -p buildMode=release assembleApp --no-daemon || true

# 2) 自己 zip（三文件平铺）
cd /tmp/appkit && zip -X -r out.app pac.json pack.info entry-default.hap

# 3) 发布证书签名
java -jar $SDK/default/openharmony/toolchains/lib/hap-sign-tool.jar sign-app \
  -mode localSign -signAlg SHA256withECDSA \
  -keystoreFile key.p12 -keystorePwd '<口令>' -keyAlias app -keyPwd '<口令>' \
  -appCertFile cert.cer -profileFile profile.p7b -inFile out.app -outFile final.app
```

签名后必须验：包名、版本、`buildMode=release`、`签名 type=release`、设备数=0。

## 3. 提审命令

```bash
$CLI publish app-id -p com.example.app               # 取 appId
$CLI upload file -a $APP -f dist/x.app -r 1          # 1=全量, 6=测试
$CLI publish compile-status -a $APP --pkg-ids <pkg>  # successStatus 0 = 通过（约 4 分钟）
$CLI publish submit -a $APP -r 1 --remark "…"
$CLI publish version-list -a $APP                    # 查 state
$CLI publish cancel-review -a $APP -v <versionId>    # 撤回
```

### state 速查

| state | 含义 | 能做什么 |
|---|---|---|
| 1 | 驳回待修改 | 直接传新包 |
| 4 | 审核中 | 只读 |
| 7 | 草稿 | 可改可传 |
| 11 | 已撤回 | 可改可传 |
| 12 | 已提审 | 只读 |

审核期间 `upload` / `app-info-update` 都会被拒（`app state can not be modified`）→ 先 `cancel-review`。

## 4. 提审前资料（缺一个就报错）

| 报错 | 补法 |
|---|---|
| `PrivacyPolicy is necessary` | `app-info-update` 绑 `privacyAgreementId` + `userAgreementIds` |
| `Description is necessary` | `language-update` 填 `appDesc` |
| `BriefInfo is necessary` | 同上补 `briefInfo` |

```bash
$CLI publish app-info-update -a $APP --body ai.json
$CLI publish language-update -a $APP --body lang.json
```

`lang.json`：`{lang, appName, briefInfo, appDesc, newFeatures}`。

## 5. 自测文件（演示录屏）

```bash
$CLI upload file -a $APP -f demo.mp4 --no-bind      # 拿 objectId
# 再写字段，注意是「字符串形式的 JSON」
{"selfTestVideos": "{\"objectIds\":[\"CN/…/demo.mp4\"]}"}
```

**实测该字段在网页「应用审核信息」里不显示**。若审核明确要自测文件，
让用户在网页手动上传：撤审 → 页面变可编辑 → 上传 → 再提审。

## 6. 常见坑

- 网页上改过「版本信息」→ 版本退回草稿 **且清空隐私协议绑定**，提交前重绑
- `publish submit` 的 appId 需在 query 里，CLI 放错位置会一直 400（需要补丁）
- `-p` 必须写 `buildMode`（驼峰），写错静默变 debug
- `hdc` 有多个 target 时报 `need connect-key`，所有命令加 `-t <target>`
