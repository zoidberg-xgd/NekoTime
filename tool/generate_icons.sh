#!/usr/bin/env bash
set -e

# 项目根目录（根据你当前路径修改，这里假设脚本在 tool/ 下）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR%/tool}"

ICON_SOURCE="$PROJECT_ROOT/assets/icons/app_icon_source.png"

echo "[1/2] 检查依赖 (flutter)..."
if ! command -v flutter >/dev/null 2>&1; then
  echo "错误: 未找到 flutter 命令，请先安装 Flutter 并配置好环境变量。" >&2
  exit 1
fi

if [ ! -f "$ICON_SOURCE" ]; then
  echo "错误: 找不到源图标文件: $ICON_SOURCE" >&2
  exit 1
fi

echo "[2/2] 使用 flutter_launcher_icons 生成多平台图标..."
cd "$PROJECT_ROOT"
flutter pub get > /dev/null
flutter pub run flutter_launcher_icons

echo "完成: 已从 $ICON_SOURCE 为各平台生成应用图标。"
