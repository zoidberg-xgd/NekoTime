# Example Mod Theme - 示例主题

这是一个功能完整的示例主题，展示了 NekoTime 主题系统的各种能力。

## 🎨 功能展示

本主题演示了以下功能：
- ✅ Solid 纯色/图片背景模式
- ✅ 自定义背景图片
- ✅ 前景叠加层（Overlay）
- ✅ 自定义字体
- ✅ 数字间距配置
- ✅ 布局对齐
- ✅ 内边距预设

## 📂 目录结构

```
example_mod/
├── theme.json              # 主题配置文件（必需）
├── digits/                 # 数字图片文件夹
│   ├── 0.gif
│   ├── 1.gif
│   ├── ...
│   └── 9.gif
└── assets/                 # 资源文件（可选）
    ├── bg.jpg              # 背景图片
    ├── overlay.png         # 前景叠加图（半透明 PNG）
    └── ExampleFont.ttf     # 自定义字体
```

## 🚀 使用方法

### 1. 定位主题目录

打开应用设置对话框，在底部找到 `themes/` 目录的完整路径。

| 平台 | 路径 |
|------|------|
| **macOS (Sandbox)** | `~/Library/Containers/com.nekotime.app/Data/Library/Application Support/com.nekotime.app/themes/` |
| **macOS (非 Sandbox)** | `~/Library/Application Support/NekoTime/themes/` |
| **Windows** | `%APPDATA%\com.nekotime.app\themes\` |
| **Linux** | `~/.local/share/com.nekotime.app/themes/` |

### 2. 安装主题

将整个 `example_mod` 文件夹复制到主题目录：

```bash
# macOS (Sandbox 模式)
cp -r example_mod ~/Library/Containers/com.nekotime.app/Data/Library/Application\ Support/com.nekotime.app/themes/
```

### 3. 准备资源（可选）

如果你想使用背景图、叠加图和字体，请准备以下文件并放入 `assets/` 文件夹：

- `bg.jpg` - 背景图片（JPG/PNG）
- `overlay.png` - 前景叠加图（建议使用半透明 PNG）
- `ExampleFont.ttf` - 自定义字体（TTF/OTF）

### 4. 重新加载主题

1. 打开托盘菜单
2. 点击 **"Reload Themes"**
3. 选择 **"Example Mod Theme"**

## ⚙️ 配置说明

### 主题配置文件

查看 `theme.json` 了解完整配置：

```json
{
  "id": "example_mod",
  "name": "Example Mod Theme",
  "version": "1.0.0",
  "kind": "solid",
  "borderRadius": 16,
  "padding": {
    "preset": "cozy"
  },
  "layout": {
    "alignment": "center"
  },
  "backgroundColor": "#101218",
  "backgroundOpacityMultiplier": 0.6,
  "backgroundImage": "assets/bg.jpg",
  "overlayImage": "assets/overlay.png",
  "overlayOpacityMultiplier": 0.3,
  "fontFamily": "ExampleFont",
  "fonts": ["assets/ExampleFont.ttf"],
  "digit": {
    "spacing": 2,
    "gifPath": "digits",
    "format": "gif"
  }
}
```

### 关键字段说明

| 字段 | 说明 | 值 |
|------|------|------|
| `kind` | 主题类型 | `solid` (纯色/图片背景) |
| `borderRadius` | 圆角半径 | `16` 像素 |
| `padding.preset` | 内边距预设 | `cozy` (舒适) |
| `layout.alignment` | 对齐方式 | `center` (居中) |
| `backgroundColor` | 背景颜色 | `#101218` |
| `backgroundOpacityMultiplier` | 背景不透明度 | `0.6` (60%) |
| `backgroundImage` | 背景图路径 | `assets/bg.jpg` |
| `overlayImage` | 叠加图路径 | `assets/overlay.png` |
| `overlayOpacityMultiplier` | 叠加不透明度 | `0.3` (30%) |
| `fontFamily` | 字体名称 | `ExampleFont` |
| `fonts` | 字体文件 | `["assets/ExampleFont.ttf"]` |
| `digit.spacing` | 数字间距 | `2` 像素 |
| `digit.gifPath` | 数字图片路径 | `digits` |
| `digit.format` | 图片格式 | `gif` |

## 🎨 自定义主题

### 复制并修改

1. 复制整个 `example_mod` 文件夹
2. 重命名为你的主题名（如 `my_theme`）
3. 编辑 `theme.json`：
   ```json
   {
     "id": "my_theme",
     "name": "My Custom Theme",
     ...
   }
   ```
4. 替换 `digits/` 和 `assets/` 中的资源
5. 重新加载主题

### 修改预设

**紧凑显示**：
```json
{
  "borderRadius": 12,
  "padding": { "preset": "compact" },
  "digit": { "spacing": 0 }
}
```

**毛玻璃效果**（改为 blur 模式）：
```json
{
  "kind": "blur",
  "blur": { "sigmaX": 16, "sigmaY": 16 }
}
```

**透明背景**：
```json
{
  "kind": "transparent",
  "backgroundImage": null,
  "overlayImage": null
}
```

## 📖 更多资源

- **[主题开发指南](../THEME_GUIDE.md)** - 完整的开发文档
- **[主题目录说明](../README.md)** - 目录结构和使用说明

## 💡 提示

1. **资源可选**：如果不需要背景图、叠加图或字体，可以删除相关字段
2. **路径相对**：所有资源路径都相对于主题根目录
3. **格式自由**：数字图片支持 GIF/PNG/JPG/WebP/BMP
4. **实时预览**：修改配置后点击"Reload Themes"即可预览

## 🔧 故障排除

**主题未加载**：
- 检查 `theme.json` 是否为有效 JSON
- 确认 `id` 和 `name` 字段存在

**图片未显示**：
- 确认图片文件存在且命名正确
- 检查路径拼写

**字体未生效**：
- 确认字体文件存在
- 字体仅应用于冒号 `:`

---

**祝你创建出精美的主题！** 🎨✨
