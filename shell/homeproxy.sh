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
    homeproxy_file="$(find_latest_file "$index_html" 'luci-app-homeproxy_[^"< ]*_all\.ipk')"
    singbox_file="$(find_latest_file "$index_html" "sing-box_[^\"< ]*_${platform}\\.ipk")"

    [ -n "$homeproxy_file" ] || { echo "Error: luci-app-homeproxy not found for ${platform}"; exit 1; }
    [ -n "$singbox_file" ] || { echo "Error: sing-box not found for ${platform}"; exit 1; }

    safe_download "${feed_url}/${homeproxy_file}" "${platform}/${homeproxy_file}"
    safe_download "${feed_url}/${singbox_file}" "${platform}/${singbox_file}"

    ls -lh "$platform"
done
