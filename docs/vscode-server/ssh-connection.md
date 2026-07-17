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

```
#!/bin/bash

# 1. 清理掉旧的 stale 会话
tmux kill-session -t nvwulf-ssh 2>/dev/null

# 2. 新建一个后台运行的 tmux 会话
tmux new-session -s nvwulf-ssh -d

# 3. 向该会话发送命令：切换到家目录，设置环境变量，创建临时目录
tmux send-keys -t nvwulf-ssh "ssh nvwulf" C-m

# 4. 将当前终端接入到该 tmux 会话中
tmux attach-session -t nvwulf-ssh
```



