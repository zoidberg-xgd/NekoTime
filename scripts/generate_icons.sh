#!/bin/bash

# 图标生成脚本 - 从 source.png 生成所有平台的图标
# 包括应用图标和系统托盘图标

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_ICON="$PROJECT_ROOT/assets/icons/app_icon_source.png"

echo "🎨 NekoTime 图标生成工具"
echo "=========================="
echo "源图标: $SOURCE_ICON"
echo ""

# 检查源图标是否存在
if [ ! -f "$SOURCE_ICON" ]; then
    echo "❌ 错误: 源图标文件不存在: $SOURCE_ICON"
    exit 1
fi

# 1. 使用 flutter_launcher_icons 生成应用图标
echo "📱 生成应用图标..."
cd "$PROJECT_ROOT"
dart run flutter_launcher_icons

echo "✅ 应用图标生成完成"
echo ""

# 2. 生成系统托盘图标 (.ico)
echo "🔔 生成系统托盘图标..."

# 检查是否安装了 ImageMagick
if command -v convert &> /dev/null; then
    echo "使用 ImageMagick 生成 .ico 文件..."
    
    # 生成 Windows 托盘图标（多尺寸 .ico）
    convert "$SOURCE_ICON" -resize 256x256 \
        \( -clone 0 -resize 16x16 \) \
        \( -clone 0 -resize 32x32 \) \
        \( -clone 0 -resize 48x48 \) \
        \( -clone 0 -resize 64x64 \) \
        \( -clone 0 -resize 128x128 \) \
        \( -clone 0 -resize 256x256 \) \
        -delete 0 -colors 256 \
        "$PROJECT_ROOT/assets/icons/tray_icon.ico"
    
    echo "✅ 托盘图标生成完成: assets/icons/tray_icon.ico"
else
    echo "⚠️  警告: 未找到 ImageMagick (convert 命令)"
    echo "   托盘图标需要手动生成或安装 ImageMagick:"
    echo "   macOS: brew install imagemagick"
    echo "   Linux: sudo apt install imagemagick"
    echo "   Windows: choco install imagemagick"
    echo ""
    echo "   或者在线转换: https://convertio.co/png-ico/"
    
    # 如果已经有 tray_icon.ico，不报错
    if [ -f "$PROJECT_ROOT/assets/icons/tray_icon.ico" ]; then
        echo "   现有托盘图标已存在，将继续使用"
    fi
fi

echo ""
echo "=========================="
echo "✅ 所有图标生成完成！"
echo ""
echo "生成的图标:"
echo "  - macOS:   macos/Runner/Assets.xcassets/AppIcon.appiconset/"
echo "  - Windows: windows/runner/resources/app_icon.ico"
echo "  - Linux:   linux/runner/resources/app_icon.png"
echo "  - 托盘:    assets/icons/tray_icon.ico"
