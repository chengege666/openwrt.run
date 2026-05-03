#!/bin/sh
set -e

BASE_URL="https://dl.openwrt.ai/packages-24.10"
PLATFORMS="x86_64 aarch64_generic aarch64_cortex-a53"
FILE_PREFIXES="daed daed-geoip daed-geosite luci-app-daed"
EXCLUDE_PREFIXES="luci-i18n-daed"

safe_download() {
    url="$1"
    output="$2"
    echo "Downloading: $url"
    curl -L --fail --connect-timeout 15 --max-time 60 "$url" -o "$output" -#
    test -s "$output"
}

for platform in $PLATFORMS; do
    feed_url="${BASE_URL}/${platform}/kiddin9"
    echo "Preparing platform: $platform"
    mkdir -p "$platform/depends"

    index_html="$(wget -qO- --timeout=15 "${feed_url}/")"

    for prefix in $FILE_PREFIXES; do
        pattern="${prefix}_[^\"< ]*\\.ipk"
        file="$(printf '%s' "$index_html" | grep -oE "$pattern" | sort -V | tail -n 1)"

        [ -z "$file" ] && echo "Warning: $prefix not found for ${platform}" && continue

        skip=0
        for exclude in $EXCLUDE_PREFIXES; do
            case "$file" in
                "$exclude"*) skip=1 ;;
            esac
        done
        [ "$skip" = 1 ] && echo "Skip: $file" && continue

        safe_download "${feed_url}/${file}" "${platform}/depends/${file}"
    done

    echo "=== $platform done ==="
    ls -lh "$platform/depends/"
done
