# Linux 故障排除指南

## 🐧 常见问题与解决方案

### 问题 1: 时钟周围有巨大黑色边框

**症状**: 应用运行正常，但时钟四周有很大的黑色区域

**原因**: 
- 窗口管理器不支持完全透明的无装饰窗口
- 某些桌面环境的合成器未启用
- GTK 客户端装饰（CSD）导致的边框

**解决方案**:

#### 方案 1: 使用启动脚本（推荐）
```bash
./run_linux.sh
```
启动脚本会自动设置必要的环境变量。

#### 方案 2: 手动设置环境变量
```bash
export GTK_CSD=0          # 禁用客户端装饰
export GDK_BACKEND=x11    # 使用 X11 后端
./neko_time
```

#### 方案 3: 启用桌面环境的合成器

**GNOME** (默认启用):
```bash
# 检查是否启用
gsettings get org.gnome.mutter compositing-manager
# 如果返回 false，启用它
gsettings set org.gnome.mutter compositing-manager true
```

**KDE Plasma**:
1. 系统设置 → 显示和监控 → 合成器
2. 确保"启用合成器"已勾选
3. 合成类型选择 "OpenGL 3.1" 或 "OpenGL 2.0"

**Xfce**:
1. 设置 → 窗口管理器调整
2. 合成器标签
3. 勾选"启用显示合成"

**MATE**:
```bash
marco --replace --composite &
```

**Cinnamon** (默认启用):
```bash
# 检查合成器状态
cinnamon-settings display
```

#### 方案 4: 使用 Picom/Compton（适用于轻量级 WM）

如果你使用 i3, Openbox 等轻量级窗口管理器：

```bash
# 安装 picom
sudo apt install picom  # Ubuntu/Debian
sudo dnf install picom  # Fedora
sudo pacman -S picom    # Arch

# 启动 picom
picom -b --backend glx --vsync
```

创建配置文件 `~/.config/picom/picom.conf`:
```conf
# 基本透明支持
backend = "glx";
vsync = true;

# 启用透明
opacity-rule = [
    "100:class_g = 'neko_time'"
];

# 禁用阴影（避免黑边）
shadow = false;
```

#### 方案 5: 检查窗口属性

```bash
# 安装 xprop
sudo apt install x11-utils

# 点击 NekoTime 窗口查看属性
xprop

# 查找以下属性：
# _NET_WM_WINDOW_TYPE = 应该是 UTILITY 或 DIALOG
# _NET_WM_STATE = 应该包含 _NET_WM_STATE_SKIP_TASKBAR
```

---

### 问题 2: 系统托盘图标不显示

**症状**: 应用运行正常，但系统托盘区域看不到图标

**原因**:
- GNOME 默认不支持系统托盘（需要扩展）
- 缺少 AppIndicator 库

**解决方案**:

#### GNOME 用户
```bash
# 安装 AppIndicator 扩展
sudo apt install gnome-shell-extension-appindicator

# 或从扩展网站安装
# https://extensions.gnome.org/extension/615/appindicator-support/

# 安装依赖库
sudo apt install libayatana-appindicator3-1

# 重启 GNOME Shell (X11)
Alt+F2, 输入 'r', 回车

# Wayland 需要注销重新登录
```

#### KDE Plasma 用户
```bash
# 确保系统托盘小部件已添加
# 右键点击面板 → 添加部件 → 系统托盘
```

#### 其他桌面环境
```bash
# 安装 stalonetray（独立系统托盘）
sudo apt install stalonetray

# 启动
stalonetray &
```

---

### 问题 3: 窗口透明度不工作

**症状**: 窗口是纯黑色背景，看不到桌面

**检查清单**:

1. **验证合成器正在运行**
```bash
# 检查是否有合成器进程
ps aux | grep -E "picom|compton|compiz|mutter|kwin"
```

2. **检查 OpenGL 支持**
```bash
glxinfo | grep "OpenGL version"
# 应该显示至少 OpenGL 2.1
```

3. **测试透明度**
```bash
# 安装 xcompmgr 测试
sudo apt install xcompmgr
xcompmgr -c &

# 启动 NekoTime 看是否有改善
./neko_time
```

---

### 问题 4: 应用黑屏或崩溃

**参考主 README 的依赖安装部分**:
```bash
sudo ./scripts/install_linux_deps.sh
```

---

## 🔍 调试信息收集

如果问题仍然存在，请收集以下信息提交 Issue:

```bash
# 1. 系统信息
uname -a
cat /etc/os-release

# 2. 桌面环境
echo $XDG_CURRENT_DESKTOP
echo $XDG_SESSION_TYPE

# 3. 窗口管理器
wmctrl -m

# 4. OpenGL 信息
glxinfo | head -20

# 5. 运行应用并收集日志
./neko_time 2>&1 | tee nekotime.log

# 6. 窗口属性
xprop | grep -E "WM_CLASS|WM_NAME|_NET_WM"
```

---

## 📚 推荐配置

### 最佳兼容性配置

| 桌面环境 | 合成器 | 托盘支持 | 推荐度 |
|---------|--------|---------|--------|
| GNOME (X11) | Mutter | AppIndicator 扩展 | ⭐⭐⭐⭐⭐ |
| KDE Plasma | KWin | 内置 | ⭐⭐⭐⭐⭐ |
| Cinnamon | Muffin | 内置 | ⭐⭐⭐⭐⭐ |
| Xfce | xfwm4 | 内置 | ⭐⭐⭐⭐ |
| MATE | Marco | 内置 | ⭐⭐⭐⭐ |
| i3 + Picom | Picom | 需要 stalonetray | ⭐⭐⭐ |

### 避免的配置
- ❌ GNOME Wayland（托盘支持有限）
- ❌ 无合成器的轻量级 WM
- ❌ 远程桌面（透明度不支持）

---

## 🆘 仍然无法解决？

1. 查看日志文件: `~/.local/share/NekoTime/logs/`
2. 提交 Issue: https://github.com/zoidberg-xgd/NekoTime/issues
3. 包含上述调试信息
