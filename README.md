# NekoTime - 猫铃时钟

> 一款极致轻量、高度可定制的**桌面**悬浮时钟应用

[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux-blue)](https://flutter.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

<div align="center">
  <img src="docs/screenshots/demo.gif" alt="NekoTime Demo" width="600">
</div>

**NekoTime** 是一款专为桌面平台设计的跨平台悬浮时钟，采用 Flutter 开发，支持 macOS、Windows 和 Linux。具备完全自定义的主题系统，你可以像安装游戏 MOD 一样轻松定制属于自己的时钟样式。

> 📱 **注意**：本项目专注于桌面体验，不支持移动端（Android/iOS）。

## ✨ 特性

### 🎨 模块化主题系统
- **零编程定制** - 纯 JSON 配置，拖放即用
- **丰富素材支持** - GIF 动画、PNG/JPG 图片、自定义字体、背景图
- **热重载** - 主题修改后无需重启，点击重载即可预览
- **内置主题** - 开箱即用的 Frosted Glass 毛玻璃主题

### 🪟 高级窗口特性
- **真透明** - 系统级透明，可穿透到桌面和其他应用
- **毛玻璃** - 支持 Blur 模糊背景效果
- **分层管理** - 桌面层 / 普通层 / 置顶层 三档切换
- **可拖拽** - 自由移动到屏幕任意位置
- **锁定保护** - 防止误操作移动窗口
- **透明度调节** - 10%-100% 实时调整，支持双击隐藏

<div align="center">
  <img src="docs/screenshots/transparency-demo.gif" alt="透明度调节演示" width="600">
  <p><em>透明度实时调节演示</em></p>
</div>

<div align="center">
  <img src="docs/screenshots/scale-demo.gif" alt="窗口缩放演示" width="600">
  <p><em>窗口尺寸自由缩放</em></p>
</div>

### ⚡ 性能优化
- **低资源占用** - 经过性能优化，避免无响应和卡顿
- **智能缓存** - 主题资源智能加载，减少重复操作
- **流畅动画** - GIF 动画平滑播放，无卡顿

### 🌐 本地化支持
- 简体中文 / English 自动切换
- 完整的国际化框架

## 🚀 快速开始

### 环境要求

**通用要求**：
- **Flutter SDK** 3.0+
- 按照 [Flutter 官方文档](https://docs.flutter.dev/get-started/install) 配置对应平台开发环境

**平台特定依赖**：

<details>
<summary><b>macOS</b></summary>

- macOS 10.14 或更高版本
- Xcode 12.0 或更高版本
- CocoaPods

```bash
# 安装 CocoaPods（如未安装）
sudo gem install cocoapods
```
</details>

<details>
<summary><b>Windows</b></summary>

- Windows 10 1809 或更高版本（建议 Windows 10 1903+ 以获得最佳透明效果）
- Visual Studio 2019 或更高版本（包含 C++ 桌面开发工具）
- 启用开发者模式
</details>

<details>
<summary><b>Linux</b></summary>

**Ubuntu/Debian**：
```bash
sudo apt-get update
sudo apt-get install -y \
    clang cmake ninja-build pkg-config \
    libgtk-3-dev liblzma-dev \
    libayatana-appindicator3-dev
```

**Fedora**：
```bash
sudo dnf install -y \
    clang cmake ninja-build \
    gtk3-devel lzma-devel \
    libayatana-appindicator-gtk3-devel
```

**Arch Linux**：
```bash
sudo pacman -S base-devel gtk3 cmake ninja
```
</details>

### 运行应用

```bash
# 克隆项目
git clone https://github.com/zoidberg-xgd/NekoTime.git
cd NekoTime

# 安装依赖
flutter pub get

# 运行 (macOS 示例)
flutter run -d macos

# 构建发行版
flutter build macos --release
```

构建产物位置：
- **macOS**: `build/macos/Build/Products/Release/NekoTime.app`
- **Windows**: `build/windows/x64/runner/Release/`
- **Linux**: `build/linux/x64/release/bundle/`

📘 **跨平台支持详情**：查看 [PLATFORM_SUPPORT.md](PLATFORM_SUPPORT.md) 了解各平台的详细构建和部署说明。

## 📖 使用指南

### 基础操作

| 操作 | 说明 |
|------|------|
| **拖动** | 鼠标按住时钟任意位置拖动（需解锁状态）|
| **隐藏** | 双击时钟窗口 / 托盘菜单选择"隐藏" |
| **显示** | 点击托盘图标 🕐 选择"显示" |
| **设置** | 右键托盘图标，选择"Settings" |

### 托盘菜单功能

- **Theme** - 快速切换已安装主题
- **Layer** - 窗口分层（Desktop / Normal / Top）
- **Scale** - 缩放倍数（0.75x ~ 2.0x）
- **Opacity** - 透明度滑块（10% ~ 100%）
- **Lock Position** - 锁定/解锁窗口位置
- **Settings** - 打开设置对话框
- **Reload Themes** - 重新加载主题列表
- **Quit** - 退出应用

### 设置对话框

- 查看当前配置
- 访问日志查看器（查看应用运行日志）
- 打开主题文件夹
- 一键打开日志目录

## 🎨 主题系统

### 主题目录位置

主题存储在应用支持目录的 `themes/` 文件夹：

- **macOS**: `~/Library/Application Support/NekoTime/themes/`
- **Windows**: `%APPDATA%\NekoTime\themes\`
- **Linux**: `~/.local/share/NekoTime/themes/`

*提示：可在设置对话框底部找到完整路径*

### 创建主题

#### 1. 目录结构

```
themes/
└── my_awesome_theme/          # 主题文件夹（ID）
    ├── theme.json             # 主题配置（必需）
    ├── digits/                # 数字图片文件夹
    │   ├── 0.gif
    │   ├── 1.gif
    │   ├── ...
    │   └── 9.gif
    └── assets/                # 其他资源（可选）
        ├── background.jpg
        ├── overlay.png
        └── CustomFont.ttf
```

#### 2. 配置示例 (`theme.json`)

```json
{
  "id": "my_awesome_theme",
  "name": "My Awesome Theme",
  "version": "1.0.0",
  "apiVersion": 1,
  "kind": "blur",
  "borderRadius": 12,
  "padding": {
    "preset": "compact"
  },
  "layout": {
    "alignment": "center"
  },
  "backgroundColor": "#202020",
  "backgroundOpacityMultiplier": 0.5,
  "tintColor": "#9E9E9E",
  "tintOpacityMultiplier": 0.15,
  "blur": {
    "sigmaX": 16,
    "sigmaY": 16
  },
  "digit": {
    "spacing": 2,
    "gifPath": "digits",
    "format": "gif"
  }
}
```

#### 3. 配置字段说明

**基础信息**
- `id` - 主题唯一标识符（建议与文件夹名一致）
- `name` - 显示名称
- `version` - 主题版本号
- `apiVersion` - API 版本（当前为 1）

**外观样式**
- `kind` - 主题类型：`transparent` | `blur` | `solid`
- `borderRadius` - 边框圆角半径（像素）
- `backgroundColor` - 背景颜色（十六进制）
- `backgroundOpacityMultiplier` - 背景不透明度系数（0.0-1.0）
- `tintColor` - 着色颜色
- `tintOpacityMultiplier` - 着色不透明度系数

**布局配置**
- `padding.preset` - 内边距预设：`none` | `compact` | `cozy` | `comfortable`
- `padding.horizontal/vertical` - 自定义水平/垂直内边距
- `layout.alignment` - 对齐方式：`left` | `center` | `right`

**数字显示**
- `digit.spacing` - 数字间距（像素）
  - 推荐值：紧凑 `0-2` / 标准 `4-8` / 宽松 `10-16`
- `digit.gifPath` - 数字图片文件夹路径（相对主题根目录）
- `digit.format` - 图片格式：`gif` | `png` | `jpg` | `webp` | `bmp`
  - 留空则自动检测

**高级选项**
- `blur.sigmaX/sigmaY` - 模糊程度（仅 `kind: blur` 生效）
- `backgroundImage` - 背景图路径（相对主题根目录）
- `overlayImage` - 前景叠加图路径
- `fontFamily` - 自定义字体族名
- `fonts` - 字体文件路径数组（TTF/OTF）

### 快速配置模板

**极简紧凑**
```json
{
  "borderRadius": 12,
  "padding": { "preset": "compact" },
  "digit": { "spacing": 0 }
}
```

**毛玻璃效果**
```json
{
  "kind": "blur",
  "blur": { "sigmaX": 16, "sigmaY": 16 },
  "tintOpacityMultiplier": 0.15
}
```

### 应用主题

1. 将主题文件夹复制到 `themes/` 目录
2. 打开托盘菜单 → 点击 **"Reload Themes"**
3. 托盘菜单 → **Theme** → 选择你的主题

📚 **详细主题开发指南**：[themes/THEME_GUIDE.md](themes/THEME_GUIDE.md)

## 🛠 技术栈

| 组件 | 说明 |
|------|------|
| **Flutter** | 跨平台 UI 框架 |
| **flutter_acrylic** | 窗口毛玻璃和透明效果 |
| **window_manager** | 跨平台窗口管理 |
| **system_tray** | 系统托盘图标和菜单 |
| **provider** | 状态管理 |
| **shared_preferences** | 配置持久化 |
| **path_provider** | 文件路径访问 |

## 📝 更新日志

### v2.1.0 (2025-11-18)

**🐛 关键 Bug 修复**
- 修复应用卡死/无响应问题（移除性能瓶颈）
- 移除每秒触发的大量调试日志
- 优化窗口属性更新逻辑（仅在配置变更时执行）

**⚡ 性能优化**
- 减少 UI 重建次数
- 智能缓存窗口配置状态
- 降低主线程负载

### v2.0.0

**🎉 重大更新**
- 修复主题切换后数字消失问题
- 优化显示紧凑度（减少 20%-75% 留白）
- 添加完整日志系统（文件日志 + 应用内查看器）
- 支持多格式数字图片（GIF/PNG/JPG/WebP/BMP）
- 新增双击隐藏功能
- 托盘菜单快速显示/隐藏
- 完善主题开发文档

📋 **完整更新日志**：[CHANGELOG.md](CHANGELOG.md)

## 🧪 测试

NekoTime 包含完整的测试套件，确保代码质量和稳定性。

### 快速测试

```bash
# 运行所有测试
make test

# 快速测试（开发时）
make test-quick

# 生成覆盖率报告
make test-coverage
```

### 测试类型

- **单元测试** - 测试核心功能和服务
- **Widget 测试** - 测试 UI 组件
- **代码分析** - 静态代码检查
- **格式检查** - 代码风格验证

### 详细文档

- 📘 [测试指南](TESTING.md) - 完整的测试文档和最佳实践
- 🛠️ [工具脚本](tool/README.md) - 测试和构建脚本说明

## ❓ 常见问题

### Windows 11 - 看不见托盘图标

**问题**：应用正常运行，但任务栏右下角看不到托盘图标 🕐

**解决方案**：

1. **查看隐藏图标**
   - 点击任务栏右下角的 **"^"** 图标（向上箭头）
   - 查看溢出区域是否有 NekoTime 图标

2. **启用托盘图标显示**
   - 打开 **设置 → 个性化 → 任务栏**
   - 点击 **"其他系统托盘图标"**
   - 找到 **NekoTime**，打开开关
   - 重启应用

3. **临时解决**
   - 即使看不到托盘图标，应用仍在运行
   - 时钟窗口可以通过双击隐藏/显示
   - 可以通过右键时钟窗口访问部分功能

### macOS - 窗口无法拖动

**问题**：无法拖动时钟窗口

**解决方案**：
- 检查是否启用了 **"锁定位置"**
- 右键托盘图标 → 取消勾选 **"Lock Position"**
- 或在设置中关闭位置锁定

### Linux - 透明效果不工作

**问题**：窗口背景不透明，无法看到桌面

**解决方案**：
- 确保桌面环境启用了**合成器（Compositor）**
- GNOME: 默认启用
- KDE Plasma: 系统设置 → 显示 → 合成器
- XFCE: 设置 → 窗口管理器微调 → 合成器

### 所有平台 - 主题不显示

**问题**：切换主题后没有变化

**解决方案**：
- 检查主题文件夹路径是否正确
- 确保 `theme.json` 格式正确（可以用 JSON 验证器检查）
- 右键托盘图标 → **"Reload Themes"** 重新加载
- 查看日志文件排查错误（设置 → 查看日志）

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 开发规范
- 遵循 Flutter 官方代码风格
- 提交前运行 `make test` 或 `./tool/run_tests.sh`
- 确保所有测试通过
- 保持测试覆盖率 ≥ 70%
- 重大功能请先开 Issue 讨论

### 开发工作流

```bash
# 1. 克隆项目
git clone https://github.com/zoidberg-xgd/NekoTime.git
cd NekoTime

# 2. 获取依赖
make get

# 3. 运行测试
make test-quick

# 4. 运行应用
make run-macos  # 或 run-windows / run-linux

# 5. 提交前检查
make pre-release
```

## 📄 许可证

本项目采用 [MIT License](LICENSE) 开源协议。

---

<p align="center">
  <strong>NekoTime - 让时间更可爱 🐱⏰</strong>
</p>