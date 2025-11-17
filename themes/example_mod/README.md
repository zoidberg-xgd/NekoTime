# 示例主题：Example Mod Theme

这是一个示例主题包，演示 solid 风格 + 背景图 + 前景叠加（overlay）+ 自定义字体 + 数字间距 + 布局对齐 + 内边距预设等能力。

## 目录结构
- theme.json（必需）
- assets/
  - bg.jpg（背景图片，jpg/png 均可）
  - overlay.png（可选，前景叠加图，建议透明 PNG）
  - ExampleModFont.ttf（可选，自定义字体文件）

## 安装与使用
1. 在应用设置对话框底部查看 `themes/` 目录路径。
2. 将整个 `example_mod` 文件夹复制到该 `themes/` 目录下。
3. 按照 `theme.json` 中的文件名，将素材放入 `assets/`：
   - `assets/bg.jpg`
   - `assets/overlay.png`
   - `assets/ExampleModFont.ttf`
4. 在应用中点击“重新加载主题”。
5. 选择“Example Mod Theme”查看效果。

## theme.json 关键字段
- kind：`transparent` | `blur` | `solid`
- borderRadius：圆角半径
- padding：
  - 数值：`horizontal` 与 `vertical`
  - 预设：`preset` 支持 `none` | `compact` | `cozy` | `comfortable`
- layout.alignment：`left` | `center` | `right`
- 颜色与不透明度：`backgroundColor`、`tintColor`、`backgroundOpacityMultiplier`、`tintOpacityMultiplier`
- 模糊参数（仅当 kind = `blur`）：`blur.sigmaX`、`blur.sigmaY`
- 背景图：`backgroundImage`（相对主题包目录）
- 前景叠加：`overlayImage`（覆盖在内容之上）
- 数字间距：`digit.spacing`
- 字体：`fontFamily` 与 `fonts`（相对路径），运行时动态加载

你可以复制此文件夹，修改 `id` 与 `name`，并调整参数快速创建你自己的主题。
