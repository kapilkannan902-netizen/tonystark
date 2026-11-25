#!/usr/bin/env bash
set -euo pipefail

SRC_HTML="${1:-./index.html}"
WEB_ROOT="${2:-/var/www/html}"
TARGET_HTML="${WEB_ROOT}/index.html"
NGINX_LOG_DIR="/var/log/nginx"

if [[ ! -f "$SRC_HTML" ]]; then
    echo "ERROR: Source HTML file not found at: $SRC_HTML" >&2
    exit 1
fi

echo "[1/5] Ensuring web root exists: $WEB_ROOT"
sudo mkdir -p "$WEB_ROOT"

echo "[2/5] Copying $SRC_HTML to $TARGET_HTML"
sudo cp "$SRC_HTML" "$TARGET_HTML"
sudo chmod 644 "$TARGET_HTML"

echo "[3/5] Checking port 80 socket status"
if command -v ss >/dev/null 2>&1; then
    sudo ss -tulpn 'sport = :80' || true
fi

echo "[4/5] Validating Nginx configuration and reloading"
sudo nginx -t
sudo systemctl reload nginx
systemctl is-active --quiet nginx && echo "Nginx service is active."

echo "[5/5] Verifying HTTP response from localhost"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1/index.html")
echo "HTTP status: $HTTP_CODE"
if [[ "$HTTP_CODE" != "200" ]]; then
    echo "ERROR: Expected HTTP 200, got $HTTP_CODE" >&2
    if [[ -d "$NGINX_LOG_DIR" ]]; then
        sudo tail -n 15 "$NGINX_LOG_DIR/error.log" || true
    fi
    exit 1
fi

echo "Deployment succeeded!"
