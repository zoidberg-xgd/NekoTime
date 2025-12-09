import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    self.contentViewController = flutterViewController
    
    // 设置初始窗口为很小且隐藏，防止白色大窗口闪烁
    let smallFrame = NSRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 1, height: 1)
    self.setFrame(smallFrame, display: false)

    // 完全透明的窗口设置
    self.isOpaque = false
    self.backgroundColor = NSColor.clear
    self.hasShadow = true
    self.styleMask.insert(.borderless)
    self.styleMask.insert(.fullSizeContentView)
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    
    // 移除窗口边框和背景
    self.level = .floating
    
    // 初始时完全透明，由 Flutter windowManager 控制显示
    self.isReleasedWhenClosed = false
    self.alphaValue = 0.0
    
    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
