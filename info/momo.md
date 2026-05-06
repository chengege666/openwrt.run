# Momo .run

- 来源：[nikkinikki-org/OpenWrt-momo](https://github.com/nikkinikki-org/OpenWrt-momo)
- 包含软件包：`sing-box`、`momo`、`luci-app-momo`
- 支持架构：`x86_64`、`aarch64_generic`、`aarch64_cortex-a53`
- 运行要求：OpenWrt 或 ImmortalWrt `24.10+`、`firewall4`、Linux 内核 `5.13+`

## 功能

- **代理工具**：基于 sing-box 核心的代理工具
- **规则路由**：支持智能规则路由和分流
- **LuCI 界面**：提供友好的 Web 管理界面
- **多协议**：支持多种代理协议

## 安装步骤

### 通过 SSH 安装

**1. 上传安装包**

方式 A - 使用 SCP（推荐）：
```bash
# x86_64 设备
scp luci-app-momo-*_x86_64.run root@192.168.1.1:/tmp/

# aarch64 设备
scp luci-app-momo-*_aarch64_generic.run root@192.168.1.1:/tmp/
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
chmod +x luci-app-momo-*.run
```

**4. 执行安装**
```bash
./luci-app-momo-*.run
```

**5. 等待安装完成**
- 安装过程会自动解压并安装插件
- 看到安装成功提示后继续下一步

**6. 刷新 LuCI 界面**
- 退出并重新登录 LuCI
- 在 **服务** 菜单下找到 **Momo** 入口

## 验证安装

**检查是否安装成功**：
```bash
opkg list-installed | grep momo
```

**查看服务状态**：
```bash
/etc/init.d/momo status
```

**访问界面**：
- 在 LuCI 菜单中找到 **服务 -> Momo** 入口

## 使用方法

**1. 打开 Momo 设置界面**
- 登录 LuCI 管理界面
- 找到 **服务 -> Momo** 菜单项

**2. 基本配置**
- **订阅链接**：添加代理订阅地址
- **运行模式**：选择代理模式（规则/全局/直连）
- **监听端口**：设置代理监听端口

**3. 节点选择**
- 在节点列表中选择可用节点
- 测试节点延迟
- 设置自动切换

**4. 保存并应用**
- 点击 **保存并应用**
- 重启 Momo 服务使配置生效

## 常见问题

### Q1: 安装后 LuCI 界面没有 Momo 菜单？
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
1. 确认 Momo 服务已启动
2. 检查防火墙规则是否正确
3. 查看日志：`logread | grep momo`

### Q4: 如何卸载 Momo？
**A**: 
```bash
opkg remove luci-app-momo
opkg remove momo
opkg remove sing-box
```

## 注意事项

- **内核要求**：需要 Linux 内核 5.13+ 和 firewall4
- **订阅更新**：定期更新订阅以获取最新节点
- **资源占用**：代理工具会占用一定系统资源

## 相关链接

- 项目主页：https://github.com/nikkinikki-org/OpenWrt-momo
