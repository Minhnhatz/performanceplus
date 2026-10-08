# PerformancePlus

PerformancePlus adds an API-backed device status page to **Settings** on
supported rootless-jailbroken iPhones. It shows your device model, iOS version,
CPU and memory readings, battery and power state, thermal state, display
capabilities, and uptime.

> PerformancePlus does not overclock your device or bypass iOS safety
> protections. Controls that are not supported by safe iOS APIs are clearly
> marked **“Not supported on this device/iOS version.”**

## Requirements

- A rootless jailbreak
- iOS 15 or later
- An arm64 or arm64e device
- Sileo or Zebra to install the package

## Install

1. Open **Sources** in Sileo or Zebra.
2. Tap **+** to add a source.
3. Enter this repository address:

   **https://minhnhatz.github.io/performanceplus/**

4. Refresh the source list and search for **PerformancePlus**.
5. Install the package and confirm.
6. Open **Settings → PerformancePlus**.

## What you’ll find

- **Device information:** model, iOS version, logical CPU core count, and
  device-wide CPU usage. The first **Refresh Device Status** establishes a
  baseline; the next reports average usage between refreshes.
- **Device capability:** identifies iPhone 6s and newer models and reports
  the display's maximum refresh rate (read-only; iOS controls the active rate).
- **System status:** memory, battery level and charging state, thermal state,
  Low Power Mode, display capture/mirroring status, and uptime. Battery status
  monitoring is enabled for the Settings app when you view this information.
- **Recovery options:** safe mode, reset actions, and a respring action that
  requires your confirmation.
- **Automatic status updates:** update the displayed battery, thermal,
  power-mode, and display-capture status when iOS reports a change. You can
  turn live updates off and refresh status manually.
- **Safe Mode:** switch to a reduced Settings page containing device status
  and recovery controls. It does not modify or bypass iOS safety protections.
- **Preference storage:** your saved settings are kept in the
  `com.blue.performanceplus` preferences domain.

Some entries show read-only status from device APIs. Those readings do not
change device behavior. Other controls report that they are unsupported because
iOS does not expose a safe system-wide API for them. RAM, CPU, and GPU beta
options default to off.

PerformancePlus does not modify kernel memory, change CPU/GPU voltage or
clock speeds, disable thermal protection, manipulate charging, or terminate
critical system processes. iOS continues to manage performance, power, and
thermals.

## Update or uninstall

To update, refresh the PerformancePlus source in Sileo or Zebra and install
the available update. To uninstall, open the package in your package manager
and choose **Remove**. You can remove the repository from **Sources** if you
no longer want to receive updates.

## Troubleshooting

- **The source cannot be added:** Check that the address is exactly
  `https://minhnhatz.github.io/performanceplus/`, including the trailing slash,
  then try refreshing again.
- **The package does not appear:** Refresh the source and search for
  `PerformancePlus`.
- **The package is incompatible:** Confirm you have iOS 15 or later and a
  rootless jailbreak.
- **PerformancePlus is missing from Settings:** Check that installation
  completed successfully. If it is still missing, respring your device.

## Function reference

This section lists the main Objective-C methods for readers who want to
understand the implementation. It describes what the code currently does;
unsupported performance controls do not apply system changes.

### `PPManager`

| Function | What it does |
| --- | --- |
| `+sharedManager` | Returns the shared preferences and device-information manager. |
| `-init` | Creates a manager instance and registers preference defaults. |
| `-registerDefaultPreferences` | Registers default values in the `com.blue.performanceplus` settings domain. |
| `-isEnabled` / `-setEnabled:` | Reads or saves the main enable preference. |
| `-isOptionEnabled:` / `-setOption:enabled:` | Reads or saves an allow-listed Boolean option. |
| `-boolForKey:defaultValue:` / `-setBool:forKey:` | Reads or saves a Boolean preference. |
| `-stringForKey:defaultValue:` / `-setString:forKey:` | Reads or saves a string preference. |
| `-refreshRateOptions` | Builds refresh-rate labels from the device's reported maximum refresh rate. |
| `-fpsOptions` | Builds FPS labels from the device's reported maximum refresh rate. |
| `-unsupportedMessage` | Returns the standard unsupported-feature message. |
| `-experimentalMessage` | Returns the experimental-feature notice. |
| `-limitedByIOSMessage` | Returns the notice that behavior is limited by iOS. |
| `-deviceModel` | Returns the device model and, when available, its hardware identifier. |
| `-deviceCapabilityStatus` | Checks the hardware identifier and reports whether the device is an iPhone 6s or newer. |
| `-displayRefreshRateStatus` | Reports the display's maximum reported refresh rate without attempting to change it. |
| `-displayCaptureStatus` | Reads whether iOS reports the display as currently captured or mirrored. |
| `-systemVersion` | Returns the installed iOS version. |
| `-cpuStatus` | Reports the logical processor count. |
| `-cpuUsageStatus` | Samples device-wide CPU ticks using the public Mach host statistics API and reports average usage between successive refreshes. |
| `-memoryStatus` | Reads and formats memory statistics using user-space APIs. |
| `-batteryStatus` | Enables battery monitoring for the Settings process and reports battery level and charging state when available. |
| `-thermalStatus` | Reports the iOS thermal state when available. |
| `-powerStatus` | Reports whether Low Power Mode is enabled. |
| `-uptimeStatus` | Formats the system uptime. |

## API support by feature

PerformancePlus uses Objective-C and UIKit/Foundation plus Darwin/Mach APIs
available to the installed tweak and preference bundle. A jailbreak allows
installation of the package, but it does not make private system controls safe,
stable, or available on every iOS version. This release uses status APIs for
monitoring and local APIs for settings; it does not patch the kernel or change
protected system performance policy.

| Feature | API-backed behavior | Limit |
| --- | --- | --- |
| Refresh rate | Reads the screen's maximum reported refresh rate. | Does not set the active refresh rate. |
| FPS control | Reports the same screen capability. | Frame-rate requests apply to an app's own rendering, not the whole system. |
| Touch optimization, touch response, gesture responsiveness | None exposed for system-wide changes. | App code can manage only its own input handling. |
| Stability / anti-glitch, stutter reduction | None exposed for system-wide changes. | iOS manages scheduling and system stability. |
| Anti-spam swipe | None exposed for other apps. | Gesture filtering belongs to the app receiving the gesture. |
| Keyboard optimization | No system-wide keyboard tuning API. | Keyboard extensions can affect only their own keyboard behavior. |
| Control Center optimization | No supported API to tune Control Center. | Controlled by iOS. |
| App compatibility mode | Identifies the device and iOS version. | Detection does not override app compatibility rules. |
| RAM optimization | Reads host memory statistics. | Does not purge other processes; iOS manages memory pressure and reclamation. |
| CPU optimization | Reads host CPU tick deltas and logical core count. | Does not change CPU frequency, voltage, or scheduler policy. |
| GPU optimization | No safe system-wide GPU tuning API. | Unsupported. |
| Screen recording optimization | Reads whether iOS reports display capture/mirroring. | Does not alter recording or encoding. |
| Charging optimization | Reads battery level and charging state. | Does not manipulate charging. |
| Battery optimization | Reads battery state and Low Power Mode. | Cannot turn Low Power Mode on/off or change system power policy. |
| Gaming mode and auto performance profile | Can display thermal and power status. | No supported system-wide performance profile control. |
| Thermal management | Reads thermal state and observes change notifications. | iOS controls thermal mitigation; protection is never bypassed. |
| Background activity control | No API to control unrelated apps' background work. | Background-task APIs are scoped to the app that schedules them. |
| Safe Mode / emergency recovery | Provides a reduced preferences page, safe-default reset, and confirmed respring. | Does not claim to activate an operating-system safe mode. |
| Device capability detection | Reads the hardware identifier and system information. | Informational only. |
| Settings storage | Stores local preferences with `NSUserDefaults`. | Does not change system performance. |

## API references

- [Apple: `UIScreen.maximumFramesPerSecond`](https://developer.apple.com/documentation/uikit/uiscreen/maximumframespersecond)
- [Apple: `UIScreen.isCaptured`](https://developer.apple.com/documentation/uikit/uiscreen/iscaptured)
- [Apple: `UIDevice.batteryLevel`](https://developer.apple.com/documentation/uikit/uidevice/batterylevel)
- [Apple: `UIDevice.batteryState`](https://developer.apple.com/documentation/uikit/uidevice/batterystate)
- [Apple: `ProcessInfo.thermalState`](https://developer.apple.com/documentation/foundation/processinfo/thermalstate-swift.enum)
- [Apple: `ProcessInfo.isLowPowerModeEnabled`](https://developer.apple.com/documentation/foundation/processinfo/islowpowermodeenabled)
- [Apple: `ProcessInfo.physicalMemory`](https://developer.apple.com/documentation/foundation/processinfo/physicalmemory)
- [Apple: `UserDefaults`](https://developer.apple.com/documentation/foundation/userdefaults)
- [Apple open-source XNU: Mach host statistics definitions](https://github.com/apple-oss-distributions/xnu/blob/main/osfmk/mach/host_info.h)

API availability and reported values can vary by device and iOS version. If a
read-only query is unavailable, PerformancePlus reports it as unavailable
instead of substituting a fabricated value.

### `PPListController`

| Function | What it does |
| --- | --- |
| `-specifiers` | Builds the rows and sections shown in Settings, including device information and unsupported-feature notices. |
| `-switchSpecifierWithTitle:key:default:` | Creates a Boolean preference row. |
| `-listSpecifierWithTitle:key:defaultValue:values:titles:` | Creates a list preference row. |
| `-valueSpecifierWithTitle:value:` | Creates a read-only label and value row. |
| `-unsupportedSpecifierWithTitle:` | Creates a read-only row displaying the standard unsupported message. |
| `-buttonSpecifierWithTitle:action:` | Creates a button row linked to an action. |
| `-readPreferenceValue:` | Reads a preference value for a Settings row. |
| `-valueForSpecifier:` | Supplies the displayed value for a read-only row. |
| `-setPreferenceValue:specifier:` | Saves a Boolean or string preference selected in Settings. |
| `-refreshDeviceStatus` | Reloads the Settings rows. |
| `-disableExperimentalFeatures` | Turns off the RAM, CPU, and GPU beta preferences and shows confirmation. |
| `-resetAllSettings` | Removes saved preferences and restores registered defaults. |
| `-restoreSafeDefaults` | Disables experimental options and resets saved preferences. |
| `-confirmRespring` | Asks for confirmation before offering a respring action. |
| `-respring` | Starts the rootless `sbreload` utility after confirmation and reports failures. |
| `-showMessage:message:` | Displays an alert with a title and message. |
| `-startObservingStatusChanges` / `-stopObservingStatusChanges` | Subscribe to battery, thermal, power-mode, and display-capture changes while the Settings page is visible. |
| `-statusDidChange:` | Refreshes the visible status rows on the main queue after a supported system status changes. |
| `-addDeviceStatusSpecifiersToArray:manager:` | Adds live device-information rows to the normal or Safe Mode page. |
| `-addRecoverySpecifiersToArray:` | Adds Safe Mode, reset, and restore controls. |

### `Tweak.x`

| Function | What it does |
| --- | --- |
| `PPApplySafeProfileState` | Reads the enable, safe-mode, gaming-mode, and thermal-profile preferences at startup. It does not change CPU/GPU speeds, thermals, or other system performance settings. |

## Links

- [PerformancePlus package source](https://minhnhatz.github.io/performanceplus/)
- [Source code and issue reporting](https://github.com/Minhnhatz/performanceplus)
