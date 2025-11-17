#!/usr/bin/env bash
set -e

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

echo "[Windows] 此脚本需在 Windows + Flutter Desktop 环境下执行。"

echo "[Windows] flutter pub get..."
flutter pub get

echo "[Windows] flutter build windows --release..."
flutter build windows --release

echo "[Windows] 构建完成，产物在 build/windows/x64/runner/Release/ 下。"
