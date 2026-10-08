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

## Links

- [PerformancePlus package source](https://minhnhatz.github.io/performanceplus/)
- [Source code and issue reporting](https://github.com/Minhnhatz/performanceplus)
