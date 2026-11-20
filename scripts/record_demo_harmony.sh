#!/bin/bash
# 鸿蒙演示录屏：设备没有 screenrecord、宿主机又拿不到屏幕录制权限时用这个。
#
# 原理：把「连拍 + 操作」放进**同一个设备端脚本**里跑（避免跨 hdc 会话丢点击），
#      跑完把 JPEG 拉回来用 ffmpeg 合成。约 5~6 fps，足够看清每一步。
#
# 用法：
#   bash record_demo_harmony.sh <包名> <步骤文件> <输出.mp4> [总帧数]
#
# 步骤文件每行一条（空行和 # 注释忽略）：
#   sleep 3
#   tap 159 1521
#   swipe 1105 1800 1105 900
#   back
#   keyevent Home
#
# 需要的坐标怎么拿：
#   hdc shell uitest dumpLayout -p /data/local/tmp/l.json
#   hdc file recv /data/local/tmp/l.json ./l.json     # 里面每个节点有 bounds
set -o pipefail
BUNDLE=${1:?用法: record_demo_harmony.sh <包名> <步骤文件> <输出.mp4> [帧数]}
STEPS=${2:?缺步骤文件}
OUT=${3:-/tmp/demo.mp4}
FRAMES=${4:-900}
H=${HDC:-hdc}          # 需要时用 HDC="/path/to/hdc -t 127.0.0.1:5555" 覆盖
TMP=$(mktemp -d)

# ---- 1. 生成设备端脚本
DEV=$TMP/ondevice.sh
{
  echo '#!/system/bin/sh'
  echo "D=/data/local/tmp/vid; rm -rf \$D; mkdir -p \$D; i=0"
  echo 'cap() {'
  echo "  while [ \$i -lt $FRAMES ]; do i=\$((i+1)); /bin/snapshot_display -f \$D/f\$i.jpeg >/dev/null 2>&1; done"
  echo '}'
  echo 'cap &'
  echo 'sleep 1'
  echo "/bin/aa start -a EntryAbility -b $BUNDLE >/dev/null 2>&1"
  while IFS= read -r line; do
    case "$line" in
      ''|'#'*) continue ;;
      sleep*) echo "/bin/sleep ${line#sleep }" ;;
      tap*) set -- $line; echo "/bin/uitest uiInput click $2 $3" ;;
      swipe*) set -- $line; echo "/bin/uitest uiInput swipe $2 $3 $4 $5 700" ;;
      back) echo "/bin/uitest uiInput keyEvent Back" ;;
      keyevent*) echo "/bin/uitest uiInput keyEvent ${line#keyevent }" ;;
      *) echo "# 跳过无法识别的行: $line" ;;
    esac
  done < "$STEPS"
  echo 'wait'
  echo "echo frames=\$(ls \$D | wc -l)"
} > "$DEV"

# ---- 2. 推上去跑
$H file send "$DEV" /data/local/tmp/rec_demo.sh >/dev/null
$H shell sh /data/local/tmp/rec_demo.sh | tail -1

# ---- 3. 拉回帧、按序号重命名（ffmpeg 要零填充）
$H shell 'cd /data/local/tmp/vid && tar cf /data/local/tmp/vid.tar f*.jpeg' >/dev/null 2>&1
$H file recv /data/local/tmp/vid.tar "$TMP/vid.tar" >/dev/null
mkdir -p "$TMP/frames"
tar xf "$TMP/vid.tar" -C "$TMP/frames"
( cd "$TMP/frames" && for f in f*.jpeg; do n=${f#f}; n=${n%.jpeg}; mv "$f" "$(printf 'g%04d.jpeg' "$n")"; done )

# ---- 4. 合成
N=$(ls "$TMP"/frames/g*.jpeg 2>/dev/null | wc -l | tr -d ' ')
[ "$N" -gt 0 ] || { echo "没抓到帧"; exit 1; }
FPS=${FPS:-6}
ffmpeg -y -framerate "$FPS" -start_number 1 -i "$TMP/frames/g%04d.jpeg" \
  -vf "scale=720:-2" -c:v libx264 -pix_fmt yuv420p -crf 22 "$OUT" 2>&1 | tail -2
echo "合成完成：$OUT（$N 帧）"
