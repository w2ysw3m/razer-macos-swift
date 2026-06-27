import SwiftUI

struct SettingsView: View {
  @State private var launchAtLogin = LaunchAtLoginController()

  var body: some View {
    TabView {
      Form {
        LabeledContent("Runtime", value: "SwiftUI/AppKit")
        LabeledContent("Device bridge", value: "librazermacos")
        Toggle(
          "Launch at Login",
          isOn: Binding(
            get: { launchAtLogin.isEnabled },
            set: { launchAtLogin.setEnabled($0) }
          )
        )
        LabeledContent("Launch at Login status", value: launchAtLogin.statusDescription)
        LabeledContent("Status bar", value: "Always on")
        LabeledContent("Signing", value: "Planned")

        Button("Open Login Items in System Settings") {
          launchAtLogin.openLoginItemsSettings()
        }

        Text(
          "Launch at Login is registered with macOS ServiceManagement. If the local unsigned build shows Requires approval or Unavailable, check System Settings > General > Login Items."
        )
        .font(.caption)
        .foregroundStyle(.secondary)

        if !launchAtLogin.statusMessage.isEmpty {
          Text(launchAtLogin.statusMessage)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .padding()
      .tabItem {
        Label("General", systemImage: "gearshape")
      }
    }
    .frame(width: 520, height: 320)
  }
}
