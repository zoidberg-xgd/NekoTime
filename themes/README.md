# NekoTime 主题目录

本目录用于存放自定义主题。NekoTime 支持模块化的主题包系统，你可以轻松创建和分享主题。

## 目录位置

主题目录位于应用支持目录下。**最简单的方法**：打开设置对话框，底部会显示完整路径。

| 平台 | 路径 |
|------|------|
| **macOS (Sandbox)** | `~/Library/Containers/com.nekotime.app/Data/Library/Application Support/com.nekotime.app/themes/` |
| **macOS (非 Sandbox)** | `~/Library/Application Support/NekoTime/themes/` |
| **Windows** | `%APPDATA%\com.nekotime.app\themes\` |
| **Linux** | `~/.local/share/com.nekotime.app/themes/` |

> **注意**：从 DMG 或 App Store 安装的 macOS 版本使用 Sandbox 模式。

## 主题结构

### 标准主题包结构

```
themes/
└── my_theme/                  # 主题文件夹（以主题 ID 命名）
    ├── theme.json             # 主题配置文件（必需）
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

### 内置主题

- **builtin/** - 应用内置主题（打包在应用中）
  - **frosted_glass/** - 默认的毛玻璃主题

### 示例主题

- **example_mod/** - 示例主题模板，展示完整配置选项

## 配置文件

### theme.json 基础结构

```json
{
  "id": "my_theme",
  "name": "My Theme",
  "version": "1.0.0",
  "apiVersion": 1,
  "kind": "blur",
  "borderRadius": 12,
  "padding": {
    "preset": "compact"
  },
  "digit": {
    "spacing": 2,
    "gifPath": "digits",
    "format": "gif"
  }
}
```

### 必需字段

| 字段 | 说明 | 示例 |
|------|------|------|
| `id` | 主题唯一标识符 | `"my_awesome_theme"` |
| `name` | 显示名称 | `"My Awesome Theme"` |

### 主题类型 (kind)

- `transparent` - 完全透明背景
- `blur` - 毛玻璃模糊效果
- `solid` - 纯色或图片背景

## 快速开始

### 1. 创建主题文件夹

```bash
# macOS (Sandbox 模式，从设置对话框获取实际路径)
mkdir -p ~/Library/Containers/com.nekotime.app/Data/Library/Application\ Support/com.nekotime.app/themes/my_theme

# Windows
mkdir %APPDATA%\com.nekotime.app\themes\my_theme

# Linux
mkdir -p ~/.local/share/com.nekotime.app/themes/my_theme
```

### 2. 创建配置文件

在主题文件夹中创建 `theme.json`：

```json
{
  "id": "my_theme",
  "name": "My First Theme",
  "kind": "transparent",
  "padding": {
    "preset": "compact"
  }
}
```

### 3. 添加数字图片（可选）

创建 `digits/` 文件夹，放入 `0.gif` 到 `9.gif` 文件，并在配置中添加：

```json
{
  "digit": {
    "gifPath": "digits",
    "format": "gif"
  }
}
```

### 4. 重新加载主题

1. 打开应用托盘菜单
2. 点击 **"Reload Themes"**
3. 选择你的主题

## 详细文档

- **[THEME_GUIDE.md](THEME_GUIDE.md)** - 完整的主题开发指南
- **[example_mod/README.md](example_mod/README.md)** - 示例主题说明

## 配置提示

### 紧凑显示

```json
{
  "borderRadius": 12,
  "padding": { "preset": "compact" },
  "digit": { "spacing": 0 }
}
```

### 毛玻璃效果

```json
{
  "kind": "blur",
  "blur": { "sigmaX": 16, "sigmaY": 16 },
  "tintOpacityMultiplier": 0.15
}
```

### 自定义颜色

```json
{
  "backgroundColor": "#202020",
  "backgroundOpacityMultiplier": 0.5,
  "tintColor": "#FF6B6B",
  "tintOpacityMultiplier": 0.2
}
```

## 故障排除

### 主题未显示

1. 检查 `theme.json` 是否为有效 JSON
2. 确认 `id` 和 `name` 字段存在
3. 查看应用日志（设置 → View Logs）

### 数字不显示

1. 检查 `digit.gifPath` 路径是否正确
2. 确认图片文件命名为 `0.gif` ~ `9.gif`
3. 尝试指定 `digit.format` 字段

### 字体未生效

1. 确认字体文件路径正确
2. 检查 `fontFamily` 名称拼写
3. 字体仅应用于冒号 `:`

## 兼容性说明

### 旧版主题支持

应用仍然支持旧版单文件主题（直接放在 `themes/` 根目录的 `.json` 文件）。但推荐使用新的主题包结构以便更好地组织资源。

### 迁移指南

旧版主题：
```
themes/
├── my_theme.json
└── gif/
    └── ...
```

新版主题：
```
themes/
└── my_theme/
    ├── theme.json
    └── digits/
        └── ...
```

## 分享主题

如果你创建了精美的主题，欢迎分享：

1. 将主题文件夹打包为 `.zip`
2. 在 GitHub/论坛发布
3. 提供 README 和预览截图

---

**更多帮助**：查看 [主题开发指南](THEME_GUIDE.md)
