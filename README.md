# PerformancePlus

PerformancePlus adds a lightweight device-status and battery-care page to
**Settings** for supported rootless-jailbroken iPhones. It helps you check
device information, watch battery and thermal status, and find recovery
options.

> PerformancePlus does not promise to make every iPhone faster. iOS manages
> system performance, charging, and thermal protection. Unsupported controls
> are identified honestly and do not pretend to change device behavior.

## Requirements

- iPhone 6s or newer (device detection is informational)
- iOS 15 or later
- A rootless jailbreak
- Sileo or Zebra

## Install

1. Open **Sources** in Sileo or Zebra and tap **+**.
2. Add the repository: **https://minhnhatz.github.io/performanceplus/**
3. Refresh sources and install **PerformancePlus**.
4. Open **Settings → PerformancePlus**.

## Features

- **Device status:** view device model, iOS version, logical CPU cores,
  device-wide CPU usage, memory, battery level and charging state, thermal
  state, Low Power Mode, display capture status, and uptime.
- **Display information:** view the screen's maximum reported refresh rate.
  This does not change the active refresh rate.
- **Automatic status updates:** refresh supported status rows when iOS reports
  battery, thermal, power, or display-capture changes. Turn updates off to
  refresh manually.
- **Charging & Heat Alerts:** choose a charging reminder threshold from 80%
  to 100%. While the PerformancePlus page is open, it can remind you when the
  charging battery reaches that level and warn if iOS reports Serious or
  Critical thermal state while charging. You must unplug the charger yourself.
- **Recovery options:** enable the reduced Safe Mode page, restore safe
  defaults, reset saved settings, or confirm a respring.
- **Low runtime footprint:** PerformancePlus does not inject into SpringBoard
  or other apps.

## Battery care

For Apple's routine-based **Optimized Battery Charging**, use the built-in
**Settings → Battery** options available for your iPhone and iOS version.
PerformancePlus does not learn charging habits, run a charging service in the
background, or stop/limit charging.

If your iPhone becomes unusually hot while charging, stop demanding apps, move
it out of direct sunlight to a cool, ventilated place, disconnect power if it
feels excessively hot, and let it cool naturally. iOS manages thermal and
charging protections; do not try to bypass them.

The charging reminder and heat alert run only while the PerformancePlus page is
open. Alerts require manual action and cannot guarantee prevention of battery
wear or overheating.

## What PerformancePlus does not do

The controls for system-wide refresh/FPS limits, touch or gesture changes,
stutter reduction, CPU/GPU/RAM tuning, app compatibility overrides, background
activity, charging limits, and thermal profiles cannot safely apply those
changes across iOS. Such items may show device status or explain the limitation;
they do not secretly modify system behavior.

PerformancePlus does not overclock, change voltage, bypass thermal protection,
write arbitrary kernel memory, disable security features, manipulate charging,
or terminate critical system processes. It cannot guarantee compatibility with
other installed jailbreak tweaks.

## Troubleshooting

- **The source cannot be added:** verify the address is
  `https://minhnhatz.github.io/performanceplus/`, including the trailing slash.
- **The package does not appear:** refresh the source list and search for
  `PerformancePlus`.
- **The preference page is missing:** check that installation completed, then
  respring from your package manager if needed.
- **A status value is unavailable:** the device or iOS version may not expose
  that reading.
- **An unsupported control has no effect:** this is expected; unsupported
  controls do not change iOS behavior.

## Update or uninstall

Refresh the PerformancePlus source in Sileo or Zebra to install updates. To
uninstall, remove the package in your package manager. Remove the repository
from **Sources** if you no longer want to receive updates.

## Links

- [Sileo repository](https://minhnhatz.github.io/performanceplus/)
- [Source code and issue reporting](https://github.com/Minhnhatz/performanceplus)
