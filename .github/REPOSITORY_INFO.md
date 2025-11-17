# GitHub 仓库配置建议

## 仓库名称
建议保持：`NekoTime`
- GitHub URL 友好
- 易于分享和引用
- 避免中文路径问题

## 仓库描述（About - Description）
```
猫铃时钟 - 可爱的桌面悬浮时钟 | A cute desktop floating clock with customizable GIF themes for macOS, Windows & Linux
```

## 网站（Website）
```
https://github.com/zoidberg-xgd/NekoTime
```

## 标签（Topics）
建议添加以下标签（在 GitHub 仓库页面设置）：
- `flutter`
- `desktop-app`
- `clock`
- `macos`
- `windows`
- `linux`
- `gif-animation`
- `transparent-window`
- `system-tray`
- `desktop-clock`
- `flutter-desktop`
- `cross-platform`
- `theme-customization`

## 如何更新

### 通过 GitHub 网页
1. 访问仓库主页：https://github.com/zoidberg-xgd/NekoTime
2. 点击右上角的 ⚙️ Settings
3. 在 "About" 区域点击 ⚙️ 图标
4. 填写：
   - **Description**: 粘贴上面的描述
   - **Website**: (可选) 添加项目网站或文档链接
   - **Topics**: 添加上面建议的标签
5. 点击 "Save changes"

### 关于仓库名称
⚠️ **不建议使用中文仓库名**，原因：
- URL 会被编码，如 `%E7%8C%AB%E9%93%83%E6%97%B6%E9%92%9F`
- 不利于命令行操作和 Git clone
- 某些系统可能不支持

✅ **推荐做法**：
- 保持英文名称：`NekoTime`
- 在 Description 中使用中文：`猫铃时钟 - ...`
- 在 README 标题中使用中文：`# NekoTime - 猫铃时钟`

## 社交预览图（Optional）
如果想添加仓库预览图：
1. Settings → General → Social preview
2. 上传 1280x640 像素的图片
3. 可以使用 `docs/screenshots/demo.gif` 的静态帧
