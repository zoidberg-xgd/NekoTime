# NekoTime 跨平台兼容性指南

本文档详细说明 NekoTime 在 macOS、Windows 和 Linux 平台上的兼容性和配置。

## 📊 平台支持总览

| 平台 | 透明效果 | 系统托盘 | 支持状态 |
|------|----------|----------|----------|
| **macOS** 10.14+ | ✅ 毛玻璃 | ✅ 完全支持 | 🌟🌟🌟 完美 |
| **Windows** 10 1903+ | ✅ Acrylic | ✅ 完全支持 | 🌟🌟🌟 完美 |
| **Windows** 11 | ✅ Acrylic 2.0 | ✅ 完全支持 | 🌟🌟🌟 最佳 |
| **Linux** (GNOME/KDE) | ✅ 原生透明 | ✅ 完全支持 | 🌟🌟🌟 优秀 |
| **Linux** (Xfce/MATE) | ⚠️ 需启用合成 | ✅ 完全支持 | 🌟🌟 良好 |
| **Linux** (i3wm) | ⚠️ 需 picom | ⚠️ 需配置 | 🌟 基础 |

---

## 🍎 macOS

### 系统要求
- macOS 10.14 (Mojave) 或更高版本
- 推荐 macOS 11+ 以获得最佳效果

### 透明效果
使用 `flutter_acrylic` 实现原生 Sidebar 毛玻璃效果：
```dart
await flutter_acrylic.Window.setEffect(
  effect: flutter_acrylic.WindowEffect.sidebar,
  color: Colors.transparent,
);
```

### 系统托盘
- 显示在菜单栏（Menu Bar）
- 使用 Emoji 图标 🕐
- 支持左键和右键点击

### 构建
```bash
flutter build macos --release
# 产物：build/macos/Build/Products/Release/NekoTime.app
```

### 已知问题
- 无

---

## 🪟 Windows

### 系统要求
- **最低**：Windows 10 1809
- **推荐**：Windows 10 1903+ 或 Windows 11
- Visual Studio C++ Redistributable (运行时依赖)

### 版本支持

| Windows 版本 | 透明效果 | Acrylic | 推荐度 |
|--------------|----------|---------|--------|
| Windows 11 | ✅ 完全 | ✅ Acrylic 2.0 | 🌟🌟🌟 |
| Windows 10 21H2 | ✅ 完全 | ✅ 完全 | 🌟🌟🌟 |
| Windows 10 1903 | ✅ 完全 | ✅ Acrylic 1.0 | 🌟🌟 |
| Windows 10 1809 | ✅ 完全 | ⚠️ 部分 | 🌟 |
| Windows 8.1 | ⚠️ 部分 | ❌ 无 | ❌ |

### 透明效果
使用 `flutter_acrylic` 实现原生 Acrylic 效果：
```dart
await flutter_acrylic.Window.setEffect(
  effect: flutter_acrylic.WindowEffect.acrylic,
  color: Colors.transparent,
);
```

### 系统托盘
- 显示在任务栏托盘区
- 使用 Emoji 图标 🕐
- 支持左键和右键点击

### 构建
```bash
flutter build windows --release
# 产物：build/windows/x64/runner/Release/
```

### 常见问题

**缺少 VCRUNTIME140.dll**
```
解决：安装 Visual C++ Redistributable
下载：https://aka.ms/vs/17/release/vc_redist.x64.exe
```

**窗口不透明**
```
检查：
1. Windows 版本 ≥ 1903
2. 设置 → 个性化 → 颜色 → 开启"透明效果"
3. 桌面窗口管理器（DWM）正在运行
```

**SmartScreen 警告**
```
正常现象（未签名应用）
点击"更多信息" → "仍要运行"
```

---

## 🐧 Linux

### 系统要求
- Linux 内核 5.0+
- GTK 3.0+
- 窗口合成器（Compositor）

### 依赖安装

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

### 桌面环境兼容性

| 桌面环境 | 透明效果 | 托盘支持 | 推荐度 |
|----------|----------|----------|--------|
| **GNOME** 40+ | ✅ 完全 | ✅ 需扩展* | 🌟🌟🌟 |
| **KDE Plasma** 5.20+ | ✅ 完全 | ✅ 完全 | 🌟🌟🌟 |
| **Cinnamon** 5.0+ | ✅ 完全 | ✅ 完全 | 🌟🌟🌟 |
| **Xfce** 4.16+ | ⚠️ 需启用合成 | ✅ 完全 | 🌟🌟 |
| **MATE** 1.24+ | ⚠️ 需启用合成 | ✅ 完全 | 🌟🌟 |
| **i3wm** | ⚠️ 需 picom | ⚠️ 需配置 | 🌟 |
| **Sway** (Wayland) | ✅ 完全 | ⚠️ 部分 | 🌟🌟 |

*GNOME 需要 AppIndicator 扩展

### 透明效果实现
使用 GTK RGBA visual（原生支持）：
```cpp
GdkScreen* screen = gtk_window_get_screen(window);
GdkVisual* visual = gdk_screen_get_rgba_visual(screen);
gtk_widget_set_visual(GTK_WIDGET(window), visual);
```

### 系统托盘配置

#### GNOME（重要！）
```bash
# 1. 安装 AppIndicator 扩展
sudo apt-get install gnome-shell-extension-appindicator

# 2. 启用扩展
gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com

# 3. 重启 GNOME Shell (X11)
Alt+F2 → r → Enter

# Wayland: 注销并重新登录
```

#### KDE Plasma
无需额外配置，原生支持系统托盘。

#### i3wm
```bash
# 在 ~/.config/i3/config 中添加
bar {
    status_command i3status
    tray_output primary
}
```

### 构建
```bash
flutter build linux --release
# 产物：build/linux/x64/release/bundle/
```

### 常见问题

**透明效果不工作**
```bash
# 确保合成器已启用
# Xfce:
xfconf-query -c xfwm4 -p /general/use_compositing -s true

# MATE:
gsettings set org.mate.Marco.general compositing-manager true

# i3wm: 启动 picom
picom --backend glx --vsync &
```

**托盘图标不显示（GNOME）**
```bash
# 检查扩展状态
gnome-extensions list | grep appindicator

# 检查依赖
dpkg -l | grep libayatana-appindicator3

# 如未安装
sudo apt-get install libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1
```

---

## 🎨 系统托盘详细说明

### 托盘实现
使用 `system_tray` v2.0.3，支持所有桌面平台。

### 托盘图标
- 使用 Emoji 🕐（跨平台兼容）
- 不依赖图片文件
- 所有平台统一显示

### 托盘菜单功能
- ✅ 主题切换
- ✅ 透明度调节（30% - 100%）
- ✅ 缩放调节（0.75x - 2.0x）
- ✅ 位置锁定/解锁
- ✅ 显示/隐藏窗口
- ✅ 窗口层级切换
- ✅ 语言切换
- ✅ 退出应用

### 平台特性

| 平台 | 图标位置 | 点击行为 | 特殊说明 |
|------|----------|----------|----------|
| macOS | 菜单栏右侧 | 左键/右键弹出菜单 | 无 |
| Windows | 任务栏托盘区 | 左键/右键弹出菜单 | 可能被默认隐藏 |
| Linux (GNOME) | 顶栏右侧 | 左键/右键弹出菜单 | 需 AppIndicator |
| Linux (KDE) | 系统托盘 | 左键/右键弹出菜单 | 原生支持 |

---

## 🔧 构建指南

### macOS
```bash
# 开发运行
flutter run -d macos

# Release 构建
flutter build macos --release

# 输出
build/macos/Build/Products/Release/NekoTime.app
```

### Windows
```batch
REM 开发运行
flutter run -d windows

REM Release 构建
flutter build windows --release

REM 输出
build\windows\x64\runner\Release\NekoTime.exe
```

### Linux
```bash
# 开发运行
flutter run -d linux

# Release 构建
flutter build linux --release

# 输出
build/linux/x64/release/bundle/neko_time
```

---

## 📦 主题目录位置

**建议从设置对话框底部复制完整路径。**

| 平台 | 主题目录 |
|------|----------|
| macOS (Sandbox) | `~/Library/Containers/com.nekotime.app/Data/Library/Application Support/com.nekotime.app/themes/` |
| macOS (非 Sandbox) | `~/Library/Application Support/NekoTime/themes/` |
| Windows | `%APPDATA%\com.nekotime.app\themes\` |
| Linux | `~/.local/share/com.nekotime.app/themes/` |

> **注意**：从 DMG 或 App Store 安装的 macOS 版本使用 Sandbox 模式。

---

## ⚡ 性能基准

### 内存使用
- **基础**：~80-100MB
- **带 GIF 主题**：~120-140MB
- **多个主题**：~150-180MB

### CPU 使用
- **空闲**：<1%
- **GIF 动画**：1-3%
- **主题切换**：临时 5-10%

### 启动时间
- **macOS**：1-2 秒
- **Windows**：1-2 秒
- **Linux**：1-2 秒

---

## 🎯 推荐配置

### 最佳体验
- **macOS**: macOS 11+ (Big Sur)
- **Windows**: Windows 11 或 Windows 10 21H2+
- **Linux**: Ubuntu 22.04+ (GNOME) 或 KDE neon

### 最低要求
- **macOS**: macOS 10.14 (Mojave)
- **Windows**: Windows 10 1809
- **Linux**: Ubuntu 20.04 或同等发行版

---

## 📚 相关文档

- [README.md](README.md) - 项目概述和快速开始
- [CHANGELOG.md](CHANGELOG.md) - 版本更新历史
- [BUILD_GUIDE.md](BUILD_GUIDE.md) - 详细构建指南
- [themes/THEME_GUIDE.md](themes/THEME_GUIDE.md) - 主题开发指南

---

**最后更新**: 2025-11-18  
**适用版本**: v2.1.0+
