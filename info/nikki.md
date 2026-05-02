# Nikki .run

- Source repo: [nikkinikki-org/OpenWrt-nikki](https://github.com/nikkinikki-org/OpenWrt-nikki)
- Source feed: `https://dl.openwrt.ai/packages-24.10/<arch>/kiddin9/`
- Included packages: `mihomo`, `nikki`, `luci-app-nikki`
- Supported architectures: `x86_64`, `aarch64_generic`, `aarch64_cortex-a53`
- Runtime requirements: OpenWrt or ImmortalWrt `24.10+`, `firewall4`, Linux kernel `5.13+`

## Usage

Upload the generated `.run` file to `/tmp` and execute:

```sh
chmod +x /tmp/luci-app-nikki-*.run
/tmp/luci-app-nikki-*.run
```
