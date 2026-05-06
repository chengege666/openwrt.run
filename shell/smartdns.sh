#!/bin/sh
set -e

REPO="pymumu/smartdns"
PLATFORMS="x86_64 aarch64_generic aarch64_cortex-a53"

safe_download() {
    url="$1"
    output="$2"
    echo "Downloading: $url"
    curl -L --fail --connect-timeout 15 --max-time 120 "$url" -o "$output" -#
    if [ ! -s "$output" ]; then
        echo "Error: Download failed or file is empty: $output"
        exit 1
    fi
    echo "Success: $(ls -lh "$output" | awk '{print $5}')"
}

get_smartdns_arch() {
    case "$1" in
        x86_64)
            echo "x86_64"
            ;;
        aarch64_generic|aarch64_cortex-a53)
            echo "arm"
            ;;
        *)
            echo "$1"
            ;;
    esac
}

echo "===== Fetching latest release info: $REPO ====="
api_json="$(curl -fsSL --connect-timeout 15 "https://api.github.com/repos/$REPO/releases/latest")"
if [ -z "$api_json" ]; then
    echo "Error: Failed to fetch release info"
    exit 1
fi

tag="$(printf '%s' "$api_json" | jq -r '.tag_name')"
if [ -z "$tag" ] || [ "$tag" = "null" ]; then
    echo "Error: Failed to parse tag_name"
    exit 1
fi
echo "Latest tag: $tag"

echo ""
echo "Available IPK files:"
printf '%s' "$api_json" | jq -r '.assets[] | select(.name | test("\\.ipk$")) | .name'

echo ""

for platform in $PLATFORMS; do
    echo "===== Processing platform: $platform ====="
    mkdir -p "$platform"

    sd_arch="$(get_smartdns_arch "$platform")"
    echo "SmartDNS architecture: $sd_arch"

    smartdns_file="$(printf '%s' "$api_json" | jq -r ".assets[] | select(.name | test(\"smartdns\\\\..*\\\\.${sd_arch}-openwrt-all\\\\.ipk$\")) | .name" | head -1)"
    if [ -n "$smartdns_file" ] && [ "$smartdns_file" != "null" ]; then
        echo "Found smartdns: $smartdns_file"
        safe_download "https://github.com/$REPO/releases/download/$tag/$smartdns_file" \
            "${platform}/${smartdns_file}"
    else
        echo "Error: smartdns IPK not found for $sd_arch"
        exit 1
    fi

    echo "=== $platform download completed ==="
    ls -lh "$platform/"
    echo ""
done

luci_file="$(printf '%s' "$api_json" | jq -r '.assets[] | select(.name | test("luci-app-smartdns\\\\..*\\\\.all-luci-all\\\\.ipk$")) | .name' | head -1)"
if [ -n "$luci_file" ] && [ "$luci_file" != "null" ]; then
    echo "Found luci-app-smartdns: $luci_file"
    for platform in $PLATFORMS; do
        safe_download "https://github.com/$REPO/releases/download/$tag/$luci_file" \
            "${platform}/${luci_file}"
    done
else
    echo "Error: luci-app-smartdns IPK not found"
    exit 1
fi

version="$(echo "$luci_file" | sed -n 's/^luci-app-smartdns\.\(.*\)\.all-luci-all\.ipk$/\1/p')"
if [ -n "$version" ]; then
    echo "$version" > /tmp/smartdns_version.txt
    echo "Version: $version"
fi

echo "===== All done ====="
