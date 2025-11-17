#!/usr/bin/env bash
set -e

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

echo "[Android] flutter pub get..."
flutter pub get

echo "[Android] flutter build apk --release..."
flutter build apk --release

echo "[Android] flutter build appbundle --release..."
flutter build appbundle --release

echo "[Android] 构建完成，APK 在 build/app/outputs/flutter-apk/，AAB 在 build/app/outputs/bundle/release/ 下。"
