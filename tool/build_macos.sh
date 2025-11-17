#!/usr/bin/env bash
set -e

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

echo "[macOS] flutter pub get..."
flutter pub get

echo "[macOS] flutter build macos --release..."
flutter build macos --release

echo "[macOS] 构建完成，产物在 build/macos/Build/Products/Release/ 下。"
