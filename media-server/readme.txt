===============================================================
               HOME MEDIA SERVER DOCUMENTATION
===============================================================
USER: pwn20wnd (UID: 1000, GID: 1000)
SERVER PATH: /home/pwn20wnd/media-server
TIMEZONE: Asia/Kuala_Lumpur
DATE UPDATED: 07 DEC 2025
===============================================================

[1] DIRECTORY STRUCTURE
---------------------------------------------------------------
Location: ~/media-server/
├── docker-compose.yml       # Main configuration file
├── config/                  # App configurations (Database, Settings)
│   ├── bazarr/
│   ├── jellyfin/
│   ├── lidarr/
│   ├── prowlarr/
│   ├── qbittorrent/
│   ├── radarr/
│   └── sonarr/
└── data/                    # Storage (Hardlinks Enabled)
    ├── torrents/            # Raw downloads from qBittorrent
    └── media/               # Sorted media for Jellyfin
        ├── movies/
        ├── tv/
        └── music/

[2] SERVICE ACCESS (DASHBOARD)
---------------------------------------------------------------
Replace <SERVER-IP> with your local IP (e.g., 192.168.x.x)

1. qBittorrent (Downloader)
   URL: http://<SERVER-IP>:8085
   User: admin
   Pass: (As set by user)

2. Prowlarr (Indexer Manager)
   URL: http://<SERVER-IP>:9696
   API Key: Found in Settings > General

3. Radarr (Movies)
   URL: http://<SERVER-IP>:7878
   Root Folder Path: /data/media/movies

4. Sonarr (TV Shows)
   URL: http://<SERVER-IP>:8989
   Root Folder Path: /data/media/tv

5. Lidarr (Music)
   URL: http://<SERVER-IP>:8686
   Root Folder Path: /data/media/music

6. Bazarr (Subtitles)
   URL: http://<SERVER-IP>:6767
   Provider: OpenSubtitles.com

7. Jellyfin (Media Player)
   URL: http://<SERVER-IP>:8096
   Libraries: /data/media/movies, /data/media/tv

[3] DOCKER COMPOSE FILE
---------------------------------------------------------------
File: ~/media-server/docker-compose.yml

services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Kuala_Lumpur
      - WEBUI_PORT=8080
    volumes:
      - ./config/qbittorrent:/config
      - ./data/torrents:/data/torrents
    ports:
      - 8085:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped

  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Kuala_Lumpur
    volumes:
      - ./config/prowlarr:/config
    ports:
      - 9696:9696
    restart: unless-stopped

  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Kuala_Lumpur
    volumes:
      - ./config/radarr:/config
      - ./data:/data
    ports:
      - 7878:7878
    depends_on:
      - qbittorrent
      - prowlarr
    restart: unless-stopped

  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Kuala_Lumpur
    volumes:
      - ./config/sonarr:/config
      - ./data:/data
    ports:
      - 8989:8989
    depends_on:
      - qbittorrent
      - prowlarr
    restart: unless-stopped

  lidarr:
    image: lscr.io/linuxserver/lidarr:latest
    container_name: lidarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Kuala_Lumpur
    volumes:
      - ./config/lidarr:/config
      - ./data:/data
    ports:
      - 8686:8686
    depends_on:
      - qbittorrent
      - prowlarr
    restart: unless-stopped

  bazarr:
    image: lscr.io/linuxserver/bazarr:latest
    container_name: bazarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Kuala_Lumpur
    volumes:
      - ./config/bazarr:/config
      - ./data:/data
    ports:
      - 6767:6767
    restart: unless-stopped

  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    container_name: jellyfin
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Kuala_Lumpur
    volumes:
      - ./config/jellyfin:/config
      - ./data/media:/data/media
    ports:
      - 8096:8096
    devices:
      - /dev/dri:/dev/dri
    restart: unless-stopped

[4] CRITICAL CONFIGURATIONS (DO NOT LOSE)
---------------------------------------------------------------

A. qBittorrent "Unauthorized" Fix
   File: ~/media-server/config/qbittorrent/qBittorrent/qBittorrent.conf
   Action: Added these lines under [Preferences] to fix WebUI login issues:
   
   WebUI\CSRFProtection=false
   WebUI\ClickjackingProtection=false
   WebUI\HostHeaderValidation=false

B. Download Client Settings (In Radarr/Sonarr)
   Host: qbittorrent
   Port: 8080  (Internal docker port)
   User: admin
   Pass: (Your Password)

C. File Size Limits (To save 750GB storage)
   Location: Settings > Quality > File Size
   1080p Limit: ~2GB - 4GB max
   WEBDL-1080p Limit: ~1.5GB - 3GB max

[5] MAINTENANCE COMMANDS
---------------------------------------------------------------
Run these commands from inside: ~/media-server/

1. Start Server:
   docker compose up -d

2. Stop Server:
   docker compose down

3. Update All Apps (Latest Version):
   docker compose pull
   docker compose up -d

4. Restart Specific App (e.g., qBittorrent):
   docker compose restart qbittorrent

5. Check Logs (Debugging):
   docker compose logs -f radarr

[6] BACKUP STRATEGY
---------------------------------------------------------------
To backup the entire server settings (database, posters, history), 
you only need to backup this folder:

   ~/media-server/config/

The 'data' folder contains large media files and does not need 
backup if you can re-download them.
