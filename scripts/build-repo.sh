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
binary_index_dir="main/binary-${architecture}"
dist_dir="$REPO_DIR/dists/stable"
mkdir -p "$dist_dir/$binary_index_dir"
cp "$REPO_DIR/Packages" "$dist_dir/$binary_index_dir/Packages"
cp "$REPO_DIR/Packages.gz" "$dist_dir/$binary_index_dir/Packages.gz"

generate_release() {
    local output_path="$1"
    shift
    local release_dir
    release_dir="$(dirname "$output_path")"
    local release_date
    release_date="$(date -Ru)"

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
        for file in "$@"; do
            printf ' %s %s %s\n' \
                "$(md5sum "$release_dir/$file" | cut -d ' ' -f 1)" \
                "$(wc -c < "$release_dir/$file" | tr -d ' ')" \
                "$file"
        done
        printf 'SHA256:\n'
        for file in "$@"; do
            printf ' %s %s %s\n' \
                "$(sha256sum "$release_dir/$file" | cut -d ' ' -f 1)" \
                "$(wc -c < "$release_dir/$file" | tr -d ' ')" \
                "$file"
        done
    } > "$output_path"
}

generate_release "$REPO_DIR/Release" Packages Packages.gz
generate_release "$dist_dir/Release" \
    "$binary_index_dir/Packages" "$binary_index_dir/Packages.gz"

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
github_repository="${github_repository,,}"
github_owner="${github_repository%%/*}"
github_repo="${github_repository#*/}"
pages_url="https://${github_owner}.github.io/${github_repo}/"

cp "$ROOT_DIR/site/styles.css" "$REPO_DIR/styles.css"
cp "$ROOT_DIR/site/app.js" "$REPO_DIR/app.js"
python3 - \
    "$ROOT_DIR/site/index.html" \
    "$REPO_DIR/index.html" \
    "$github_repository" \
    "$github_owner" \
    "$pages_url" \
    "$package_name" \
    "$package_description" \
    "$package_version" \
    "$architecture" \
    "$PACKAGE_NAME" \
    "$package_filename" <<'PY'
import html
import pathlib
import sys

(
    template_path,
    output_path,
    github_repository,
    github_owner,
    pages_url,
    package_name,
    package_description,
    package_version,
    architecture,
    package_id,
    package_filename,
) = sys.argv[1:]

replacements = {
    "{{GITHUB_REPOSITORY}}": github_repository,
    "{{GITHUB_OWNER}}": github_owner,
    "{{PAGES_URL}}": pages_url,
    "{{PACKAGE_NAME}}": package_name,
    "{{PACKAGE_DESCRIPTION}}": package_description,
    "{{PACKAGE_VERSION}}": package_version,
    "{{ARCHITECTURE}}": architecture,
    "{{PACKAGE_ID}}": package_id,
    "{{PACKAGE_FILENAME}}": package_filename,
}

page = pathlib.Path(template_path).read_text()
for placeholder, value in replacements.items():
    page = page.replace(placeholder, html.escape(value, quote=True))
pathlib.Path(output_path).write_text(page)
PY

gzip -t "$REPO_DIR/Packages.gz" "$dist_dir/$binary_index_dir/Packages.gz"
cmp "$REPO_DIR/Packages" <(gzip -dc "$REPO_DIR/Packages.gz")
cmp "$REPO_DIR/Packages" "$dist_dir/$binary_index_dir/Packages"
cmp "$REPO_DIR/Packages.gz" "$dist_dir/$binary_index_dir/Packages.gz"

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

release_paths = [
    (repo / "Release", repo),
    (
        repo / "dists/stable/Release",
        repo / "dists/stable",
    ),
]
for release_path, release_root in release_paths:
    release = release_path.read_text()
    for checksum_type, algorithm in (("MD5Sum", hashlib.md5), ("SHA256", hashlib.sha256)):
        section = release.split(f"{checksum_type}:\n", 1)[1]
        if checksum_type == "MD5Sum":
            section = section.split("\nSHA256:\n", 1)[0]
        for line in section.splitlines():
            if not line.strip():
                continue
            expected_hash, expected_size, filename = line.split()
            content = (release_root / filename).read_bytes()
            assert str(len(content)) == expected_size, filename
            assert algorithm(content).hexdigest() == expected_hash, filename

print(
    f"Validated {fields['Package']} {fields['Version']} "
    f"({fields['Architecture']}) at {fields['Filename']} "
    "in flat and stable distributions"
)
PY

printf 'APT repository generated at %s\n' "$REPO_DIR"
printf 'GitHub Pages URL: %s\n' "$pages_url"
