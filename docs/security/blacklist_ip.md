看来你的 **Phoenix-Beast-ARM** 已经引起了公网扫描器的注意。看到这些 `Invalid user solv` 和 `root` 的尝试了吗？这在 Oracle Cloud 这种大厂 IP 段非常普遍。这些是自动化的暴力破解脚本。

针对你现在的情况，我为你准备了三个层级的防御方案。考虑到你已经在用 **12666** 端口（或者正打算换），咱们直接上“组合拳”：

---

### 1. 战术层：立刻拉黑该 IP (手工精准打击)
由于你使用的是 Ubuntu 且已经通过之前的配置保存了防火墙规则，你可以直接用 `iptables` 封死这个 IP 及其同伙。

**针对 `80.94.92.184` 执行：**
```bash
sudo iptables -I INPUT -s 80.94.92.184 -j DROP
```

**持久化保存（非常重要，否则重启后失效）：**
```bash
sudo netfilter-persistent save
```
> **顾问提醒：** `-I` 是插入（Insert），确保这条规则在最前面，系统会直接丢弃来自这些 IP 的所有包，甚至连 SSH 端口都不会让它们摸到。

---

### 2. 战役层：部署 Fail2Ban (全自动防御系统)
作为 SBU 的博士，你肯定不想手动去刷日志封 IP。**Fail2Ban** 是你的最佳数字保镖，它会自动监控 `/var/log/auth.log`，发现谁尝试失败超过 N 次，直接封禁。

**安装并启动：**
```bash
sudo apt update && sudo apt install fail2ban -y
```

**配置针对 SSH 的防御规则：**
1. 创建个人配置文件：`sudo nano /etc/fail2ban/jail.local`
2. 粘贴以下内容：
```ini
[sshd]
enabled = true
port = 12666,22  # 包含你自定义的端口
filter = sshd
logpath = /var/log/auth.log
maxretry = 3     # 允许尝试 3 次，第 4 次就封禁
findtime = 600   # 在 10 分钟内失败 3 次
bantime = 86400  # 封禁 24 小时 (也可以写 -1 永久封禁)
```
3. 重启服务：`sudo systemctl restart fail2ban`

---

### 3. 战略层：彻底“隐身” (终极加固建议)
Michael，既然你的“三位一体”架构里有 **2 号机 (AMD)**，我建议你把 1 号机的安全等级拉到最高：

1.  **关闭公网 SSH 端口：** 在 Oracle VCN 的 Security List 中，**删掉** 0.0.0.0/0 访问 12666 或 22 端口的规则。
2.  **通过内网管理：** 你从 SBU 登录 2 号机（因为 2 号机配置低，扫描器即便攻破也拿不到你的 Stormer 算力），然后从 2 号机通过**内网 IP (10.0.0.x)** 跳转到 1 号机。
3.  **禁用密码登录：** 确保 `/etc/ssh/sshd_config` 中 `PasswordAuthentication no`。

### 📊 攻击者背景小考
那个 `80.94.92.184` 实际上是来自塞浦路斯或俄罗斯方向的常见僵尸网络。它们这种 `solv` 或 `root` 尝试是在扫弱口令。
