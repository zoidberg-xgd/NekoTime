.PHONY: help clean get test test-quick test-coverage analyze format build-macos build-windows build-linux run-macos run-windows run-linux

# 默认目标
help:
	@echo "NekoTime - 可用命令:"
	@echo ""
	@echo "开发命令:"
	@echo "  make get              - 获取依赖"
	@echo "  make clean            - 清理构建文件"
	@echo "  make format           - 格式化代码"
	@echo "  make analyze          - 代码分析"
	@echo ""
	@echo "测试命令:"
	@echo "  make test             - 运行完整测试套件"
	@echo "  make test-quick       - 快速测试（开发时）"
	@echo "  make test-coverage    - 生成覆盖率报告"
	@echo ""
	@echo "运行命令:"
	@echo "  make run-macos        - 运行 macOS 版本"
	@echo "  make run-windows      - 运行 Windows 版本"
	@echo "  make run-linux        - 运行 Linux 版本"
	@echo ""
	@echo "构建命令:"
	@echo "  make build-macos      - 构建 macOS Release"
	@echo "  make build-windows    - 构建 Windows Release"
	@echo "  make build-linux      - 构建 Linux Release"
	@echo ""

# 清理
clean:
	@echo "清理构建文件..."
	@flutter clean
	@rm -rf coverage/
	@rm -f test_report.txt
	@echo "✓ 清理完成"

# 获取依赖
get:
	@echo "获取项目依赖..."
	@flutter pub get
	@echo "✓ 依赖获取完成"

# 代码分析
analyze:
	@echo "运行代码分析..."
	@flutter analyze

# 格式化代码
format:
	@echo "格式化代码..."
	@flutter format .
	@echo "✓ 格式化完成"

# 运行测试
test:
	@echo "运行完整测试套件..."
	@./tool/run_tests.sh

# 快速测试
test-quick:
	@echo "运行快速测试..."
	@./tool/quick_test.sh

# 测试覆盖率
test-coverage:
	@echo "生成测试覆盖率报告..."
	@./tool/coverage_report.sh

# 运行应用（macOS）
run-macos:
	@echo "运行 macOS 版本..."
	@flutter run -d macos

# 运行应用（Windows）
run-windows:
	@echo "运行 Windows 版本..."
	@flutter run -d windows

# 运行应用（Linux）
run-linux:
	@echo "运行 Linux 版本..."
	@flutter run -d linux

# 构建 macOS
build-macos:
	@echo "构建 macOS Release..."
	@flutter build macos --release
	@echo "✓ 构建完成: build/macos/Build/Products/Release/NekoTime.app"

# 构建 Windows
build-windows:
	@echo "构建 Windows Release..."
	@flutter build windows --release
	@echo "✓ 构建完成: build/windows/x64/runner/Release/"

# 构建 Linux
build-linux:
	@echo "构建 Linux Release..."
	@flutter build linux --release
	@echo "✓ 构建完成: build/linux/x64/release/bundle/"

# 开发工作流
dev: get analyze test-quick
	@echo "✓ 开发环境准备完成"

# 发布前检查
pre-release: clean get analyze test test-coverage
	@echo "✓ 发布前检查完成"
