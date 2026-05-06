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

cd "$SCRIPT_DIR"

log "正在更新软件源..."
opkg update

log "正在安装 SmartDNS..."
for ipk in *.ipk; do
    [ -f "$ipk" ] || continue
    opkg install "$ipk" --force-depends
done

if ! opkg list-installed | grep -q 'luci-app-smartdns'; then
    fail "未检测到 luci-app-smartdns 已安装。"
fi

log "启用 SmartDNS 服务..."
/etc/init.d/smartdns enable 2>/dev/null || true

log "刷新 LuCI 缓存..."
rm -rf /tmp/luci-modulecache /tmp/luci-indexcache

log "重启相关服务..."
/etc/init.d/uhttpd restart 2>/dev/null || /etc/init.d/nginx restart 2>/dev/null
/etc/init.d/rpcd restart 2>/dev/null

log "安装完成，请在 LuCI 中打开 SmartDNS 继续配置。"
