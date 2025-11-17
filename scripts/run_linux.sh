#!/bin/bash

# NekoTime Linux 启动脚本
# 自动处理常见的图形和依赖问题

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检测可执行文件位置（脚本可能在根目录或 scripts/ 目录）
if [ -f "$SCRIPT_DIR/neko_time" ]; then
    EXECUTABLE="$SCRIPT_DIR/neko_time"
    APP_DIR="$SCRIPT_DIR"
elif [ -f "$SCRIPT_DIR/../neko_time" ]; then
    EXECUTABLE="$SCRIPT_DIR/../neko_time"
    APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
    echo "❌ 错误: 找不到 neko_time 可执行文件"
    echo "   请确保 neko_time 与此脚本在同一目录"
    echo "   当前目录: $SCRIPT_DIR"
    ls -la "$SCRIPT_DIR" | head -10
    exit 1
fi

echo "🐱 NekoTime 启动中..."
echo "📂 应用目录: $APP_DIR"
echo "🚀 可执行文件: $EXECUTABLE"

# 确保可执行权限
chmod +x "$EXECUTABLE"

# 检查关键依赖
echo "🔍 检查依赖..."
MISSING_DEPS=()

if ! ldconfig -p | grep -q "libgtk-3"; then
    MISSING_DEPS+=("libgtk-3")
fi

if ! ldconfig -p | grep -q "libEGL"; then
    MISSING_DEPS+=("libEGL")
fi

if ! ldconfig -p | grep -q "libGL"; then
    MISSING_DEPS+=("libGL")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "⚠️  检测到缺失的依赖:"
    for dep in "${MISSING_DEPS[@]}"; do
        echo "  - $dep"
    done
    echo ""
    echo "请运行依赖安装脚本:"
    echo "  sudo ./scripts/install_linux_deps.sh"
    echo ""
    read -p "是否继续启动? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 设置环境变量以修复常见问题
export GDK_BACKEND=x11  # 强制使用 X11 后端（避免 Wayland 问题）
export LIBGL_ALWAYS_SOFTWARE=0  # 使用硬件加速
export MESA_GL_VERSION_OVERRIDE=3.3  # 确保 OpenGL 版本

# 检测桌面环境
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    echo "ℹ️  检测到 Wayland 会话"
    echo "   使用 XWayland 后端运行..."
    
    # 检查 xwayland 是否可用
    if ! command -v Xwayland &> /dev/null; then
        echo "⚠️  警告: 未找到 XWayland"
        echo "   某些功能可能无法正常工作"
        echo "   建议安装: sudo apt install xwayland"
    fi
fi

# 启动应用
cd "$APP_DIR"
"$EXECUTABLE" "$@" 2>&1

# 捕获退出状态
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ 应用异常退出 (退出码: $EXIT_CODE)"
    echo ""
    echo "🔧 常见问题解决方案:"
    echo ""
    echo "1. 黑屏或 'No rendering surface available':"
    echo "   sudo ./scripts/install_linux_deps.sh"
    echo ""
    echo "2. 透明效果不工作:"
    echo "   - 确保桌面环境启用了合成器"
    echo "   - GNOME: 默认启用"
    echo "   - KDE: 系统设置 → 显示 → 合成器"
    echo "   - Xfce: 设置 → 窗口管理器调整 → 合成器"
    echo ""
    echo "3. 托盘图标不显示:"
    echo "   - GNOME: 安装 AppIndicator 扩展"
    echo "   - sudo apt install gnome-shell-extension-appindicator"
    echo ""
    echo "4. 权限问题:"
    echo "   chmod +x neko_time"
    echo ""
    echo "5. 查看详细日志:"
    echo "   ./neko_time --verbose"
fi

exit $EXIT_CODE
