
### 1. 为什么“时间同步”对你的架构至关重要？
在你的三位一体架构中，时间偏差是导致“断网”最隐蔽的原因：

* **VLESS-Reality 握手：** Reality 协议虽然不依赖严格的时间戳（不像旧版 VMess），但底层 TLS 握手对证书有效期有检查。如果时间偏差过大，验证会直接失败。
* **Hysteria2 拥塞控制：** Hysteria2 基于 UDP，其自适应拥塞控制算法对 RTT（往返时延）非常敏感。如果系统时钟存在抖动或偏差，可能会影响其对带宽的预判。
* **日志对齐（科研痛点）：** 这是最关键的。你的 1 号机在 Phoenix（美西），2 号机监控也在云端，旁路由在 SBU（美东）。如果你需要复盘某个实验脚本（Stormer 项目）崩溃的原因，对比 1 号机的计算日志和旁路由的流量日志时，如果差了 3 小时，你会非常痛苦。

---

### 2. 为什么推荐“美东时间 (EST/EDT)”？
虽然 1 号机物理上在美西（Phoenix），但我建议你统一设为 **美东时间**：

* **生活直觉：** 你人在纽约州，你的所有操作逻辑、备份任务、定时开关机脚本（Crontab）都应该符合你的生物钟。
* **日志易读：** 当你凌晨 2 点在实验室修 Bug 时，你查看到的日志显示也是凌晨 2 点，而不是前一晚的 11 点，这能极大地降低认知负荷。
* **Webshare 配合：** 住宅 IP 服务的风控审计通常也以访问者的当地时区为准。

---

### 3. 操作指南：如何一键对齐
请在你的 1 号机、2 号机以及旁路由（AOOSTAR）上分别执行以下操作：

#### **第一步：修改时区为美东**
```bash
sudo timedatectl set-timezone America/New_York
```

#### **第二步：强制同步 NTP 服务器**
确保系统会自动校准时间（防止硬件时钟走偏）：
```bash
sudo systemctl enable --now systemd-timesyncd
```

#### **第三步：验证状态**
执行 `timedatectl`，你应该看到类似如下输出：
```text
      Local time: Fri 2026-04-17 01:32:00 EDT  # 确保这里是美东时间
  Universal time: Fri 2026-04-17 05:32:00 UTC
        RTC time: Fri 2026-04-17 05:32:00
       Time zone: America/New_York (EDT, -0400)
 System clock synchronized: yes                # 必须为 yes
               NTP service: active             # 必须为 active
```

---

### 4. 专家级贴士：关于 Crontab 的坑
Michael，特别提醒：**修改时区后，必须重启 Cron 服务**。
否则你的流量监控脚本（2 号机）可能还会按旧的时区运行，导致你以为是半夜备份，结果正好撞在白天的高峰期。

```bash
sudo systemctl restart cron
```
