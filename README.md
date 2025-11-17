# 猫铃时钟 NekoTime

一款基于 Flutter 的桌面悬浮时钟（macOS/Windows/Linux），以像素风 GIF 数字呈现，支持透明/磨砂玻璃/水玻璃三种主题、可调透明度与等比缩放，并提供系统托盘菜单进行所有设置。

## 特性
- 无边框透明窗口，窗口尺寸自动贴合内容
- 主题：Transparent（透明）/ Frosted Glass（磨砂）/ Aqua Glass（水玻璃）
- 透明度可调（0.30/0.50/0.70/0.85/1.00）
- 等比缩放（0.75x/1.00x/1.25x/1.50x/2.00x），窗口随内容自适应
- 托盘菜单完成全部设置（不在窗口内占位）：
  - 主题/透明度/缩放
  - 显示秒 开/关（默认关闭）
  - 锁定位置、窗口层级（置顶/普通/桌面）
  - 退出
- macOS 托盘采用 template 单色图标（并有 ⏰ 标题兜底），适配浅/深色菜单栏

## 运行
```bash
flutter pub get
flutter run -d macos   # 或 -d windows / -d linux
```

如需生成托盘模板/图标（需已安装 ImageMagick）：
```bash
bash tool/generate_tray_icons.sh
```

## 目录
- lib/core/* 配置与时间服务
- lib/ui/* 界面与组件
- lib/utils/tray_controller.dart 托盘菜单逻辑（system_tray）

## 许可
本项目仅用于学习与演示，GIF 资源请按各自授权使用。
