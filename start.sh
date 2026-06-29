#!/bin/sh
set -e

# Generate Matrix signing key if it doesn't exist
if [ ! -f /etc/dendrite/matrix_key.pem ]; then
  echo "Generating Matrix private key..."
  generate-keys --private-key /etc/dendrite/matrix_key.pem
fi

echo "Starting Dendrite Matrix Homeserver..."
exec dendrite-monolith-server -tls-cert="" -tls-key="" -config /etc/dendrite/dendrite.yaml
