#!/bin/sh
set -e

REPO="nikkinikki-org/OpenWrt-nikki"
PLATFORMS="x86_64 aarch64_generic aarch64_cortex-a53"

safe_download() {
    url="$1"
    output="$2"

    echo "Downloading: $url"
    wget -q --timeout=60 --tries=5 --retry-connrefused --waitretry=5 -O "$output" "$url" || \
    wget -q --timeout=60 --tries=5 --retry-connrefused --waitretry=5 -O "$output" "https://ghproxy.com/$url" || \
    wget -q --timeout=60 --tries=5 --retry-connrefused --waitretry=5 -O "$output" "https://mirror.ghproxy.com/$url"

    test -s "$output"
}

echo "Fetching latest release info..."
RELEASE_JSON="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest")"
TAG_NAME="$(echo "$RELEASE_JSON" | jq -r '.tag_name')"

[ -n "$TAG_NAME" ] && [ "$TAG_NAME" != "null" ] || { echo "Error: failed to get latest tag"; exit 1; }

echo "Latest release: $TAG_NAME"

for platform in $PLATFORMS; do
    echo "Preparing platform: $platform"
    mkdir -p "$platform"

    asset_name="nikki_${platform}-openwrt-24.10.tar.gz"
    asset_url="https://github.com/${REPO}/releases/download/${TAG_NAME}/${asset_name}"

    safe_download "$asset_url" "${platform}/${asset_name}"

    echo "Extracting ${asset_name}..."
    tar -xzf "${platform}/${asset_name}" -C "$platform"/
    rm -f "${platform}/${asset_name}"

    ls -lh "$platform"
done
