#!/usr/bin/env bash
# NekoTime 快速测试脚本
# 仅运行基础检查，适合开发时快速验证

set -e

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

# 颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}NekoTime 快速测试${NC}"
echo ""

echo -e "${BLUE}[1/3] 代码分析...${NC}"
flutter analyze --no-fatal-infos

echo ""
echo -e "${BLUE}[2/3] 格式检查...${NC}"
flutter format --set-exit-if-changed --dry-run lib/ test/ || true

echo ""
echo -e "${BLUE}[3/3] 运行测试...${NC}"
flutter test

echo ""
echo -e "${GREEN}✓ 快速测试完成${NC}"
