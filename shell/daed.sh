#!/bin/sh
set -e

REPO="QiuSimons/luci-app-daed"
PLATFORMS="x86_64 aarch64_generic aarch64_cortex-a53"
FALLBACK_MAP="aarch64_cortex-a53:aarch64_generic"

safe_download() {
    url="$1"
    output="$2"
    echo "下载: $url"
    curl -L --fail --connect-timeout 15 --max-time 120 "$url" -o "$output" -#
    if [ ! -s "$output" ]; then
        echo "错误: 下载失败或文件为空: $output"
        exit 1
    fi
    echo "成功: $(ls -lh "$output" | awk '{print $5}')"
}

get_fallback() {
    for pair in $FALLBACK_MAP; do
        src="${pair%%:*}"
        dst="${pair##*:}"
        [ "$src" = "$1" ] && echo "$dst" && return
    done
    echo "$1"
}

echo "===== 获取最新 Release 信息: $REPO ====="
api_json="$(curl -fsSL --connect-timeout 15 "https://api.github.com/repos/$REPO/releases/latest")"
if [ -z "$api_json" ]; then
    echo "错误: 无法获取 Release 信息，API 返回为空"
    exit 1
fi

tag="$(printf '%s' "$api_json" | jq -r '.tag_name')"
if [ -z "$tag" ] || [ "$tag" = "null" ]; then
    echo "错误: 无法解析 tag_name"
    exit 1
fi
echo "最新 tag: $tag"

version="${tag#daed_}"
echo "版本号: $version"

# 列出所有可用 ipk 资产
echo ""
echo "可用的 ipk 文件:"
printf '%s' "$api_json" | jq -r '.assets[] | select(.name | test("\\.ipk$")) | .name'

echo ""

for platform in $PLATFORMS; do
    echo "===== 处理平台: $platform ====="
    mkdir -p "$platform/depends"

    arch="$(get_fallback "$platform")"
    echo "实际架构: $arch"

    # daed 二进制（架构相关）
    prog_file="daed_${version}_${arch}-openwrt-24.10.ipk"
    safe_download "https://github.com/$REPO/releases/download/$tag/$prog_file" \
        "${platform}/depends/$prog_file"

    # luci-app-daed（all 架构）
    luci_file="$(printf '%s' "$api_json" | jq -r '.assets[] | select(.name | test("luci-app-daed_.*_all-openwrt-24\\.10\\.ipk$")) | .name' | head -1)"
    if [ -n "$luci_file" ] && [ "$luci_file" != "null" ]; then
        echo "找到 luci-app-daed: $luci_file"
        safe_download "https://github.com/$REPO/releases/download/$tag/$luci_file" \
            "${platform}/depends/$luci_file"
    else
        echo "错误: 未找到 luci-app-daed ipk"
        exit 1
    fi

    # luci-i18n-daed-zh-cn（all 架构）— 中文翻译
    i18n_file="$(printf '%s' "$api_json" | jq -r '.assets[] | select(.name | test("luci-i18n-daed-zh-cn_.*_all-openwrt-24\\.10\\.ipk$")) | .name' | head -1)"
    if [ -n "$i18n_file" ] && [ "$i18n_file" != "null" ]; then
        echo "找到中文包: $i18n_file"
        safe_download "https://github.com/$REPO/releases/download/$tag/$i18n_file" \
            "${platform}/depends/$i18n_file"
    else
        echo "错误: 未找到中文翻译包 luci-i18n-daed-zh-cn"
        exit 1
    fi

    echo "=== $platform 下载完成 ==="
    ls -lh "$platform/depends/"
    echo ""
done

echo "$version" > /tmp/daed_version.txt
echo "===== 全部完成 ====="
