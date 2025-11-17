#!/usr/bin/env bash
set -e

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

echo "[iOS] flutter pub get..."
flutter pub get

echo "[iOS] flutter build ios --release..."
flutter build ios --release

echo "[iOS] 构建完成，请在 Xcode 中打开 ios/Runner.xcworkspace 进行签名和真机安装。"
