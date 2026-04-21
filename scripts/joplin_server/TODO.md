# Joplin Server Sync Issue TODO

## Current Status (2026-04-21)
- **Problem**: Android app crashes (OOM or Network Request Failed) within 10s of starting sync.
- **Scope**: Affects multiple Android devices (new and existing installs).
- **Data Load**: ~14,000 resources (heavy metadata overhead).
- **Current Connection**: Cloudflare Quick Tunnel (`trycloudflare.com`) - **Unstable**.
- **Observation**: Windows sync is fast and stable, proving the server and database are functioning correctly.

## Recommended Solution to Try Later
1. **Abandon Cloudflare Tunnel**: The overhead and connection resets of public tunnels are likely triggering the Android app's crash during batch metadata processing.
2. **Implement Tailscale/VPN**: 
   - Install Tailscale on the VPS and Android devices.
   - Use the Tailscale internal IP for synchronization (e.g., `http://100.x.y.z:22790`).
   - This bypasses Cloudflare's timeouts and packet inspection, providing a raw TCP connection.
3. **Android App Optimization**:
   - Set max concurrent connections to 1.
   - Set attachment download to "Manual".

## Immediate Action
- Migrate back to OneDrive (WebDAV) via the Windows client to ensure data availability on mobile.
