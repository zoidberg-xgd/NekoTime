# 更新日志

NekoTime 的所有重要变更都将记录在此文件中。

本日志格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
项目遵循[语义化版本](https://semver.org/lang/zh-CN/)规范。

## [未发布]

## [2.2.2] - 2025-11-18

### 修复
- **隐藏/显示**：修复显示窗口后透明度丢失问题
  - 显示窗口时恢复用户配置的透明度，而不是固定为 1.0
- **锁定位置**：锁定位置后禁用双击隐藏功能
  - 避免锁定状态下误触发隐藏

## [2.2.1] - 2025-11-18

### 修复
- **CI 兼容性**：修复 Flutter SDK 版本兼容性问题
  - 更新 CI 到 Flutter 3.27.1
  - 使用现代 Color API component accessors (`.a/.r/.g/.b`)
  - 修复所有 CI 平台的构建失败问题
- **配置兼容性**：修复旧版本配置加载崩溃
  - 添加对旧版三层级配置的兼容处理
  - 修复 `layerIndex` 越界导致的 RangeError
- **窗口显示**：修复首次启动时窗口大小不正确
  - 确保首次构建时正确应用窗口尺寸
  - 修复布局溢出问题

## [2.2.0] - 2025-11-18

### 变更
- **窗口层级简化**：将三层级（桌面层/普通层/置顶层）简化为两层级（桌面层/置顶层）
  - 原因：由于跨平台库限制，普通层与桌面层实际效果相同
  - 改进：简化用户界面，避免功能重复混淆
  - 影响：现有用户的"普通层"设置会自动转换为"桌面层"

### 修复
- **代码质量改进**：修复 Flutter SDK API 废弃警告
  - 更新 `Color.withOpacity()` 为 `Color.withValues(alpha:)`
  - 更新 `Color.value` 为 `Color.toARGB32()`
  - 更新 `Color.opacity` 为 `Color.a`
  - 移除未使用的导入
  - 通过静态分析检查，无问题

## [2.1.0] - 2025-11-18

### 修复
- **关键修复**：应用卡死/无响应问题（导致 macOS 强制退出对话框）
  - 根本原因：每秒触发大量调试日志输出
  - 根本原因：`ClockScreen` 构建方法中重复执行窗口操作
  - 解决方案：移除所有每秒触发的调试日志
  - 解决方案：添加配置状态缓存以防止冗余窗口更新
  - 解决方案：仅在配置实际变更时更新窗口属性

### 变更
- 优化 UI 渲染性能
  - 移除 `TimeDisplay` 组件中的过量日志
  - 移除 `DigitGifV2` 组件中的频繁日志
  - 保留错误日志用于调试
- 改进窗口管理
  - 窗口大小仅在主题或缩放变化时更新
  - 透明度仅在数值变化时更新
  - 避免重复的 `addPostFrameCallback` 调用

### 性能
- 通过消除高频 I/O 操作降低主线程负载
- 最小化不必要的 `setState` 调用
- 优化状态比较逻辑

## [2.0.0] - 2025-11-18

### 新增
- **模块化主题系统**，采用主题包结构
- **内置毛玻璃主题**，随应用预装
- **完整的日志系统**
  - 基于文件的日志，自动轮转（5MB 上限，保留 3 个备份）
  - 应用内日志查看器，实时显示
  - 多级日志：DEBUG、INFO、WARNING、ERROR
- **多格式图片支持**用于数字显示
  - 支持格式：GIF、PNG、JPG、JPEG、WebP、BMP
  - 自动格式检测
- **双击隐藏**功能
- **托盘菜单增强**
  - 快速显示/隐藏切换
  - 主题重载按钮
  - 日志查看器入口
- **开发者工具**
  - 日志查看器对话框
  - 打开主题文件夹
  - 打开日志目录
- 完善的主题开发文档
  - `themes/THEME_GUIDE.md` - 完整主题开发指南
  - `themes/README.md` - 主题使用说明
  - `themes/example_mod/README.md` - 示例主题文档

### 修复
- **无限重建循环**导致主题切换后数字消失
  - 根本原因：`ensureFontsLoaded()` 中的 `setState` 触发无限重建
  - 解决方案：添加主题加载缓存（`_lastLoadedThemeId`）
  - 解决方案：仅在主题 ID 变化时加载字体一次
- **窗口缩放比例**问题
  - 修复缩放时宽高比错误
  - 优化窗口尺寸计算逻辑

### 变更
- **显示紧凑度改进**
  - 数字宽度：`0.75 → 0.6`（紧凑 20%）
  - 冒号宽度：`0.4 → 0.3`（紧凑 25%）
  - 内置主题内边距：`16/8 → 12/8`
  - 示例主题数字间距：`8-10 → 2`（减少 75%）
- 主题资源现在自动加载
- 向后兼容旧版单文件主题

### 性能
- 字体加载缓存机制防止重复加载
- 使用 `AutomaticKeepAliveClientMixin` 保持 GIF 动画状态
- `StreamBuilder` 和组件使用稳定 key
- 减少不必要的组件重建

## [1.0.0] - 2025-11-18

### 新增
- 初始版本发布
- 跨平台桌面时钟（macOS、Windows、Linux）
- 系统级窗口透明
- 模糊/毛玻璃效果
- 可拖动和锁定窗口
- 两层窗口管理（桌面层/置顶层）
- 缩放调节（0.75x - 2.0x）
- 透明度控制（10% - 100%）
- 系统托盘集成
- 基础主题支持
- 国际化（中文/英文）
- 配置持久化

---

## 迁移指南

### 从 v1.x 升级到 v2.0

**主题结构变更**

旧结构（仍然支持）：
```
themes/
├── my_theme.json
└── gif/
    └── ...
```

新结构（推荐）：
```
themes/
└── my_theme/
    ├── theme.json
    └── digits/
        └── ...
```

**配置变更**

- 新增 `digit.gifPath` 和 `digit.format` 字段
- 新增 `padding.preset` 用于快速配置内边距
- 新增 `blur.sigmaX` 和 `blur.sigmaY` 用于模糊效果

### 从 v2.0 升级到 v2.1

无破坏性变更。这是一个专注于修复应用卡死问题的性能优化版本。

---

## 说明

### 性能考虑

- v2.1.0 通过消除性能瓶颈显著提升了稳定性
- 调试日志已减少；使用日志查看器进行故障排除
- 窗口操作现在是智能且带缓存的

### 主题开发

- 查看 `themes/THEME_GUIDE.md` 了解完整文档
- 使用 `example_mod` 主题作为模板
- 所有主题资源路径都相对于主题根目录

### 已知限制

- 冒号（`:`）使用文本渲染，暂不支持自定义图片
- 主题修改后需手动重载

---

**项目仓库**：https://github.com/zoidberg-xgd/NekoTime

[未发布]: https://github.com/zoidberg-xgd/NekoTime/compare/v2.2.2...HEAD
[2.2.2]: https://github.com/zoidberg-xgd/NekoTime/compare/v2.2.1...v2.2.2
[2.2.1]: https://github.com/zoidberg-xgd/NekoTime/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/zoidberg-xgd/NekoTime/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/zoidberg-xgd/NekoTime/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/zoidberg-xgd/NekoTime/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/zoidberg-xgd/NekoTime/releases/tag/v1.0.0
