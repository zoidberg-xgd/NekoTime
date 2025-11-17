#!/usr/bin/env bash
# NekoTime 测试整合脚本
# 运行所有测试：单元测试、Widget测试、代码分析等

set -e

# 切换到项目根目录
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   NekoTime 测试整合脚本               ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo ""

# 检查Flutter环境
check_flutter() {
    echo -e "${BLUE}[1/6] 检查 Flutter 环境...${NC}"
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}✗ 错误: 未找到 Flutter，请先安装 Flutter SDK${NC}"
        exit 1
    fi
    flutter --version
    echo -e "${GREEN}✓ Flutter 环境正常${NC}"
    echo ""
}

# 获取依赖
get_dependencies() {
    echo -e "${BLUE}[2/6] 获取项目依赖...${NC}"
    flutter pub get
    echo -e "${GREEN}✓ 依赖获取完成${NC}"
    echo ""
}

# 运行代码分析
run_analyze() {
    echo -e "${BLUE}[3/6] 运行代码分析 (flutter analyze)...${NC}"
    if flutter analyze --no-fatal-infos; then
        echo -e "${GREEN}✓ 代码分析通过${NC}"
        ANALYZE_STATUS="✓ 通过"
    else
        echo -e "${YELLOW}⚠ 代码分析发现问题${NC}"
        ANALYZE_STATUS="⚠ 有警告"
    fi
    echo ""
}

# 运行格式检查
run_format_check() {
    echo -e "${BLUE}[4/6] 检查代码格式...${NC}"
    # 检查是否有未格式化的文件
    if flutter format --set-exit-if-changed --dry-run lib/ test/ > /dev/null 2>&1; then
        echo -e "${GREEN}✓ 代码格式正确${NC}"
        FORMAT_STATUS="✓ 通过"
    else
        echo -e "${YELLOW}⚠ 发现未格式化的文件，运行 'flutter format .' 可自动格式化${NC}"
        FORMAT_STATUS="⚠ 需格式化"
    fi
    echo ""
}

# 运行单元测试
run_tests() {
    echo -e "${BLUE}[5/6] 运行单元测试...${NC}"
    
    # 检查是否存在测试文件
    if [ ! -d "test" ] || [ -z "$(ls -A test 2>/dev/null)" ]; then
        echo -e "${YELLOW}⚠ 未找到测试文件${NC}"
        TEST_STATUS="⚠ 无测试"
        echo ""
        return
    fi
    
    # 运行测试并生成覆盖率报告
    if flutter test --coverage; then
        echo -e "${GREEN}✓ 测试通过${NC}"
        TEST_STATUS="✓ 通过"
        
        # 如果有覆盖率数据，显示覆盖率信息
        if [ -f "coverage/lcov.info" ]; then
            echo -e "${YELLOW}覆盖率报告已生成: coverage/lcov.info${NC}"
            
            # 如果安装了lcov，生成HTML报告
            if command -v genhtml &> /dev/null; then
                echo -e "${BLUE}生成 HTML 覆盖率报告...${NC}"
                genhtml coverage/lcov.info -o coverage/html > /dev/null 2>&1
                echo -e "${GREEN}✓ HTML 覆盖率报告: coverage/html/index.html${NC}"
            else
                echo -e "${YELLOW}提示: 安装 lcov 可生成 HTML 覆盖率报告${NC}"
            fi
        fi
    else
        echo -e "${RED}✗ 测试失败${NC}"
        TEST_STATUS="✗ 失败"
    fi
    echo ""
}

# 运行集成测试（如果存在）
run_integration_tests() {
    echo -e "${BLUE}[6/6] 检查集成测试...${NC}"
    
    if [ -d "integration_test" ] && [ -n "$(ls -A integration_test 2>/dev/null)" ]; then
        echo -e "${YELLOW}发现集成测试，是否运行? (y/N)${NC}"
        read -p "" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if flutter test integration_test; then
                echo -e "${GREEN}✓ 集成测试通过${NC}"
                INTEGRATION_STATUS="✓ 通过"
            else
                echo -e "${RED}✗ 集成测试失败${NC}"
                INTEGRATION_STATUS="✗ 失败"
            fi
        else
            INTEGRATION_STATUS="⊘ 跳过"
        fi
    else
        echo -e "${YELLOW}未找到集成测试${NC}"
        INTEGRATION_STATUS="⊘ 无测试"
    fi
    echo ""
}

# 生成测试报告
generate_report() {
    echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          测试结果汇总                 ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "项目: ${BLUE}NekoTime${NC}"
    echo -e "时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo -e "代码分析:     ${ANALYZE_STATUS}"
    echo -e "代码格式:     ${FORMAT_STATUS}"
    echo -e "单元测试:     ${TEST_STATUS}"
    echo -e "集成测试:     ${INTEGRATION_STATUS}"
    echo ""
    
    # 将报告保存到文件
    cat > test_report.txt << EOF
NekoTime 测试报告
================

生成时间: $(date '+%Y-%m-%d %H:%M:%S')

测试结果:
---------
代码分析: ${ANALYZE_STATUS}
代码格式: ${FORMAT_STATUS}
单元测试: ${TEST_STATUS}
集成测试: ${INTEGRATION_STATUS}

Flutter 版本:
$(flutter --version)

EOF
    
    echo -e "${GREEN}✓ 测试报告已保存到: test_report.txt${NC}"
    echo ""
}

# 主函数
main() {
    # 初始化状态变量
    ANALYZE_STATUS="未运行"
    FORMAT_STATUS="未运行"
    TEST_STATUS="未运行"
    INTEGRATION_STATUS="未运行"
    
    # 运行所有检查
    check_flutter
    get_dependencies
    run_analyze
    run_format_check
    run_tests
    run_integration_tests
    
    # 生成报告
    generate_report
    
    echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         测试完成！                    ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
}

# 运行主函数
main
