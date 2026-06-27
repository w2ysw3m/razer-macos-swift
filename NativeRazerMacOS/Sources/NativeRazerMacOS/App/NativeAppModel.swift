import AppKit
import SwiftUI

@MainActor
final class NativeAppModel {
  static let shared = NativeAppModel()

  let store = NativeDeviceStore()
  private var mainWindow: NSWindow?

  private init() {}

  func showMainWindow() {
    if let existingWindow = NSApp.windows.first(where: { $0.title == "Razer macOS Native" }) {
      existingWindow.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
      return
    }

    let window = mainWindow ?? makeMainWindow()
    mainWindow = window

    if !window.isVisible {
      window.center()
    }
    window.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  func refreshDevices() {
    store.refresh()
  }

  func showAboutPanel() {
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
      ?? "0.4.14"
    let credits = NSAttributedString(
      string: """
      Native SwiftUI/AppKit control app for Razer devices on macOS.

      Current native surface:
      - Menu-bar resident app
      - Launch at Login
      - DeathAdder V3 Pro discovery
      - DPI and polling-rate controls through librazermacos
      - Hardware status with conservative timeout reporting

      Legacy Electron support keeps the broader device catalog and historical color/state logic. The native app marks a device native-ready only after its controls are wired and tested on macOS hardware.

      Built on 1kc/razer-macos, librazermacos, and OpenRazer device work.
      """
    )

    NSApp.orderFrontStandardAboutPanel(options: [
      .applicationName: "Razer macOS Native",
      .applicationVersion: version,
      .version: "SwiftUI/AppKit + librazermacos bridge",
      .credits: credits
    ])
    NSApp.activate(ignoringOtherApps: true)
  }

  func shutdown() {
    store.shutdown()
  }

  private func makeMainWindow() -> NSWindow {
    let rootView = ContentView(store: store)
      .frame(minWidth: 860, minHeight: 540)

    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 960, height: 680),
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered,
      defer: false
    )
    window.title = "Razer macOS Native"
    window.contentView = NSHostingView(rootView: rootView)
    window.isReleasedWhenClosed = false
    window.setFrameAutosaveName("NativeRazerMacOSMainWindow")
    return window
  }
}
