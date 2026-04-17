## 使用 VS Code Server 远程开发

1.  **安装 VS Code CLI**：
    ```bash
    curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-arm64' --output vscode_cli.tar.gz
    tar -xf vscode_cli.tar.gz
    ```
    如果是 AMD 机器，请替换下载链接中的 `arm64` 为 `x64` (`curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz`)

    (Optional but recommended) 将 `code` 命令添加到 PATH：
    ```bash
    sudo mv code /usr/local/bin/
    sudo chown root:root /usr/local/bin/code
    sudo chmod +x /usr/local/bin/code
    ```
2.  **启动隧道**：
    ```bash
    code tunnel
    ```
3.  **身份认证**：
    * 终端会给出一个 8 位代码和一个 GitHub/Microsoft 登录链接。
    * 在浏览器打开链接，输入代码，完成授权。
4.  **网页访问**：
    * 授权成功后，终端会返回一个类似 `https://vscode.dev/tunnel/your-machine-name` 的 URL。
    * 你在任何地方打开这个网址，就能直接看到你 1 号机的文件系统并运行终端跑代码了。
5.  **永久化进程**：
    ```bash
    # 将 tunnel 注册为系统服务 (systemd)
    code tunnel service install
    sudo loginctl enable-linger $USER
    ```
    * 这样即使重启机器，VS Code Server 也会自动启动。
    * 你可以随时通过 `code tunnel service status` 查看服务状态，或 `code tunnel service restart` 重启服务。
    * 如果需要卸载服务，使用 `code tunnel service uninstall`。
    * 注意：如果你不想使用 systemd，也可以使用其他工具（如 `nohup` 或 `tmux`）来保持隧道进程持续运行，但 systemd 提供了更好的管理和自动重启功能。以tmux在x86机器上为例：
    ```bash
    cd ~
    curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz
    tar -xf vscode_cli.tar.gz
    tmux new -s vscode-tunnel
    # 在 tmux 会话中运行隧道
    cd ~
    ./code tunnel
    ```
    这样即使你关闭终端，隧道也会继续运行。要

