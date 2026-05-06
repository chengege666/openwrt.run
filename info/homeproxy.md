# HomeProxy .run

- 来源：`https://dl.openwrt.ai/packages-24.10/<arch>/kiddin9/`
- 包含软件包：`luci-app-homeproxy`、`sing-box`
- 支持架构：`x86_64`、`aarch64_generic`、`aarch64_cortex-a53`
- 运行要求：OpenWrt 或 ImmortalWrt `23.05+`、`firewall4`、Linux 内核 `5.10+`

## 功能

- **多协议支持**：基于 sing-box 核心，支持多种代理协议
- **智能分流**：支持规则分流和全局代理模式
- **TUN 模式**：支持 TUN 模式实现透明代理
- **LuCI 界面**：提供友好的 Web 管理界面

## 安装步骤

### 通过 SSH 安装

**1. 上传安装包**

方式 A - 使用 SCP（推荐）：
```bash
# x86_64 设备
scp luci-app-homeproxy-*_x86_64.run root@192.168.1.1:/tmp/

# aarch64 设备
scp luci-app-homeproxy-*_aarch64_generic.run root@192.168.1.1:/tmp/
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
chmod +x luci-app-homeproxy-*.run
```

**4. 执行安装**
```bash
./luci-app-homeproxy-*.run
```

**5. 等待安装完成**
- 安装过程会自动解压并安装插件
- 服务会自动启用
- 看到安装成功提示后继续下一步

**6. 刷新 LuCI 界面**
- 退出并重新登录 LuCI
- 在 **服务** 菜单下找到 **HomeProxy** 入口

## 验证安装

**检查是否安装成功**：
```bash
opkg list-installed | grep homeproxy
```

**查看服务状态**：
```bash
/etc/init.d/homeproxy status
```

**访问界面**：
- 在 LuCI 菜单中找到 **服务 -> HomeProxy** 入口

## 使用方法

**1. 打开 HomeProxy 设置界面**
- 登录 LuCI 管理界面
- 找到 **服务 -> HomeProxy** 菜单项

**2. 基本配置**
- **运行模式**：选择代理模式（规则/全局/直连）
- **节点设置**：添加代理节点信息
- **端口设置**：配置本地监听端口

**3. 高级配置**
- **TUN 设置**：启用 TUN 模式实现透明代理
- **DNS 设置**：配置 DNS 解析方式
- **路由规则**：设置分流规则

**4. 保存并应用**
- 点击 **保存并应用**
- 重启 HomeProxy 服务使配置生效

## 常见问题

### Q1: 安装后 LuCI 界面没有 HomeProxy 菜单？
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
1. 确认 HomeProxy 服务已启动
2. 检查防火墙规则是否正确
3. 查看日志：`logread | grep homeproxy`

### Q4: 如何卸载 HomeProxy？
**A**: 
```bash
opkg remove luci-app-homeproxy
opkg remove sing-box
```

## 注意事项

- **内核要求**：需要 Linux 内核 `5.10+` 支持
- **防火墙**：需要 `firewall4` 支持
- **资源占用**：代理工具会占用一定系统资源

## 相关链接

- 项目主页：https://github.com/immortalwrt/homeproxy
