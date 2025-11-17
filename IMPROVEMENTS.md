# NekoTime 改进与更新日志

## 版本历史

### v2.1.0 (2025-01-18) - 性能优化版本

#### 🐛 关键 Bug 修复

**应用卡死/无响应问题**
- **问题描述**：应用运行一段时间后出现无响应，系统弹出"强制退出"对话框
- **根本原因**：
  1. 每秒触发的大量调试日志输出（`TimeDisplay`, `DigitGifV2`）
  2. `ClockScreen` build 方法中每秒多次调用 `addPostFrameCallback`
  3. 每秒执行窗口大小和透明度设置操作
  4. 累积的性能开销导致主线程阻塞
  
- **解决方案**：
  1. 移除所有每秒触发的调试日志
  2. 添加配置状态缓存（`_lastConfigThemeId`, `_lastScale`, `_lastOpacity`）
  3. 仅在配置实际变更时才执行窗口操作
  4. 保留错误日志以便故障诊断

#### ⚡ 性能优化

**减少 UI 重建**
- 移除 `TimeDisplay` 中无意义的日志输出
- 优化 `DigitGifV2` 资源检查逻辑
- 减少每秒的函数调用次数

**智能窗口管理**
- 窗口大小仅在主题或缩放变化时更新
- 透明度仅在值变化时应用
- 避免重复的 `addPostFrameCallback` 调用

**降低主线程负载**
- 移除高频日志 I/O 操作
- 优化状态比较逻辑
- 减少不必要的 `setState` 调用

#### 📁 修改文件

1. **lib/ui/widgets/time_display.dart**
   - 移除所有调试日志
   - 保持核心渲染逻辑不变

2. **lib/ui/widgets/digit_gif_v2.dart**
   - 移除频繁的调试日志
   - 保留错误日志以便诊断
   - 优化资源检查流程

3. **lib/ui/screens/clock_screen.dart**
   - 添加配置状态缓存变量
   - 仅在配置变更时更新窗口
   - 移除冗余的 `addPostFrameCallback`

---

### v2.0.0 - 重构版本

#### 🎉 重大功能

**主题系统重构**
- 支持模块化主题包（独立文件夹结构）
- 内置 Frosted Glass 毛玻璃主题
- 主题资源自动解析和加载
- 兼容旧版单 JSON 文件主题

**完整日志系统**
- 文件日志自动轮转（5MB 上限，保留 3 个备份）
- 应用内日志查看器（实时查看、复制、清空）
- 多级日志：DEBUG, INFO, WARNING, ERROR
- 详细的操作追踪（主题加载、图片加载、字体加载）

**多格式图片支持**
- 支持格式：GIF, PNG, JPG, JPEG, WebP, BMP
- 自动格式检测机制
- 配置化图片路径和格式

#### 🐛 问题修复

**主题切换后数字消失**
- **原因**：`ensureFontsLoaded()` 中的 `setState` 导致无限重建循环
- **解决**：
  - 添加主题加载缓存（`_lastLoadedThemeId`）
  - 仅在主题 ID 变化时加载字体
  - 移除循环触发的 `setState`

**显示紧凑度优化**
- 数字宽度：`0.75 → 0.6`（紧凑 20%）
- 冒号宽度：`0.4 → 0.3`（紧凑 25%）
- 内置主题 padding：`16/8 → 12/8`
- 示例主题数字间距：`8-10 → 2`

**窗口缩放比例问题**
- 修复缩放时窗口宽高比失调
- 优化窗口尺寸计算逻辑

#### ✨ 新增功能

**双击隐藏**
- 双击时钟窗口隐藏（透明度设为 0）
- 通过托盘菜单恢复显示

**托盘菜单增强**
- 快速显示/隐藏切换
- 主题热重载按钮
- 日志查看入口

**开发者工具**
- 日志查看器对话框
- 打开主题文件夹
- 打开日志目录

#### 📚 文档完善

新增文档：
- `themes/THEME_GUIDE.md` - 主题开发完整指南
- `themes/README.md` - 主题使用说明
- `themes/example_mod/README.md` - 示例主题说明

更新文档：
- `README.md` - 项目主文档
- `IMPROVEMENTS.md` - 本文件

#### 🔧 代码改进

**新增文件**
1. `lib/core/services/log_service.dart` - 日志服务
2. `lib/ui/widgets/log_viewer_dialog.dart` - 日志查看器
3. `lib/ui/widgets/digit_gif_v2.dart` - 重构的数字组件
4. `themes/THEME_GUIDE.md` - 主题指南

**修改文件**
1. `lib/ui/screens/clock_screen.dart` - 主题缓存、窗口管理
2. `lib/ui/widgets/digit_gif.dart` - 多格式支持
3. `lib/ui/widgets/time_display.dart` - 日志集成
4. `lib/core/services/theme_service.dart` - 主题包加载
5. `lib/core/models/theme_definition.dart` - 数字图片字段

**性能优化**
- 字体加载缓存机制
- GIF 动画状态保持（`AutomaticKeepAliveClientMixin`）
- StreamBuilder 稳定 key
- 减少不必要的重建

---

## 最佳实践

### 主题配置

**紧凑显示**
```json
{
  "borderRadius": 12,
  "padding": { "preset": "compact" },
  "digit": { "spacing": 2 }
}
```

**Padding 预设**
- `none`: 0/0（无边距）
- `compact`: 8/4（紧凑）
- `cozy`: 16/8（舒适，默认）
- `comfortable`: 24/12（宽松）

**数字间距推荐**
- 紧凑：0-2 像素
- 标准：4-8 像素
- 宽松：10-16 像素

### 开发建议

**日志使用**
1. 打开设置对话框
2. 点击 "View Logs" 查看运行日志
3. 可复制或清空日志内容
4. 点击 "Open Logs Folder" 访问日志文件

**主题开发**
1. 在 `themes/` 目录创建主题文件夹
2. 编写 `theme.json` 配置文件
3. 准备数字图片（0-9）和可选资源
4. 点击 "Reload Themes" 重新加载
5. 在托盘菜单切换到新主题

**调试技巧**
- 查看日志文件排查问题
- 使用错误日志定位加载失败的资源
- 主题 JSON 语法错误会被记录

---

## 已知限制

- 冒号使用文本渲染，暂不支持自定义图片
- 主题修改后需手动重载

## 未来计划

- [ ] 支持自定义冒号样式
- [ ] 主题文件监听（自动热重载）
- [ ] 更多内置主题
- [ ] 主题市场/分享平台
- [ ] 秒数显示选项
- [ ] 日期显示支持
- [ ] 更多布局模式

---

**最后更新**: 2025-01-18
