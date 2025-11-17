#!/usr/bin/env bash
# NekoTime 测试覆盖率报告生成脚本

set -e

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

# 颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}生成测试覆盖率报告${NC}"
echo ""

# 运行测试并生成覆盖率
echo -e "${BLUE}[1/3] 运行测试...${NC}"
flutter test --coverage

# 检查覆盖率文件
if [ ! -f "coverage/lcov.info" ]; then
    echo -e "${YELLOW}未生成覆盖率文件${NC}"
    exit 1
fi

echo -e "${GREEN}✓ 测试完成${NC}"
echo ""

# 生成 HTML 报告
echo -e "${BLUE}[2/3] 生成 HTML 报告...${NC}"
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html --ignore-errors source
    echo -e "${GREEN}✓ HTML 报告已生成${NC}"
    echo -e "${YELLOW}查看报告: open coverage/html/index.html${NC}"
else
    echo -e "${YELLOW}⚠ 未安装 lcov/genhtml${NC}"
    echo -e "${YELLOW}提示: 在 macOS 上运行 'brew install lcov' 安装${NC}"
fi

echo ""

# 显示覆盖率摘要
echo -e "${BLUE}[3/3] 覆盖率摘要${NC}"
if command -v lcov &> /dev/null; then
    lcov --summary coverage/lcov.info 2>&1 | grep -E "lines\.\.\.|functions\.\.\."
else
    echo -e "${YELLOW}安装 lcov 可查看详细摘要${NC}"
fi

echo ""
echo -e "${GREEN}✓ 覆盖率报告生成完成${NC}"
