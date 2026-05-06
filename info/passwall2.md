# PassWall2 .run

- 来源：[Openwrt-Passwall/openwrt-passwall2](https://github.com/Openwrt-Passwall/openwrt-passwall2)
- 包含软件包：`luci-app-passwall2`、`luci-i18n-passwall2-zh-cn` 及完整依赖包
- 支持架构：`x86_64`、`aarch64_cortex-a53`、`aarch64_generic`
- 运行要求：OpenWrt 或 ImmortalWrt `23.05+`

## 功能

- **多协议支持**：支持 V2Ray、Trojan、Shadowsocks、Hysteria 等主流协议
- **智能分流**：支持 GFW 列表、中国大陆列表等分流规则
- **节点管理**：支持节点订阅、测速、自动切换
- **LuCI 界面**：提供友好的 Web 管理界面

## 安装步骤

### 通过 SSH 安装

**1. 上传安装包**

方式 A - 使用 SCP（推荐）：
```bash
# x86_64 设备
scp luci-app-passwall2-*_x86_64.run root@192.168.1.1:/tmp/

# aarch64 设备
scp luci-app-passwall2-*_aarch64_cortex-a53.run root@192.168.1.1:/tmp/
```

方式 B - 使用 WinSCP/FileZilla：
- 连接路由器（协议：SCP，端口：22）
- 将对应的 `.run` 文件上传到 `/tmp/` 目录

**注意**：不要使用 LuCI 的"上传软件包"功能，`.run` 文件不是 IPK 包！

**2. 进入临时目录**
```bash
cd /tmp
```

**3. 添加执行权限**
```bash
chmod +x luci-app-passwall2-*.run
```

**4. 执行安装**
```bash
./luci-app-passwall2-*.run
```

**5. 等待安装完成**
- 安装过程会自动解压并安装插件和依赖
- 服务会自动启用
- 看到安装成功提示后继续下一步

**6. 刷新 LuCI 界面**
- 退出并重新登录 LuCI
- 在 **服务** 菜单下找到 **PassWall2** 入口

## 验证安装

**检查是否安装成功**：
```bash
opkg list-installed | grep passwall2
```

**查看服务状态**：
```bash
/etc/init.d/passwall2 status
```

**访问界面**：
- 在 LuCI 菜单中找到 **服务 -> PassWall2** 入口

## 使用方法

**1. 打开 PassWall2 设置界面**
- 登录 LuCI 管理界面
- 找到 **服务 -> PassWall2** 菜单项

**2. 基本配置**
- **运行模式**：选择代理模式（GFW 列表/全局/绕过中国大陆）
- **节点设置**：添加或导入代理节点
- **订阅管理**：配置节点订阅链接

**3. 高级配置**
- **DNS 设置**：配置 DNS 解析方式
- **访问控制**：设置代理规则和例外
- **负载均衡**：配置多节点负载均衡

**4. 保存并应用**
- 点击 **保存并应用**
- 重启 PassWall2 服务使配置生效

## 常见问题

### Q1: 安装后 LuCI 界面没有 PassWall2 菜单？
**A**: 这是 LuCI 缓存问题，请：
1. 退出 LuCI 登录
2. 清除浏览器缓存
3. 重新登录即可

### Q2: 如何确认我的设备架构？
**A**: 通过 SSH 执行以下命令：
```bash
uname -m
```
- 输出 `x86_64` 选择 x86_64 版本
- 输出 `aarch64` 选择 aarch64 版本

### Q3: 代理不生效？
**A**: 检查以下几点：
1. 确认 PassWall2 服务已启动
2. 检查节点是否可用
3. 查看日志：`logread | grep passwall2`

### Q4: 如何卸载 PassWall2？
**A**: 
```bash
opkg remove luci-app-passwall2
opkg remove luci-i18n-passwall2-zh-cn
```

## 注意事项

- **依赖完整**：安装包已包含所有必需依赖
- **节点管理**：建议定期更新订阅获取最新节点
- **资源占用**：代理工具会占用一定系统资源

## 相关链接

- 项目主页：https://github.com/Openwrt-Passwall/openwrt-passwall2
