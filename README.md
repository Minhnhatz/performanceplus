# PerformancePlus APT Repository

An APT repository for the PerformancePlus userspace performance controls and
device status preference pane. Packages target Dopamine/rootless jailbreaks on
iOS 15 or later and include arm64 and arm64e slices where supported.

## Install with Sileo or Zebra

1. Open Sileo or Zebra.
2. Go to **Sources** and tap **+**.
3. Add:

   **https://Minhnhatz.github.io/PerformancePlus/**

4. Search for **PerformancePlus** and install.

The source URL is the GitHub Pages site for `Minhnhatz/PerformancePlus`.
The repository workflow builds the rootless `.deb`, generates APT metadata
from that package, validates the repository, and deploys it to GitHub Pages.

## Build locally

With Theos installed and `THEOS` set:

```sh
make clean
make package FINALPACKAGE=1
scripts/build-repo.sh
```

The generated package is written to `packages/`; the deployable APT repository
root is `repo/` and contains `Release`, `Packages`, `Packages.gz`, and `pool/`.

## Safety

PerformancePlus does not overclock CPU/GPU, change voltage, bypass thermal
protection, manipulate charging, or modify kernel memory. Its performance
switches save userspace preferences only.
