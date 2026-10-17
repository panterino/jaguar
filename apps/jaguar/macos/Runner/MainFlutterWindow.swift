import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    // Room for the program list, the code and the console side by side.
    self.minSize = NSSize(width: 760, height: 480)
    self.setContentSize(NSSize(width: 1280, height: 800))
    self.center()
    self.setFrameAutosaveName("JaguarMainWindow")

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
