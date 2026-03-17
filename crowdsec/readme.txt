==============================================================================
CROWDSEC HYBRID SECURITY ARCHITECTURE DOCUMENTATION
Server: flowkraft.xyz
Date: December 2025
==============================================================================

1. ARCHITECTURE OVERVIEW
------------------------------------------------------------------------------
This deployment utilizes a "Hybrid" security architecture designed for maximum 
stability and comprehensive threat mitigation:
[A] The Agent (Log Parser): Runs containerized via Docker. Analyzes access logs 
                            from the Nginx Proxy Manager (NPM).
[B] The Bouncer (Firewall): Runs natively on the Host OS via systemd. Enforces 
                            IP bans directly at the kernel level (iptables/nftables).

This architecture guarantees that even in the event of a Docker daemon failure, 
the Host Firewall remains active, providing continuous protection for both the 
Host OS (e.g., SSH brute force) and the containerized services.


2. CRITICAL PATH CONFIGURATIONS
------------------------------------------------------------------------------
[Containerized Agent]
- Deployment Config:    ./docker-compose.yml
- CrowdSec Config:      ./config/
- Ingress Logs Target:  ${NPM_LOGS_DIR} (Mounted as Read-Only)

[Host OS Firewall Bouncer]
- Bouncer Config:       /etc/crowdsec/bouncers/crowdsec-firewall-bouncer.yaml
- Bouncer Logs:         /var/log/crowdsec-firewall-bouncer.log
- Systemd Service:      crowdsec-firewall-bouncer


3. API KEY MANAGEMENT & BACKUP
------------------------------------------------------------------------------
WARNING: The Host Firewall Bouncer relies on a Local API (LAPI) key to fetch 
ban decisions from the Docker Agent. 

[ACTION REQUIRED] Ensure you backup your active LAPI key. Do NOT commit this 
to version control. Store it securely in a password manager.
(The active key is defined within the host bouncer configuration).


4. NETWORK PORT BINDINGS
------------------------------------------------------------------------------
- LAPI Exposed Port:    8082 (Mapped to internal port 8080)
  *Rationale: Port 8080 is reserved for internal network routing.*
- IPv6 Resolution:      Explicitly DISABLED in bouncer configuration to ensure 
                        networking stability.


5. OPERATIONAL COMMANDS (CSCLI)
------------------------------------------------------------------------------
As the Agent operates within a container, all `cscli` commands must be executed 
via `docker exec`.

[A] SYSTEM DIAGNOSTICS
    Verify Host Bouncer connection to the Agent:
    $ docker exec crowdsec cscli bouncers list

    Review active ban decisions:
    $ docker exec crowdsec cscli decisions list

[B] MANUAL THREAT MITIGATION (Ban)
    Manually ban a malicious IP address:
    $ docker exec crowdsec cscli decisions add --ip 1.2.3.4 --reason "Manual intervention"

[C] FALSE POSITIVE REMEDIATION (Unban)
    Remove a ban decision for an IP address:
    $ docker exec crowdsec cscli decisions delete --ip 1.2.3.4

[D] SECURITY POSTURE UPDATES
    Fetch the latest threat intelligence and scenarios from the Hub:
    $ docker exec crowdsec cscli hub update
    $ docker exec crowdsec cscli hub upgrade


6. TROUBLESHOOTING PROTOCOLS
------------------------------------------------------------------------------
Issue: Potential Host Firewall failure or disconnect.
Resolution: Inspect the Host OS bouncer logs.
Command:  tail -n 50 /var/log/crowdsec-firewall-bouncer.log
Expected Output: "Processing new and deleted decisions"

Issue: Requirement to restart the Host Firewall Bouncer.
Command:  systemctl restart crowdsec-firewall-bouncer

Issue: Requirement to restart the Docker Agent.
Command:  docker compose restart crowdsec

==============================================================================
END OF ARCHITECTURE DOCUMENTATION
==============================================================================
