# Daed .run

- 来源: `https://github.com/QiuSimons/luci-app-daed/releases`
- 打包内容: `daed`（核心）、`luci-app-daed`（LuCI 界面）、`luci-i18n-daed-zh-cn`（中文翻译）
- 支持架构: `x86_64`、`aarch64_generic`、`aarch64_cortex-a53`
- 运行环境: OpenWrt 或 ImmortalWrt `23.05+`

## 使用方法

将生成的 `.run` 文件上传到路由器的 `/tmp` 目录，然后执行：

```sh
chmod +x /tmp/daed-*.run
/tmp/daed-*.run
```

安装完成后，在 LuCI 的「服务」菜单中找到 Daed 即可配置。
