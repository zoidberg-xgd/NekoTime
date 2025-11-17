# NekoTime 测试指南

本文档说明如何运行 NekoTime 的各种测试和代码质量检查。

## 📋 目录

- [快速开始](#快速开始)
- [测试类型](#测试类型)
- [测试脚本](#测试脚本)
- [CI/CD 集成](#cicd-集成)
- [测试覆盖率](#测试覆盖率)
- [常见问题](#常见问题)

## 🚀 快速开始

### 运行所有测试

```bash
# 运行完整测试套件（推荐）
./tool/run_tests.sh

# 或使用 Flutter 命令
flutter test
```

### 快速验证

```bash
# 开发时快速检查（代码分析 + 格式 + 测试）
./tool/quick_test.sh
```

## 🧪 测试类型

### 1. 单元测试 (Unit Tests)

测试单个函数、类或模块的功能。

```bash
# 运行所有单元测试
flutter test

# 运行特定测试文件
flutter test test/widget_test.dart

# 运行测试并显示详细输出
flutter test --verbose
```

**测试位置**: `test/` 目录

### 2. Widget 测试

测试 UI 组件的行为和交互。

```bash
# Widget 测试包含在单元测试中
flutter test test/widget_test.dart
```

### 3. 集成测试 (Integration Tests)

测试完整的应用流程和多组件交互。

```bash
# 如果存在集成测试
flutter test integration_test
```

**测试位置**: `integration_test/` 目录（如需创建）

### 4. 代码分析 (Static Analysis)

检查代码质量、潜在问题和最佳实践。

```bash
# 运行代码分析
flutter analyze

# 忽略 info 级别的提示
flutter analyze --no-fatal-infos
```

### 5. 代码格式检查

确保代码符合 Dart 格式规范。

```bash
# 检查格式（不修改文件）
flutter format --set-exit-if-changed --dry-run .

# 自动格式化代码
flutter format .
```

## 🛠 测试脚本

项目提供了多个测试脚本，位于 `tool/` 目录：

### `run_tests.sh` - 完整测试套件

运行所有测试和检查，生成详细报告。

```bash
./tool/run_tests.sh
```

**包含内容**:
- ✓ Flutter 环境检查
- ✓ 依赖获取
- ✓ 代码分析
- ✓ 格式检查
- ✓ 单元测试
- ✓ 集成测试（可选）
- ✓ 测试报告生成

**输出**: 在项目根目录生成 `test_report.txt`

### `quick_test.sh` - 快速测试

开发时的快速验证，跳过耗时的步骤。

```bash
./tool/quick_test.sh
```

**包含内容**:
- ✓ 代码分析
- ✓ 格式检查
- ✓ 单元测试

### `coverage_report.sh` - 覆盖率报告

生成测试覆盖率报告。

```bash
./tool/coverage_report.sh
```

**输出**:
- `coverage/lcov.info` - 覆盖率数据
- `coverage/html/index.html` - HTML 报告（需安装 lcov）

**安装 lcov**:
```bash
# macOS
brew install lcov

# Ubuntu/Debian
sudo apt-get install lcov

# Fedora
sudo dnf install lcov
```

## 🔄 CI/CD 集成

项目包含 GitHub Actions 工作流配置：`.github/workflows/test.yml`

### 自动化测试

每次推送或 PR 时自动运行：

1. **代码分析** - 检查代码质量
2. **格式检查** - 验证代码格式
3. **单元测试** - 运行所有测试
4. **构建测试** - 验证各平台构建

### 查看 CI 结果

1. 访问 GitHub 仓库
2. 点击 "Actions" 标签
3. 查看最新的工作流运行

### 覆盖率报告上传

测试覆盖率会自动上传到 Codecov（如已配置）。

## 📊 测试覆盖率

### 生成覆盖率

```bash
# 方法 1: 使用脚本
./tool/coverage_report.sh

# 方法 2: 手动运行
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
```

### 查看覆盖率

```bash
# 在浏览器中打开 HTML 报告
# macOS
open coverage/html/index.html

# Linux
xdg-open coverage/html/index.html

# Windows
start coverage/html/index.html
```

### 覆盖率目标

- **总覆盖率**: ≥ 70%
- **核心服务**: ≥ 80%
- **UI 组件**: ≥ 60%

## 📝 编写测试

### 单元测试示例

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:neko_time/core/services/config_service.dart';

void main() {
  group('ConfigService Tests', () {
    test('初始化配置服务', () async {
      final service = ConfigService();
      await service.init();
      
      expect(service.config, isNotNull);
    });
    
    test('更新配置', () async {
      final service = ConfigService();
      await service.init();
      
      // 测试配置更新逻辑
      expect(service.config.scale, equals(1.0));
    });
  });
}
```

### Widget 测试示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neko_time/ui/widgets/time_display.dart';

void main() {
  testWidgets('TimeDisplay 显示正确时间', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TimeDisplay(
          digits: ['1', '2', ':', '3', '4'],
          scale: 1.0,
          digitSpacing: 2.0,
        ),
      ),
    );
    
    // 验证组件存在
    expect(find.byType(TimeDisplay), findsOneWidget);
  });
}
```

## 🐛 调试测试

### 详细输出

```bash
# 显示详细测试输出
flutter test --verbose

# 显示打印语句
flutter test --debug
```

### 运行特定测试

```bash
# 运行单个文件
flutter test test/widget_test.dart

# 运行匹配名称的测试
flutter test --name "ConfigService"

# 运行特定路径下的测试
flutter test test/core/
```

### 调试单个测试

在测试中添加断点，然后：

```bash
flutter test --start-paused
```

## ❓ 常见问题

### Q: 测试失败但本地运行正常？

**A**: 可能原因：
1. 缓存问题 - 运行 `flutter clean && flutter pub get`
2. 依赖版本不同 - 检查 `pubspec.lock`
3. 平台差异 - 检查 CI 日志

### Q: 如何跳过某些测试？

**A**: 使用 `skip` 参数：

```dart
test('临时跳过的测试', () {
  // ...
}, skip: '等待 bug 修复');
```

### Q: 测试运行很慢？

**A**: 优化建议：
1. 只运行修改相关的测试
2. 使用 `--concurrency` 参数并行运行
3. 减少 Widget 测试中的 `pump` 调用

### Q: 如何测试异步代码？

**A**: 使用 `async/await`：

```dart
test('异步测试', () async {
  final result = await someAsyncFunction();
  expect(result, equals(expected));
});
```

### Q: 覆盖率报告无法生成？

**A**: 确保：
1. 已安装 lcov: `brew install lcov` (macOS)
2. 测试已运行: `flutter test --coverage`
3. 覆盖率文件存在: `coverage/lcov.info`

## 📚 相关资源

- [Flutter 测试文档](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Flutter Widget 测试](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [集成测试指南](https://docs.flutter.dev/testing/integration-tests)

## 🎯 最佳实践

1. **编写测试优先** - 新功能先写测试
2. **保持测试简单** - 一个测试只验证一件事
3. **使用描述性名称** - 测试名称清晰说明测试内容
4. **避免测试内部实现** - 测试行为，不是实现
5. **定期运行测试** - 每次提交前运行测试
6. **维护测试覆盖率** - 保持在目标范围内

---

**维护者**: NekoTime 开发团队  
**最后更新**: 2025-11-18
