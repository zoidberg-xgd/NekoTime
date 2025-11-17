#!/usr/bin/env bash
set -e

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

echo "[Linux] 此脚本需在 Linux + Flutter Desktop 环境下执行。"

echo "[Linux] flutter pub get..."
flutter pub get

echo "[Linux] flutter build linux --release..."
flutter build linux --release

echo "[Linux] 构建完成，产物在 build/linux/x64/release/bundle/ 下。"
