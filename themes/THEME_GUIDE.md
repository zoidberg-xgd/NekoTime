# 主题开发指南

## 数字图片配置

应用支持多种图片格式作为数字显示，包括：GIF、PNG、JPG、JPEG、WebP、BMP 等。

### 配置方式

在主题的 `theme.json` 文件中，通过 `digit` 对象配置数字图片：

```json
{
  "digit": {
    "spacing": 8,           // 数字间距
    "gifPath": "gif",       // 数字图片文件夹路径（相对于主题包根目录）
    "format": "gif"         // 图片格式：gif、png、jpg、webp 等（可选，留空自动检测）
  }
}
```

### 配置说明

1. **gifPath**（必需）
   - 指定数字图片所在的文件夹路径
   - 可以是相对路径（如 `"gif"`, `"images/digits"`）
   - 对于内置主题，可以使用 `"assets/gif"` 指向应用内置资源

2. **format**（可选）
   - 指定数字图片的格式
   - 支持的格式：`gif`、`png`、`jpg`、`jpeg`、`webp`、`bmp`
   - 如果不指定或留空，应用会自动检测（按 gif → png → jpg → jpeg → webp → bmp 的顺序）

3. **spacing**（可选）
   - 数字之间的间距（像素）
   - 默认值为 0
   - 推荐值：
     - 紧凑显示：0-2
     - 标准显示：4-8
     - 宽松显示：10-16

### 文件命名规则

数字图片文件必须按以下规则命名：

- `0.gif` / `0.png` - 数字 0
- `1.gif` / `1.png` - 数字 1
- `2.gif` / `2.png` - 数字 2
- `3.gif` / `3.png` - 数字 3
- `4.gif` / `4.png` - 数字 4
- `5.gif` / `5.png` - 数字 5
- `6.gif` / `6.png` - 数字 6
- `7.gif` / `7.png` - 数字 7
- `8.gif` / `8.png` - 数字 8
- `9.gif` / `9.png` - 数字 9

注意：冒号（:）使用文本渲染，不需要图片文件。

### 示例配置

#### 使用 GIF 动画

```json
{
  "id": "animated_theme",
  "name": "Animated Theme",
  "digit": {
    "spacing": 10,
    "gifPath": "gif",
    "format": "gif"
  }
}
```

文件结构：
```
animated_theme/
├── theme.json
└── gif/
    ├── 0.gif
    ├── 1.gif
    ├── 2.gif
    └── ...
```

#### 使用 PNG 静态图片

```json
{
  "id": "static_theme",
  "name": "Static Theme",
  "digit": {
    "spacing": 5,
    "gifPath": "images",
    "format": "png"
  }
}
```

文件结构：
```
static_theme/
├── theme.json
└── images/
    ├── 0.png
    ├── 1.png
    ├── 2.png
    └── ...
```

#### 自动检测格式

```json
{
  "id": "auto_theme",
  "name": "Auto Detect Theme",
  "digit": {
    "spacing": 8,
    "gifPath": "digits"
    // 不指定 format，自动检测
  }
}
```

应用会自动查找 `digits/0.gif`、`digits/0.png` 等文件。

### 最佳实践

1. **动画效果**：使用 GIF 或 WebP 格式支持动画
2. **静态图片**：使用 PNG 格式获得最佳质量
3. **文件大小**：JPG 格式可以减小文件大小，但不支持透明背景
4. **性能考虑**：避免使用过大的图片文件（建议每个文件 < 500KB）
5. **透明背景**：推荐使用 PNG 或 GIF 格式以支持透明背景

## 调整紧凑度

如果你觉得时钟显示太大或四周有过多留白，可以调整以下参数：

### 1. Padding（内边距）
```json
"padding": { "preset": "compact" }  // 紧凑（推荐）
"padding": { "preset": "cozy" }     // 舒适
"padding": { "preset": "comfortable" } // 宽松
"padding": { "preset": "none" }     // 无边距
```

或自定义：
```json
"padding": { "horizontal": 8, "vertical": 4 }
```

### 2. 数字间距
```json
"digit": { "spacing": 2 }  // 紧凑显示
```

### 3. 边框圆角
```json
"borderRadius": 12  // 较小的圆角，视觉上更紧凑
```

## 完整主题示例（紧凑版）

```json
{
  "id": "my_custom_theme",
  "name": "My Custom Theme",
  "version": "1.0.0",
  "apiVersion": 1,
  "kind": "blur",
  "borderRadius": 12,
  "padding": { "preset": "compact" },
  "layout": { "alignment": "center" },
  "backgroundColor": "#202020",
  "backgroundOpacityMultiplier": 0.5,
  "blur": { "sigmaX": 12, "sigmaY": 12 },
  "digit": {
    "spacing": 2,
    "gifPath": "gif",
    "format": "gif"
  }
}
```
