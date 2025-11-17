import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // --- Start of custom configuration ---

    // 无边框透明窗口，适合悬浮显示
    self.styleMask = [.borderless]
    self.isOpaque = false
    self.backgroundColor = .clear
    self.hasShadow = false
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden
    self.isMovableByWindowBackground = true
    // 透明内容：让 Flutter 视图背景透明
    flutterViewController.view.wantsLayer = true
    flutterViewController.view.layer?.backgroundColor = NSColor.clear.cgColor

    // --- End of custom configuration ---

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}

