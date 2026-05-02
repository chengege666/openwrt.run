#!/bin/sh
set -e

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"

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

    echo "警告：未能自动安装依赖 $pkg，请确认当前软件源可用。"
    return 0
}

ls "$SCRIPT_DIR"/*.ipk >/dev/null 2>&1 || fail "未找到 Nikki 安装包。"

log "正在更新软件源..."
opkg update

log "正在安装 Nikki 运行时依赖..."
install_optional_pkg firewall4
install_optional_pkg kmod-nft-tproxy
install_optional_pkg kmod-nft-socket
install_optional_pkg kmod-tun
install_optional_pkg kmod-inet-diag

log "正在安装本地 ipk 包..."
opkg install "$SCRIPT_DIR"/*.ipk || fail "Nikki 安装失败，请检查系统版本是否为 OpenWrt 24.10+，以及依赖源是否完整。"

if ! opkg list-installed | grep -q '^luci-app-nikki '; then
    fail "未检测到 luci-app-nikki 已安装。"
fi

log "刷新 LuCI 缓存..."
rm -rf /tmp/luci-modulecache /tmp/luci-indexcache

log "重启相关服务..."
/etc/init.d/uhttpd restart 2>/dev/null || /etc/init.d/nginx restart 2>/dev/null
/etc/init.d/rpcd restart 2>/dev/null

if [ -f /usr/share/luci/menu.d/luci-app-nikki.json ] || [ -f /usr/lib/lua/luci/controller/nikki.lua ]; then
    log "已检测到 LuCI 入口文件。"
else
    echo "警告：未检测到传统 LuCI 入口文件，请手动刷新页面并检查“服务”菜单。"
fi

log "安装完成，请在 LuCI 中打开 Nikki 继续配置。"
