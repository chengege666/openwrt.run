#!/bin/sh
set -e

PASSWALL_FEEDS="passwall_luci passwall_packages passwall2"
CUSTOMFEEDS="/etc/opkg/customfeeds.conf"
KEY_TMP="/tmp/passwall-ipk.pub"

log() {
    echo "===> $*"
}

fail() {
    echo "错误：$*" >&2
    exit 1
}

install_optional_pkg() {
    pkg="$1"

    if opkg list-installed | grep -q "^$pkg "; then
        log "已安装依赖: $pkg"
        return 0
    fi

    if opkg install "$pkg"; then
        log "已安装依赖: $pkg"
        return 0
    fi

    echo "警告：未能自动安装依赖 $pkg，请确认当前软件源是否提供该包。"
    return 0
}

download_passwall_key() {
    rm -f "$KEY_TMP"

    if wget -O "$KEY_TMP" "https://master.dl.sourceforge.net/project/openwrt-passwall-build/ipk.pub"; then
        return 0
    fi

    if wget -O "$KEY_TMP" "https://master.dl.sourceforge.net/project/openwrt-passwall-build/passwall.pub"; then
        return 0
    fi

    fail "Passwall 公钥下载失败。"
}

prepare_passwall_feeds() {
    local base_url temp_file feed

    [ -n "$1" ] || fail "未提供 Passwall feed 地址。"
    base_url="$1"
    temp_file="/tmp/customfeeds.passwall.$$"

    touch "$CUSTOMFEEDS"
    grep -v 'openwrt-passwall-build' "$CUSTOMFEEDS" > "$temp_file" || true

    for feed in $PASSWALL_FEEDS; do
        echo "src/gz $feed $base_url/$feed" >> "$temp_file"
    done

    cat "$temp_file" > "$CUSTOMFEEDS"
    rm -f "$temp_file"
}

install_dnsmasq_full() {
    if opkg list-installed | grep -q '^dnsmasq-full '; then
        log "已安装 dnsmasq-full"
        return 0
    fi

    if opkg list-installed | grep -q '^dnsmasq '; then
        log "检测到 dnsmasq，准备替换为 dnsmasq-full..."
        opkg remove dnsmasq || fail "无法移除 dnsmasq，请手动处理后重试。"
    fi

    opkg install dnsmasq-full || fail "dnsmasq-full 安装失败。"
}

restart_luci_services() {
    log "刷新 LuCI 缓存..."
    rm -rf /tmp/luci-modulecache /tmp/luci-indexcache

    log "重启 Web 服务..."
    /etc/init.d/uhttpd restart 2>/dev/null || /etc/init.d/nginx restart 2>/dev/null || true
    /etc/init.d/rpcd restart 2>/dev/null || true
    /etc/init.d/dnsmasq restart 2>/dev/null || true
}

[ -x /bin/opkg ] || fail "当前系统未检测到 opkg，不适用于此安装器。"
[ -r /etc/openwrt_release ] || fail "未找到 /etc/openwrt_release，无法识别系统版本。"

. /etc/openwrt_release

ARCH="$DISTRIB_ARCH"
RELEASE="${DISTRIB_RELEASE%.*}"

[ -n "$ARCH" ] || fail "无法识别系统架构。"

case "$DISTRIB_RELEASE" in
    SNAPSHOT*|*SNAPSHOT*)
        FEED_BASE="https://master.dl.sourceforge.net/project/openwrt-passwall-build/snapshots/packages/$ARCH"
        ;;
    *)
        [ -n "$RELEASE" ] || fail "无法识别系统版本号。"
        FEED_BASE="https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$RELEASE/$ARCH"
        ;;
esac

log "正在导入 Passwall 软件源公钥..."
download_passwall_key
opkg-key add "$KEY_TMP" || fail "Passwall 公钥导入失败。"
rm -f "$KEY_TMP"

log "正在写入 Passwall 软件源..."
prepare_passwall_feeds "$FEED_BASE"

log "正在更新软件源..."
opkg update

log "正在安装基础依赖..."
install_dnsmasq_full
install_optional_pkg unzip
install_optional_pkg ipset
install_optional_pkg kmod-nft-tproxy
install_optional_pkg kmod-nft-socket
install_optional_pkg iptables-mod-tproxy
install_optional_pkg iptables-mod-socket
install_optional_pkg iptables-mod-iprange
install_optional_pkg iptables-mod-conntrack-extra

log "正在安装 Passwall..."
opkg install luci-app-passwall || fail "luci-app-passwall 安装失败，请检查软件源与系统版本是否匹配。"
install_optional_pkg luci-i18n-passwall-zh-cn

if ! opkg list-installed | grep -q '^luci-app-passwall '; then
    fail "未检测到 luci-app-passwall 已安装。"
fi

restart_luci_services

if [ -f /usr/share/luci/menu.d/luci-app-passwall.json ] || [ -f /usr/lib/lua/luci/controller/passwall.lua ]; then
    log "已检测到 LuCI 入口文件。"
else
    echo "警告：未检测到传统 LuCI 入口文件，请手动刷新页面并检查“服务”菜单。"
fi

log "安装完成，请在 LuCI 中打开 Passwall 继续配置。"
