#!/bin/sh
set -e

# Lock the Go Engine to container limits to stop 40-second CPU freezes
export GOMAXPROCS=1
# Force the server to dump unused RAM 2x faster before Render throttles it
export GOGC=50
# Force Go network layer to bypass heavy OS system calls
export GODEBUG=netdns=go+http2server=1

# Optimize system kernel thresholds for maximum network stream throughput
ulimit -n 65535 || true

# Generate Matrix signing key if it doesn't exist
if [ ! -f /etc/dendrite/matrix_key.pem ]; then
  echo "Generating Matrix private key..."
  if command -v generate-keys >/dev/null 2>&1; then
    generate-keys --private-key /etc/dendrite/matrix_key.pem
  elif command -v dendrite-generate-keys >/dev/null 2>&1; then
    dendrite-generate-keys --private-key /etc/dendrite/matrix_key.pem
  else
    echo "Error: Could not find key generation binary."
    exit 1
  fi
fi

echo "Injecting environment variables into config..."
sed -i "s|\${SERVER_NAME}|$SERVER_NAME|g" /etc/dendrite/dendrite.yaml
sed -i "s|\${SUPABASE_DB_URL}|$SUPABASE_DB_URL|g" /etc/dendrite/dendrite.yaml
sed -i "s|\${REGISTRATION_SECRET}|$REGISTRATION_SECRET|g" /etc/dendrite/dendrite.yaml

echo "⚡ Applying High-Speed, Zero-Logs & Low-Memory Optimizations..."

# 1. Total Silence Log Policy (Stops processing thousands of string logs in memory)
sed -i -E 's/level:[[:space:]]*"?(info|warn|warning)"?/level: "error"/g' /etc/dendrite/dendrite.yaml

# 2. Total Removal of Presence and Status Typing Loops
sed -i 's/enable_inbound: true/enable_inbound: false/g' /etc/dendrite/dendrite.yaml
sed -i 's/enable_outbound: true/enable_outbound: false/g' /etc/dendrite/dendrite.yaml

# 3. Database Connection Tunnel Hold (Prevents queuing up deletions/messages)
sed -i 's/max_open_conns: .*/max_open_conns: 12/g' /etc/dendrite/dendrite.yaml
sed -i 's/max_idle_conns: .*/max_idle_conns: 3/g' /etc/dendrite/dendrite.yaml

if ! grep -q "max_conn_lifetime:" /etc/dendrite/dendrite.yaml; then
    sed -i '/max_idle_conns:/a \    max_conn_lifetime: 15m\n    conn_max_idle_time: 2m' /etc/dendrite/dendrite.yaml
fi

# 4. Drop Media Cache Footprint down to a tiny size
sed -i 's/max_size_estimated: .*/max_size_estimated: 8mb/g' /etc/dendrite/dendrite.yaml

# 5. Inject 30-Minute Internal DNS Cache
if ! grep -q "dns_cache:" /etc/dendrite/dendrite.yaml; then
    sed -i '/global:/a \  dns_cache:\n    enabled: true\n    cache_size: 2048\n    cache_lifetime: 1800s' /etc/dendrite/dendrite.yaml
fi

echo "✅ Optimization profiles fully injected."
echo "🚀 Starting Silent High-Speed Matrix Hub..."

if command -v dendrite-monolith-server >/dev/null 2>&1; then
  exec dendrite-monolith-server -tls-cert="" -tls-key="" -config /etc/dendrite/dendrite.yaml
elif command -v dendrite >/dev/null 2>&1; then
  exec dendrite monolith -tls-cert="" -tls-key="" -config /etc/dendrite/dendrite.yaml
else
  echo "Error: Could not find Dendrite server binary."
  exit 1
fi
