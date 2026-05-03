# SSR-Plus .run

- Source feed: `https://dl.openwrt.ai/packages-24.10/<arch>/kiddin9/`
- Included packages: `luci-app-ssr-plus` + full dependency set (shadowsocks-rust, shadowsocksr-libev, xray-core, trojan, hysteria, naiveproxy, etc.)
- Supported architectures: `x86_64`, `aarch64_cortex-a53`
- Runtime requirements: OpenWrt or ImmortalWrt `23.05+`

## Usage

Upload the generated `.run` file to `/tmp` and execute:

```sh
chmod +x /tmp/ssrp_*.run
/tmp/ssrp_*.run
```
