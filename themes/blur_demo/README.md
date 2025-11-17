# 示例主题：Blur Demo Theme

一个 blur 风格的示例主题，展示 毛玻璃 + 背景图 + 前景叠加（overlay）+ 布局对齐 + 内边距预设 等能力。

## 目录结构
- theme.json（必需）
- assets/
  - bg.jpg（背景图片）
  - overlay.png（可选，前景叠加图，透明 PNG）
  - BlurDemoFont.ttf（可选，自定义字体）

## 使用步骤
1. 将整个 `blur_demo` 文件夹复制到应用的 `themes/` 目录（可在设置对话框的提示中查看路径）。
2. 将上面列出的素材放到 `assets/` 下，并确保与 `theme.json` 中的文件名一致。
3. 在应用中点击“重新加载主题”，选择 “Blur Demo Theme”。

## theme.json 关键字段
- kind：固定为 `blur`
- 内边距预设：`padding.preset` 支持 `none` | `compact` | `cozy` | `comfortable`
- 布局对齐：`layout.alignment` 支持 `left` | `center` | `right`
- 背景与前景：`backgroundImage`、`overlayImage`（相对本主题文件夹）
- 模糊强度：`blur.sigmaX`、`blur.sigmaY`
- 颜色与不透明度：`backgroundColor`、`tintColor`、`backgroundOpacityMultiplier`、`tintOpacityMultiplier`
- 数字间距：`digit.spacing`
- 字体：`fontFamily`、`fonts`
