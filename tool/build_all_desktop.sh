#!/usr/bin/env bash
set -e

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

echo "[ALL DESKTOP] flutter pub get..."
flutter pub get

echo "[ALL DESKTOP] 尝试构建 macOS / Windows / Linux（当前系统支持哪个就构建哪个）..."

UNAME_OUT="$(uname -s)"
case "${UNAME_OUT}" in
    Darwin*)  
      echo "[ALL DESKTOP] 当前为 macOS，执行 flutter build macos --release";
      flutter build macos --release;
      ;;
    Linux*)   
      echo "[ALL DESKTOP] 当前为 Linux，执行 flutter build linux --release";
      flutter build linux --release;
      ;;
    MINGW*|MSYS*|CYGWIN*)
      echo "[ALL DESKTOP] 当前为 Windows，执行 flutter build windows --release";
      flutter build windows --release;
      ;;
    *)        
      echo "[ALL DESKTOP] 未识别的桌面平台：${UNAME_OUT}，不进行构建";
      ;;
esac

echo "[ALL DESKTOP] 完成。"
