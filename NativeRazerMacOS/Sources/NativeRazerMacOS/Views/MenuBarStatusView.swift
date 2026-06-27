import AppKit
import SwiftUI

struct MenuBarStatusView: View {
  let store: NativeDeviceStore
  let openMainWindow: () -> Void
  let showAbout: () -> Void

  var body: some View {
    Button("Open Razer macOS") {
      openMainWindow()
    }

    Button("Refresh Devices") {
      store.refresh()
    }

    Divider()

    if let device = store.selectedDevice {
      Button(device.name) {
        openMainWindow()
      }
      .disabled(true)

      if let dpi = device.controlState.dpi {
        Text("DPI: \(dpi)")
      }

      if let pollingRate = device.controlState.pollingRate {
        Text("Rate: \(pollingRate) Hz")
      }

      if let batteryLevel = device.controlState.batteryLevel {
        Text("Battery: \(batteryLevel)%")
      }
    } else {
      Text("No Razer mouse")
    }

    Divider()

    Text(store.lastRefreshSummary)

    Divider()

    SettingsLink()

    Button("About Razer macOS") {
      showAbout()
    }

    Button("Quit") {
      NSApplication.shared.terminate(nil)
    }
    .keyboardShortcut("q")
  }
}
