==============================================================================
SERVER DOCUMENTATION: NGINX PROXY MANAGER (NPM)
Date Updated: December 2025
Server Hostname: pwn20wndserver
Maintainer: pwn20wnd
==============================================================================

1. ARCHITECTURE OVERVIEW
------------------------------------------------------------------------------
Nginx Proxy Manager (NPM) functions as the core "Reverse Proxy" for the 
infrastructure. It acts as the intermediary between the public internet and 
internal Docker containers.
Key Responsibilities:
  - Ingress Traffic Routing (Ports 80 & 443).
  - SSL/TLS Termination (Automated certificate provisioning via Let's Encrypt).
  - Subdomain routing to backend services (Nextcloud, Sonarr, etc.).

2. DEPLOYMENT SPECIFICATIONS
------------------------------------------------------------------------------
* Deployment Directory: /root/npm
* Docker Image:         jc21/nginx-proxy-manager:latest
* Primary Network:      pwn20wnd-network (Shared with backend apps & CrowdSec)
* Admin Dashboard:      http://192.168.0.25:81
* Database Engine:      SQLite (Persisted in the /data volume)

3. PORT BINDINGS
------------------------------------------------------------------------------
* Port 80 (External)  -> Mapped to Port 80  (HTTP / Automated SSL Validation)
* Port 443 (External) -> Mapped to Port 443 (Secure HTTPS Traffic)
* Port 81 (External)  -> Mapped to Port 81  (Admin Dashboard Interface)

CRITICAL: Ports 80 and 443 must be port-forwarded from the network edge 
(Router) directly to the Server IP (192.168.0.25).

4. CONFIGURATION WORKFLOW (SOP: ADDING A NEW SUBDOMAIN)
------------------------------------------------------------------------------
Example: Provisioning `sonarr.flowkraft.xyz`

Step 1: DNS Configuration (Cloudflare)
   - Record Type:  CNAME
   - Name:         sonarr
   - Target:       dns.flowkraft.xyz (Resolves to Server Public IP)
   - Proxy Status: DNS Only (Grey Cloud) during initial setup/testing.

Step 2: Host Firewall (UFW)
   - Ensure the backend container's port is accessible.
   - Command: $ sudo ufw allow 8989/tcp

Step 3: NPM Dashboard Configuration
   - Navigate to: "Proxy Hosts" -> "Add Proxy Host"
   - Domain Names: sonarr.flowkraft.xyz
   - Scheme:       http
   - Forward Host: Use the exact Container Name (e.g., 'sonarr') as both 
                   reside on 'pwn20wnd-network'. Fallback: Use Server IP.
   - Forward Port: 8989
   - Security:     Enable "Block Common Exploits"
   - Websockets:   Enable "Websockets Support"

Step 4: SSL/TLS Provisioning
   - Navigate to the "SSL" tab.
   - Select: "Request a new SSL Certificate"
   - Enable: "Force SSL" & "HTTP/2 Support"
   - Input your registration email and agree to the TOS. Click Save.

5. INCIDENT RESPONSE & TROUBLESHOOTING
------------------------------------------------------------------------------
[Error] "502 Bad Gateway"
* Cause: NPM cannot establish a connection to the upstream container.
* Resolution: 
  1. Verify the backend container is running.
  2. Validate the "Forward Host" IP/Container Name.
  3. Validate the "Forward Port" mappings.

[Error] "504 Gateway Time-out"
* Cause: NPM initiated a connection, but it timed out waiting for a response.
* Resolution:
  1. Verify Host Firewall (UFW) is not blocking internal traffic.
  2. Verify the backend application is not deadlocked (Restart container).

[Error] "Internal Error" during SSL Generation
* Cause: Let's Encrypt failed to verify domain ownership.
* Resolution:
  1. Verify Router port-forwarding for Port 80 to 192.168.0.25.
  2. Verify Cloudflare DNS records propagate correctly.
  3. Disable Cloudflare Proxy (Orange Cloud -> Grey Cloud) until SSL is issued.

6. CROWDSEC IPS INTEGRATION
------------------------------------------------------------------------------
CrowdSec actively monitors this NPM instance to mitigate malicious traffic.
* Target Log Path: /root/npm/data/logs
* Verification: Run `$ docker exec -t crowdsec cscli metrics` and verify 
  'type:nginx-proxy-manager' exists under Acquisition Metrics.
==============================================================================
END OF DOCUMENTATION
==============================================================================
