#!/bin/bash

# Linux 运行时依赖安装脚本
# 修复 "No rendering surface available" 错误

set -e

echo "🐧 NekoTime Linux 依赖安装工具"
echo "================================"
echo ""

# 检测 Linux 发行版
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo "❌ 无法检测 Linux 发行版"
    exit 1
fi

echo "检测到系统: $PRETTY_NAME"
echo ""

# 根据发行版安装依赖
case $OS in
    ubuntu|debian|linuxmint|pop)
        echo "📦 安装 Ubuntu/Debian 依赖..."
        sudo apt-get update
        sudo apt-get install -y \
            libgtk-3-0 \
            libglib2.0-0 \
            libgdk-pixbuf2.0-0 \
            libcairo2 \
            libpango-1.0-0 \
            libpangocairo-1.0-0 \
            libatk1.0-0 \
            libatk-bridge2.0-0 \
            libegl1 \
            libgl1 \
            libgles2 \
            libglx0 \
            libx11-6 \
            libxcomposite1 \
            libxdamage1 \
            libxext6 \
            libxfixes3 \
            libxi6 \
            libxrandr2 \
            libxrender1 \
            libxcursor1 \
            libxinerama1 \
            libayatana-appindicator3-1
        
        echo "✅ Ubuntu/Debian 依赖安装完成"
        ;;
        
    fedora|rhel|centos)
        echo "📦 安装 Fedora/RHEL 依赖..."
        sudo dnf install -y \
            gtk3 \
            glib2 \
            gdk-pixbuf2 \
            cairo \
            pango \
            atk \
            at-spi2-atk \
            mesa-libEGL \
            mesa-libGL \
            mesa-libGLES \
            libX11 \
            libXcomposite \
            libXdamage \
            libXext \
            libXfixes \
            libXi \
            libXrandr \
            libXrender \
            libXcursor \
            libXinerama \
            libayatana-appindicator-gtk3
        
        echo "✅ Fedora/RHEL 依赖安装完成"
        ;;
        
    arch|manjaro)
        echo "📦 安装 Arch Linux 依赖..."
        sudo pacman -Syu --noconfirm \
            gtk3 \
            glib2 \
            gdk-pixbuf2 \
            cairo \
            pango \
            atk \
            at-spi2-core \
            mesa \
            libx11 \
            libxcomposite \
            libxdamage \
            libxext \
            libxfixes \
            libxi \
            libxrandr \
            libxrender \
            libxcursor \
            libxinerama \
            libayatana-appindicator
        
        echo "✅ Arch Linux 依赖安装完成"
        ;;
        
    opensuse*|suse)
        echo "📦 安装 openSUSE 依赖..."
        sudo zypper install -y \
            gtk3 \
            glib2 \
            gdk-pixbuf \
            cairo \
            pango \
            atk \
            at-spi2-core \
            Mesa-libEGL1 \
            Mesa-libGL1 \
            libX11-6 \
            libXcomposite1 \
            libXdamage1 \
            libXext6 \
            libXfixes3 \
            libXi6 \
            libXrandr2 \
            libXrender1 \
            libXcursor1 \
            libXinerama1 \
            libayatana-appindicator3-1
        
        echo "✅ openSUSE 依赖安装完成"
        ;;
        
    *)
        echo "❌ 不支持的发行版: $OS"
        echo ""
        echo "请手动安装以下依赖:"
        echo "  - GTK 3"
        echo "  - GLib 2.0"
        echo "  - Mesa (OpenGL/EGL)"
        echo "  - X11 库"
        echo "  - AppIndicator"
        exit 1
        ;;
esac

echo ""
echo "🔍 验证依赖..."

# 检查关键库
MISSING=0

check_lib() {
    if ldconfig -p | grep -q "$1"; then
        echo "  ✅ $1"
    else
        echo "  ❌ $1 (缺失)"
        MISSING=1
    fi
}

check_lib "libgtk-3"
check_lib "libEGL"
check_lib "libGL"
check_lib "libX11"

echo ""

if [ $MISSING -eq 0 ]; then
    echo "✅ 所有依赖已正确安装！"
    echo ""
    echo "现在可以运行 NekoTime:"
    echo "  ./neko_time"
else
    echo "⚠️  仍有依赖缺失，请检查上面的输出"
fi

echo ""
echo "📚 常见问题:"
echo "  1. 仍然黑屏? 尝试设置环境变量:"
echo "     export GDK_BACKEND=x11"
echo "     ./neko_time"
echo ""
echo "  2. Wayland 用户:"
echo "     部分功能可能需要 XWayland"
echo "     确保 xwayland 已安装"
echo ""
echo "  3. 透明效果不工作?"
echo "     检查桌面环境是否启用了合成器"
