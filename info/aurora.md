# Aurora .run

- 来源：`https://github.com/eamonxg/luci-theme-aurora/releases`
- 包含软件包：`luci-theme-aurora`
- 支持架构：`all`（与架构无关）
- 运行要求：OpenWrt 或 ImmortalWrt `22.03+`

## 功能

- 现代化 LuCI 主题界面，支持亮色/暗色模式
- 毛玻璃效果、自定义背景、主题色设置
- 丰富的自定义配置选项

## 安装步骤

### 通过 SSH 安装

**1. 上传安装包**

方式 A - 使用 SCP（推荐）：
```bash
scp luci-theme-aurora_*.run root@192.168.1.1:/tmp/
```

方式 B - 使用 WinSCP/FileZilla：
- 连接路由器（协议：SCP，端口：22）
- 将 `luci-theme-aurora_*.run` 文件上传到 `/tmp/` 目录

**注意**：不要使用 LuCI 的"上传软件包"功能，`.run` 文件不是 IPK 包！

**2. 进入临时目录**
```bash
cd /tmp
```

**3. 添加执行权限**
```bash
chmod +x luci-theme-aurora_*.run
```

**4. 执行安装**
```bash
./luci-theme-aurora_*.run
```

**5. 等待安装完成**
- 安装过程会自动解压并安装主题
- 看到安装成功提示后继续下一步

**6. 刷新 LuCI 界面**
- 退出并重新登录 LuCI
- 在 **系统 -> 系统** 页面选择 Aurora 主题

## 验证安装

**检查是否安装成功**：
```bash
opkg list-installed | grep aurora
```

**查看主题文件**：
```bash
ls /www/luci-static/aurora/
```

**应用主题**：
- 登录 LuCI 管理界面
- 进入 **系统 -> 系统** 页面
- 在 **主题** 下拉框中选择 `aurora`
- 点击 **保存并应用**

## 常见问题

### Q1: 安装后 LuCI 界面没有变化？
**A**: 需要手动切换主题：
1. 进入 **系统 -> 系统** 页面
2. 在 **主题** 下拉框中选择 `aurora`
3. 点击 **保存并应用**

### Q2: 暗色模式不生效？
**A**: 清除浏览器缓存后重试，或在主题设置中检查暗色模式配置。

### Q3: 如何恢复默认主题？
**A**:
1. 进入 **系统 -> 系统** 页面
2. 在 **主题** 下拉框中选择 `bootstrap` 或其他主题
3. 点击 **保存并应用**

### Q4: 如何卸载 Aurora 主题？
**A**:
```bash
opkg remove luci-theme-aurora
```
卸载后请切换回其他主题。

## 注意事项

- **主题切换**：切换主题后建议清除浏览器缓存
- **自定义设置**：部分自定义功能需额外安装 `luci-app-aurora-config`
- **兼容性**：建议使用现代浏览器获得最佳体验
