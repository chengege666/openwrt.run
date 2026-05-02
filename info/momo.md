# Momo .run

- Source repo: [nikkinikki-org/OpenWrt-momo](https://github.com/nikkinikki-org/OpenWrt-momo)
- Source feed: `https://dl.openwrt.ai/packages-24.10/<arch>/kiddin9/`
- Included packages: `sing-box`, `momo`, `luci-app-momo`
- Supported architectures: `x86_64`, `aarch64_generic`, `aarch64_cortex-a53`
- Runtime requirements: OpenWrt or ImmortalWrt `24.10+`, `firewall4`, Linux kernel `5.13+`

## Usage

Upload the generated `.run` file to `/tmp` and execute:

```sh
chmod +x /tmp/luci-app-momo-*.run
/tmp/luci-app-momo-*.run
```
