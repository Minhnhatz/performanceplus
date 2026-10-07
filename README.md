# PerformancePlus

PerformancePlus is a rootless jailbreak tweak with a Settings page for device
information and a small set of user-preference switches. It is distributed
through this Sileo/Zebra source:

**https://minhnhatz.github.io/performanceplus/**

## Before you install

- Your device must be jailbroken with a **rootless** jailbreak.
- The package requires **iOS 15 or later**.
- The repository provides the `iphoneos-arm64` package.

## Add the source in Sileo

1. Open **Sileo** and select **Sources**.
2. Tap **+** to add a source.
3. Enter `https://minhnhatz.github.io/performanceplus/` and confirm.
4. Wait for Sileo to refresh the source list.
5. Search for **PerformancePlus**, open the package, and tap **Get**.
6. Review the changes and confirm the installation.

## Add the source in Zebra

1. Open **Zebra** and go to **Sources**.
2. Tap **+** and choose to add a repository.
3. Enter `https://minhnhatz.github.io/performanceplus/` and save it.
4. Let Zebra refresh, then search for **PerformancePlus**.
5. Open the package, tap **Get**, and confirm the installation.

## Use PerformancePlus

After installation, open **Settings → PerformancePlus**.

- **Performance** contains the master switch and the Performance Mode, Memory
  Optimization, and App Launch Optimization switches. These switches save
  preferences only; they do not change CPU scheduling, purge memory, or alter
  app-launch behavior.
- **Device Status** shows information such as CPU cores, memory, battery,
  iOS version, and device model.
- Other sections show tweak status and provide available actions, including
  refreshing displayed information and respringing SpringBoard.

PerformancePlus does not overclock the CPU or GPU, change voltage, bypass
thermal protections, manipulate charging, or modify kernel memory. iOS remains
in control of scheduling and thermal behavior.

## Update or remove

To check for an update, open your package manager and refresh the source, then
visit the **Updates** or **Changes** tab. To uninstall, open the PerformancePlus
package in Sileo or Zebra and choose **Remove**. You can remove the repository
later from the package manager's **Sources** list if you no longer need it.

## Troubleshooting

- **The source will not add:** Check that the URL is exactly
  `https://minhnhatz.github.io/performanceplus/`, including the trailing slash,
  then retry on a working internet connection.
- **The package does not appear:** Pull down to refresh the source list, then
  search for `PerformancePlus` again.
- **The package is marked incompatible:** Confirm that your device is on iOS
  15 or later and uses a rootless jailbreak.
- **The Settings page is missing:** Confirm the installation completed in your
  package manager. If it still does not appear, respring your device and check
  again.

## Project

Browse the source code or report a problem on
[GitHub](https://github.com/Minhnhatz/performanceplus).
