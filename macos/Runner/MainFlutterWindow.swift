import Cocoa
import FlutterMacOS
import hid_listener

class MainFlutterWindow: NSWindow {
  // hid_listener instance
  let listener = HidListener()

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
