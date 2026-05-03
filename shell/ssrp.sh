#!/bin/sh
set -e

BASE_URL="https://dl.openwrt.ai/packages-24.10"
PLATFORMS="x86_64 aarch64_generic aarch64_cortex-a53"

safe_download() {
    url="$1"
    output="$2"

    echo "Downloading: $url"
    wget -q --timeout=15 --tries=3 -O "$output" "$url"
    test -s "$output"
}

find_latest_file() {
    index_html="$1"
    pattern="$2"

    printf '%s' "$index_html" | grep -oE "$pattern" | sort -V | tail -n 1
}

for platform in $PLATFORMS; do
    feed_url="${BASE_URL}/${platform}/kiddin9"
    echo "Preparing platform: $platform"
    mkdir -p "$platform"

    index_html="$(curl -fsSL --connect-timeout 15 --max-time 30 "${feed_url}/")"
    ssrp_app="$(find_latest_file "$index_html" 'luci-app-ssr-plus_[^"< ]*_all\.ipk')"

    [ -n "$ssrp_app" ] || { echo "Error: luci-app-ssr-plus not found for ${platform}"; exit 1; }

    safe_download "${feed_url}/${ssrp_app}" "${platform}/${ssrp_app}"

    ls -lh "$platform"
done
