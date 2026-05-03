#!/bin/sh
set -e

GH_REPO="Openwrt-Passwall/openwrt-passwall2"

safe_download() {
    url="$1"
    output="$2"
    echo "Downloading: $url"
    curl -L --fail "$url" -o "$output" -#
    test -s "$output"
}

echo "Fetching latest release info from $GH_REPO"
RELEASE_JSON="$(curl -fsSL "https://api.github.com/repos/${GH_REPO}/releases/latest")"
TAG="$(echo "$RELEASE_JSON" | jq -r '.tag_name')"
echo "Latest tag: $TAG"

ASSETS_JSON="$(echo "$RELEASE_JSON" | jq -c '.assets[]')"

BASE="https://github.com/${GH_REPO}/releases/download/$TAG"

LUCI_URL="$(echo "$ASSETS_JSON" | jq -r 'select(.name | test("luci-app-passwall2_.*\\.ipk$")) | .browser_download_url' | head -1)"
I18N_URL="$(echo "$ASSETS_JSON" | jq -r 'select(.name | test("luci-i18n-passwall2-zh-cn_.*\\.ipk$")) | .browser_download_url' | head -1)"

safe_download "$LUCI_URL" "/tmp/luci-app-passwall2.ipk"
safe_download "$I18N_URL" "/tmp/luci-i18n-passwall2-zh-cn.ipk"

for ARCH in x86_64 aarch64_cortex-a53 aarch64_generic; do
    ZIP_NAME="passwall_packages_ipk_${ARCH}.zip"
    ZIP_URL="$(echo "$ASSETS_JSON" | jq -r --arg n "$ZIP_NAME" 'select(.name == $n) | .browser_download_url' | head -1)"

    if [ -z "$ZIP_URL" ]; then
        echo "Warning: $ZIP_NAME not found, skipping $ARCH"
        continue
    fi

    echo "Preparing $ARCH"
    mkdir -p "$ARCH/depends"

    safe_download "$ZIP_URL" "/tmp/${ZIP_NAME}"
    unzip -qo "/tmp/${ZIP_NAME}" -d "$ARCH/depends/"
    rm -f "/tmp/${ZIP_NAME}"

    cp /tmp/luci-app-passwall2.ipk "$ARCH/"
    cp /tmp/luci-i18n-passwall2-zh-cn.ipk "$ARCH/"

    echo "=== $ARCH contents ==="
    ls -lh "$ARCH/"
    echo "=== $ARCH/depends (first 20 lines) ==="
    ls -lh "$ARCH/depends/" | head -20
done

rm -f /tmp/luci-app-passwall2.ipk /tmp/luci-i18n-passwall2-zh-cn.ipk
