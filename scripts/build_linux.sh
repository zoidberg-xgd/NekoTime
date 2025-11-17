#!/bin/bash

# NekoTime Linux 构建脚本
# 用法: ./scripts/build_linux.sh

set -e

VERSION="2.1.0"
APP_NAME="NekoTime"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}===================================${NC}"
echo -e "${GREEN}${APP_NAME} Linux 构建脚本 v${VERSION}${NC}"
echo -e "${GREEN}===================================${NC}"
echo ""

# 检查 Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}[错误] 未找到 Flutter，请确保已安装并添加到 PATH${NC}"
    exit 1
fi

# 检查系统依赖
echo -e "${BLUE}[0/5] 检查系统依赖...${NC}"
MISSING_DEPS=""

for cmd in clang cmake ninja pkg-config; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_DEPS="$MISSING_DEPS $cmd"
    fi
done

if [ ! -z "$MISSING_DEPS" ]; then
    echo -e "${YELLOW}警告: 缺少以下依赖:$MISSING_DEPS${NC}"
    echo -e "${YELLOW}请先安装依赖，参考 README.md 中的说明${NC}"
    echo ""
    read -p "是否继续? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 清理旧构建
echo -e "${BLUE}[1/5] 清理旧构建...${NC}"
flutter clean
flutter pub get
echo -e "${GREEN}✓ 清理完成${NC}"
echo ""

# 构建 Release 版本
echo -e "${BLUE}[2/5] 构建 Linux Release 版本...${NC}"
flutter build linux --release
echo -e "${GREEN}✓ 构建完成${NC}"
echo ""

# 创建分发目录
echo -e "${BLUE}[3/5] 准备打包...${NC}"
mkdir -p dist
RELEASE_DIR="build/linux/x64/release/bundle"
TAR_NAME="${APP_NAME}-Linux-x64-v${VERSION}.tar.gz"

# 打包 tar.gz
echo -e "${BLUE}[4/5] 创建 tar.gz 压缩包...${NC}"
cd build/linux/x64/release
tar -czf "../../../../dist/${TAR_NAME}" bundle
cd -
echo -e "${GREEN}✓ 打包完成${NC}"
echo ""

# 创建 README
echo -e "${BLUE}[5/5] 创建 README...${NC}"
cat > "${RELEASE_DIR}/README.txt" << EOF
NekoTime - 猫铃时钟 v${VERSION}
==============================

安装说明:
1. 解压到任意目录
2. 运行 ./digital_clock
3. 如遇权限问题: chmod +x digital_clock

系统要求:
- Linux 发行版（Ubuntu 20.04+, Fedora 35+, Arch Linux 等）
- GTK 3.0+
- 窗口合成器（用于透明效果）

推荐桌面环境:
- GNOME 40+
- KDE Plasma 5.20+
- Cinnamon 5.0+

如遇问题:
- 查看完整文档: https://github.com/zoidberg-xgd/NekoTime
- 提交 Issue: https://github.com/zoidberg-xgd/NekoTime/issues
- Linux 兼容性: 查看 LINUX_COMPATIBILITY.md

主题目录:
~/.local/share/digital_clock/themes/

日志目录:
~/.local/share/digital_clock/logs/

常见问题:
1. 透明效果不工作
   - 确保桌面环境启用了合成器
   - GNOME Wayland: 需要 AppIndicator 扩展

2. 托盘图标不显示
   - 安装 libayatana-appindicator3
   - GNOME: 安装 appindicator 扩展

3. 缺少依赖
   - Ubuntu/Debian:
     sudo apt-get install libgtk-3-0 libayatana-appindicator3-1
   - Fedora:
     sudo dnf install gtk3 libayatana-appindicator-gtk3
   - Arch:
     sudo pacman -S gtk3

EOF

echo -e "${GREEN}✓ README.txt 已创建${NC}"
echo ""

# 显示结果
echo -e "${GREEN}===================================${NC}"
echo -e "${GREEN}构建成功！${NC}"
echo -e "${GREEN}===================================${NC}"
echo ""
echo -e "${BLUE}输出文件:${NC} dist/${TAR_NAME}"
ls -lh "dist/${TAR_NAME}"
echo ""
echo -e "${BLUE}可执行文件位置:${NC}"
echo "${RELEASE_DIR}/digital_clock"
echo ""
echo -e "${YELLOW}提示:${NC} 可以直接运行以下命令测试:"
echo "  cd ${RELEASE_DIR}"
echo "  ./digital_clock"
echo ""

# 询问是否创建 AppImage（可选）
if command -v appimagetool &> /dev/null; then
    echo -e "${YELLOW}检测到 appimagetool，是否创建 AppImage? (y/N)${NC}"
    read -p "" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}创建 AppImage...${NC}"
        # 这里需要 AppDir 结构，留给用户自定义
        echo -e "${YELLOW}AppImage 创建需要额外配置，请参考 Linux 打包文档${NC}"
    fi
fi

echo -e "${GREEN}完成！${NC}"
