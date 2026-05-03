#!/bin/sh
set -e

OPENWRT_VERSION="${OPENWRT_VERSION:-24.10}"
BASE_URL="https://momomomo.pages.dev/openwrt-${OPENWRT_VERSION}"
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
    feed_url="${BASE_URL}/${platform}/momo"
    echo "Preparing platform: $platform"
    mkdir -p "$platform"

    index_html="$(curl -fsSL "${feed_url}/")"

    momo_file="$(find_latest_file "$index_html" "momo_[^\"< ]*_${platform}\\.ipk")"
    luci_app_file="$(find_latest_file "$index_html" 'luci-app-momo_[^"< ]*_all\.ipk')"
    language_files="$(printf '%s' "$index_html" | grep -oE 'luci-i18n-momo-[^"< ]*_all\.ipk' | sort -Vu || true)"

    [ -n "$momo_file" ] || { echo "Error: momo not found for ${platform}"; exit 1; }
    [ -n "$luci_app_file" ] || { echo "Error: luci-app-momo not found for ${platform}"; exit 1; }

    safe_download "${feed_url}/${momo_file}" "${platform}/${momo_file}"
    safe_download "${feed_url}/${luci_app_file}" "${platform}/${luci_app_file}"

    if [ -n "$language_files" ]; then
        printf '%s\n' "$language_files" | while IFS= read -r lang_file; do
            [ -n "$lang_file" ] || continue
            safe_download "${feed_url}/${lang_file}" "${platform}/${lang_file}"
        done
    else
        echo "Warning: no luci-i18n packages found for ${platform}"
    fi

    ls -lh "$platform"
done
