## 将 SSH 默认端口修改为一个不常用的高位端口（以12666为例）

虽然默认的 SSH Key 登录已经非常安全，但 22 端口是全球黑客脚本扫描的头号目标 。修改它不仅能过滤掉 99% 的自动化扫描，还能显著减少系统日志中那些烦人的无效报错 。

### 🛡️ 正确的操作顺序（防失联指南）

为了确保你不会把自己锁在外面，请务必按这个顺序操作：

#### 第一步：在 Oracle 控制台推开“外墙大门”
1.  登录 Oracle Cloud 控制台。
2.  进入 **Networking** -> **Virtual Cloud Networks** -> 点击你的 VCN。
3.  在左侧选择 **Security Lists**，点击对应的 Default Security List。
4.  点击 **Add Ingress Rules**：
    * **Source CIDR:** `0.0.0.0/0`（或者为了更安全，填入你 SBU 宿舍/实验室的固定 IP）。
    * **IP Protocol:** `TCP`。
    * **Destination Port Range:** 填写你的新端口（例如 `12666`）。
    * **Description:** SSH Custom Port。

#### 第二步：在 Linux 内部修改“实验室大门”
在 SSH 连接还在的时候，执行：

1.  **修改配置文件**：
    ```bash
    sudo nano /etc/ssh/sshd_config
    ```
2.  **找到 `Port 22` 这一行**：
    建议暂时保留 22，在下方新起一行：
    ```text
    Port 22
    Port 12666
    ```
    *（注：等新端口登录成功后，再回来删掉 Port 22，这是最稳的职业习惯。）*
3.  **确认密钥登录开启，禁用密码**（Michael 核心安全需求）：
    确保以下两行配置正确：
    ```text
    PubkeyAuthentication yes
    PasswordAuthentication no
    ```
4.  **保存并重启 SSH 服务**：
    ```bash
    sudo sshd -t  # 检查配置语法是否有误，没报错再重启
    sudo systemctl restart ssh
    ```

#### 第三步：放行 Ubuntu 自带防火墙（如果有）
虽然你之前清理过 iptables，但为了保险，执行一下：
```bash
sudo ufw allow 12666/tcp  # 如果你开启了ufw
# 或者直接清理一遍甲骨文Ubuntu自带的规则
sudo iptables -I INPUT -p tcp --dport 12666 -j ACCEPT
```

Oracle 的镜像非常鸡贼，它默认自带了一套非常硬核的 `iptables` 规则，即使你关闭了 `ufw`，它依然可能拦截流量。
执行这个命令强制放行新 SSH 端口：
```bash
sudo iptables -I INPUT -p tcp --dport 12666 -j ACCEPT
# 如果你想一劳永逸（以后只靠 Oracle 面板控制），可以运行：
sudo netfilter-persistent save
```

#### 第三步：验证（不要断开当前的连接！）
**保持当前的 SSH 窗口别动**，新开一个终端尝试连接：
`ssh -i [你的私钥] -p 12666 ubuntu@[你的IP]`
如果成功了，恭喜你！你已经成功把 SSH 端口换了个隐蔽的位置。接下来，你可以回到配置文件里删除 `Port 22` 那行，彻底关闭默认端口。
---

### 💡 进阶：如何彻底甩掉 Oracle 内部防火墙的纠缠？

既然你已经在 VCN（外层）做好了安全防护，很多博士生的做法是直接把 Ubuntu 内部那层“多余”的防火墙规则清空，让流量完全由 Oracle Web 界面控制。这样你以后部署 Sing-box 或 Hysteria2 时，就不需要每次都在 Linux 里敲 `iptables` 了。

**清空内部限制指令（慎用，确保你 VCN 外墙是稳固的）：**
```bash
sudo apt-get purge netfilter-persistent -y
sudo rm -rf /etc/iptables/
# 然后手动清空当前规则
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -F
```



Michael，现在两台机器的新端口都连上了吗？如果稳住了，下一步我们聊聊怎么把那个 **24GB RAM** 的主力机配置成**非 Root 用户运行**，这能防止你的科研数据（Stormer 项目）不小心被黑客一锅端。



### 🛡️ Michael 的本地连接优化 (VS Code / Terminal)

为了让你以后不用每次都打 `-p 58222`，请修改你**本地电脑**（Mac/Windows）的 `~/.ssh/config`：

```text
Host stormer
    HostName 1号机公网IP
    User ubuntu
    Port 12666                # 以后只需 ssh stormer 即可自动识别端口
    IdentityFile ~/.ssh/to_stormer_arm
    AddKeysToAgent yes        # 配合 passphrase，只需输入一次密码
    UseKeychain yes           # macOS专属，自动存入钥匙串
```

### 取消22端口

在Oracle控制台的Security List里，删除22端口的入站规则：
1. 进入 **Networking** -> **Virtual Cloud Networks** -> 点击你的 VCN。
2. 在左侧选择 **Security Lists**，点击对应的 Default Security List。
3. 找到允许 22 端口的规则，点击删除。或者把CIDR改成更安全的范围（例如只允许 SBU 的固定 IP）。
   * **If you want to allow this ONE specific IP:** Use a **`/32`** prefix. Change it to: `69.120.195.224/32`
   * **If you want to allow EVERYONE (The whole internet):** Use the standard "Anywhere" notation: `0.0.0.0/0`
   * **If you want to allow a range (Subnet):**
       If this is your home/office network and you want to allow the local neighborhood of IPs, you likely meant something like **`/24`** (which covers `69.120.195.0` to `69.120.195.255`), but the address would need to be written as `69.120.195.0/24`.
