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

cat > "$REPO_DIR/index.html" <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>PerformancePlus APT Repository</title>
</head>
<body>
  <h1>PerformancePlus APT Repository</h1>
  <p>APT repository for Dopamine/rootless jailbreaks.</p>
  <ul>
    <li><a href="Release">Release</a></li>
    <li><a href="Packages">Packages</a></li>
    <li><a href="Packages.gz">Packages.gz</a></li>
    <li><a href="pool/main/c/${PACKAGE_NAME}/${package_filename}">${package_filename}</a></li>
  </ul>
  <p>Sileo/Zebra source: <a href="${pages_url}">${pages_url}</a></p>
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
