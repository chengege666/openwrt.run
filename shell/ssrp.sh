#!/bin/sh
set -e

BASE_URL="${BASE_URL:-https://dl.openwrt.ai}"
PACKAGE_VERSION="${PACKAGE_VERSION:-packages-24.10}"
BASE_URL="${BASE_URL}/${PACKAGE_VERSION}"
PLATFORMS="x86_64 aarch64_cortex-a53"

FILE_PREFIXES="shadowsocks-libev-ss-server dns2tcp lua-neturl chinadns-ng dns2socks hysteria ipt2socks microsocks mosdns naiveproxy redsocks2 shadowsocksr-libev shadowsocks-rust shadow-tls simple-obfs-client tcping trojan tuic-client v2ray-plugin xray-core luci-app-ssr-plus"
EXCLUDE_PREFIXES="luci-app-chinadns-ng luci-app-microsocks luci-app-mosdns luci-app-naiveproxy luci-app-redsocks2 luci-app-shadowsocks"

safe_download() {
    url="$1"
    output="$2"
    echo "Downloading: $url"
    curl -L --fail "$url" -o "$output" -#
    test -s "$output"
}

libopenssl3_url() {
    arch="$1"
    case "$arch" in
        x86_64)
            echo "https://github.com/wkccd/build/releases/download/pw1/libopenssl3_3.0.16-1_x86_64.ipk"
            ;;
        aarch64_cortex-a53)
            echo "https://github.com/wkccd/build/releases/download/pw1/libopenssl3_3.0.16-1_aarch64_cortex-a53.ipk"
            ;;
        *)
            return 1
            ;;
    esac
}

for platform in $PLATFORMS; do
    feed_url="${BASE_URL}/${platform}/kiddin9/"
    echo "Preparing platform: $platform"
    mkdir -p "$platform/depends"

    # Download libopenssl3 from GitHub release
    ossl_url=$(libopenssl3_url "$platform")
    if [ -n "$ossl_url" ]; then
        safe_download "$ossl_url" "$platform/depends/libopenssl3.ipk"
    fi

    # Download libudns from packages feed
    wget -qO- "${BASE_URL}/${platform}/packages/" | \
    while IFS= read -r LINE; do
        echo "$LINE" | grep -qE 'libudns' || continue
        FILE=$(echo "$LINE" | grep -oP 'href="\K[^"]*')
        [ -n "$FILE" ] || continue
        curl -L --fail "${BASE_URL}/${platform}/packages/${FILE}" -o "$platform/depends/$(basename $FILE)" -#
    done

    # Download SSR-Plus and dependency packages from kiddin9 feed
    wget -qO- "$feed_url" | \
    while IFS= read -r LINE; do
        for PREFIX in $FILE_PREFIXES; do
            echo "$LINE" | grep -q "$PREFIX" || continue
            FILE=$(echo "$LINE" | grep -oP 'href="\K[^"]*')
            [ -n "$FILE" ] || continue

            skip=0
            for EXCLUDE in $EXCLUDE_PREFIXES; do
                case "$FILE" in
                    $EXCLUDE*) skip=1; break ;;
                esac
            done
            [ "$skip" -eq 1 ] && echo "Skip file: $FILE" && continue

            curl -L --fail "${feed_url}${FILE}" -o "$platform/depends/$(basename $FILE)" -#
        done
    done

    # Move luci-app-ssr-plus to root
    mv "$platform/depends/luci-app-ssr-plus"*.ipk "$platform/"

    echo "=== $platform contents ==="
    ls -lh "$platform/"
    echo "=== $platform/depends contents ==="
    ls -lh "$platform/depends/"
done
