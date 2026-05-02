#!/bin/sh

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

install_local_ipk() {
    pkg_file="$1"
    pkg_name="$(basename "$pkg_file")"

    if opkg list-installed | grep -q "^$(echo "$pkg_name" | sed 's/_.*//') "; then
        log "已安装: $pkg_name"
        return 0
    fi

    log "安装: $pkg_name"
    opkg install "$pkg_file"
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
for pkg_pattern in mihomo-meta nikki luci-app-nikki; do
    found=0
    for pkg_file in "$SCRIPT_DIR"/${pkg_pattern}_*.ipk; do
        [ -f "$pkg_file" ] || continue
        found=1
        install_local_ipk "$pkg_file" || echo "警告：包 $(basename "$pkg_file") 安装未完全成功，继续下一个。"
    done
    [ "$found" -eq 1 ] || fail "缺少关键安装包: ${pkg_pattern}_*.ipk"
done

for pkg_file in "$SCRIPT_DIR"/*.ipk; do
    base_name="$(basename "$pkg_file")"
    case "$base_name" in
        mihomo-meta_*|nikki_*|luci-app-nikki_*)
            continue
            ;;
    esac
    install_local_ipk "$pkg_file" || echo "警告：包 $(basename "$pkg_file") 安装未完全成功，继续下一个。"
done

log "验证安装结果..."
INSTALL_FAIL=0
for pkg_pattern in mihomo-meta nikki luci-app-nikki; do
    if opkg list-installed | grep -q "^$pkg_pattern"; then
        log "已检测到: $pkg_pattern"
    else
        echo "错误：未检测到 $pkg_pattern，安装失败。"
        INSTALL_FAIL=1
    fi
done

[ "$INSTALL_FAIL" -eq 0 ] || fail "Nikki 关键组件未全部安装成功。"

log "刷新 LuCI 缓存..."
rm -rf /tmp/luci-modulecache /tmp/luci-indexcache

log "重启相关服务..."
/etc/init.d/uhttpd restart 2>/dev/null || /etc/init.d/nginx restart 2>/dev/null
/etc/init.d/rpcd restart 2>/dev/null

if [ -f /usr/share/luci/menu.d/luci-app-nikki.json ] || [ -f /usr/lib/lua/luci/controller/nikki.lua ]; then
    log "已检测到 LuCI 入口文件。"
else
    echo "警告：未检测到传统 LuCI 入口文件，请手动刷新页面并检查"服务"菜单。"
fi

log "安装完成，请在 LuCI 中打开 Nikki 继续配置。"
