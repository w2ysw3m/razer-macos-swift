import Foundation
import NativeRazerCore

struct DeviceSidebarSections: Equatable {
  let connectedDevices: [NativeDevice]
  let supportedDevices: [NativeDevice]

  init(devices: [NativeDevice], searchText: String) {
    let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    let filteredDevices = query.isEmpty
      ? devices
      : devices.filter { device in
        device.name.localizedCaseInsensitiveContains(query)
          || device.productId.localizedCaseInsensitiveContains(query)
          || device.kind.rawValue.localizedCaseInsensitiveContains(query)
      }

    self.connectedDevices = filteredDevices.filter { device in
      device.hardwareInternalId != nil
    }
    self.supportedDevices = filteredDevices.filter { device in
      device.hardwareInternalId == nil
    }
  }
}
