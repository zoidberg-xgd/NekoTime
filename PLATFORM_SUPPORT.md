# 跨平台支持说明

NekoTime 支持在 macOS、Windows 和 Linux 三个桌面平台上运行。

## 🖥️ 支持的平台

| 平台 | 状态 | 透明效果 | 说明 |
|------|------|----------|------|
| **macOS** | ✅ 完全支持 | 毛玻璃（Sidebar） | 使用 flutter_acrylic 实现原生效果 |
| **Windows** | ✅ 完全支持 | Acrylic | Windows 10+ 原生 Acrylic 效果 |
| **Linux** | ✅ 完全支持 | 原生透明 | 依赖窗口管理器（KDE/GNOME/等） |

📘 **平台详细兼容性**：
- **Windows**：查看 [WINDOWS_COMPATIBILITY.md](WINDOWS_COMPATIBILITY.md) 了解 Windows 版本支持和详细配置
- **Linux**：查看 [LINUX_COMPATIBILITY.md](LINUX_COMPATIBILITY.md) 了解不同桌面环境的支持情况

## 🚀 平台构建

### macOS

**环境要求**：
- macOS 10.14 或更高版本
- Xcode 12.0 或更高版本
- CocoaPods

**构建命令**：
```bash
# 开发运行
flutter run -d macos

# Release 构建
flutter build macos --release

# 构建产物位置
build/macos/Build/Products/Release/digital_clock.app
```

**安装**：
将 `.app` 文件拖到 `Applications` 文件夹即可。

---

### Windows

**环境要求**：
- Windows 10 1809 或更高版本（建议 Windows 10 1903+ 以获得最佳 Acrylic 效果）
- Visual Studio 2019 或更高版本（包含 C++ 桌面开发工具）
- 启用开发者模式

**构建命令**：
```bash
# 开发运行
flutter run -d windows

# Release 构建
flutter build windows --release

# 构建产物位置
build/windows/x64/runner/Release/
```

**打包**：
```bash
# 创建安装目录
mkdir NekoTime-Windows
cp -r build/windows/x64/runner/Release/* NekoTime-Windows/

# 压缩为 zip
# Windows 用户可以直接右键压缩文件夹
```

**注意事项**：
- Windows 7/8 不支持 Acrylic 效果，将使用基础透明
- 首次运行可能需要安装 Visual C++ Redistributable
- 防火墙可能会提示，选择允许

---

### Linux

**环境要求**：
- Linux 发行版（推荐 Ubuntu 20.04+、Fedora 35+、Arch Linux）
- GTK 3.0+ 和相关开发库
- Clang 或 GCC

**安装依赖（Ubuntu/Debian）**：
```bash
sudo apt-get update
sudo apt-get install -y \
    clang cmake ninja-build pkg-config \
    libgtk-3-dev liblzma-dev \
    libayatana-appindicator3-dev
```

**安装依赖（Fedora）**：
```bash
sudo dnf install -y \
    clang cmake ninja-build \
    gtk3-devel lzma-devel \
    libayatana-appindicator-gtk3-devel
```

**构建命令**：
```bash
# 开发运行
flutter run -d linux

# Release 构建
flutter build linux --release

# 构建产物位置
build/linux/x64/release/bundle/
```

**打包**：
```bash
# 创建 AppImage 或 .deb 包（需要额外工具）
# 简单方式：直接压缩 bundle 目录
tar -czf NekoTime-Linux.tar.gz -C build/linux/x64/release bundle
```

**注意事项**：
- 透明效果依赖于窗口管理器（Compositor）
- GNOME、KDE Plasma、Xfce 等主流桌面环境都支持
- i3、Sway 等平铺式窗口管理器可能需要额外配置

**推荐桌面环境**：
- ✅ GNOME 3.38+（完整支持）
- ✅ KDE Plasma 5.20+（完整支持）
- ⚠️ Xfce 4.16+（部分支持，需启用合成器）
- ⚠️ i3/Sway（需要 compton/picom 等合成器）

---

## 🔧 平台特定配置

### 透明效果实现

**macOS**：
```dart
// 使用 Sidebar 效果（原生毛玻璃）
await flutter_acrylic.Window.setEffect(
  effect: flutter_acrylic.WindowEffect.sidebar,
  color: Colors.transparent,
);
```

**Windows**：
```dart
// 使用 Acrylic 效果（Windows 10 1903+）
await flutter_acrylic.Window.setEffect(
  effect: flutter_acrylic.WindowEffect.acrylic,
  color: Colors.transparent,
);
```

**Linux**：
```dart
// 使用基础透明（依赖窗口管理器）
// 在 WindowOptions 中设置 backgroundColor: Colors.transparent
```

### 系统托盘

所有三个平台都支持系统托盘，使用 `system_tray` 包实现：

- **macOS**：菜单栏图标
- **Windows**：任务栏托盘区
- **Linux**：系统托盘（需要桌面环境支持）

### 主题目录位置

| 平台 | 主题目录路径 |
|------|-------------|
| macOS | `~/Library/Application Support/digital_clock/themes/` |
| Windows | `%APPDATA%\digital_clock\themes\` |
| Linux | `~/.local/share/digital_clock/themes/` |

---

## 🧪 测试建议

### 测试清单

每个平台发布前建议测试：

- [ ] 窗口透明效果显示正常
- [ ] 拖动窗口功能正常
- [ ] 系统托盘图标和菜单正常
- [ ] 主题切换功能正常
- [ ] 缩放和透明度调节正常
- [ ] 窗口分层（置顶/普通/桌面层）正常
- [ ] 双击隐藏功能正常
- [ ] 日志查看器正常
- [ ] 主题文件夹打开正常
- [ ] 配置持久化正常

### 多显示器测试

在多显示器环境下测试：
- 窗口位置记忆
- 拖动到不同显示器
- DPI 缩放（Windows/Linux）

---

## 🐛 已知问题

### Windows
- Windows 7/8 不支持 Acrylic 效果（降级为基础透明）
- 某些主题可能在高 DPI 显示器上显示模糊（Windows 缩放问题）

### Linux
- Wayland 下透明效果支持取决于合成器
- 某些轻量级桌面环境可能不支持窗口透明
- i3wm 等平铺式窗口管理器需要配置 picom/compton

### macOS
- 暂无已知问题

---

## 📦 依赖包平台支持

| 包名 | macOS | Windows | Linux | 说明 |
|------|-------|---------|-------|------|
| `window_manager` | ✅ | ✅ | ✅ | 窗口管理 |
| `system_tray` | ✅ | ✅ | ✅ | 系统托盘 |
| `flutter_acrylic` | ✅ | ✅ | ❌ | 透明效果（Linux 不需要） |
| `shared_preferences` | ✅ | ✅ | ✅ | 配置存储 |
| `path_provider` | ✅ | ✅ | ✅ | 路径访问 |

---

## 🔄 CI/CD 建议

### GitHub Actions 示例

```yaml
name: Build Multi-Platform

on: [push, pull_request]

jobs:
  build-macos:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build macos --release
      
  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter build windows --release
      
  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: |
          sudo apt-get update
          sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev
          flutter build linux --release
```

---

## 📞 故障排除

### Windows: "找不到 VCRUNTIME140.dll"
**解决方案**：安装 [Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)

### Linux: 透明效果不工作
**检查步骤**：
1. 确认桌面环境支持合成（Compositor）
2. 检查是否启用了窗口合成效果
3. 尝试安装 picom/compton

### 所有平台: 托盘图标不显示
**检查步骤**：
1. 确认系统托盘功能已启用
2. 检查日志文件中的错误信息
3. 重启应用

---

**更新日期**：2025-11-18  
**适用版本**：v2.1.0+
