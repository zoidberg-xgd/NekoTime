# 猫铃时钟 NekoTime 

一款基于 Flutter 构建的桌面悬浮数字时钟，使用可爱的像素风格 GIF 动画角色展示时间，支持 macOS、Windows 和 Linux。

> 让可爱的像素猫娘为你报时！

![时钟截图](https://user-images.githubusercontent.com/86920182/209436903-0a6c1f5a-4ab6-454f-a37d-78a5d699f3df.png)

## ✨ 功能特性

### 核心功能

- **动态 GIF 角色显示**：使用像素风 GIF 动画角色展示时间数字，每个数字都是可爱的猫娘形象！
- **双击隐藏**：双击时钟窗口即可隐藏，通过托盘菜单重新显示
- **完整日志系统**：
  - 自动记录所有操作和错误
  - 应用内日志查看器（实时查看、复制、清空）
  - 日志文件自动轮转管理（最大5MB，保留3个备份）
- **多格式数字图片支持**：支持 GIF、PNG、JPG、WebP、BMP 等多种格式

### 主题系统

- **高度可定制化主题**：
  - 内置一款毛玻璃主题，开箱即用
  - 支持通过 JSON 文件自定义主题，实现完全个性化
  - 可创建 `solid`（纯色）、`blur`（毛玻璃）或 `transparent`（透明）三种类型
  - 自动在应用支持目录创建 `themes` 文件夹，便于放置自定义主题

### 显示设置

- **缩放**：自由调整时钟大小（0.75x - 2.0x）
- **透明度**：控制窗口整体不透明度
- **显示秒**：可选择是否显示秒数

### 窗口管理

- **置顶显示**：可将窗口设置为总在最前
- **位置锁定**：防止意外拖动
- **无边框设计**：简洁的无边框设计，完全透明背景
- **Dock 栏隐藏 (macOS)**：作为 `LSUIElement` 运行，不在 Dock 栏显示图标
- **系统托盘**：
  - 提供系统托盘图标 🕐，点击可快速访问所有设置菜单
  - **隐藏/显示功能**：通过托盘菜单控制窗口显示
  - 菜单项支持中英文切换
- **多语言**：支持简体中文和英文

## 🎯 快捷操作

- **拖动窗口**：按住窗口任意位置拖动（解锁状态）
- **双击隐藏**：双击时钟窗口可隐藏
- **托盘显示**：点击托盘图标 🕐，选择"隐藏/显示"
- **查看日志**：设置 → 查看日志 → 实时查看所有操作记录
- **打开主题文件夹**：设置对话框底部有路径提示

## 🚀 开始使用

### 环境要求

- Flutter 3.0 或更高版本
- 已根据 [Flutter Desktop 文档](https://docs.flutter.dev/desktop) 配置好相应平台的开发环境。

### 运行与构建

1. **获取依赖**
   ```bash
   flutter pub get
   ```

2. **运行应用** (以 macOS 为例)
   ```bash
   flutter run -d macos
   ```

3. **构建发行版** (以 macOS 为例)
   ```bash
   flutter build macos
   ```
   可执行文件将位于 `build/macos/Build/Products/Release/`。

## 🎨 自定义主题（主题包）

应用支持以“主题包”的方式加载主题：在应用支持目录的 `themes/` 下创建子文件夹，每个文件夹包含 `theme.json` 与可选的 `assets/` 静态资源。仍兼容旧版：放在 `themes/` 根目录的独立 `.json` 文件也会被识别。

- 主题目录路径会在设置弹窗底部提示，例如 macOS：`~/Library/Application Support/digital_clock/themes`

### 目录结构示例
```
themes/
  my_theme/
    theme.json
    assets/
      bg.jpg
      overlay.png
      MyFont.ttf
```

### theme.json 示例
```json
{
  "id": "my_theme",
  "name": "我的主题",
  "version": "1.0.0",
  "apiVersion": 1,
  "kind": "blur",
  "borderRadius": 16,
  "padding": { "preset": "cozy", "horizontal": 16, "vertical": 8 },
  "layout": { "alignment": "right" },
  "backgroundColor": "#101218",
  "backgroundOpacityMultiplier": 0.4,
  "tintColor": "#9E9E9E",
  "tintOpacityMultiplier": 0.12,
  "blur": { "sigmaX": 16, "sigmaY": 16 },
  "backgroundImage": "assets/bg.jpg",
  "overlayImage": "assets/overlay.png",
  "fontFamily": "MyFont",
  "fonts": [ "assets/MyFont.ttf" ],
  "digit": {
    "spacing": 2,
    "gifPath": "gif",
    "format": "gif"
  }
}
```

### 字段说明（Manifest）
- 基础：`id`、`name`、`version`、`apiVersion`、`kind (transparent|blur|solid)`
- 布局与间距：
  - `padding`：数值 `horizontal/vertical` 或预设 `preset (none|compact|cozy|comfortable)`
  - `layout.alignment`：`left|center|right`
  - `digit.spacing`：数字间距（推荐：紧凑0-2，标准4-8，宽松10-16）
  - `digit.gifPath`：数字图片文件夹路径（相对主题目录）
  - `digit.format`：图片格式（gif/png/jpg/webp等，可选，留空自动检测）
- 视觉：
  - `backgroundColor`、`backgroundOpacityMultiplier`
  - `tintColor`、`tintOpacityMultiplier`
  - `blur.sigmaX`、`blur.sigmaY`（仅 kind=blur 有效）
  - `backgroundImage`（背景图）、`overlayImage`（前景叠加）
- 字体：`fontFamily` 与 `fonts`（相对路径），运行时动态加载

### 紧凑显示配置

如果你觉得时钟显示太大或四周有过多留白，推荐配置：

```json
{
  "borderRadius": 12,
  "padding": { "preset": "compact" },
  "digit": { "spacing": 0 }
}
```

详细的主题开发指南请查看：[THEME_GUIDE.md](themes/THEME_GUIDE.md)

修改或添加主题包后，在设置弹窗或系统托盘菜单点击"重新加载主题"即可生效。

## 📦 主要依赖

- `flutter_acrylic`: 实现窗口磨砂玻璃和透明效果
- `window_manager`: 提供强大的跨平台窗口管理能力
- `system_tray`: 用于创建和管理系统托盘图标及菜单
- `provider`: 进行状态管理
- `shared_preferences`: 持久化用户配置
- `path_provider`: 访问应用支持目录

## 📝 更新日志

### v2.0.0 (最新)

**重大改进**
- ✨ 修复主题切换后数字消失问题（无限循环重建）
- 🎨 优化显示紧凑度（减少20-75%间距和留白）
- 📝 添加完整的日志系统（文件日志+应用内查看器）
- 🖼️ 支持多种数字图片格式（GIF/PNG/JPG/WebP/BMP）
- 👆 添加双击隐藏功能
- 🎯 添加托盘菜单隐藏/显示功能
- 📚 添加主题开发指南和改进文档
- 🐛 修复缩放时窗口比例问题
- 🔧 改进错误处理和日志记录

**详细变更请查看**: [IMPROVEMENTS.md](IMPROVEMENTS.md)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

---

**猫铃时钟 NekoTime** - 让可爱的像素猫娘陪伴你的每一分钟！ 🐱💕