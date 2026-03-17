# 🖥️ pwn20wnd's Homelab Architecture

```text
    ____                  ___  ____                     __
   / __ \_      ______   |__ \/ __ \_      ______  ____/ /
  / /_/ / | /| / / __ \  __/ / / / / | /| / / __ \/ __  / 
 / ____/| |/ |/ / / / / / __/ /_/ /| |/ |/ / / / / /_/ /  
/_/     |__/|__/_/ /_/ /____/\____/ |__/|__/_/ /_/\__,_/


Welcome to my personal homelab repository! This project showcases a comprehensive, self-hosted Docker architecture deployed on a Debian Linux laptop server. It is built with a strong emphasis on security, privacy, and automated media management.
🏗️ Infrastructure Overview

    Operating System: Debian Linux

    Containerization: Docker Engine & Docker Compose

    Datacenter Location: Masjid Tanah, Melaka 🇲🇾

    Reverse Proxy: Nginx Proxy Manager (NPM) + Cloudflare

    Network Security: UFW + CrowdSec (Hybrid IPS)

🚀 Services & Stack
🔐 Security & Networking

    Nginx Proxy Manager: Primary ingress controller handling SSL termination and subdomain routing.

    CrowdSec: Hybrid setup (Docker Agent + Host Bouncer) parsing NPM logs to ban malicious IPs automatically.

    Cloudflare DDNS: Automated dynamic DNS updater for A-records.

    AdGuard Home: Network-wide ad blocking and DNS privacy.

📊 Monitoring & Telemetry

    Grafana + Prometheus: Real-time hardware and service metric visualization.

    Netdata: High-resolution host and container monitoring.

    Node Exporter: Hardware telemetry scraping.

🎬 The *arr Media Stack

An optimized, automated media ingestion and streaming ecosystem utilizing atomic moves (hardlinks) to conserve storage.

    qBittorrent: Primary download client.

    Prowlarr: Indexer manager.

    Radarr & Sonarr: Automated movie and TV series fetching.

    Lidarr & Bazarr: Music and subtitle management.

    Jellyfin: Hardware-accelerated media streaming server.

    FlareSolverr: Cloudflare anti-bot bypass proxy for indexers.

☁️ Cloud & Productivity

    Nextcloud: Enterprise-grade file synchronization and sharing platform.

    OnlyOffice: Real-time document editing integrated with Nextcloud.

    Immich: High-performance, AI-powered photo and video backup solution (Google Photos alternative).

    Stirling-PDF: Secure, offline PDF manipulation tool.

⚙️ Automation & Management

    n8n: Node-based workflow automation platform.

    Portainer CE: Centralized GUI for Docker container management.

    Glance: Unified homelab dashboard.

🔒 Security Practices

To maintain operational security, all sensitive data has been rigorously excluded from this repository:

    All .env files containing passwords, API keys, and cryptographic tokens are ignored via .gitignore.

    Application data volumes (e.g., PostgreSQL databases, Nextcloud user data, NPM logs, Let's Encrypt certificates) are strictly excluded.

    Public-facing templates (.env.example) are provided for deployment referencing.

👨‍💻 About The Architect

Built and maintained by Afiq (pwn20wnd).
Currently in my final year pursuing a Bachelor's Degree in Telecommunication Engineering Technology with Honours at UniKL BMI. Passionate about Cloud Infrastructure, Systems Engineering, IoT, and Cyber Security.
