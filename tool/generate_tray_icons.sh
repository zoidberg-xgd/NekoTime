#!/usr/bin/env bash
set -e

# 生成托盘模板/图标（macOS 模板黑色单色；Windows/Linux PNG）
# 依赖：ImageMagick (magick/convert)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR%/tool}"
SRC_ICON="$PROJECT_ROOT/assets/icons/icon.png"
MAC_TEMPLATE_OUT="$PROJECT_ROOT/assets/icons/icon_template.png"
WIN_OUT="$PROJECT_ROOT/assets/icons/tray_win.png"
LINUX_OUT="$PROJECT_ROOT/assets/icons/tray_linux.png"

if command -v magick >/dev/null 2>&1; then
  CMD=magick
elif command -v convert >/dev/null 2>&1; then
  CMD=convert
else
  echo "未找到 ImageMagick，请先安装: brew install imagemagick" >&2
  exit 1
fi

if [ ! -f "$SRC_ICON" ]; then
  echo "源图标不存在: $SRC_ICON" >&2
  exit 1
fi

mkdir -p "$PROJECT_ROOT/assets/icons"

# macOS template：将透明区域提取为 alpha，将前景转黑色，保持透明背景
# 方法：转灰度 -> 阈值提取 alpha -> 以黑色填充前景
$CMD "$SRC_ICON" \
  -alpha extract -threshold 30% \
  -write mpr:alpha +delete \
  "$SRC_ICON" -fill black -colorize 100 \
  -alpha off -compose copyopacity mpr:alpha -composite \
  -resize 18x18 \( +clone -resize 36x36 \) \
  "$MAC_TEMPLATE_OUT"

echo "生成 macOS 模板图标: $MAC_TEMPLATE_OUT"

# Windows/Linux 托盘：生成 24x24 的清晰 PNG（保持透明）
$CMD "$SRC_ICON" -resize 24x24 "$WIN_OUT"
$CMD "$SRC_ICON" -resize 24x24 "$LINUX_OUT"

echo "生成 Win/Linux 托盘图标: $WIN_OUT, $LINUX_OUT"

echo "完成。"
