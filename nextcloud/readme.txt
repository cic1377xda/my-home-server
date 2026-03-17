==============================================================================
NEXTCLOUD + ONLYOFFICE + CLOUDFLARE (PERFORMANCE OPTIMIZED DEPLOYMENT)
Date Setup: December 2025
Server: Ubuntu/Debian via Docker Engine
Domain: nextcloud.flowkraft.xyz
==============================================================================

[1] ARCHITECTURE & FILE LOCATIONS
------------------------------------------------------------------------------
Project Directory:      /root/nextcloud
Docker Compose:         ./docker-compose.yml
Environment Variables:  ./.env (Holds all passwords and JWT secrets)
Nextcloud Config (PHP): /var/www/html/config/config.php (Inside App Container)
Persistent Storage:     Defined by ${NEXTCLOUD_ROOT_DIR} in the .env file

[2] REVERSE PROXY (CLOUDFLARE) & PERFORMANCE CONFIGURATIONS
------------------------------------------------------------------------------
Target File: /var/www/html/config/config.php
Execute: docker exec -it nextcloud-app nano /var/www/html/config/config.php

Essential settings to append for Cloudflare and Redis caching:
--------------------------------------------------------------
  'trusted_proxies' => ['172.16.0.0/12', '192.168.0.0/16', '10.0.0.0/8'],
  'overwritehost' => 'nextcloud.flowkraft.xyz',
  'overwriteprotocol' => 'https',
  'overwrite.cli.url' => 'https://nextcloud.flowkraft.xyz',
  
  'memcache.distributed' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' => 
  array (
    'host' => 'redis',
    'password' => '',
    'port' => 6379,
  ),

  'maintenance_window_start' => 2,
  'default_phone_region' => 'MY',
  'maintenance' => false,


[3] MAINTENANCE CHEATSHEET (OCC COMMANDS)
------------------------------------------------------------------------------
*Note: Execute these commands directly on the host terminal.

1. MANUAL UPGRADE:
   $ docker exec -u www-data nextcloud-app php occ upgrade

2. DISABLE MAINTENANCE MODE (If website is stuck):
   $ docker exec -u www-data nextcloud-app php occ maintenance:mode --off

3. REPAIR MISSING DATABASE INDICES:
   $ docker exec -u www-data nextcloud-app php occ db:add-missing-indices

4. REPAIR MIMETYPES / FILE CACHE:
   $ docker exec -u www-data nextcloud-app php occ maintenance:repair --include-expensive

5. UPDATE .HTACCESS HEADERS:
   $ docker exec -u www-data nextcloud-app php occ maintenance:update:htaccess

6. DISABLE PROBLEMATIC APPS (e.g., AppAPI or RichDocuments):
   $ docker exec -u www-data nextcloud-app php occ app:disable app_api
   $ docker exec -u www-data nextcloud-app php occ app:disable richdocumentscode


[4] CLOUDFLARE TUNNEL SETTINGS
------------------------------------------------------------------------------
1. Tunnel Configuration (config.yml or via Cloudflare Zero Trust Dashboard):
   - Hostname: nextcloud.flowkraft.xyz
   - Service:  http://127.0.0.1:8080 (or the port defined in .env)

2. SSL/TLS Configuration (Cloudflare Dashboard):
   - Encryption Mode: Full (Strict)
   - Edge Certificates > HSTS: Enable
   - Max-Age: 6 Months
   - Include subdomains: On


[5] TROUBLESHOOTING GUIDE
------------------------------------------------------------------------------
Q: The upgrade process is hanging at "richdocumentscode"?
A: Press Ctrl+C to abort, disable the app using OCC Command #6, then re-run the upgrade.

Q: Website displays "Maintenance Mode" constantly?
A: Run OCC Command #2 to force it off.

Q: Encoutering "Transactional File Locking" errors?
A: Ensure the 'redis' container is running ($ docker ps). Verify that config.php contains the exact Redis array configuration shown in Section [2].

Q: Nextcloud warns that "Background jobs haven't run in X hours"?
A: Verify the 'nextcloud-cron' container is running. It is configured to execute jobs automatically every 5 minutes.

==============================================================================
END OF DOCUMENTATION
==============================================================================
