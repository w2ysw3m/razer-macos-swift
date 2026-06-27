# Razer macOS

Razer macOS is an open-source macOS control app for Razer peripherals. This fork is now moving away from the legacy Electron shell and toward a native SwiftUI/AppKit app backed by the existing `librazermacos` IOKit/HID driver code.

The current development focus is practical macOS support for newer Razer devices imported from OpenRazer, starting with the Razer DeathAdder V3 Pro.

## Current Status

- Native SwiftUI/AppKit app shell in `NativeRazerMacOS`
- macOS menu-bar resident app with a persistent status item
- Native settings window with Launch at Login support through `ServiceManagement` and a System Settings Login Items shortcut
- Native device controls for DPI and polling rate
- Battery/status display when the bridge can read it from hardware
- C bridge from Swift into `librazermacos`
- Refreshed device catalog under `src/devices` with 267 device JSON profiles
- Legacy Electron app retained as a reference implementation and fallback

## Support Matrix

There are two support layers in this repository:

- Legacy Electron app keeps the broad device catalog from the original razer-macos/OpenRazer work. The `src/devices` directory currently contains 267 device JSON profiles, and the legacy UI still owns the historical color, brightness, state, keyboard, mouse, mouse mat, dock, eGPU, headphone, and laptop logic.
- Native app verified hardware path is stricter. A device is listed here only when the SwiftUI/AppKit surface, C bridge, and macOS hardware behavior have been wired and tested. DeathAdder V3 Pro is the first verified native control target; this is not the full native support matrix and it does not mean the project supports only one mouse.

Native verified control targets:

| Device | Product ID | Native controls |
| --- | --- | --- |
| Razer DeathAdder V3 Pro | `0x00B7` | Discovery, DPI, polling rate, battery/status |

## Known Hardware Limitation

On the current test machine, the native bridge and the legacy Node addon both detect the DeathAdder V3 Pro through `librazermacos`.

The native hardware probe reports:

```text
productId=0x00B7 internalDeviceId=0 dpi=0 pollingRate=0
count=1
```

The device is detected, but DPI, polling-rate, and battery readback commands can still time out on this hardware path. The native UI therefore uses safe default values when readback returns `0`, clearly reports that settings readback timed out, and only reports write commands as sent through the bridge.

## Native App

Build and open the native app:

```sh
./script/build_and_run.sh
```

Build, open, and verify the app process starts:

```sh
./script/build_and_run.sh --verify
```

Scan connected Razer mice through the native C bridge:

```sh
./script/build_and_run.sh --scan-hardware
```

Run Swift tests:

```sh
swift test --package-path NativeRazerMacOS
```

The native app keeps running after its main window is closed. Reopen it from the menu-bar item, Dock, or the Razer command menu. Launch at Login is available from the native Settings window.

## Legacy Electron App

The original Electron app remains in the repository while the native app catches up feature by feature. It still provides the historical menu-bar UI, color effects, state management, and broader device coverage. It is the compatibility reference for other device classes until the native app ports those controls and proves them on macOS.

Install Node dependencies:

```sh
yarn
```

Run the Electron development app:

```sh
yarn dev
```

Rebuild the native Node addon after driver changes:

```sh
yarn rebuild
```

Compile the Electron app:

```sh
yarn compile
```

Build a distribution package:

```sh
yarn dist
```

## Architecture

The repository currently has two application layers over the same driver lineage:

- `NativeRazerMacOS/` contains the new SwiftUI/AppKit macOS app.
- `NativeRazerMacOS/Sources/NativeRazerBridgeC/` exposes the C driver functions to Swift.
- `librazermacos/` contains the low-level Razer USB/HID protocol implementation.
- `src/` contains the legacy Electron UI, state manager, menu-bar app, and Node addon integration.
- `src/devices/` contains device profiles imported and maintained from OpenRazer and the previous razer-macos work.

Long-term, the SwiftUI/AppKit app should become the primary macOS UI because it fits menu-bar behavior, Launch at Login, signing, notarization, and IOKit/HID integration more naturally than Electron.

## Device Support Policy

New-device support should be grounded in OpenRazer device definitions, then verified on real hardware whenever possible. For devices not physically available, the repo can import identifiers and capability metadata, but UI controls should stay conservative until a matching hardware path is tested.

Other device functionality should be moved over from the legacy app by capability, not by copying every screen at once:

1. Mouse controls: DPI, polling rate, battery, charging, and receiver/wired pairing paths.
2. Lighting controls: static color, spectrum/cycle effects, brightness zones, and per-device effect constraints.
3. State management: startup/refresh states, menu-bar device actions, and persistence.
4. Keyboard and accessory controls: profile, layout, brightness, and device-specific feature gates.
5. Distribution packaging: signed and notarized native app with hardened runtime and clear macOS permission copy.

Distribution packaging is release-only work. It is not a missing device-control feature, not a missing Launch at Login feature, and Packaging is not required for local development with `./script/build_and_run.sh`.

Until a capability is connected through the native C bridge and verified against a real device, it should remain documented as legacy-supported rather than native-supported.

For the DeathAdder V3 Pro path, the next driver-level task is improving or replacing the timed-out settings readback commands for DPI, polling rate, and battery state.

## Installation Notes

Packaged, signed, and notarized native builds are not complete yet because they require release artifacts, signing identity, hardened runtime validation, and Apple notarization credentials. For local development, run from source with `./script/build_and_run.sh`.

The legacy Electron packaging flow still supports ad-hoc signing:

```sh
codesign -s - --deep --force ./dist/mac-universal/Razer\ macOS.app
```

## Credits

This project builds on work from:

- [1kc/razer-macos](https://github.com/1kc/razer-macos)
- [openrazer/openrazer](https://github.com/openrazer/openrazer)
- [osx-razer-blade](https://github.com/kprinssu/osx-razer-blade)
- [osx-razer-led](https://github.com/dylanparker/osx-razer-led)
