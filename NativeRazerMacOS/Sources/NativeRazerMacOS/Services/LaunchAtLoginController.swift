import Foundation
import Observation
import ServiceManagement
import AppKit

@Observable
final class LaunchAtLoginController {
  private(set) var statusMessage: String = ""

  var isEnabled: Bool {
    SMAppService.mainApp.status == .enabled
  }

  var statusDescription: String {
    switch SMAppService.mainApp.status {
    case .enabled:
      "Enabled"
    case .notRegistered:
      "Disabled"
    case .notFound:
      "Unavailable"
    case .requiresApproval:
      "Requires approval"
    @unknown default:
      "Unknown"
    }
  }

  func setEnabled(_ enabled: Bool) {
    do {
      if enabled {
        if SMAppService.mainApp.status != .enabled {
          try SMAppService.mainApp.register()
        }
        statusMessage = "Launch at login is enabled."
      } else {
        if SMAppService.mainApp.status == .enabled {
          try SMAppService.mainApp.unregister()
        }
        statusMessage = "Launch at login is disabled."
      }
    } catch {
      statusMessage = error.localizedDescription
    }
  }

  func openLoginItemsSettings() {
    guard let settingsURL = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") else {
      return
    }

    NSWorkspace.shared.open(settingsURL)
  }
}
