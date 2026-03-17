#!/bin/bash

# 1. Masuk folder project
cd /root/adguard

# 2. Run Lego (Guna dua --domains supaya satu sijil ada dua nama)
# Pakai 'renew' untuk auto-update kalau < 60 hari baki
docker run --rm \
  -e CLOUDFLARE_DNS_API_TOKEN="aumRujun48yl1n5SqpUWsPJPJoLdSAmkkYODhagm" \
  -v $(pwd)/conf/certs:/certs \
  goacme/lego \
  --email="flowkraftmy@gmail.com" \
  --dns="cloudflare" \
  --domains="dns.flowkraft.xyz" \
  --domains="dot.flowkraft.xyz" \
  --path="/certs" \
  run
 # renew --days 60

# Nota: Kalau nak paksa buat baru terus, tukar 'renew --days 60' kepada 'run'

# 3. Restart AdGuard supaya dia sedut sijil baru
docker restart adguardhome
