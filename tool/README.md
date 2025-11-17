# NekoTime 工具脚本

本目录包含用于构建、测试和开发 NekoTime 的实用脚本。

## 📁 脚本列表

### 构建脚本

| 脚本 | 用途 | 平台 |
|------|------|------|
| `build_all_desktop.sh` | 构建当前平台桌面版本 | macOS/Windows/Linux |
| `build_macos.sh` | 构建 macOS 版本 | macOS |
| `build_windows.sh` | 构建 Windows 版本 | Windows |
| `build_linux.sh` | 构建 Linux 版本 | Linux |
| `build_android.sh` | 构建 Android 版本 | 全平台 |
| `build_ios.sh` | 构建 iOS 版本 | macOS |

### 测试脚本

| 脚本 | 用途 | 说明 |
|------|------|------|
| `run_tests.sh` | 完整测试套件 | 运行所有测试和检查 |
| `quick_test.sh` | 快速测试 | 开发时快速验证 |
| `coverage_report.sh` | 覆盖率报告 | 生成测试覆盖率报告 |

### 其他工具

| 脚本 | 用途 |
|------|------|
| `generate_icons.sh` | 生成应用图标 |

## 🚀 使用方法

### 构建脚本

```bash
# 构建当前平台
./tool/build_all_desktop.sh

# 构建特定平台
./tool/build_macos.sh      # macOS
./tool/build_windows.sh    # Windows
./tool/build_linux.sh      # Linux
```

### 测试脚本

```bash
# 完整测试（推荐）
./tool/run_tests.sh

# 快速测试（开发时）
./tool/quick_test.sh

# 生成覆盖率报告
./tool/coverage_report.sh
```

## 📊 测试脚本详细说明

### `run_tests.sh` - 完整测试套件

**功能**:
- ✓ 检查 Flutter 环境
- ✓ 获取项目依赖
- ✓ 运行代码分析
- ✓ 检查代码格式
- ✓ 运行单元测试
- ✓ 运行集成测试（可选）
- ✓ 生成测试报告

**输出**:
- 控制台显示测试结果
- 生成 `test_report.txt` 文件
- 生成覆盖率数据 `coverage/lcov.info`

**使用场景**:
- 提交代码前的完整验证
- CI/CD 流水线
- 发布前的质量检查

### `quick_test.sh` - 快速测试

**功能**:
- ✓ 代码分析
- ✓ 格式检查
- ✓ 单元测试

**使用场景**:
- 开发过程中的快速验证
- 修改代码后的即时反馈
- 频繁运行的轻量级检查

### `coverage_report.sh` - 覆盖率报告

**功能**:
- ✓ 运行测试并生成覆盖率数据
- ✓ 生成 HTML 覆盖率报告
- ✓ 显示覆盖率摘要

**依赖**:
- `lcov` - 用于生成 HTML 报告
  ```bash
  # macOS
  brew install lcov
  
  # Ubuntu/Debian
  sudo apt-get install lcov
  ```

**输出**:
- `coverage/lcov.info` - 覆盖率数据
- `coverage/html/index.html` - HTML 报告

**使用场景**:
- 查看代码测试覆盖情况
- 识别未测试的代码
- 质量报告

## 🔧 权限设置

首次使用前，需要给脚本添加执行权限：

```bash
# 添加所有脚本的执行权限
chmod +x tool/*.sh

# 或单独添加
chmod +x tool/run_tests.sh
chmod +x tool/quick_test.sh
chmod +x tool/coverage_report.sh
```

## 📝 脚本输出示例

### run_tests.sh 输出

```
╔═══════════════════════════════════════╗
║   NekoTime 测试整合脚本               ║
╚═══════════════════════════════════════╝

[1/6] 检查 Flutter 环境...
Flutter 3.16.0 • channel stable
✓ Flutter 环境正常

[2/6] 获取项目依赖...
✓ 依赖获取完成

[3/6] 运行代码分析...
Analyzing neko_time...
✓ 代码分析通过

[4/6] 检查代码格式...
✓ 代码格式正确

[5/6] 运行单元测试...
All tests passed!
✓ 测试通过

[6/6] 检查集成测试...
未找到集成测试

╔═══════════════════════════════════════╗
║          测试结果汇总                 ║
╚═══════════════════════════════════════╝

项目: NekoTime
时间: 2025-11-18 02:45:00

代码分析:     ✓ 通过
代码格式:     ✓ 通过
单元测试:     ✓ 通过
集成测试:     ⊘ 无测试

✓ 测试报告已保存到: test_report.txt
```

## ⚠️ 注意事项

1. **平台限制**: 某些构建脚本只能在特定平台运行
2. **依赖检查**: 运行前确保已安装 Flutter SDK
3. **网络要求**: 首次运行可能需要下载依赖
4. **权限问题**: macOS/Linux 需要执行权限

## 🐛 故障排查

### 脚本无法执行

```bash
# 检查权限
ls -l tool/*.sh

# 添加执行权限
chmod +x tool/<script_name>.sh
```

### Flutter 命令未找到

```bash
# 检查 Flutter 是否在 PATH 中
which flutter

# 添加到 PATH（临时）
export PATH="$PATH:/path/to/flutter/bin"
```

### 测试失败

```bash
# 清理并重试
flutter clean
flutter pub get
./tool/quick_test.sh
```

## 📚 更多信息

- 详细测试说明: [TESTING.md](../TESTING.md)
- 构建指南: [BUILD_GUIDE.md](../BUILD_GUIDE.md)
- 项目文档: [README.md](../README.md)

---

**维护者**: NekoTime 开发团队  
**最后更新**: 2025-11-18
