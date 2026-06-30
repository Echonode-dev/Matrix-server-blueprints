#!/bin/sh
set -e

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
# Replace the placeholder text with actual environment variable values
sed -i "s|\${SERVER_NAME}|$SERVER_NAME|g" /etc/dendrite/dendrite.yaml
sed -i "s|\${SUPABASE_DB_URL}|$SUPABASE_DB_URL|g" /etc/dendrite/dendrite.yaml
sed -i "s|\${REGISTRATION_SECRET}|$REGISTRATION_SECRET|g" /etc/dendrite/dendrite.yaml

echo "⚡ Applying High-Speed, Zero-Logs & Low-Memory Optimizations..."

# 1. Enforce Zero-Logs Policy (Completely mutes text spam allocations in RAM)
sed -i 's/level: info/level: error/g' /etc/dendrite/dendrite.yaml
sed -i 's/level: warn/level: error/g' /etc/dendrite/dendrite.yaml
sed -i 's/level: warning/level: error/g' /etc/dendrite/dendrite.yaml

# 2. Total Removal of Presence and Status Typing Loops
sed -i 's/enable_inbound: true/enable_inbound: false/g' /etc/dendrite/dendrite.yaml
sed -i 's/enable_outbound: true/enable_outbound: false/g' /etc/dendrite/dendrite.yaml

# 3. Database Connection Tunnel Hold (Eliminates "context canceled" lags)
sed -i 's/max_open_conns: .*/max_open_conns: 8/g' /etc/dendrite/dendrite.yaml
sed -i 's/max_idle_conns: .*/max_idle_conns: 4/g' /etc/dendrite/dendrite.yaml

if ! grep -q "max_conn_lifetime:" /etc/dendrite/dendrite.yaml; then
    sed -i '/max_idle_conns:/a \    max_conn_lifetime: 30m\n    conn_max_idle_time: 5m' /etc/dendrite/dendrite.yaml
fi

# 4. Safe Limit Media Cache Footprint to protect 512MB RAM container ceiling
sed -i 's/max_size_estimated: .*/max_size_estimated: 16mb/g' /etc/dendrite/dendrite.yaml

# 5. Inject 30-Minute Internal DNS Cache
if ! grep -q "dns_cache:" /etc/dendrite/dendrite.yaml; then
    sed -i '/global:/a \  dns_cache:\n    enabled: true\n    cache_size: 2048\n    cache_lifetime: 1800s' /etc/dendrite/dendrite.yaml
fi

echo "✅ Optimization profiles fully injected."

echo "🚀 Starting Silent High-Speed Matrix Hub..."
# Force Go runtime network stack to prioritize fast HTTP/2 connection multiplexing
export GODEBUG=netdns=go+http2server=1

# Dendrite versions vary on binary naming. Try common ones.
if command -v dendrite-monolith-server >/dev/null 2>&1; then
  exec dendrite-monolith-server -tls-cert="" -tls-key="" -config /etc/dendrite/dendrite.yaml
elif command -v dendrite >/dev/null 2>&1; then
  exec dendrite monolith -tls-cert="" -tls-key="" -config /etc/dendrite/dendrite.yaml
else
  echo "Error: Could not find Dendrite server binary."
  exit 1
fi
