#!/usr/bin/env bash
set -e

# 项目根目录（根据你当前路径修改，这里假设脚本在 tool/ 下）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR%/tool}"

GIF_PATH="$PROJECT_ROOT/assets/gif/3.gif"
ICON_SOURCE="$PROJECT_ROOT/assets/icons/app_icon_source.png"

echo "[1/3] 检查依赖 (ImageMagick & flutter)..."
if command -v magick >/dev/null 2>&1; then
  CONVERT_CMD="magick"
elif command -v convert >/dev/null 2>&1; then
  CONVERT_CMD="convert"
else
  echo "错误: 未找到 ImageMagick 的 magick/convert 命令，请先安装 ImageMagick 后重试。" >&2
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "错误: 未找到 flutter 命令，请先安装 Flutter 并配置好环境变量。" >&2
  exit 1
fi

if [ ! -f "$GIF_PATH" ]; then
  echo "错误: 找不到 GIF 文件: $GIF_PATH" >&2
  exit 1
fi

mkdir -p "$PROJECT_ROOT/assets/icons"

echo "[2/3] 从 $GIF_PATH 提取首帧为 PNG: $ICON_SOURCE"
"$CONVERT_CMD" "$GIF_PATH[0]" "$ICON_SOURCE"

echo "[3/3] 使用 flutter_launcher_icons 生成多平台图标..."
cd "$PROJECT_ROOT"
flutter pub get
flutter pub run flutter_launcher_icons

echo "完成: 已从 3.gif 生成 app_icon_source.png，并为各平台生成应用图标。"
