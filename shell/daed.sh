#!/bin/sh
set -e

REPO="QiuSimons/luci-app-daed"
PLATFORMS="x86_64 aarch64_generic aarch64_cortex-a53"
# aarch64_cortex-a53 无专用包，复用 aarch64_generic
FALLBACK_MAP="aarch64_cortex-a53:aarch64_generic"

safe_download() {
    url="$1"
    output="$2"
    echo "Downloading: $url"
    curl -L --fail --connect-timeout 15 --max-time 120 "$url" -o "$output" -#
    test -s "$output"
}

get_fallback() {
    for pair in $FALLBACK_MAP; do
        src="${pair%%:*}"
        dst="${pair##*:}"
        [ "$src" = "$1" ] && echo "$dst" && return
    done
    echo "$1"
}

echo "Fetching latest release from $REPO ..."
api_json="$(curl -fsSL --connect-timeout 15 "https://api.github.com/repos/$REPO/releases/latest")"
tag="$(printf '%s' "$api_json" | jq -r '.tag_name')"
echo "Latest tag: $tag"

version="${tag#daed_}"
echo "Version: $version"

for platform in $PLATFORMS; do
    echo "Preparing platform: $platform"
    mkdir -p "$platform/depends"

    arch="$(get_fallback "$platform")"

    # daed 二进制（架构相关）
    prog_file="daed_${version}_${arch}-openwrt-24.10.ipk"
    prog_url="https://github.com/$REPO/releases/download/$tag/$prog_file"
    safe_download "$prog_url" "${platform}/depends/$prog_file"

    # luci-app-daed（all 架构）
    luci_file="$(printf '%s' "$api_json" | jq -r '.assets[] | select(.name | test("luci-app-daed_.*_all-openwrt-24\\.10\\.ipk$")) | .name' | head -1)"
    if [ -n "$luci_file" ]; then
        safe_download "https://github.com/$REPO/releases/download/$tag/$luci_file" "${platform}/depends/$luci_file"
    else
        echo "Warning: luci-app-daed ipk not found, skipping"
    fi

    # luci-i18n-daed-zh-cn（all 架构）
    i18n_file="$(printf '%s' "$api_json" | jq -r '.assets[] | select(.name | test("luci-i18n-daed-zh-cn_.*_all-openwrt-24\\.10\\.ipk$")) | .name' | head -1)"
    if [ -n "$i18n_file" ]; then
        safe_download "https://github.com/$REPO/releases/download/$tag/$i18n_file" "${platform}/depends/$i18n_file"
    else
        echo "Warning: luci-i18n-daed-zh-cn ipk not found, skipping"
    fi

    echo "=== $platform done ==="
    ls -lh "$platform/depends/"
done

# 保存版本供工作流使用
echo "$version" > /tmp/daed_version.txt
