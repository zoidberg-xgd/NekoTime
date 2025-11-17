# 自定义主题

应用启动时会在应用支持目录（macOS 为 `~/Library/Application Support/digital_clock/themes`）下寻找以 `.json` 结尾的主题文件。每个文件描述一个主题，示例：

```json
{
  "id": "neon_purple",
  "name": "Neon Purple",
  "kind": "blur",
  "borderRadius": 24,
  "paddingHorizontal": 24,
  "paddingVertical": 12,
  "blurSigmaX": 20,
  "blurSigmaY": 20,
  "tintColor": "#FF8A2BE2",
  "tintOpacityMultiplier": 0.18
}
```

字段说明：

| 字段 | 说明 |
| --- | --- |
| `id` | 唯一 ID，供配置引用 |
| `name` | UI 与托盘菜单显示的名称 |
| `kind` | `transparent` / `blur` / `solid` |
| `borderRadius` | 圆角半径 |
| `paddingHorizontal` / `paddingVertical` | 内边距 |
| `blurSigmaX` / `blurSigmaY` | 毛玻璃模糊半径（仅 `blur` 有效） |
| `tintColor` + `tintOpacityMultiplier` | 覆盖色与不透明度（0-1，可叠加 `config.opacity`） |
| `backgroundColor` + `backgroundOpacityMultiplier` | 背景色枚举 |

修改或添加文件后，可在设置弹窗或托盘菜单中点击“重新加载主题”立即生效。***


