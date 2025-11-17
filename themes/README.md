# 自定义主题（主题包）

应用支持以“主题包”的方式加载主题：在 `themes/` 目录下创建子文件夹，每个文件夹内包含一个 `theme.json` 和可选的 `assets/` 静态资源。也兼容旧版：放在 `themes/` 根目录的独立 `.json` 文件仍会被加载。

## 目录结构示例
```
/themes/
  your_theme_id/
    theme.json
    assets/
      bg.jpg
      overlay.png
      CustomFont.ttf
```

## theme.json 示例
```json
{
  "id": "your_theme_id",
  "name": "你的主题名",
  "version": "1.0.0",
  "apiVersion": 1,
  "kind": "solid",
  "borderRadius": 16,
  "padding": { "preset": "cozy", "horizontal": 16, "vertical": 8 },
  "layout": { "alignment": "center" },
  "backgroundColor": "#101218",
  "backgroundOpacityMultiplier": 0.6,
  "tintColor": "#3D5AFE",
  "tintOpacityMultiplier": 0.08,
  "blur": { "sigmaX": 12, "sigmaY": 12 },
  "backgroundImage": "assets/bg.jpg",
  "overlayImage": "assets/overlay.png",
  "fontFamily": "CustomFont",
  "fonts": [ "assets/CustomFont.ttf" ],
  "digit": { "spacing": 8 }
}
```

## 字段说明（Manifest Schema）
- 基础
  - `id`：主题唯一 ID（建议与文件夹名一致）
  - `name`：显示名称
  - `version`：主题自身版本（可选）
  - `apiVersion`：主题 API 版本（可选，用于兼容性控制）
  - `kind`：`transparent` | `blur` | `solid`
- 布局与间距
  - `padding`：
    - 数值：`horizontal`、`vertical`
    - 或预设：`preset` 支持 `none` | `compact` | `cozy` | `comfortable`
  - `layout.alignment`：`left` | `center` | `right`
  - `digit.spacing`（或 `digitSpacing`）：数字间距（像素）
- 视觉
  - `backgroundColor`、`backgroundOpacityMultiplier`
  - `tintColor`、`tintOpacityMultiplier`
  - `blur.sigmaX`、`blur.sigmaY`（仅 `kind = blur` 有效）
  - `backgroundImage`：背景图片（相对主题包目录）
  - `overlayImage`：前景叠加图（覆盖在内容之上）
- 字体
  - `fontFamily`：字体族名
  - `fonts`：字体文件列表（相对路径），运行时动态加载

## 使用步骤
1. 打开应用设置对话框，查看底部提示的 `themes/` 目录路径。
2. 将你的主题包文件夹（含 `theme.json` 与 `assets/`）复制到该目录。
3. 点击“重新加载主题”，在列表中选择你的主题。

## 兼容说明（旧版）
- 仍支持将单个 `.json` 放在 `themes/` 根目录（不带子文件夹）。此时资源路径以该 `.json` 所在目录为基准解析。
- 建议优先使用“主题包”结构，便于组织资源与分享。
