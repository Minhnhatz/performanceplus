#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_DIR="${PACKAGE_DIR:-$ROOT_DIR/packages}"
REPO_DIR="${REPO_DIR:-$ROOT_DIR/repo}"
PACKAGE_NAME="com.blue.performanceplus"
EXPECTED_ARCH="iphoneos-arm64"
POOL_PACKAGE_DIR="$REPO_DIR/pool/main/c/$PACKAGE_NAME"

for tool in dpkg-deb dpkg dpkg-scanpackages gzip sha256sum md5sum python3; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'Required command not found: %s\n' "$tool" >&2
        exit 1
    fi
done

shopt -s nullglob
deb_files=("$PACKAGE_DIR"/*.deb)
if ((${#deb_files[@]} == 0)); then
    printf 'No .deb packages found in %s\n' "$PACKAGE_DIR" >&2
    exit 1
fi

selected_deb=""
selected_version=""
for deb in "${deb_files[@]}"; do
    package="$(dpkg-deb -f "$deb" Package)"
    [[ "$package" == "$PACKAGE_NAME" ]] || continue

    arch="$(dpkg-deb -f "$deb" Architecture)"
    [[ "$arch" == "$EXPECTED_ARCH" ]] || {
        printf 'Unexpected architecture in %s: %s\n' "$deb" "$arch" >&2
        exit 1
    }

    version="$(dpkg-deb -f "$deb" Version)"
    if [[ -z "$selected_deb" ]] ||
        dpkg --compare-versions "$version" gt "$selected_version"; then
        selected_deb="$deb"
        selected_version="$version"
    fi
done

if [[ -z "$selected_deb" ]]; then
    printf 'No %s package found in %s\n' "$PACKAGE_NAME" "$PACKAGE_DIR" >&2
    exit 1
fi

mkdir -p "$POOL_PACKAGE_DIR"
find "$POOL_PACKAGE_DIR" -maxdepth 1 -type f -name "${PACKAGE_NAME}_*.deb" -delete
package_filename="$(basename "$selected_deb")"
cp "$selected_deb" "$POOL_PACKAGE_DIR/$package_filename"

(
    cd "$REPO_DIR"
    dpkg-scanpackages --multiversion pool /dev/null > Packages
    python3 -c 'from pathlib import Path; path = Path("Packages"); path.write_text(path.read_text().rstrip() + "\n")'
    gzip -n -9 -c Packages > Packages.gz
)

architecture="$(dpkg-deb -f "$selected_deb" Architecture)"
package_name="$(dpkg-deb -f "$selected_deb" Name)"
package_version="$(dpkg-deb -f "$selected_deb" Version)"
package_description="$(dpkg-deb -f "$selected_deb" Description)"
date -Ru > "$REPO_DIR/.release-date"
release_date="$(cat "$REPO_DIR/.release-date")"
rm "$REPO_DIR/.release-date"
{
    printf 'Origin: PerformancePlus\n'
    printf 'Label: PerformancePlus\n'
    printf 'Suite: stable\n'
    printf 'Codename: stable\n'
    printf 'Date: %s\n' "$release_date"
    printf 'Architectures: %s\n' "$architecture"
    printf 'Components: main\n'
    printf 'Description: PerformancePlus jailbreak tweak repository\n'
    printf 'MD5Sum:\n'
    for file in Packages Packages.gz; do
        printf ' %s %s %s\n' \
            "$(md5sum "$REPO_DIR/$file" | cut -d ' ' -f 1)" \
            "$(wc -c < "$REPO_DIR/$file" | tr -d ' ')" \
            "$file"
    done
    printf 'SHA256:\n'
    for file in Packages Packages.gz; do
        printf ' %s %s %s\n' \
            "$(sha256sum "$REPO_DIR/$file" | cut -d ' ' -f 1)" \
            "$(wc -c < "$REPO_DIR/$file" | tr -d ' ')" \
            "$file"
    done
} > "$REPO_DIR/Release"

github_repository="${GITHUB_REPOSITORY:-}"
if [[ -z "$github_repository" ]]; then
    remote_url="$(git -C "$ROOT_DIR" remote get-url origin 2>/dev/null || true)"
    if [[ "$remote_url" =~ github\.com[:/]([^/]+/[^/.]+)(\.git)?$ ]]; then
        github_repository="${BASH_REMATCH[1]}"
    fi
fi

if [[ -z "$github_repository" || "$github_repository" != */* ]]; then
    printf 'Could not determine GitHub owner/repository from GITHUB_REPOSITORY or origin remote.\n' >&2
    exit 1
fi
github_owner="${github_repository%%/*}"
github_repo="${github_repository#*/}"
pages_url="https://${github_owner}.github.io/${github_repo}/"

cp "$ROOT_DIR/site/styles.css" "$REPO_DIR/styles.css"
cp "$ROOT_DIR/site/app.js" "$REPO_DIR/app.js"
cat > "$REPO_DIR/index.html" <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#6655e8">
  <meta name="description" content="PerformancePlus — userspace performance controls and device status for Dopamine rootless jailbreaks.">
  <title>PerformancePlus — APT Repository</title>
  <link rel="stylesheet" href="styles.css">
  <script src="app.js" defer></script>
</head>
<body>
  <header class="shell topbar">
    <a class="brand" href="./" aria-label="PerformancePlus home">
      <span class="brand-mark" aria-hidden="true">PP</span>
      <span>PerformancePlus <span class="sr-only">APT Repository</span></span>
    </a>
    <nav class="nav-links" aria-label="Main navigation">
      <a href="#package">Package</a>
      <a href="#install">Installation</a>
      <a class="nav-github" href="https://github.com/${github_repository}" target="_blank" rel="noreferrer">
        <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 .9a11.1 11.1 0 0 0-3.51 21.63c.56.1.76-.24.76-.54v-2.1c-3.1.68-3.76-1.31-3.76-1.31-.5-1.3-1.24-1.65-1.24-1.65-1.01-.69.08-.68.08-.68 1.12.08 1.71 1.15 1.71 1.15.99 1.7 2.59 1.21 3.22.93.1-.72.39-1.21.7-1.49-2.48-.28-5.09-1.24-5.09-5.52 0-1.22.44-2.21 1.15-2.99-.12-.28-.5-1.42.11-2.96 0 0 .94-.3 3.06 1.14a10.66 10.66 0 0 1 5.57 0c2.13-1.44 3.06-1.14 3.06-1.14.61 1.54.23 2.68.12 2.96.71.78 1.14 1.77 1.14 2.99 0 4.29-2.62 5.23-5.11 5.51.4.35.75 1.03.75 2.08v3.08c0 .3.2.65.77.54A11.1 11.1 0 0 0 12 .9Z"/></svg>
        GitHub
      </a>
    </nav>
  </header>

  <main>
    <section class="shell hero">
      <div>
        <p class="eyebrow">Dopamine · Rootless · iOS 15+</p>
        <h1>A little more insight.<br><span>All user space.</span></h1>
        <p class="hero-copy">PerformancePlus brings safe performance preferences and clear device status to one native iOS settings pane. No overclocking. No thermal bypasses. Just useful controls and information.</p>
        <div class="hero-actions">
          <a class="button button-primary" href="#install">
            Add to Sileo / Zebra
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
          </a>
          <a class="button button-secondary" href="#package">View package</a>
        </div>
      </div>
      <div class="hero-art" aria-hidden="true">
        <div class="orb"></div>
        <div class="orb-logo">PP</div>
        <div class="float-card float-card-one">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m5 12 4 4L19 6"/></svg>
          <span><strong>Rootless ready</strong><small>Built for Dopamine</small></span>
        </div>
        <div class="float-card float-card-two">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 3v18M3 12h18"/><circle cx="12" cy="12" r="9"/></svg>
          <span><strong>Safe by design</strong><small>Userspace preferences</small></span>
        </div>
      </div>
    </section>

    <section class="shell section" id="package">
      <div class="section-heading">
        <div>
          <p class="eyebrow">Latest release</p>
          <h2>Available package</h2>
        </div>
        <p>Install through your favorite package manager.</p>
      </div>
      <article class="package-card">
        <div class="package-main">
          <div class="package-icon" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M12 3 4.5 7.2v9.6L12 21l7.5-4.2V7.2L12 3Z"/><path d="m4.8 7.4 7.2 4 7.2-4M12 11.5V21"/></svg>
          </div>
          <div>
            <h3 class="package-title">${package_name}</h3>
            <p class="package-id">${package_description}</p>
            <div class="package-meta">
              <span class="pill">Version ${package_version}</span>
              <span class="pill">${architecture}</span>
              <span class="pill">Rootless</span>
            </div>
          </div>
        </div>
        <a class="button button-secondary package-download" href="pool/main/c/${PACKAGE_NAME}/${package_filename}" download>
          Download .deb
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M12 3v12m-5-5 5 5 5-5M5 20h14"/></svg>
        </a>
      </article>
      <div class="feature-grid">
        <article class="feature-card">
          <span class="feature-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M12 3 4.5 7.2v9.6L12 21l7.5-4.2V7.2L12 3Z"/><path d="m9 12 2 2 4-4"/></svg></span>
          <h3>Made for rootless</h3>
          <p>Packaged for Dopamine with files installed under the jailbreak root.</p>
        </article>
        <article class="feature-card">
          <span class="feature-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="5" y="5" width="14" height="14" rx="3"/><path d="M9 2v3m6-3v3M9 19v3m6-3v3M2 9h3m14 0h3M2 15h3m14 0h3"/></svg></span>
          <h3>Device insights</h3>
          <p>Check CPU, memory, battery, iOS version, and device model at a glance.</p>
        </article>
        <article class="feature-card">
          <span class="feature-icon" aria-hidden="true"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M12 3v3m0 12v3m9-9h-3M6 12H3m15.36-6.36-2.12 2.12M7.76 16.24l-2.12 2.12m12.72 0-2.12-2.12M7.76 7.76 5.64 5.64"/><circle cx="12" cy="12" r="4"/></svg></span>
          <h3>Safe preferences</h3>
          <p>Userspace toggles only. iOS keeps control of thermals and scheduling.</p>
        </article>
      </div>
    </section>

    <section class="shell section" id="install">
      <div class="install-panel">
        <div>
          <p class="eyebrow">Quick setup</p>
          <h2>Your tweaks, one tap away.</h2>
          <p class="install-panel-copy">Add this source to Sileo or Zebra. The package will appear in search once the source refreshes.</p>
        </div>
        <div>
          <ol class="install-steps">
            <li>Open Sileo or Zebra and go to Sources.</li>
            <li>Tap the + button to add a source.</li>
            <li>Paste this repository URL and confirm.</li>
            <li>Search for PerformancePlus and install.</li>
          </ol>
          <div class="source-copy">
            <code>${pages_url}</code>
            <button type="button" data-copy-source="${pages_url}" aria-label="Copy repository URL">Copy</button>
            <span class="sr-only" id="copy-status" aria-live="polite"></span>
          </div>
        </div>
      </div>
    </section>
  </main>

  <footer class="shell footer">
    <p>© ${github_owner} · PerformancePlus APT Repository</p>
    <nav class="footer-links" aria-label="Repository links">
      <a href="Release">Release</a>
      <a href="Packages">Packages</a>
      <a href="Packages.gz">Packages.gz</a>
      <a href="https://github.com/${github_repository}" target="_blank" rel="noreferrer">Source</a>
    </nav>
  </footer>
</body>
</html>
EOF

gzip -t "$REPO_DIR/Packages.gz"
cmp "$REPO_DIR/Packages" <(gzip -dc "$REPO_DIR/Packages.gz")

python3 - "$REPO_DIR" "$selected_deb" "$PACKAGE_NAME" "$EXPECTED_ARCH" <<'PY'
import hashlib
import pathlib
import subprocess
import sys

repo = pathlib.Path(sys.argv[1])
deb = pathlib.Path(sys.argv[2])
expected_package = sys.argv[3]
expected_arch = sys.argv[4]

def control_field(path: pathlib.Path, field: str) -> str:
    return subprocess.check_output(
        ["dpkg-deb", "-f", str(path), field], text=True
    ).strip()

fields = {}
for line in (repo / "Packages").read_text().splitlines():
    if line.startswith(" ") or not line:
        continue
    key, separator, value = line.partition(":")
    if separator:
        fields[key] = value.strip()

assert fields.get("Package") == expected_package, fields
assert fields.get("Architecture") == expected_arch, fields
assert fields.get("Version") == control_field(deb, "Version"), fields
assert fields.get("Name") == control_field(deb, "Name"), fields
assert fields.get("Filename"), fields
assert fields.get("Size") == str(deb.stat().st_size), fields
assert fields.get("SHA256") == hashlib.sha256(deb.read_bytes()).hexdigest(), fields

package_path = repo / fields["Filename"]
assert package_path.is_file(), fields["Filename"]
assert package_path.stat().st_size == int(fields["Size"])
assert hashlib.sha256(package_path.read_bytes()).hexdigest() == fields["SHA256"]

release = (repo / "Release").read_text()
for checksum_type, algorithm in (("MD5Sum", hashlib.md5), ("SHA256", hashlib.sha256)):
    section = release.split(f"{checksum_type}:\n", 1)[1]
    if checksum_type == "MD5Sum":
        section = section.split("\nSHA256:\n", 1)[0]
    for line in section.splitlines():
        if not line.strip():
            continue
        expected_hash, expected_size, filename = line.split()
        content = (repo / filename).read_bytes()
        assert str(len(content)) == expected_size, filename
        assert algorithm(content).hexdigest() == expected_hash, filename

print(
    f"Validated {fields['Package']} {fields['Version']} "
    f"({fields['Architecture']}) at {fields['Filename']}"
)
PY

printf 'APT repository generated at %s\n' "$REPO_DIR"
printf 'GitHub Pages URL: %s\n' "$pages_url"
