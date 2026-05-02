# HomeProxy .run

- Source feed: `https://dl.openwrt.ai/packages-24.10/<arch>/kiddin9/`
- Included packages: `luci-app-homeproxy` and `sing-box`
- Supported architectures: `x86_64`, `aarch64_generic`, `aarch64_cortex-a53`
- Runtime requirements: OpenWrt or ImmortalWrt `23.05+`, `firewall4`, Linux kernel `5.10+`

## Usage

Upload the generated `.run` file to `/tmp` and execute:

```sh
chmod +x /tmp/luci-app-homeproxy-*.run
/tmp/luci-app-homeproxy-*.run
```
