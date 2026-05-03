# openwrt.run

一个用于生成 OpenWrt `.run` 自解压安装包的仓库。

仓库通过 `GitHub Actions` 自动拉取上游插件、主题或核心文件，再使用 `makeself` 打包成可直接在路由器上执行的 `.run` 文件，方便在 `OpenWrt` 或 `ImmortalWrt` 上离线安装。

## 仓库用途

- 自动构建常用 OpenWrt 插件的 `.run` 安装包
- 将多文件安装过程封装成单个可执行文件
- 尽量在安装阶段自动处理依赖、LuCI 缓存和 Web 服务刷新
- 适合没有完整软件源、需要手动上传安装包的场景

## 当前支持

| 项目 | 工作流 | 输出类型 | 说明 |
| --- | --- | --- | --- |
| `HomeProxy` | `.github/workflows/homeproxy.yml` | 多架构 `.run` | 下载 `luci-app-homeproxy` 及相关依赖并打包 |
| `Nikki` | `.github/workflows/nikki.yml` | 多架构 `.run` | 校验 `mihomo-meta`、`nikki`、`luci-app-nikki` 后打包 |
| `Momo` | `.github/workflows/momo.yml` | 多架构 `.run` | 校验 `momo`、`luci-app-momo` 后打包 |
| `Passwall` | `.github/workflows/Passwall.yml` | 安装器 `.run` | 运行时写入官方 feed，再安装 `luci-app-passwall` |
| `MosDNS` | `.github/workflows/mosdns.yml` | `.run` | 打包 `mosdns`、`v2dat`、`luci-app-mosdns` 等文件 |
| `OpenClash` | `.github/workflows/openclash.yml` | `.run` | 拉取 OpenClash 包与核心后打包 |
| `AdGuardHome` | `.github/workflows/adg.yml` | `.run` | 打包 LuCI 插件与官方核心 |
| `SSR-Plus` | `.github/workflows/ssrp.yml` | 多架构 `.run` | 下载 `luci-app-ssr-plus` 并打包 |
| `Argon Theme` | `.github/workflows/Argon.yml` | `.run` | 打包纯主题安装包 |

## 目录结构

```text
.
├─ .github/workflows/   GitHub Actions 工作流
├─ info/                Release 说明模板
├─ shell/               下载脚本与路由器端安装脚本
└─ README.md            仓库说明
```

## 构建方式

### 1. 手动触发工作流

1. 打开仓库的 `Actions`
2. 选择需要构建的工作流
3. 点击 `Run workflow`
4. 等待工作流完成
5. 在对应的 `Release` 中下载生成的 `.run` 文件

### 2. 工作流的大致流程

1. 拉取上游插件、主题或核心文件
2. 按架构整理目录
3. 放入对应的 `install.sh`
4. 使用 `makeself` 生成 `.run`
5. 上传到 `GitHub Release`

## 路由器端安装

大多数 `.run` 文件的使用方式如下：

```sh
chmod +x /tmp/*.run
/tmp/xxx.run
```

更常见的实际操作方式：

```sh
cd /tmp
chmod +x luci-app-*.run
./luci-app-*.run
```

安装完成后，建议执行以下操作确认 LuCI 菜单已经刷新：

```sh
rm -rf /tmp/luci-modulecache /tmp/luci-indexcache
/etc/init.d/rpcd restart
/etc/init.d/uhttpd restart 2>/dev/null || /etc/init.d/nginx restart 2>/dev/null
```

## 已实现的脚本约定

- `shell/*.sh` 主要负责下载、整理或校验构建文件
- `shell/*-install.sh` 主要负责路由器端安装逻辑
- `info/*.md` 用作对应 `Release` 的说明内容
- 多架构项目通常输出到 `x86_64`、`aarch64_generic`、`aarch64_cortex-a53`

## 当前仓库特点

- `Nikki` 已改为从官方 feed 页面抓取所需包，并在打包前校验关键依赖
- `Momo` 已切换到当前可用的 feed 源，并在工作流中校验关键包是否存在
- `Passwall` 当前采用“安装器模式”，不再打包失效的旧 IPK，而是在路由器上写入 feed 后直接安装
- `HomeProxy` 使用独立下载脚本和通用安装脚本

## 注意事项

- 不同插件对 `OpenWrt` 版本、内核版本和 `firewall4` 依赖不同
- 某些上游项目会变更发布方式，工作流可能需要同步调整
- 部分项目为多架构输出，部分项目目前仅提供单架构包
- 若安装后 LuCI 中没有菜单，优先检查包是否真的安装成功，再清缓存

## 建议

- 构建失败时，优先查看工作流日志中的“缺少关键安装包”或下载链接报错
- 路由器安装失败时，优先保存 `opkg` 输出日志
- 如果上游改版，优先修复 `shell/` 中的下载逻辑，再调整工作流

## 许可与说明

本仓库主要用于整理和分发自动构建流程，本身不维护上游插件源码。各插件、主题和核心文件的版权与许可归各自原项目所有。
