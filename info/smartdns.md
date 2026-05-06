# SmartDNS .run

- 来源：`https://github.com/pymumu/smartdns/releases`
- 包含软件包：`luci-app-smartdns`、`smartdns`
- 支持架构：`x86_64`、`aarch64_generic`、`aarch64_cortex-a53`
- 运行要求：OpenWrt 或 ImmortalWrt `22.03+`

## 功能

- **DNS 加速**：多线程并发查询，提升 DNS 解析速度
- **智能分流**：支持国内外 DNS 分流，优化访问体验
- **去广告**：内置广告过滤功能
- **LuCI 界面**：提供友好的 Web 管理界面

## 安装步骤

### 通过 SSH 安装

**1. 上传安装包**

方式 A - 使用 SCP（推荐）：
```bash
# x86_64 设备
scp luci-app-smartdns-*_x86_64.run root@192.168.1.1:/tmp/

# aarch64 设备
scp luci-app-smartdns-*_aarch64_generic.run root@192.168.1.1:/tmp/
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
chmod +x luci-app-smartdns-*.run
```

**4. 执行安装**
```bash
./luci-app-smartdns-*.run
```

**5. 等待安装完成**
- 安装过程会自动解压并安装插件
- 服务会自动启用
- 看到安装成功提示后继续下一步

**6. 刷新 LuCI 界面**
- 退出并重新登录 LuCI
- 在 **服务** 菜单下找到 **SmartDNS** 入口

## 验证安装

**检查是否安装成功**：
```bash
opkg list-installed | grep smartdns
```

**查看服务状态**：
```bash
/etc/init.d/smartdns status
```

**访问界面**：
- 在 LuCI 菜单中找到 **服务 -> SmartDNS** 入口

## 使用方法

**1. 打开 SmartDNS 设置界面**
- 登录 LuCI 管理界面
- 找到 **服务 -> SmartDNS** 菜单项

**2. 基本配置**
- **监听端口**：默认 53，可自定义
- **上游服务器**：添加 DNS 上游服务器地址
- **分流规则**：配置国内外 DNS 分流

**3. 高级配置**
- **缓存设置**：调整 DNS 缓存大小
- **去广告**：启用广告过滤功能
- **测速**：启用 DNS 测速优化

**4. 保存并应用**
- 点击 **保存并应用**
- 重启 SmartDNS 服务使配置生效

## 常见问题

### Q1: 安装后 LuCI 界面没有 SmartDNS 菜单？
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

### Q3: DNS 解析不生效？
**A**: 检查以下几点：
1. 确认 SmartDNS 服务已启动
2. 检查防火墙是否放行 53 端口
3. 查看日志：`logread | grep smartdns`

### Q4: 如何卸载 SmartDNS？
**A**: 
```bash
opkg remove luci-app-smartdns
opkg remove smartdns
```

## 注意事项

- **端口冲突**：确保 53 端口未被其他 DNS 服务占用
- **上游服务器**：建议配置多个上游服务器提高稳定性
- **缓存大小**：根据设备内存调整缓存大小

## 相关链接

- 项目主页：https://github.com/pymumu/smartdns
