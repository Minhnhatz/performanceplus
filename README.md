# PerformancePlus

PerformancePlus is a rootless jailbreak tweak with a Settings page for device
information and stored preferences.
It is distributed through this Sileo/Zebra source:

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

- **Device Status** displays information such as CPU cores, memory, battery,
  thermal state, power mode, uptime, iOS version, and device model.
- **Recovery** provides a safe-mode preference, reset actions, and a
  user-confirmed respring action.
- **Settings Storage** reports where PerformancePlus preferences are stored.
- Performance controls that cannot be safely applied through supported
  user-space APIs are identified as unsupported; their preference switches are
  not presented as working optimizations.

PerformancePlus does not overclock the CPU or GPU, change voltage, bypass
thermal protections, manipulate charging, or modify kernel memory. iOS remains
in control of scheduling and thermal behavior. Unsupported controls display
**Not supported on this device/iOS version.** Experimental RAM, CPU, and GPU
optimization preferences default to off.

## Build from source

Install Theos with its iOS SDK and Linux toolchain, then set `THEOS` to the
Theos installation directory. From the repository root, run:

```sh
make clean
make package FINALPACKAGE=1
```

The project targets rootless iOS 15 or later and packages arm64 and arm64e
architectures. The `Build and deploy APT repository` GitHub Actions workflow
performs the same clean build before validating and publishing the package.

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
