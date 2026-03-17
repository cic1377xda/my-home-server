# 🛡️ AdGuard Home + Cloudflare (Hybrid DNS Setup)

==============================================================================
SERVER DOCUMENTATION: ADGUARD HOME (DNS-over-HTTPS / DNS-over-TLS)
Date Updated: March 2026
Server Hostname: pwn20wndserver
Maintainer: cic1377xda
==============================================================================

## 1. ARCHITECTURE OVERVIEW
------------------------------------------------------------------------------
This project deploys a self-hosted AdGuard Home instance acting as a network-wide ad blocker and private DNS resolver. 
It utilizes a "Hybrid Setup" integrating Cloudflare for Dynamic DNS (DDNS) and Let's Encrypt for automated SSL provisioning via DNS challenges.

Key Features:
* DNS-over-TLS (DoT): Port 853 exposed for secure Android/Mobile connections.
* DNS-over-HTTPS (DoH): Port 443 exposed for secure browser-based queries.
* Cloudflare DDNS: Automatically updates the dynamic home IP to the DNS A-record.
* DNS Challenge SSL: Bypasses the need for Port 80 validation, avoiding conflicts with reverse proxies.

## 2. DIRECTORY STRUCTURE
------------------------------------------------------------------------------
Ensure the following directory structure is maintained:

/path/to/adguard/
├── docker-compose.yml       # Main Docker configuration
├── .env                     # (IGNORED) Contains API Tokens and Secrets
├── renew-cert.sh            # (IGNORED) Script for Let's Encrypt SSL renewal
├── conf/                    # AdGuard configuration files
│   └── certs/               # SSL Certificates storage
└── work/                    # AdGuard operational data and query logs

## 3. DOCKER COMPOSE CONFIGURATION
------------------------------------------------------------------------------
Note: Ensure you have an .env file populated with your specific variables before running.

version: "3"
services:
  # AdGuard Home Core
  adguardhome:
    image: adguard/adguardhome
    container_name: adguardhome
    restart: unless-stopped
    ports:
      - "53:53/tcp"       # Standard DNS (TCP)
      - "53:53/udp"       # Standard DNS (UDP)
      - "3000:3000/tcp"   # Web UI (Routed via Cloudflare Tunnel/Reverse Proxy)
      - "853:853/tcp"     # DNS-over-TLS (DoT)
      - "443:443/tcp"     # DNS-over-HTTPS (DoH)
      - "443:443/udp"     # DNS-over-HTTPS (QUIC)
      # Port 80 is deliberately disabled to prevent host port conflicts
    volumes:
      - ./work:/opt/adguardhome/work
      - ./conf:/opt/adguardhome/conf

  # Cloudflare DDNS Updater
  ddns:
    image: favonia/cloudflare-ddns:latest
    container_name: cloudflare-ddns
    restart: always
    environment:
      - CF_API_TOKEN=${CF_API_TOKEN}
      - DOMAINS=${DNS_SUBDOMAIN}
      - PROXIED=false     # CRITICAL: Must be false (Grey Cloud) to support DoT
      - IP6_PROVIDER=none

## 4. ROUTER PORT FORWARDING & FIREWALL
------------------------------------------------------------------------------
To allow external devices to securely query your DNS, forward the following ports from your Edge Router to your local server IP:

1. Port 853 (TCP) -> Local Port 853 (Required for Android Private DNS)
2. Port 443 (TCP/UDP) -> Local Port 443 (Required for DoH / QUIC)
3. Port 80 -> DISABLE/REMOVE (Not required due to DNS Challenge SSL)

## 5. CLOUDFLARE CONFIGURATION
------------------------------------------------------------------------------
A. DNS Records (Cloudflare Dashboard):
* Type: A
* Name: dns (or your preferred subdomain)
* Content: <Your Public IP> (This will be auto-updated by the DDNS container)
* Proxy Status: DNS Only (Grey Cloud)

B. Cloudflare Tunnel (Optional UI Access):
If exposing the Web UI via Cloudflare Tunnels (config.yml):
* hostname: adguard.yourdomain.com
* service: http://127.0.0.1:3000

## 6. SSL AUTOMATION (Let's Encrypt via Lego)
------------------------------------------------------------------------------
Since Port 80 is occupied or blocked, SSL certificates are provisioned using Let's Encrypt via the DNS-01 Challenge.

Cronjob Setup (Automated Renewal):
Run `crontab -e` and add the following entry to execute the renewal script at 4:00 AM on the 1st of every month:
0 4 1 * * /path/to/adguard/renew-cert.sh >> /var/log/adguard-renew.log 2>&1

## 7. CLIENT CONNECTION GUIDE
------------------------------------------------------------------------------
1. Android (Samsung/Pixel):
* Navigate to: Settings > Connections > More connection settings > Private DNS
* Select Private DNS provider hostname
* Enter: dns.yourdomain.com

2. Web Browsers (Chrome/Firefox/Brave):
* Enable "Secure DNS" in browser settings.
* Enter custom DoH URL: https://dns.yourdomain.com/dns-query

## 8. CHEATSHEET & OPERATIONS
------------------------------------------------------------------------------
Start Stack      : docker compose up -d
Stop Stack       : docker compose down
Restart AdGuard  : docker restart adguardhome
Tail Logs        : docker logs -f adguardhome
Manual SSL Renew : ./renew-cert.sh
Check Ports      : sudo ss -tulnp | grep -E '53|853|443'
