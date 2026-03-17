============================================================
PROJEK ADGUARD HOME + CLOUDFLARE (HYBRID SETUP)
Date Setup: 05 Dec 2025
Server: Ubuntu/Debian
Location: /root/adguard
Domain: flowkraft.xyz
============================================================

[1] LOKASI FILE PENTING
------------------------------------------------------------
Project Folder: /root/adguard
Docker Compose: /root/adguard/docker-compose.yml
Data & Config : /root/adguard/work  &  /root/adguard/conf
SSL Certs Path: /root/adguard/conf/certs
Renew Script  : /root/adguard/renew-cert.sh
Cloudflared   : (Check folder cloudflared bro, biasanya /etc/cloudflared atau ~/cloudflared)

[2] DOCKER COMPOSE CONFIG (docker-compose.yml)
------------------------------------------------------------
version: "3"
services:
  # AdGuard Home Core
  adguardhome:
    image: adguard/adguardhome
    container_name: adguardhome
    restart: unless-stopped
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "3000:3000/tcp"   # Web UI (Mapped ke Tunnel)
      - "853:853/tcp"     # DoT (Port Forwarded di Router)
      - "443:443/tcp"     # DoH (Port Forwarded di Router)
      - "443:443/udp"     # DoH QUIC
      # Port 80 DISABLED (Sebab clash dengan Apache Host)
    volumes:
      - ./work:/opt/adguardhome/work
      - ./conf:/opt/adguardhome/conf

  # Robot DDNS (Update IP Rumah)
  ddns:
    image: favonia/cloudflare-ddns:latest
    container_name: cloudflare-ddns
    restart: always
    environment:
      - CF_API_TOKEN=<PASTE_TOKEN_SINI>
      - DOMAINS=dns.flowkraft.xyz
      - PROXIED=false     # MESTI FALSE (Grey Cloud) utk support DoT
      - IP6_PROVIDER=none

[3] ROUTER PORT FORWARDING (UNIFI/ROUTER)
------------------------------------------------------------
Local IP Server: 192.168.0.25 (Contoh, check IP terkini)
Rules:
1. Port 853 (TCP)     -> Local Port 853 (Untuk Android Private DNS)
2. Port 443 (TCP/UDP) -> Local Port 443 (Untuk DoH)
3. Port 80            -> DISABLE/DELETE (Dah tak pakai lepas SSL verify)

[4] CLOUDFLARE SETTINGS
------------------------------------------------------------
A. DNS Records (Dashboard):
   - Type: A
   - Name: dns
   - Content: <Auto Update by DDNS>
   - Proxy: DNS Only (Grey Cloud) ☁️

B. Cloudflare Tunnel (config.yml):
   - Ingress Rule untuk Web UI:
     - hostname: adguard.flowkraft.xyz
     - service: http://127.0.0.1:3000

[5] SSL & AUTOMATION (Lets Encrypt via Lego)
------------------------------------------------------------
Method: DNS Challenge (Tak perlu port 80)
Renew Script: /root/adguard/renew-cert.sh

Isi Script Renew:
-----------------
#!/bin/bash
cd /root/adguard
docker run --rm \
  -e CLOUDFLARE_DNS_API_TOKEN="<TOKEN_CLOUDFLARE>" \
  -v $(pwd)/conf/certs:/certs \
  goacme/lego \
  --email="email@bro.com" \
  --dns="cloudflare" \
  --domains="dns.flowkraft.xyz" \
  --path="/certs" \
  renew --days 60
docker restart adguardhome
-----------------

Cronjob (Auto Run):
Command: crontab -e
Entry: 0 4 1 * * /root/adguard/renew-cert.sh >> /var/log/adguard-renew.log 2>&1
(Run setiap 1hb, pukul 4 pagi)

[6] CARA CONNECT CLIENT
------------------------------------------------------------
1. Android (Samsung/Pixel):
   - Settings > Connections > More connection settings > Private DNS
   - Hostname: dns.flowkraft.xyz

2. Browser/PC (DoH):
   - URL: https://dns.flowkraft.xyz/dns-query

[7] CHEATSHEET COMMAND
------------------------------------------------------------
Start Server  : docker compose up -d
Stop Server   : docker compose down
Restart       : docker restart adguardhome
Check Logs    : docker logs -f adguardhome
Manual Renew  : ./renew-cert.sh
Check Port    : sudo ss -tulnp
Edit Config   : nano /root/adguard/docker-compose.yml
