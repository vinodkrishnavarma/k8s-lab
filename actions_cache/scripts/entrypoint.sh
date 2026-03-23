#!/usr/bin/env bash
# Entrypoint for the warmer container (Kubernetes CronJob / Job usage).
# Refreshes the CA trust store from any mounted certificates, then runs
# the cache-warmer script.
set -euo pipefail

CA_DIR=/usr/local/share/ca-certificates

if ls "${CA_DIR}"/*.crt 1>/dev/null 2>&1; then
    echo "[entrypoint] Updating CA certificates from ${CA_DIR} ..."
    update-ca-certificates --fresh 2>&1 | tail -3
fi

exec /warmer/warm-cache.sh "$@"
