import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

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
    
    // 初始时隐藏窗口，等 Flutter 准备好再显示
    self.isReleasedWhenClosed = false
    self.alphaValue = 0.0
    
    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
    
    // 延迟后淡入显示
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      NSAnimationContext.runAnimationGroup({ context in
        context.duration = 0.2
        self?.animator().alphaValue = 1.0
      }, completionHandler: nil)
    }
  }
}
