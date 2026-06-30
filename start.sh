#!/bin/sh
set -e

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

echo "Starting Dendrite Matrix Homeserver..."
# Dendrite versions vary on binary naming. Try common ones.
if command -v dendrite-monolith-server >/dev/null 2>&1; then
  exec dendrite-monolith-server -tls-cert="" -tls-key="" -config /etc/dendrite/dendrite.yaml
elif command -v dendrite >/dev/null 2>&1; then
  exec dendrite monolith -tls-cert="" -tls-key="" -config /etc/dendrite/dendrite.yaml
else
  echo "Error: Could not find Dendrite server binary."
  exit 1
fi
