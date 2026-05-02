#!/bin/sh
set -e

BASE_URL="https://dl.openwrt.ai/packages-24.10"
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

find_latest_file() {
    index_html="$1"
    pattern="$2"

    printf '%s' "$index_html" | grep -oE "$pattern" | sort -V | tail -n 1
}

for platform in $PLATFORMS; do
    feed_url="${BASE_URL}/${platform}/kiddin9"
    echo "Preparing platform: $platform"
    mkdir -p "$platform"

    index_html="$(curl -fsSL "${feed_url}/")"

    mihomo_file="$(find_latest_file "$index_html" "mihomo_[^\"< ]*_${platform}\\.ipk")"
    nikki_file="$(find_latest_file "$index_html" "nikki_[^\"< ]*_${platform}\\.ipk")"
    luci_app_file="$(find_latest_file "$index_html" 'luci-app-nikki_[^"< ]*_all\.ipk')"

    [ -n "$mihomo_file" ] || { echo "Error: mihomo not found for ${platform}"; exit 1; }
    [ -n "$nikki_file" ] || { echo "Error: nikki not found for ${platform}"; exit 1; }
    [ -n "$luci_app_file" ] || { echo "Error: luci-app-nikki not found for ${platform}"; exit 1; }

    safe_download "${feed_url}/${mihomo_file}" "${platform}/${mihomo_file}"
    safe_download "${feed_url}/${nikki_file}" "${platform}/${nikki_file}"
    safe_download "${feed_url}/${luci_app_file}" "${platform}/${luci_app_file}"

    ls -lh "$platform"
done
