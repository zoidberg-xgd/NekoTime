# NekoTime 主题开发指南

## 概述

NekoTime 采用模块化的主题系统，允许你通过 JSON 配置文件和资源文件创建自定义主题。本指南将详细介绍如何开发、配置和发布主题。

## 快速开始

### 最小主题结构

```
my_theme/
├── theme.json          # 主题配置（必需）
└── digits/             # 数字图片文件夹（可选）
    ├── 0.gif
    ├── 1.gif
    └── ...
```

### 最小配置示例

```json
{
  "id": "my_theme",
  "name": "My Theme",
  "kind": "transparent"
}
```

这就是一个完整可用的主题！

---

## 完整配置参考

### 基础信息

```json
{
  "id": "my_awesome_theme",
  "name": "My Awesome Theme",
  "version": "1.0.0",
  "apiVersion": 1
}
```

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `id` | String | ✅ | 主题唯一标识符，建议与文件夹名一致 |
| `name` | String | ✅ | 显示名称 |
| `version` | String | ❌ | 主题版本号（语义化版本） |
| `apiVersion` | Number | ❌ | API 版本，当前为 1 |

---

## 外观配置

### 主题类型 (kind)

```json
{
  "kind": "blur"
}
```

支持三种类型：
- `transparent` - 完全透明，无背景
- `blur` - 毛玻璃模糊效果
- `solid` - 纯色/图片背景

### 颜色与透明度

```json
{
  "backgroundColor": "#202020",
  "backgroundOpacityMultiplier": 0.5,
  "tintColor": "#9E9E9E",
  "tintOpacityMultiplier": 0.15
}
```

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `backgroundColor` | String | `null` | 背景颜色（十六进制） |
| `backgroundOpacityMultiplier` | Number | 0.0 | 背景不透明度系数（0.0-1.0） |
| `tintColor` | String | `null` | 着色/叠加颜色 |
| `tintOpacityMultiplier` | Number | 0.0 | 着色不透明度系数 |

**注意**：实际透明度 = 系数 × 用户设置的透明度

### 模糊效果（仅 kind: blur）

```json
{
  "blur": {
    "sigmaX": 16,
    "sigmaY": 16
  }
}
```

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `blur.sigmaX` | Number | 0 | 水平模糊程度（0-50） |
| `blur.sigmaY` | Number | 0 | 垂直模糊程度（0-50） |

推荐值：
- 轻微模糊：8-12
- 标准模糊：12-18
- 强烈模糊：18-30

### 边框与圆角

```json
{
  "borderRadius": 12
}
```

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `borderRadius` | Number | 0 | 圆角半径（像素） |

推荐值：
- 无圆角：0
- 轻微圆角：8-12
- 标准圆角：12-16
- 强圆角：16-24

---

## 布局配置

### 内边距 (padding)

**使用预设**：
```json
{
  "padding": {
    "preset": "compact"
  }
}
```

预设选项：
- `none` - 0/0（无边距）
- `compact` - 8/4（紧凑）
- `cozy` - 16/8（舒适，默认）
- `comfortable` - 24/12（宽松）

**自定义值**：
```json
{
  "padding": {
    "horizontal": 12,
    "vertical": 6
  }
}
```

### 对齐方式 (alignment)

```json
{
  "layout": {
    "alignment": "center"
  }
}
```

选项：
- `left` - 左对齐
- `center` - 居中（默认）
- `right` - 右对齐

---

## 数字图片配置

### 基础配置

```json
{
  "digit": {
    "spacing": 2,
    "gifPath": "digits",
    "format": "gif"
  }
}
```

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `digit.spacing` | Number | ❌ | 数字间距（像素），默认 0 |
| `digit.gifPath` | String | ❌ | 数字图片文件夹路径（相对主题根目录） |
| `digit.format` | String | ❌ | 图片格式，留空自动检测 |

### 支持的图片格式

- `gif` - GIF 动画（支持透明背景）
- `png` - PNG 图片（支持透明背景，推荐静态图）
- `jpg` / `jpeg` - JPEG 图片（不支持透明背景）
- `webp` - WebP 图片（支持动画和透明背景）
- `bmp` - BMP 位图

### 文件命名规范

**必须**使用以下文件名：
```
digits/
├── 0.gif
├── 1.gif
├── 2.gif
├── 3.gif
├── 4.gif
├── 5.gif
├── 6.gif
├── 7.gif
├── 8.gif
└── 9.gif
```

**注意**：冒号 `:` 使用文本渲染，无需提供图片文件。

### 数字间距推荐

```json
{
  "digit": {
    "spacing": 0    // 紧凑：0-2
  }
}
```

- **紧凑**：0-2 像素
- **标准**：4-8 像素
- **宽松**：10-16 像素

### 格式自动检测

如果不指定 `format`，应用会按以下顺序查找：
```
digits/0.gif → digits/0.png → digits/0.jpg → digits/0.jpeg → digits/0.webp → digits/0.bmp
```

找到第一个存在的文件后，使用该格式。

---

## 背景图片与叠加

### 背景图片

```json
{
  "backgroundImage": "assets/background.jpg"
}
```

支持格式：JPG, PNG, WebP, BMP

### 前景叠加图

```json
{
  "overlayImage": "assets/overlay.png",
  "overlayOpacityMultiplier": 0.3
}
```

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `overlayImage` | String | `null` | 前景叠加图路径 |
| `overlayOpacityMultiplier` | Number | 1.0 | 叠加图不透明度系数 |

**推荐**：使用 PNG 格式的半透明图片作为叠加层。

---

## 自定义字体

### 配置字体

```json
{
  "fontFamily": "MyCustomFont",
  "fonts": [
    "assets/MyCustomFont-Regular.ttf",
    "assets/MyCustomFont-Bold.ttf"
  ]
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `fontFamily` | String | 字体族名（用于 CSS font-family） |
| `fonts` | Array | 字体文件路径数组（TTF/OTF） |

**注意**：
- 字体文件路径相对于主题根目录
- 支持 TrueType (.ttf) 和 OpenType (.otf)
- 字体仅应用于冒号 `:` 的文本显示

---

## 完整主题示例

### 极简透明主题

```json
{
  "id": "minimal",
  "name": "Minimal Transparent",
  "kind": "transparent",
  "padding": {
    "preset": "compact"
  },
  "digit": {
    "spacing": 2,
    "gifPath": "digits",
    "format": "png"
  }
}
```

### 毛玻璃主题

```json
{
  "id": "frosted_glass",
  "name": "Frosted Glass",
  "version": "1.0.0",
  "apiVersion": 1,
  "kind": "blur",
  "borderRadius": 16,
  "padding": {
    "preset": "cozy"
  },
  "backgroundColor": "#9E9E9E",
  "backgroundOpacityMultiplier": 0.3,
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

### 背景图主题

```json
{
  "id": "cyberpunk",
  "name": "Cyberpunk Theme",
  "version": "1.0.0",
  "kind": "solid",
  "borderRadius": 12,
  "padding": {
    "horizontal": 16,
    "vertical": 8
  },
  "backgroundColor": "#0A0E27",
  "backgroundOpacityMultiplier": 0.8,
  "backgroundImage": "assets/cyberpunk_bg.jpg",
  "overlayImage": "assets/grid_overlay.png",
  "overlayOpacityMultiplier": 0.5,
  "fontFamily": "CyberpunkFont",
  "fonts": ["assets/Cyberpunk.ttf"],
  "digit": {
    "spacing": 4,
    "gifPath": "digits",
    "format": "gif"
  }
}
```

---

## 最佳实践

### 性能优化

1. **图片大小**：控制每个数字图片 < 500KB
2. **GIF 优化**：使用工具压缩 GIF 动画
3. **分辨率**：推荐数字图片高度 80-120px
4. **格式选择**：
   - 动画 → GIF/WebP
   - 静态 → PNG（透明）/JPG（实景）

### 视觉设计

1. **对比度**：确保数字在背景上清晰可见
2. **透明度**：合理使用不透明度系数（0.3-0.7）
3. **紧凑度**：减少留白提升空间利用率
4. **一致性**：保持所有数字视觉风格统一

### 目录结构

推荐的主题目录结构：
```
my_theme/
├── theme.json
├── digits/
│   ├── 0.gif
│   ├── 1.gif
│   └── ...
└── assets/
    ├── background.jpg
    ├── overlay.png
    └── CustomFont.ttf
```

---

## 测试与调试

### 本地测试

1. 将主题文件夹复制到 themes 目录
2. 打开托盘菜单 → **Reload Themes**
3. 选择你的主题查看效果

### 查看日志

1. 打开设置对话框
2. 点击 **View Logs**
3. 查找主题加载错误信息

常见错误：
- JSON 语法错误
- 图片文件缺失
- 字体加载失败

### 配置验证

确保 `theme.json` 是有效的 JSON：
```bash
# 使用 jq 验证
cat theme.json | jq .

# 或使用在线工具
https://jsonlint.com
```

---

## 主题发布

### 打包主题

1. 确保主题文件夹包含所有必需资源
2. 压缩为 `.zip` 文件
3. 提供清晰的 README 说明

### 分享主题

可以通过以下方式分享：
- GitHub Release
- 论坛/社区
- 主题网站（未来支持）

---

## 配置字段速查表

| 字段 | 类型 | 必需 | 默认值 | 说明 |
|------|------|------|--------|------|
| `id` | String | ✅ | - | 主题 ID |
| `name` | String | ✅ | - | 显示名称 |
| `version` | String | ❌ | - | 版本号 |
| `apiVersion` | Number | ❌ | 1 | API 版本 |
| `kind` | String | ❌ | `transparent` | 主题类型 |
| `borderRadius` | Number | ❌ | 0 | 圆角半径 |
| `padding.preset` | String | ❌ | `cozy` | 内边距预设 |
| `padding.horizontal` | Number | ❌ | - | 水平内边距 |
| `padding.vertical` | Number | ❌ | - | 垂直内边距 |
| `layout.alignment` | String | ❌ | `center` | 对齐方式 |
| `backgroundColor` | String | ❌ | `null` | 背景颜色 |
| `backgroundOpacityMultiplier` | Number | ❌ | 0.0 | 背景不透明度 |
| `tintColor` | String | ❌ | `null` | 着色颜色 |
| `tintOpacityMultiplier` | Number | ❌ | 0.0 | 着色不透明度 |
| `blur.sigmaX` | Number | ❌ | 0 | 水平模糊 |
| `blur.sigmaY` | Number | ❌ | 0 | 垂直模糊 |
| `backgroundImage` | String | ❌ | `null` | 背景图路径 |
| `overlayImage` | String | ❌ | `null` | 叠加图路径 |
| `overlayOpacityMultiplier` | Number | ❌ | 1.0 | 叠加不透明度 |
| `fontFamily` | String | ❌ | `null` | 字体族名 |
| `fonts` | Array | ❌ | `[]` | 字体文件路径 |
| `digit.spacing` | Number | ❌ | 0 | 数字间距 |
| `digit.gifPath` | String | ❌ | `null` | 数字图片路径 |
| `digit.format` | String | ❌ | `null` | 图片格式 |

---

**最后更新**: 2025-01-18  
**文档版本**: 2.0
