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

[ -d "$SCRIPT_DIR/depends" ] || fail "未找到 depends 目录，安装包可能不完整。"
ls "$SCRIPT_DIR"/*.ipk >/dev/null 2>&1 || fail "未找到 PassWall2 主程序包。"

log "正在更新软件源..."
opkg update

log "正在安装 PassWall2 依赖包..."
opkg install "$SCRIPT_DIR/depends"/*.ipk --force-depends || echo "警告：部分依赖包安装失败，继续尝试安装主程序..."

log "正在安装 PassWall2 主程序..."
opkg install "$SCRIPT_DIR"/*.ipk --force-depends || fail "PassWall2 安装失败。"

if ! opkg list-installed | grep -q '^luci-app-passwall2 '; then
    fail "未检测到 luci-app-passwall2 已安装。"
fi

log "刷新 LuCI 缓存..."
rm -rf /tmp/luci-modulecache /tmp/luci-indexcache

log "重启相关服务..."
/etc/init.d/uhttpd restart 2>/dev/null || /etc/init.d/nginx restart 2>/dev/null
/etc/init.d/rpcd restart 2>/dev/null

if [ -f /usr/share/luci/menu.d/luci-app-passwall2.json ] || [ -f /usr/lib/lua/luci/controller/passwall2.lua ]; then
    log "已检测到 LuCI 入口文件。"
else
    echo "警告：未检测到 LuCI 入口文件，请手动刷新页面并检查“服务”菜单。"
fi

log "安装完成，请在 LuCI 中打开 PassWall2 继续配置。"
