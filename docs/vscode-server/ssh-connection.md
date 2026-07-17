如果你是想从自己电脑 `ssh` 到 NVwulf 时不再输入账号密码，做法是把**本机的公钥**放到 NVwulf 上的 `~/.ssh/authorized_keys` 里。

如果没有 `ssh-copy-id`，手动做：
```bash
cat ~/.ssh/id_ed25519.pub
```
把输出复制到 NVwulf 上的：
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXpVTYpCb23irwsU2GrSxT1LtSwp24kMUEf3JXGKxuW' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
# rclone copy odp:Backups/ssh/config ~/.ssh/
# rclone copy ~/.ssh/ odp:Backups/ssh/Oracle
```

### 测试登录
```bash
ssh nvwulf
```

### 保持链接

为了保证 SSH 连接的稳定性和自动重连，推荐使用 `autossh` 配合本地 SSH Keepalive 配置，并与 `tmux` 结合使用。

#### 1. 配置 SSH 保持存活
在本地 `~/.ssh/config` 中，为 `nvwulf` 主机添加心跳配置：
```text
Host nvwulf
    HostName login.nvwulf.stonybrook.edu
    User jichao
    ServerAliveInterval 60
    ServerAliveCountMax 10
```
* `ServerAliveInterval 60`: 每 60 秒发送一次心跳包。
* `ServerAliveCountMax 10`: 连续 10 次心跳无响应才断开连接，从而触发 `autossh` 自动重连。

#### 2. 使用 Autossh 脚本保持连接
通过 `autossh` 替代原生的 `ssh`，当连接断开时它会自动重新连接：
```bash
#!/bin/bash

# 1. 清理掉旧的 stale 会话
tmux kill-session -t nvwulf-ssh 2>/dev/null

# 2. 新建一个后台运行的 tmux 会话
tmux new-session -s nvwulf-ssh -d

# 3. 使用 autossh 建立连接（-M 0 表示使用 ssh 本身的心跳机制）
tmux send-keys -t nvwulf-ssh "autossh -M 0 nvwulf" C-m

# 4. 将当前终端接入到该 tmux 会话中
tmux attach-session -t nvwulf-ssh
```

#### 3. 进阶：会话自动保存与恢复
若希望在服务器/VPS 重启后，能自动恢复 tmux 窗口、布局及运行中的 `autossh` 进程，请参考详细指南：[Tmux & SSH Keepalive 指南](file:///home/ubuntu/projects/vps/docs/vscode-server/tmux-ssh-keepalive.md)。



