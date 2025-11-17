#!/bin/bash

# NekoTime 全平台构建脚本
# 用法: ./scripts/build_all.sh [平台]
# 平台: macos, windows, linux, all

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

VERSION="2.1.0"
APP_NAME="NekoTime"

echo -e "${GREEN}=== NekoTime 构建脚本 v${VERSION} ===${NC}"
echo ""

# 清理旧构建
clean_build() {
    echo -e "${YELLOW}清理旧构建...${NC}"
    flutter clean
    flutter pub get
    echo -e "${GREEN}✓ 清理完成${NC}"
    echo ""
}

# 构建 macOS
build_macos() {
    echo -e "${GREEN}=== 构建 macOS 版本 ===${NC}"
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}✗ 错误: macOS 构建必须在 macOS 系统上进行${NC}"
        return 1
    fi
    
    flutter build macos --release
    
    # 打包
    MACOS_APP="build/macos/Build/Products/Release/digital_clock.app"
    DIST_DIR="dist"
    mkdir -p "$DIST_DIR"
    
    # 创建 DMG（可选，需要 create-dmg 工具）
    if command -v create-dmg &> /dev/null; then
        echo -e "${YELLOW}创建 DMG 安装包...${NC}"
        create-dmg \
            --volname "${APP_NAME}" \
            --window-pos 200 120 \
            --window-size 600 400 \
            --icon-size 100 \
            --icon "${APP_NAME}.app" 175 120 \
            --hide-extension "${APP_NAME}.app" \
            --app-drop-link 425 120 \
            "${DIST_DIR}/${APP_NAME}-macOS-v${VERSION}.dmg" \
            "$MACOS_APP"
    else
        # 创建 ZIP
        echo -e "${YELLOW}创建 ZIP 压缩包...${NC}"
        cd build/macos/Build/Products/Release
        zip -r "../../../../../${DIST_DIR}/${APP_NAME}-macOS-v${VERSION}.zip" digital_clock.app
        cd -
    fi
    
    echo -e "${GREEN}✓ macOS 构建完成${NC}"
    echo -e "  路径: ${DIST_DIR}/"
    ls -lh "$DIST_DIR"/*.{dmg,zip} 2>/dev/null || true
    echo ""
}

# 构建 Windows
build_windows() {
    echo -e "${GREEN}=== 构建 Windows 版本 ===${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo -e "${RED}✗ 错误: Windows 构建必须在 Windows 系统上进行${NC}"
        echo -e "${YELLOW}提示: 请在 Windows 上运行 scripts/build_windows.bat${NC}"
        return 1
    fi
    
    flutter build windows --release
    
    # 打包
    DIST_DIR="dist"
    mkdir -p "$DIST_DIR"
    
    echo -e "${YELLOW}创建便携版压缩包...${NC}"
    cd build/windows/x64/runner/Release
    7z a -tzip "../../../../../${DIST_DIR}/${APP_NAME}-Windows-v${VERSION}.zip" .
    cd -
    
    echo -e "${GREEN}✓ Windows 构建完成${NC}"
    echo -e "  路径: ${DIST_DIR}/${APP_NAME}-Windows-v${VERSION}.zip"
    echo ""
}

# 构建 Linux
build_linux() {
    echo -e "${GREEN}=== 构建 Linux 版本 ===${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${RED}✗ 错误: Linux 构建必须在 Linux 系统上进行${NC}"
        echo -e "${YELLOW}提示: 请在 Linux 上运行此脚本${NC}"
        return 1
    fi
    
    flutter build linux --release
    
    # 打包
    DIST_DIR="dist"
    mkdir -p "$DIST_DIR"
    
    echo -e "${YELLOW}创建 tar.gz 压缩包...${NC}"
    cd build/linux/x64/release
    tar -czf "../../../../${DIST_DIR}/${APP_NAME}-Linux-x64-v${VERSION}.tar.gz" bundle
    cd -
    
    echo -e "${GREEN}✓ Linux 构建完成${NC}"
    echo -e "  路径: ${DIST_DIR}/${APP_NAME}-Linux-x64-v${VERSION}.tar.gz"
    echo ""
}

# 创建源码包
create_source_archive() {
    echo -e "${GREEN}=== 创建源码归档 ===${NC}"
    
    DIST_DIR="dist"
    mkdir -p "$DIST_DIR"
    
    git archive --format=tar.gz --prefix="${APP_NAME}-v${VERSION}/" \
        -o "${DIST_DIR}/${APP_NAME}-Source-v${VERSION}.tar.gz" HEAD
    
    echo -e "${GREEN}✓ 源码归档创建完成${NC}"
    echo -e "  路径: ${DIST_DIR}/${APP_NAME}-Source-v${VERSION}.tar.gz"
    echo ""
}

# 显示使用说明
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  macos      - 构建 macOS 版本"
    echo "  windows    - 构建 Windows 版本"
    echo "  linux      - 构建 Linux 版本"
    echo "  all        - 构建当前平台版本"
    echo "  source     - 创建源码归档"
    echo "  clean      - 清理构建文件"
    echo "  help       - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 macos       # 构建 macOS"
    echo "  $0 all         # 构建当前平台所有版本"
    echo ""
}

# 主函数
main() {
    local platform="${1:-all}"
    
    case "$platform" in
        macos)
            clean_build
            build_macos
            ;;
        windows)
            clean_build
            build_windows
            ;;
        linux)
            clean_build
            build_linux
            ;;
        all)
            clean_build
            if [[ "$OSTYPE" == "darwin"* ]]; then
                build_macos
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                build_linux
            elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
                build_windows
            else
                echo -e "${RED}✗ 未知的操作系统: $OSTYPE${NC}"
                exit 1
            fi
            create_source_archive
            ;;
        source)
            create_source_archive
            ;;
        clean)
            clean_build
            echo -e "${GREEN}仅清理，不构建${NC}"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}✗ 错误: 未知选项 '$platform'${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}=== 构建完成 ===${NC}"
}

main "$@"
