# PerformancePlus

PerformancePlus adds a device information page to **Settings** on supported
rootless-jailbroken iPhones. It shows details such as your device model, iOS
version, memory, battery, thermal state, power mode, and uptime.

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

- **Device information:** model, iOS version, and logical CPU core count.
- **System status:** memory, battery, thermal state, power mode, and uptime.
- **Recovery options:** safe mode, reset actions, and a respring action that
  requires your confirmation.
- **Preference storage:** your saved settings are kept in the
  `com.blue.performanceplus` preferences domain.

Some performance controls are displayed for clarity, but cannot currently
change system behavior safely. They report that they are unsupported rather
than claiming to improve performance. RAM, CPU, and GPU beta options default
to off.

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
| `-systemVersion` | Returns the installed iOS version. |
| `-cpuStatus` | Reports the logical processor count. |
| `-memoryStatus` | Reads and formats memory statistics using user-space APIs. |
| `-batteryStatus` | Reports battery level and charging state when available. |
| `-thermalStatus` | Reports the iOS thermal state when available. |
| `-powerStatus` | Reports whether Low Power Mode is enabled. |
| `-uptimeStatus` | Formats the system uptime. |

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

### `Tweak.x`

| Function | What it does |
| --- | --- |
| `PPApplySafeProfileState` | Reads the enable, safe-mode, gaming-mode, and thermal-profile preferences at startup. It does not change CPU/GPU speeds, thermals, or other system performance settings. |

## Links

- [PerformancePlus package source](https://minhnhatz.github.io/performanceplus/)
- [Source code and issue reporting](https://github.com/Minhnhatz/performanceplus)
