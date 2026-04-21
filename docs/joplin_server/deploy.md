# Joplin Server Deployment Guide

This guide describes how to deploy and configure Joplin Server securely on port `22790` using a non-root Docker setup and Cloudflare Tunnel for public access.

## Important Compatibility Note
- **VSCode Public Tunnels**: Incompatible. They rewrite the request origin to `localhost`, which Joplin rejects as `Invalid origin`.
- **Cloudflare Tunnel**: Recommended. It preserves headers correctly and provides a secure, HTTPS-enabled public URL.

## Prerequisites
- Docker and Docker Compose installed.
- Cloudflare `cloudflared` binary installed (ARM64 version for VPS).

## 1. Prepare the Environment
Run the following commands to create the required volume folders and set the correct ownership (for UID/GID 1001) in the centralized data directory:

```bash
mkdir -p /home/ubuntu/projects/vps/data/joplin_server/joplin-data \
         /home/ubuntu/projects/vps/data/joplin_server/joplin_logs \
         /home/ubuntu/projects/vps/data/joplin_server/joplin_temp
# Ensure the host user (1001:1001) owns these folders
sudo chown -R 1001:1001 /home/ubuntu/projects/vps/data/joplin_server/
```

## 2. Expose the Server via Cloudflare Tunnel

To get a public URL for your phone and computer without a domain, use a "Quick Tunnel":

1. Start the tunnel in a background process (or screen/tmux):
   ```bash
   cloudflared tunnel --url http://localhost:22790
   ```
2. Look for the generated URL in the logs (e.g., `https://random-words.trycloudflare.com`).
3. **Note**: This URL will change if the process restarts. For a permanent setup, link a real domain in the Cloudflare Dashboard.

## 3. Configure and Start the Server

1. Edit `/home/ubuntu/projects/vps/scripts/joplin_server/.env`:
   ```ini
   APP_BASE_URL=https://your-generated-url.trycloudflare.com
   APP_PORT=22790
   TRUSTED_PROXIES=0.0.0.0/0
   JOPLIN_IS_REVERSE_PROXY=1
   MAILER_ENABLED=false
   
   # Database credentials...
   ```
2. Start the containers:
   ```bash
   cd /home/ubuntu/projects/vps/scripts/joplin_server
   docker compose up -d --force-recreate
   ```

## 4. Initial Login & Setup
1. Navigate to your Cloudflare URL.
2. Default credentials:
   - **Email**: `admin@localhost`
   - **Password**: `admin`
3. **Change Password**: Go to settings and update your password immediately.
4. **Email Update**: Since `MAILER_ENABLED=false`, updating your email will trigger a "Confirmation sent" message that you won't receive. You must manually confirm it in the database:
   ```bash
   docker exec joplin_db psql -U joplin -d joplin -c "UPDATE users SET email = 'your@email.com', email_confirmed = 1 WHERE is_admin = 1;"
   ```

## Security Notes
- **Non-Root**: Both Joplin and Postgres run as UID `1001`.
- **Custom Port**: Port `22790` helps reduce automated port scanning.
- **No Public IP**: Cloudflare Tunnel allows you to keep your VPS firewall closed to port `22790` while still accessing it externally.
